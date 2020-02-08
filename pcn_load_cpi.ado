/*==================================================
project:       Load CPI data
Author:        R.Andres Castaneda
E-email:       acastanedaa@worldbank.org
url:
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     7 Feb 2020 - 20:02:16
Modification Date:
Do-file version:    01
References:
Output:
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pcn_load_cpi, rclass
syntax [anything], [  ///
version(string)       ///
clear                 ///
]
version 14

local outdir "p:/01.PovcalNet/01.Vintage_control/_aux/cpi"
if ("`version'" != "") {
  
  /*==================================================
  select version 
  ==================================================*/
  local files: dir "`outdir'/vintage/" files "povcalnet_cpi_*"
  local vcnumbers: subinstr local files "povcalnet_cpi_" "", all
  local vcnumbers: subinstr local vcnumbers ".dta" "", all
  local vcnumbers: list sort vcnumbers
  
  local vcnumbers: list sort vcnumbers
  * return local vcnumbers = "`vcnumbers'"
  noi disp in y "list of available vintage control dates for file " in g "povcalnet_cpi"
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
      local vcnumber = `version'
      local version: disp %tcDDmonCCYY_HH:MM:SS `vcnumber'
    }
    else {
      if (!regexm("`version'", "^[0-9]+[a-z]+[0-9]+ [0-9]+:[0-9]+:[0-9]+$") /* 
      */ | length("`version'")!= 18) {
        
        local datesample: disp %tcDDmonCCYY_HH:MM:SS /* 
        */   clock("`c(current_date)' `c(current_time)'", "DMYhms")
        noi disp as err "version() format must be %tdDDmonCCYY, e.g " _c /* 
        */ `"{cmd:`=trim("`datesample'")'}"' _n
        error
      }
      local vcnumber: disp %13.0f clock("`version'", "DMYhms")
    }
  }  // end of checking version format
  
  use "`outdir'/vintage/povcalnet_cpi_`vcnumber'.dta", `clear'
  noi disp in y "File " in g "{stata br:povcalnet_cpi_`vcnumber'.dta}" /* 
  */ in y " has been loaded"
  
} // end of version != ""

//========================================================
//  current file 
//========================================================
else {
  use "`outdir'/povcalnet_cpi.dta", `clear'
  noi disp in y "File " in g "{stata br:povcalnet_cpi.dta}" /* 
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


