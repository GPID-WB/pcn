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
program define pcn_download_pending, rclass
syntax [anything(name=subcmd id="subcommand")],  ///
[                                   ///
COUNtries(string)                   ///
Years(numlist)                      ///
REGions(string)                     ///
DIR(string)                         ///
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

local dir "p:\01.PovcalNet\03.QA\02.PRIMUS_pending"

//========================================================
// Check version of pending data
//========================================================

qui {
	* working month
	local cmonth: disp %tdnn date("`c(current_date)'", "DMY")
	
	*Working year
	local wkyr:  disp %tdCCyy date("`c(current_date)'", "DMY")
	
	* Either Annual meeting (AM) or Spring meeting (SM)
	
	if inrange(`cmonth', 1, 4) | inrange(`cmonth', 11, 12)  local meeting "SM"
	if inrange(`cmonth', 5, 10) local meeting "AM"
	
	if inrange(`cmonth', 11, 12) {
		local wkyr = `wkyr' + 1  // workign for the next year's meeting
	}
	
	return local wkyr = `wkyr'
	return local meeting = "`meeting'"
	
	/*==================================================
	downloading transaction_id from primus
	==================================================*/
	
	pcn_primus_query, countries(`countries') years(`years') ///
	`pause' status(pending)
	
	local varlist = "`r(varlist)'"
	local n = _N
	
	if (`n' == 0) {
		noi disp as error "There is no data in PRIMUS for the convination of " ///
		"country/years selected"
		error
	}
	
	//========================================================
	// check if transaction IDs have changed
	//========================================================
	
	cap mkdir "`dir'/`wkyr'_`meeting'"
	
	local dirname "`dir'/`wkyr'_`meeting'/vintage"
	cap mkdir "`dirname'"
	
	cap noi datasignature confirm using "`dirname'/`wkyr'_`meeting'"
	if (_rc == 601) { // file not found
		datasignature set, reset saving("`dirname'/`wkyr'_`meeting'", replace)
		save "`dirname'/`wkyr'_`meeting'.dta", replace
		save "`dirname'/`wkyr'_`meeting'_`date_time'.dta", replace
		
	}
	else if (_rc ==9) {
		local files: dir "`dirname'"  files "`wkyr'_`meeting'_*.dta", respectcase
		
		foreach file of local files {
			if regexm("`dirname'", "`wkyr'_`meeting'_([0-9]+)\.dta") {
				local ver = regexs(1)
				local vers "`vers' `ver'"
			}
		}
		
		local vers: subsintr local vers " " ",", all
		local ver = max(`vers')
		datasignature set, reset saving("`dirname'/`wkyr'_`meeting'", replace)
		save "`dirname'/`wkyr'_`meeting'.dta", replace
		save "`dirname'/`wkyr'_`meeting'_`date_time'.dta", replace
		
		//------------Changes in the data
		merge 1:1 survey_id using "`dirname'/`wkyr'_`meeting'_`ver'.dta", /* 
		*/ keep(master) nogen
		
		//------------Send to MATA
		qui ds
		local varlist = "`r(varlist)'"
		mata: R = st_sdata(.,tokens(st_local("varlist")))
		
	}
	else {
		noi disp in y "File `wkyr'_`meeting' has not changed since last time"
		exit
	}
	
	/*==================================================
	2:  Loop over surveys
	==================================================*/
		
	drop _all
	tempfile dlf
	save `dlf', empty
	noi _dots 0, title(Progress of downloading transactions)
	
	mata: P  = J(0,0, .z)   // matrix with information about each survey
	local i = 0
	qui while (`i' < `n') {
		local ++i
		noi _dots `i' 0

		mata: pcn_ind(R)
		primus download , tranxid(`transaction_id')
		append using `dlf', force
		save `dlf', replace

	} // end of while
	
	cap mkdir "`dir'/`wkyr'_`meeting'/estimates" // create folder is it does not exist
	//========================================================
	// save and arrange data
	//========================================================
	
	gen date = `date_time'
	format date %tcDDmonCCYY_HH:MM:SS
	
	local filename "`dir'/`wkyr'_`meeting'/estimates/primus_estimates"
	save "`filename'_`date_time'.dta", replace
	cap confirm new file "`filename'.dta"
	if (_rc) {
		append using "`filename'.dta"
	}
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



mata
T = ("a", "b")
A = asarray_create()

for (f=1; f<=cols(T); f++) {
	
	asarray(A, T[1,f], st_local(T[1,f]))
	
}


for (loc=asarray_first(A); loc!=NULL; loc=asarray_next(A, loc)) {
	
	asarray_contents(A, loc)
	
}

asarray(A, T[1,f])

end
