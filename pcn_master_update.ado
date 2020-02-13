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
POPMAXYear(integer 2018)   ///
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
local popdir   "p:/01.PovcalNet/03.QA/03.Population/data"

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
    _pcn_max_master, mastervin("`mastervin'") newfile("`newfile'")
    local newfile = "`r(newfile)'"
    
    //------------ modify country name and coverage
    local msheet "CPI"
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
  
  
  /*=================================================
  GDP
  ==================================================*/
  if (inlist(lower("`update'"),"gdp")) {
    
    
    //========================================================
    // gets data from WDI API
    //========================================================
    
    /* Note: This section is based on Espen's do-files available in 
    p:\02.personal\_handover\Espen\NAS process\*/
    
*##s
    set checksum off
    wbopendata, indicator(NE.CON.PRVT.PC.KD;NY.GDP.PCAP.KD) long clear 
    ren ne_con_prvt_pc_kd wdi_pce 
    ren ny_gdp_pcap_kd wdi_gdp
    keep countrycode year wdi*
    
    gen sourcegdp="wdi2019" 
		gen sourcepce="wdi2019" 
		
    

    local madison "https://www.rug.nl/ggdc/historicaldevelopment/maddison/data/mpd2018.dta"
    merge 1:1 countrycode year using "`madison'", nogen 
    rename rgdpnapc mdp_gdp
    
    replace sourcegdp ="Maddison 2018" if sourcegdp == ""
		replace sourcepce ="Maddison 2018" if sourcepce == ""
    
    replace mdp_gdp = . if year>1999 // do not use madison for recent spells 
    
    //========================================================
    // Special cases
    //========================================================
    expand 3 if inlist(countrycode, "IND", "IDN", "CHN")
    bysort countrycode year: egen coverage = seq()
    tostring coverage, replace
    replace coverage =cond(coverage == "1", "National", /* 
    */                cond(coverage == "2", "Urban", "Rural"))

    tempfile fna
    save `fna'
    
    //------------Find most recent version
    local popdir "p:\01.PovcalNet\03.QA\04.NationalAccounts\data"
    local files: dir "`popdir'" files "NAS special*xlsx"
    local vers = 0
    foreach file of local files {
      if regexm("`file'", "_([0-9\-]+)\.xlsx") local fdate = regexs(1)
      local sdata = date("`fdate'", "YMD")
      local vers "`vers', `sdata'"
    }
    local maxdate = max(`vers')
    local fver: disp %tdCCYY-NN-DD `maxdate' // file version 
    local fver = trim("`fver'")
    
    import excel using "`popdir'/NAS special_`fver'.xlsx", describe
    
    import excel using "`popdir'/NAS special_`fver'.xlsx", /* 
    */  clear sheet("`sheet'") firstrow case(lower)
    
    tempfile sna
    save `sna'
    
    * Merge with special cases and downloaded data
    use `fna', clear
    
    merge 1:1 countrycode coverage year using `sna', replace update
    rename (gdp pce) sp_=
    gen special=(_merge==3)
    drop _merge    
*##e


    //---- Espen's code ----- Start
    gen new_gdp=wdi_gdp  // default
    
    
    
    local s "mdp_gdp"
    
    bys countrycode coverage (year): gen lfbck_`s'= /* 
    */ (new_gdp!=. & new_gdp[_n-1]==. & _n!=1)*new_gdp/`s'
    
    bys countrycode coverage (year): egen lfbck_`s'i=max(lfbck_`s')
    
    // Linking factors, forward
    bys countrycode coverage (year): gen lffwd_`s'= /* 
    */  (new_gdp!=. & new_gdp[_n+1]==. & _n!=_N)*new_gdp/`s'
    
    bys countrycode coverage (year): egen lffwd_`s'i=max(lffwd_`s')
    
    // Assess where to apply (forward==1 or backward==1)
    bys countrycode coverage (year): gen gap_`s'=1 if new_gdp==. & new_gdp[_n-1]!=.
    bys countrycode coverage (year): replace gap_`s'=1 if _n==1
    bys countrycode coverage (year): gen gapsum_`s'=sum(gap_`s')
    
    // Apply: create linked value
    gen lvfwd_`s'=`s'*lffwd_`s'i
    gen lvbck_`s'=`s'*lfbck_`s'i
    
    // Replace where missing and indicate source 
    
    // fwd
    * replace source`n'="`s'" if new`n'==. & gapsum_`s'==2 & lvfwd_`s'!=.
    replace new`n'= lvfwd_`s' if new`n'==. & gapsum_`s'==2
    
    // bck
    * replace source`n'="`s'" if new`n'==. & gapsum_`s'==1 & lvbck_`s'!=.
    replace new`n'= lvbck_`s' if new`n'==. & gapsum_`s'==1
    //---- Espen's code ----- End
    

    keep if year >= 1960
    missings dropobs, force
    keep countrycode coverage year new_gdp 
    preserve 
    datalibweb_inventory, clear
    tempfile dlw
    save `dlw'
    restore
    merge m:1 countrycode  using `dlw', keep(match) nogen

    //--vector of available years
    sum year, meanonly
    local ymin = r(min)
    local ymax = r(max)
    tempname C
    mata: C = `ymin'..`ymax'; /*
    */  st_matrix("`C'", C)
    
    rename new_gdp y
    reshape wide y, i(countryname countrycode coverage) j(year)
    
    // cleaning
    drop if inlist(region, "NAC", "OTHERS")
    drop region
    missings dropvars, force
    
    gen note = ""
    local idvars "countryname coverage countrycode note"
    order `idvars'
    sort  `idvars'

    //------------ modify master file
    
    tempname D
    mkmat y*, matrix(`D')
    
    //------------ Find most recent version of master file 
    _pcn_max_master, mastervin("`mastervin'") newfile("`newfile'")
    local newfile = "`r(newfile)'"
    
    //------------ modify country name and coverage
    local msheet "GDP"
    export excel `idvars' using "`mastervin'/`newfile'.xlsx", /*
    */ sheet("`msheet'") sheetreplace firstrow(varlabels)
    
    //------------ Add cpi values
    putexcel set "`mastervin'/`newfile'.xlsx", modify sheet("`msheet'")
    putexcel E1 = matrix(`C')
    putexcel E2 = matrix(`D')
    putexcel save
    
    //------------Update current version
    copy "`mastervin'/`newfile'.xlsx" "`masterdir'/01.current/Master.xlsx", replace
    
    local success = 1
    
  }
  
  
  //=================================================
  // PCE
  //=================================================
  
  
  /*==================================================
  Population
  ==================================================*/
  
  if (inlist(lower("`update'"),"pop", "popu", "population")) {
    /* Note: there is no way to know the starting point of the data. So, 
    the we have to hardcode the limits. 
    There are two different procedures: WDI or data sent by Emi Suzuki
    */
    
    //------------If data comes from Emi Suzuki
    
    
    //------------Find most recent version
    local popdir "p:\01.PovcalNet\03.QA\03.Population\data"
    local files: dir "`popdir'" files "population_country*xlsx"
    local vers = 0
    foreach file of local files {
      if regexm("`file'", "_([0-9\-]+)\.xlsx") local fdate = regexs(1)
      local sdata = date("`fdate'", "YMD")
      local vers "`vers', `sdata'"
    }
    local maxdate = max(`vers')
    local fver: disp %tdCCYY-NN-DD `maxdate' // file version 
    local fver = trim("`fver'")
    
    import excel using "`popdir'/population_country_`fver'.xlsx", describe
    if regexm("`r(range_1)'", ":([A-Z]+)[0-9]+$") local lc = regexs(1)
    local sheet = "`r(worksheet_1)'"
    
    //------------ Find years available
    import excel using "`popdir'/population_country_`fver'.xlsx", /* 
    */ cellrange(F1:`lc'1) clear sheet("`sheet'") 
    ds 
    local vars = "`r(varlist)'"
    rename (`vars') year=
    gen n = 1
    reshape long year, i(n) j(col) string
    replace col = upper(col)
    sort year
    drop n
    
    tempfile fyear
    save `fyear'
    
    //------------Data available
    import excel using "`popdir'/population_country_`fver'.xlsx", /* 
    */ cellrange(A3) clear sheet("`sheet'") firstrow 
    cap drop scale
    
    ds, has(type string)
    local idvars = "`r(varlist)'"
    
    ds, has(type numeric)
    disp "`r(varlist)'"
    local vars = "`r(varlist)'"
    rename (`vars') pop=
    reshape long pop, i(`idvars') j(col) string
    replace col = upper(col)
    replace pop = pop/1e6   // divide by million 
    
    //------------Merge data and clean
    merge m:1 col using `fyear', keep(match) nogen
    rename *, lower
    gen coverage = cond(series == "SP.POP.TOTL", "National", /* 
    */            cond(series == "SP.RUR.TOTL", "Rural","Urban"))
    
    drop if series == "SP.URB.TOTL.IN.ZS"
    drop series_name col series
    drop if year > `popmaxyear' 
    sort country year
    
    //------------Matrix with years available
    sum year, meanonly
    local ymin = r(min)
    local ymax = r(max)
    tempname C
    mata: C = `ymin'..`ymax'; /*
    */  st_matrix("`C'", C)
    
    local idvars "country_name coverage country"
    reshape wide pop, i(`idvars') j(year)
    order `idvars'
    sort `idvars'
    label var coverage     "Coverage"
    label var country_name "Country Name"
    label var country      "Country Code"
    //------------Matrix with population values
    tempname D
    mkmat pop*, matrix(`D')    
    
    //------------Find most recent master file 
    _pcn_max_master, mastervin("`mastervin'") newfile("`newfile'")
    local newfile = "`r(newfile)'"
    
    //------------ modify country name and coverage
    local msheet "Population"
    export excel `idvars' using "`mastervin'/`newfile'.xlsx",   /*
    */ sheet("`msheet'") sheetreplace firstrow(varlabels)
    
    
    //------------ Add cpi values
    putexcel set "`mastervin'/`newfile'.xlsx", modify sheet("`msheet'")
    putexcel D1 = matrix(`C')
    putexcel D2 = matrix(`D')
    putexcel save
    
    //------------Update current version
    copy "`mastervin'/`newfile'.xlsx" "`masterdir'/01.current/Master.xlsx", replace
    
    local success = 1
    }
  
  /*==================================================
  PPP
  ==================================================*/
  
  
  /*==================================================
  CCF
  ==================================================*/
  
  
  
  /*==================================================
  modify vintage control
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


//========================================================
// Aux programs
//========================================================

//------------ Find most recent Master file 
program _pcn_max_master, rclass

syntax, mastervin(string) newfile(string)

local mfiles: dir "`mastervin'" files "Master_*.xlsx", respect
local vcnumbers: subinstr local mfiles "Master_" "", all
local vcnumbers: subinstr local vcnumbers ".xlsx" "", all
local vcnumbers: list sort vcnumbers

mata: VC = strtoreal(tokens(`"`vcnumbers'"')); /*
*/ st_local("maxvc", strofreal(max(VC), "%15.0f"))

copy "`mastervin'/Master_`maxvc'.xlsx" "`mastervin'/`newfile'.xlsx" , replace

return local newfile = "`newfile'"

end


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


