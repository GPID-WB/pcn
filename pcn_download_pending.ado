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

/*==================================================
1:
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
// Check version of pending data
//========================================================

* working month
local cmonth: disp %tdnn date("`c(current_date)'", "DMY")

*Working year
local wkyr:  disp %tdyy date("`c(current_date)'", "DMY")

* Either Annual meeting (AM) or Spring meeting (SM)

if inrange(`cmonth', 1, 4) | inrange(`cmonth', 11, 12)  local meeting "SM"
if inrange(`cmonth', 5, 10) local meeting "AM"

if inrange(`cmonth', 11, 12) {
	local wkyr = `wkyr' + 1  // workign for the next year's meeting
}

return local wkyr = `wkyr'
return local meeting = "`meeting'"


/*==================================================
2:  Loop over surveys
==================================================*/

drop _all
tempfile dlf
save `dfl', empty

mata: P  = J(0,0, .z)   // matrix with information about each survey
local i = 0
while (`i' < `n') {
	local ++i
	local status     ""
	local dlwnote  ""
	
	
	mata: pcn_ind(R)
	primus download , tranxid(`transaction_id')
	append using `dfl', force
	save `dfl', replace
	
} // end of while

//========================================================
// save and arrange data
//========================================================

cap mkdir "`dir'/`wkyr'_`meeting'"
cap mkdir "`dir'/`wkyr'_`meeting'/estimates"




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
