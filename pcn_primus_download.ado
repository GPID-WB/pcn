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
program define pcn_primus_download, rclass
syntax [anything(name=subcmd id="subcommand")],  ///
[                                   ///
COUNtries(string)                   ///
Years(numlist)                      ///
REGions(string)                     ///
DIR(string)                         ///
Status(string)						///
DOWNload(string)						///
TRANSfile(string)						///
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

/*
if ("`status'" == "approved")	 local dir "p:\01.PovcalNet\03.QA\05.PRIMUS_approved"
else	 						 local dir "p:\01.PovcalNet\03.QA\02.PRIMUS_pending"
*/
if ("`status'" == "approved")	 local dir "p:\01.PovcalNet\03.QA\02.PRIMUS\approved"
else	 						             local dir "p:\01.PovcalNet\03.QA\02.PRIMUS\pending"

if ("`countries'" == "") local countries "all"

// =============================
// Preliminay checks
// =============================

if !inlist("`download'", "transactions", "trans","estimates") {
	noi di as err "download must be either transactions or estimates"
}

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


	//===========================================================
	// Check transaction ID's
	//===========================================================
	if ("`transfile'" == "") {
		noi pcn_primus_download_trans, countries(`countries') years(`years') status(`status') ///
		wkyr(`wkyr') meeting(`meeting') dir(`dir') date_time(`date_time')
		return local change = "`r(change)'"
	}
	else {
		return local change = "User given"
	}

	//===========================================================
	// Download estimates (If demanded)
	//===========================================================
	if ("`r(change)'" != "No Change") {
		if ("`download'" == "trans" | "`download'" == "transactions") {
			// nothing happens
		}
		else if ("`download'" == "" | "`download'" == "estimates") {
			noi pcn_primus_download_estimates, status(`status') date_time(`date_time') ///
			wkyr(`wkyr') meeting(`meeting') dir(`dir') transfile(`transfile')
		}
		else {
			noi di as err "Only estimates or transactions are allowed to be loaded."
			error
		}
	}
	else{
		noi di as result "Not new estimates to download"
	}

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
