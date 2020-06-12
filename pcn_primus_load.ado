/*==================================================
project:       Load CPI data
Author:        R.Andres Castaneda
E-email:       acastanedaa@worldbank.org
url:
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     7 Feb 2020 - 20:02:16
Modification Date: 12 Jun 2020 - major change
Do-file version:    01
References:
Output:
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pcn_primus_load, rclass
syntax [anything(name=subcmd id="subcommand")],  ///
[                                   ///
Status(string)			///
load(string)				///
VERsion(string) 			///
MEeting(string)			///
WYear(string)					///
clear                   ///
pause                   ///
]

version 14

*---------- pause
if ("`pause'" == "pause") pause on
else                      pause off


* ---- Initial parameters
local date = date("`c(current_date)'", "DMY")  // %tdDDmonCCYY
local time = clock("`c(current_time)'", "hms") // %tcHH:MM:SS
local date_time = `date'*24*60*60*1000 + `time'  // %tcDDmonCCYY_HH:MM:SS
local datetimeHRF: disp %tcDDmonCCYY_HH:MM:SS `date_time'
local datetimeHRF = trim("`datetimeHRF'")
local user=c(username)


if ("`status'" == "approved")	 local maindir "p:\01.PovcalNet\03.QA\02.PRIMUS\approved"
else	 						 local maindir "p:\01.PovcalNet\03.QA\02.PRIMUS\pending"

//=======================================================
// Working directory
//=======================================================

if !inlist("`meeting'", "AM", "SM", "")	{
	di "meeting must be SM or AM" 
	error
}

* working month
local cmonth: disp %tdnn date("`c(current_date)'", "DMY")
*Working year
if ("`wyear'" == ""){
	local wkyr:  disp %tdCCyy date("`c(current_date)'", "DMY")
}
else{
	local wkyr = `wyear'
}
* Either Annual meeting (AM) or Spring meeting (SM)

if ("`meeting'" == ""){
	if inrange(`cmonth', 1, 4) | inrange(`cmonth', 11, 12)  local meeting "SM"
	if inrange(`cmonth', 5, 10) local meeting "AM"

	if (inrange(`cmonth', 11, 12) & "`year'" == "") {
		local wkyr = `wkyr' + 1  // workign for the next year's meeting
	}
}
else{
	local meeting = "`meeting'"
}

return local wkyr = `wkyr'
return local meeting = "`meeting'"

if ("`load'" == "trans" | "`load'" == "transactions") {
	local maindir "`maindir'/`wkyr'_`meeting'/vintage"
}
else local maindir "`maindir'/`wkyr'_`meeting'/estimates"

//========================================================
// Check version of data
//========================================================

if ("`load'" == "trans" | "`load'" == "transactions") {
	local fileroot "`wkyr'_`meeting'"
	noi di as text "looking for transactions"
	}
else{
	noi di as text "looking for estimates"
	local fileroot "primus_estimates"
	if ("`status'" == "approved") local fileroot = "`fileroot'_approved"
}

if ("`version'" != "") {
  local files: dir "`maindir'" files "`fileroot'_*"
  local filerootl = lower("`fileroot'")
  local vcnumbers: subinstr local files "`filerootl'_" "", all
  local vcnumbers: subinstr local vcnumbers ".dta" "", all
  local vcnumbers: list sort vcnumbers 
  local vcnumbers: list sort vcnumbers
  * return local vcnumbers = "`vcnumbers'"
  noi disp in y "list of available vintage control dates for file " in g "`fileroot'_"
  local alldates ""
  local i = 0
  foreach vc of local vcnumbers {
    
    local ++i
    if (length("`i'") == 1 ) local i = "00`i'"
    if (length("`i'") == 2 ) local i = "0`i'"
    
    local dispdate: disp %tcDDmonCCYY_HH:MM:SS `vc'
    local dispdate = trim("`dispdate'")
    
    noi disp `"   `i' {c |} {stata `vc':`dispdate'}"'
    
    local alldates "`alldates' `dispdate'"
  }
  
 if (inlist("`version'" , "", "pick", "choose", "select")) {
    noi disp _n "select vintage control date from the list above" _request(_vcnumber)
    local version: disp %tcDDmonCCYY_HH:MM:SS `vcnumber' 
 }
 else {
    cap confirm number `version'
    if (_rc ==0) {
		if (length("`version'")<18 & regexm("`version'", "-") | "`version'" == "0"){
			loc i = subinstr("`version'", "-","",.)
			loc i = `i'
			loc versions : list sizeof local(vcnumbers)
			mata: vermat = J(`versions',1,.)
			loc j = 0
			foreach vc of local vcnumbers {
				loc ++j
				mata: vermat[`j',1] = `vc' 
			}
			qui mata: sort(vermat,1)
			loc i = `versions' - `i'
			mata: st_numscalar("verScalar", vermat[`i',1])
			loc version = verScalar
		} 
		local vcnumber = `version'
		local version: disp %tcDDmonCCYY_HH:MM:SS `vcnumber'
      
    }
    else {
      if (!regexm("`version'", "^[0-9]+[a-z]+[0-9]+ [0-9]+:[0-9]+:[0-9]+$") /* 
      */ | length("`version'")!= 18) {
        
        local datesample: disp %tcDDmonCCYY_HH:MM:SS /* 
        */   clock("`c(current_date)' `c(current_time)'", "DMYhms")
        noi disp as err "version() format must be %tcDDmonCCYY_HH:MM:SS, e.g " _c /* 
        */ `"{cmd:`=trim("`datesample'")'}"' _n
        error
      }
      local vcnumber: disp %13.0f clock("`version'", "DMYhms")
    }
  }  // end of checking version format
  
  use "`maindir'/`fileroot'_`vcnumber'.dta", clear
  noi disp in y "File " in g "{stata br:`fileroot'_`vcnumber'.dta}" /* 
  */ in y " has been loaded"
  
} // end of version != ""

//========================================================
//  current file 
//========================================================
else {
  use "`maindir'/`fileroot'.dta", clear
  noi disp in y "File " in g "{stata br:`fileroot'.dta}" /* 
  */ in y " has been loaded"
}

end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


