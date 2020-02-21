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
]
version 16


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

/*==================================================
1:  Folder structure
==================================================*/

*------Parameter of the file
if regexm("`dlwcall'", "module\((.*)\))") local mod = upper(regexs(1))

local filename "`survey_id'_`mod'"
local dirname "`maindir'/`country'/`country'_`year'_`survey'"
local dirname "`dirname'/`survey_id'/Data"

* Confirm file exists
cap confirm file "`dirname'/`filename'.dta"

if (_rc) {  // if file does not exist
  
  mata: st_local("direxists", strofreal(direxists("`dirname'")))
  
  if (`direxists' != 1) { // if folder does not exist
    cap mkdir "`maindir'/`country'"
    cap mkdir "`maindir'/`country'/`country'_`year'_`survey'"
    cap mkdir "`maindir'/`country'/`country'_`year'_`survey'/`survey_id'"
    cap mkdir "`maindir'/`country'/`country'_`year'_`survey'/`survey_id'/Data"
  }
  
  cap `dlwcall'
  if (_rc != 0 & "`try'" != "") {
    local mod = upper("`try'")
    local dlwcall = regexr("`dlwcall'", "(module\(.*\))", "")
    cap `dlwcall' module(`mod')
  }
  if (_rc) {
    local dlwnote "Error on datalibweb. File does NOT exist in P drive"
    local status 1
  }
  else {
    local filename "`survey_id'_`mod'"
    char _dta[pcn_datetimeHRF]    "`datetimeHRF'"
    char _dta[pcn_datetime]       "`date_time'"
    char _dta[pcn_user]           "`user'"
    
    datasignature set, reset saving("`dirname'/`filename'", replace)
    save "`dirname'/`filename'.dta"
    local dlwnote "Saved successfully"
    local status 0
  }
}

else {  // If file exists, check data signature
  
  if ("`replace'" != "") {
    cap `dlwcall'
    if (_rc != 0 & "`try'" != "") {
      local mod = upper("`try'")
      local dlwcall = regexr("`dlwcall'", "(module\(.*\))", "")
      cap `dlwcall' module(`mod')
    }
    if (_rc) {
      local dlwnote "Error on datalibweb. File already exists in P drive"
      local status 1
    }
    else {
      local filename "`survey_id'_`mod'"
      char _dta[pcn_datetimeHRF]    "`datetimeHRF'"
      char _dta[pcn_datetime]       "`date_time'"
      char _dta[pcn_user]           "`user'"
      cap noi datasignature confirm using "`dirname'/`filename'"
    }
    if (_rc) { // if data do not match
      
      cap mkdir "`dirname'/_vintage"
      preserve   // I cannot use  copy because I need the pcn_datetime char
      
      use "`dirname'/`filename'.dta", clear
      save "`dirname'/_vintage/`filename'_`:char _dta[pcn_datetime]'", replace
      
      restore
      
      save "`dirname'/`filename'.dta", replace
      local dlwnote "Saved and replaced successfully"
      local status 0
    }
    else { // if replace option not selected
      local dlwnote "File are identical. Skiped"
      local status -1
    }
  }
  else { // if replace option not selected
    local dlwnote "Not replaced. Skiped"
    local status -1
  }
}  //  end of file exists condition

return local status  = `status'
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


