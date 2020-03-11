/*==================================================
project:       Save datalibweb files using HISN structure
Author:        R.Andres Castaneda Aguilar
E-email:       acastanedaa@worldbank.org
url:
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     4 Feb 2020 - 10:02:09
Modification Date:
Do-file version:    01
References:
Output:
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pcn_savedata, rclass
syntax [anything],       [  ///
filename(string)           ///
country(string)            ///
survey(string)             ///
year(string)               ///
survey_id(string)          ///
maindir(string)            ///
dlwcall(string)            ///
try(string)                ///
pause                      ///
replace                    ///
force                      ///
]

version 14

*---------- conditions
if ("`pause'" == "pause") pause on
else                      pause off


//========================================================
// Basic Info
//========================================================
* ---- Initial parameters
local date = date("`c(current_date)'", "DMY")  // %tdDDmonCCYY
local time = clock("`c(current_time)'", "hms") // %tcHH:MM:SS
local date_time = `date'*24*60*60*1000 + `time'  // %tcDDmonCCYY_HH:MM:SS
local datetimeHRF: disp %tcDDmonCCYY_HH:MM:SS `date_time'
local datetimeHRF = trim("`datetimeHRF'")
local user=c(username)


//========================================================
// load data
//========================================================

cap `dlwcall'
local rc = _rc
if (`rc' != 0 & "`try'" != "") {
  
  pause savedata: first try `dlwcall'
  local mod = upper("`try'")
  local dlwcall = regexr("`dlwcall'", "(module\([a-zA-Z0-9]+\))", "")
  
  cap `dlwcall' module(`mod')
  local rc = _rc
}
if (`rc' != 0) {
  
  pause savedata: second try `dlwcall' 
  local dlwnote "Error on datalibweb. File does NOT exist in P drive"
  local status "datalibweb error"
  local st 1
  
}
else {
  if regexm("`r(filename)'", "(.*)\.dta")          local filename = regexs(1)
  if regexm("`r(filename)'", "(.*_GMD)_(.*)\.dta") local surveyid = regexs(1)
  
  local dirname              "`maindir'/`country'/`country'_`year'_`survey'"
  local dirname              "`dirname'/`surveyid'/Data"
  
  char _dta[pcn_datetimeHRF] "`datetimeHRF'"
  char _dta[pcn_datetime]    "`date_time'"
  char _dta[pcn_user]        "`user'"
}



/*==================================================
Folder structure
==================================================*/

*------Parameter of the file

* Confirm file exists

mata: st_local("direxists", strofreal(direxists("`dirname'")))

if (`direxists' != 1) { // if folder does not exist
  cap mkdir "`maindir'/`country'"
  cap mkdir "`maindir'/`country'/`country'_`year'_`survey'"
  cap mkdir "`maindir'/`country'/`country'_`year'_`survey'/`surveyid'"
  cap mkdir "`maindir'/`country'/`country'_`year'_`survey'/`surveyid'/Data"
}


cap datasignature confirm using "`dirname'/`filename'"
local rcds = _rc

if (`rcds' != 0) { // if data do not match or force option applied
  
  if ("`replace'" != "" & `rcds' == 9) {
    cap mkdir "`dirname'/_vintage"
    preserve   // I cannot use  copy because I need the pcn_datetime char
    
    use "`dirname'/`filename'.dta", clear
    save "`dirname'/_vintage/`filename'_`:char _dta[pcn_datetime]'", replace
    local dlwnote "-replaced"
    
    restore
  }
  
  if (`rcds' == 601 | "`replace'" != "") {
    save "`dirname'/`filename'.dta", replace
    local status "Saved successfully"
    local dlwnote "Saved `dlwnote' successfully"
    local st 0
    datasignature set, reset saving("`dirname'/`filename'", replace)
  }
  else { // if replace option not selected
    local dlwnote "Not replaced. Skiped"
    local status "not saved"
    local st -1
  }
}
else { // if replace option not selected
  local dlwnote "File are identical. Skiped"
  local status "not saved"
  local st -1
}

return local st      = `st'
return local status  = "`status'"
return local dlwnote = "`dlwnote'"


end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:
