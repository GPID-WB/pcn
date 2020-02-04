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
program define pcn_download_wrk, rclass
syntax [anything(name=subcmd id="subcommand")],  ///
[                                   ///
COUNtries(string)                   ///
Years(numlist)                      ///
REGions(string)                     ///
MAINDir(string)                     ///
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
	Get lattest version of pending data
	==================================================*/
	local wrkdir "`maindir'/`wkyr'_`meeting'/wrk"
	cap mkdir "`wrkdir'"
	use "`maindir'/`wkyr'_`meeting'/vintage/`wkyr'_`meeting'.dta", clear
	
	
	//------------ Send to Mata
	qui ds
	local varlist = "`r(varlist)'"
	mata: R = st_sdata(.,tokens(st_local("varlist")))
	
	local n = _N
	
	
	/*==================================================
	2:  Loop over surveys
	==================================================*/
	mata: P  = J(0,0, .z)   // matrix with information about each survey
	local i = 0
	noi _dots 0, title(Downloading WRK data) reps(`n')
	while (`i' < `n') {
		local ++i
		local status   ""
		local dlwnote  ""
		
		
		mata: pcn_ind(R)
		
		if regexm("`survey'", "LIS$") {
			local mod "bin"
			local try 0
		}
		else {
			local mod "ALL"
			local try 1
		}
		
		*--------------------2.2: Load data
		cap datalibweb, country(`country') year(`year')  /*
		*/   type(GMD) mod(`mod') veralt(wrk) clear
		
		if (_rc != 0 & `try' == 1) {
			local mod "gpwg"
			cap datalibweb, country(`country') year(`year')  /*
			*/   type(GMD) mod(`mod') veralt(wrk) clear
		}
		if (_rc) {
			
			local status "dlw error"
			
			local dlwnote "datalibweb, country(`country') year(`year') type(GMD) mod(`mod') veralt(wrk) clear"
			
			mata: P = pcn_info(P)
			noi _dots `i' 1
			continue
		}
		
		cap pcn_savedata , filename(`r(filename)') country(`country') survey(`survey') /*
		*/  year(`year') survey_id(`survey_id') maindir(`wrkdir')
		
		if (_rc) {
			local status "saving error"
			
			local dlwnote "pcn_savedata , filename("`r(filename)'") country(`country') survey(`survey') year(`year') survey_id(`survey_id') maindir(`wrkdir')"
			
			mata: P = pcn_info(P)
			noi _dots `i' -1
			continue
		}
		local status = "`r(status)'"
		noi _dots `i' 0
		mata: P = pcn_info(P)
		
	} // end of while
	/*==================================================
	3: import results file
	==================================================*/
	
	*----------3.1:
	drop _all
	
	getmata (surveyid status dlwnote) = P
	
	* Add chars
	char _dta[pcn_datetimeHRF]    "`datetimeHRF'"
	char _dta[pcn_datetime]       "`date_time'"
	char _dta[pcn_user]           "`user'"
	
	
	*----------3.2:
	cap mkdir "`maindir'/`wkyr'_`meeting'/_aux"
	cap noi datasignature confirm using "`maindir'/`wkyr'_`meeting'/_aux/pcn_info"
	if (_rc) {
		
		datasignature set, reset saving("`maindir'/`wkyr'_`meeting'/_aux/pcn_info", replace)
		saveold "`maindir'/`wkyr'_`meeting'/_aux/pcn_info_`date_time'.dta"
		saveold "`maindir'/`wkyr'_`meeting'/_aux/pcn_info.dta", replace
	}	
	
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
