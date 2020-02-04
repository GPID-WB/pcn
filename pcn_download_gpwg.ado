/*==================================================
project:       Download GPWG databases
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
program define pcn_download_gpwg, rclass
syntax [anything(name=subcmd id="subcommand")],  ///
[                                   ///
COUNtries(string)                   ///
Years(numlist)                      ///
REGions(string)                     ///
maindir(string)                     ///
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
1:
==================================================*/
pcn_primus_query, countries(`countries') years(`years') ///
`pause'

local varlist = "`r(varlist)'"
local n = _N

if (`n' == 0) {
	noi disp as error "There is no data in PRIMUS for the convination of " ///
	"country/years selected"
	error
}

/*==================================================
2:  Loop over surveys
==================================================*/
mata: P  = J(0,0, .z)   // matrix with information about each survey
local i = 0
noi _dots 0, title(Downloading GPWG data) reps(`n')
while (`i' < `n') {
	local ++i
	local status     ""
	local dlwnote  ""


	mata: pcn_ind(R)

	*--------------------2.2: Load data
	cap datalibweb, country(`country') year(`year') surveyid(`survey')  /*
	*/   type(GMD) mod(GPWG) vermast(`vermast') veralt(`veralt') clear

	if (_rc) {
		local status "dlw error"

		local dlwnote "datalibweb, country(`country') year(`year') surveyid(`survey') type(GMD) mod(GPWG) vermast(`vermast') veralt(`veralt') clear"

		mata: P = pcn_info(P)
		noi _dots `i' 1
		continue
	}

	cap pcn_savedata , filename("`r(filename)'") country(`country') survey(`survey') /* 
             */  year(`year') survey_id(`survey_id') maindir(`maindir')
	
	if (_rc) {
		local status "saving error"

		local dlwnote "pcn_savedata , filename("`r(filename)'") country(`country') survey(`survey') year(`year') survey_id(`survey_id') maindir(`maindir')"

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

cap noi datasignature confirm using "`maindir'/_aux/info/pcn_info"
if (_rc) {

	datasignature set, reset saving("`maindir'/_aux/info/pcn_info", replace)
	saveold "`maindir'/_aux/info/_vintage/pcn_info_`date_time'.dta"
	saveold "`maindir'/_aux/info/pcn_info.dta", replace

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
