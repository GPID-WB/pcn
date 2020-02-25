/*==================================================
project:       Download pending databases from PRIMUS
Author:        R.Andres Castaneda
E-email:       acastanedaa@worldbank.org
url:
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    29 Jul 2019 - 16:01:01
Modification Date:
Do-file version:    01
References:
Output:
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pcn_primus_download_estimates, rclass
syntax [anything(name=subcmd id="subcommand")],  ///
[                                   ///
REGions(string)                     ///
DIR(string)                         ///
status(string)						///
TRANSfile(string)						///
date_time(string)						///
wkyr(string)							///
meeting(string)						///
replace                             ///
clear                              ///
pause                              ///
]

version 14

*---------- conditions
if ("`pause'" == "pause") pause on
else                      pause off


* ---- Initial parameters
local date = date("`c(current_date)'", "DMY")  // %tdDDmonCCYY
local time = clock("`c(current_time)'", "hms") // %tcHH:MM:SS
local date_time = `date'*24*60*60*1000 + `time'  // %tcDDmonCCYY_HH:MM:SS
local datetimeHRF: disp %tcDDmonCCYY_HH:MM:SS `date_time'
local datetimeHRF = trim("`datetimeHRF'")
local user=c(username)

/*==================================================
1:  Load transctions
==================================================*/
qui {
	
	if ("`transfile'" != ""){
		cap confirm file "`transfile'"
		if _rc{
			noi di as err "Transaction file not found"
			exit
		}
		else{
			noi use "`transfile'.dta"
		}
	}
	
	//------------Send to MATA
	ds
	local varlist = "`r(varlist)'"
	local n = _N
	mata: R = st_sdata(.,tokens(st_local("varlist")))
	
	pause after sendin to mata
	
	/*==================================================
	2:  Loop over surveys
	==================================================*/
	
	drop _all
	tempfile dlf
	save `dlf', empty
	
	mata: P  = J(0,0, .z)   // matrix with information about each survey
	local i = 0
	noi _dots 0, title(Progress of downloading transactions) reps(`n')
	qui while (`i' < `n') {
		local ++i
		drop _all
		
		// chunk of code that should be executed with no failure
		cap {
			mata: pcn_ind(R)
			primus download , tranxid(`transaction_id')
			
			ds comments*
			local commvars "`r(varlist)'"
			tostring `commvars', replace force
			
			ds, has(type string)
			local strvars "`r(varlist)'"
			
			foreach v of local strvars{
				replace `v' = "" if inlist(lower(`v'), "n.a.", ".")
			}
			destring `strvars', replace
			append using `dlf', force
			save `dlf', replace
		}
		if (_rc) noi _dots `i' 1
		else     noi _dots `i' 0
		
	} // end of while
	noi disp _n ""
	cap mkdir "`dir'/`wkyr'_`meeting'/estimates" // create folder if it does not exist
	//============================================
	// save and arrange data
	//============================================
	
	gen date = `date_time'
	format date %tcDDmonCCYY_HH:MM:SS
	
	local filename "`dir'/`wkyr'_`meeting'/estimates/primus_estimates"
	if ("`status'" == "approved") local filename "`filename'_approved"
	if ("`replace'"!="" & "`nochange'" == "nochange" ) local filename "`filename'_replaced"
	noi di "`filename'"
	save "`filename'_`date_time'.dta", replace
	cap confirm new file "`filename'.dta"
	if (_rc != 0 & "`replace'"=="") {
		append using "`filename'.dta", force
	}
	
	ds
	local duplvars = "`r(varlist)'"
	local duplvars: subinstr local duplvars "date" "", word
	duplicates drop `duplvars' , force
	save "`filename'.dta", replace
	
} // end of qui
end


/*====================================================================
Mata functions
====================================================================*/

findfile "pcn_functions.mata"
include "`r(fn)'"



exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:

