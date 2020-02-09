/*==================================================
project:       update master file
Author:        R.Andres Castaneda
E-email:       acastanedaa@worldbank.org
url:
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     8 Feb 2020 - 21:40:33
Modification Date:
Do-file version:    01
References:
Output:
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pcn_master_update, rclass
syntax [anything],         ///
update(string)             ///
[                          ///
cpivin(string)             ///
]

version 15 // this is really important 

*---------- conditions
if ("`pause'" == "pause") pause on
else                      pause off


*------------------ Initial Parameters  ------------------
local date = date("`c(current_date)'", "DMY")  // %tdDDmonCCYY
local time = clock("`c(current_time)'", "hms") // %tcHH:MM:SS
local date_time = `date'*24*60*60*1000 + `time'  // %tcDDmonCCYY_HH:MM:SS
local datetimeHRF:    disp %tcDDmonCCYY_HH:MM:SS `date_time'
local datetimeMaster: disp %tcCCYYNNDDHHMMSS     `date_time'
local datetimeHRF = trim("`datetimeHRF'")
local user=c(username)


local masterdir "p:/01.PovcalNet/00.Master"
local mastervin "`masterdir'/02.vintage"
local newfile "Master_`datetimeMaster'"

local success = 0
//========================================================
// Conditions
//========================================================

if wordcount("`update'") != 1 {
  noi dis in red "Only one sheet of the master file could be updated " _n /*
  */ "at the same time."
  error
}

qui {

  /*==================================================
  1: CPI
  ==================================================*/
  if (lower("`update'") == "cpi") {

    *----------Find most recent version of CPI data in datalibweb
    if ("`cpivin'" == "") {
      local cpipath "c:\ado\personal\Datalibweb\data\GMD\SUPPORT\SUPPORT_2005_CPI"
      local cpidirs: dir "`cpipath'" dirs "*CPI_*_M"

      local cpivins "0"
      foreach cpidir of local cpidirs {
        if regexm("`cpidir'", "cpi_v([0-9]+)_m") local cpivin = regexs(1)
        local cpivins "`cpivins', `cpivin'"
      }
      local cpivin = max(`cpivins')
    } // if no cpi vintage is selected

    cap datalibweb, country(Support) year(2005) type(GMDRAW)   /*
     */ fileserver surveyid(Support_2005_CPI_v0`cpivin'_M) /*
     */ filename(Final_CPI_PPP_to_be_used.dta)

    //------------ vector of available years
    sum year, meanonly
    local ymin = r(min)
    local ymax = r(max)
    tempname C
    mata: C = `ymin'..`ymax'; /*
    */  st_matrix("`C'", C)

    //------------Rename to match Master file especifications
    rename (cpi2011 code levelnote countryname) (y CountryCode Coverqge CountryName)
    keep y CountryCode Coverqge CountryName survname year
    reshape wide y, i(CountryCode CountryName Coverqge survname) j(year)

    collapse (mean) y*, by(CountryCode CountryName Coverqge)
    tempname D
    mkmat y*, matrix(`D')

    //------------ Find most recent version of master file

    local mfiles: dir "`mastervin'" files "Master_*.xlsx", respect
    local vcnumbers: subinstr local mfiles "Master_" "", all
    local vcnumbers: subinstr local vcnumbers ".xlsx" "", all
    local vcnumbers: list sort vcnumbers

    mata: VC = strtoreal(tokens(`"`vcnumbers'"')); /*
    */ st_local("maxvc", strofreal(max(VC), "%15.0f"))

    //------------Load Master CPI
    local msheet "CPI"
    copy "`mastervin'/Master_`maxvc'.xlsx" "`mastervin'/`newfile'.xlsx" , replace

    //------------ modify country name and coverage
    export excel CountryName Coverqge CountryCode         /*
    */ using "`mastervin'/`newfile'.xlsx", /*
    */ sheet("`msheet'") sheetreplace firstrow(variables)


    //------------ Add cpi values
    putexcel set "`mastervin'/`newfile'.xlsx", modify sheet("`msheet'")
    putexcel D1 = matrix(`C')
    putexcel D2 = matrix(`D')
    putexcel save
    
    //------------Update current version
    copy "`mastervin'/`newfile'.xlsx" "`masterdir'/01.current/Master.xlsx", replace

    local success = 1

  } // end of CPI update

  /*==================================================
  2: PPP
  ==================================================*/


  *----------2.1:


  *----------2.2:


  /*==================================================
  3: CCF
  ==================================================*/


  *----------3.1:


  *----------3.2:


  /*==================================================
  4: GDP
  ==================================================*/


  *----------4.1:


  *----------4.2:


  /*==================================================
  5: Population
  ==================================================*/


  *----------5.1:


  *----------5.2:


  /*==================================================
  6:
  ==================================================*/


  *----------6.1:


  *----------6.2:


  /*==================================================
  7: modify vintage control
  ==================================================*/

  if (`success' == 1) {

    import excel "`masterdir'/_vintage_control.xlsx", describe
    if regexm("`r(range_1)'", "([0-9]+$)") {
      local lr = real(regexs(1))+1 // last row
    }

    putexcel set "`masterdir'/_vintage_control.xlsx", modify sheet("_vintage")
    putexcel A`lr' = "`newfile'"
    putexcel B`lr' = "`user'"
    putexcel C`lr' = "`msheet'"
    putexcel D`lr' = "Update `update' using datalibweb cpi version `cpivin'. Stata: pcn master, update(`update')"

    putexcel save
    
    noi disp in y "sheet(`msheet') in Master data has been update."
  } // end of success
} // end of qui

end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

  Notes:
  1.
  2.
  3.


  Version Control:


