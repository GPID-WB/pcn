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
program define pcn_primus_download_trans, rclass
syntax [anything(name=subcmd id="subcommand")],  ///
[                                   ///
COUNtries(string)                   ///
Years(numlist)                      ///
REGions(string)                     ///
DIR(string)                         ///
status(string)						///
wkyr(string)							///
meeting(string)						///
date_time(string)						///
replace                             /// 
clear                              ///
pause                              ///
]

version 14



/*==================================================
downloading transaction_id from primus
==================================================*/

qui {

	pcn_primus_query, countries(`countries') years(`years') ///
	`pause' status(`status')
	
	if ("`meeting'" == "SM") {
		local filtdate = "`=`wkyr'-1'-12" // filter date (december last year)
	}
	else {
		// I still don't know the cut off for Annual meetings
	}
	
	tempvar fd
	gen double `fd' = clock(datetime, "DMY hms")
	
	keep if  `fd' >= clock("`filtdate'", "YM")

	ds
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
	cap mkdir "`dir'/`wkyr'_`meeting'/vintage"

	local dirname "`dir'/`wkyr'_`meeting'/vintage"
	cap mkdir "`dirname'"
	
	cap noi datasignature confirm using "`dirname'/`wkyr'_`meeting'"
	if (_rc == 601) { // file not found
		qui datasignature set, reset saving("`dirname'/`wkyr'_`meeting'", replace)
		save "`dirname'/`wkyr'_`meeting'.dta", replace
		save "`dirname'/`wkyr'_`meeting'_`date_time'.dta", replace
		noi di as text "Data siganture not found"
		noi di as result "Data siganture created"
		local change = "Real Change"
	}
	else if (_rc ==9) {
		local files: dir "`dirname'"  files "`wkyr'_`meeting'_*.dta", respectcase
		
		local vers = 0  
		foreach file of local files {
			if regexm("`file'", "`wkyr'_`meeting'_([0-9]+)\.dta") {
				local ver = regexs(1)
				local vers "`vers' `ver'"
			}
		}
		
		local vers: subinstr local vers " " ",", all
		local ver = max(`vers')
		
		datasignature set, reset saving("`dirname'/`wkyr'_`meeting'", replace)
		save "`dirname'/`wkyr'_`meeting'.dta", replace
		save "`dirname'/`wkyr'_`meeting'_`date_time'.dta", replace
		
		//------------Changes in the data
		merge 1:1 survey_id using "`dirname'/`wkyr'_`meeting'_`ver'.dta", /* 
		*/ keep(master) nogen
		
		pause after merge 

		local change = "Real Change"
	}
	else {
		noi disp in y "File `wkyr'_`meeting' has not changed since last time"
		if ("`replace'" == ""){
			local change = "No Change"
			return local change = "`change'"
			exit
		}
		else local change = "Replace"
	}
	
	return local change = "`change'"
	
	noi di as result "Transactions have been correctly downloaded"
	noi di as text   "at: `dirname'/`wkyr'_`meeting'.dta"
}

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

