/*==================================================
project:       update master file
Author:        R.Andres Castaneda
E-email:       acastanedaa@worldbank.org
url:
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     8 Feb 2020 - 21:40:33
Modification Date: 6 Jan 2021 by Daniel Gerszon Mahler
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
MAXYear(integer 2019)     ///
FORCE                     ///
pause                     ///
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
  
  cap pcn master, load(CountryList) `pause'
  keep countryname countrycode
  tempfile countrylist
  save `countrylist'
  
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
    
    *Special cases
    replace cpi2011_unadj = cpi2011 if inlist(code, "IDN", "IND", "CHN")
    
    keep if !(code == "BRA" & year >= 2012 & survname == "PNAD")
    
    //------------ vector of available years
    
    gen yr = year
    replace yr = floor(ref_year) if ref_year <. // starting year of the survey
    
    sum yr, meanonly
    local ymin = r(min)
    local ymax = r(max)
    tempname C
    mata: C = `ymin'..`ymax'; /*
    */  st_matrix("`C'", C)
    
    //------------Rename to match Master file especifications
    rename (cpi2011_unadj code levelnote countryname) (y CountryCode Coverqge CountryName)
    keep y CountryCode Coverqge CountryName survname yr
    
    replace Coverqge = lower(Coverqge)
    
    duplicates drop // to adress the case of ETH
    
    preserve
    contract CountryCode Coverqge CountryName survname
    drop _freq
    local csize = `ymax'- `ymin'
    expand `csize'
    bysort CountryCode Coverqge CountryName survname: egen yr = seq()
    replace yr = yr - 1 + `ymin'
    tempfile cdata
    save `cdata'
    restore
    
    merge 1:1 CountryCode Coverqge CountryName survname yr using `cdata', nogen
    sort CountryCode yr survname
    
    //------------Manual fix for India
    sort CountryCode Coverqge survname yr
    replace y = y[_n-1] if (CountryCode == "IND" & yr == 2012)
    replace y = 1 if (CountryCode == "IND" & yr == 2011)
    
    //------------Re format to export
    
    reshape wide y, i(CountryCode CountryName Coverqge survname) j(yr)
    
    collapse (mean) y*, by(CountryCode CountryName Coverqge)  // fix if cpi per survey change
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
    
	************************
	*** PREPARE WDI DATA ***
	************************
	
	set checksum off
	wbopendata, indicator(NY.GDP.PCAP.KD) long clear
	ren ny_gdp_pcap_kd wdi_gdp
	keep countrycode countryname year wdi_gdp
	tempfile wdi_gdp
	save    `wdi_gdp'

	************************
	*** PREPARE WEO DATA ***
	************************
	
	// Find and load most recent version
	local popdir "p:\01.PovcalNet\03.QA\04.NationalAccounts\data"
	local files: dir "`popdir'" files "WEO*xls"
	local vers = 0
	foreach file of local files {
	  if regexm("`file'", "_([0-9\-]+)\.xls") local fdate = regexs(1)
	  local sdata = date("`fdate'", "YMD")
	  local vers "`vers', `sdata'"
	}
	local maxdate = max(`vers')
	local fver: disp %tdCCYY-NN-DD `maxdate' // file version
	local fver = trim("`fver'")

	import excel using "`popdir'/WEO_`fver'.xls", describe

	import excel using "`popdir'/WEO_`fver'.xls", /*
	*/  clear sheet("`sheet'") firstrow case(lower)
	
	// Only keeping variables on real gdp per capita
	keep if inlist(weosubjectcode,"NGDPRPC","NGDPRPPPPC","NGDP_R")
	replace weosubjectcode="_lcu"     if weosubjectcode=="NGDPRPC"
	replace weosubjectcode="_ppp2017" if weosubjectcode=="NGDPRPPPPC"
	// Somalia, and possibly other countries, have data on real GDP but not real GDP per capita:
	// We keep this variable as well. We will merge in population data, and convert it to per capita terms
	replace weosubjectcode="_lcu_notpc"        if weosubjectcode=="NGDP_R"
	// Renaming variable names after year
	foreach var of varlist * {
	// Only perform changes for variables whose label start with 19 or 20 
	if inlist(substr("`: var label `var''",1,2),"19","20") {
	rename `var' weo_gdp`: var label `var''
	}
	}
	// Only keeping relevant variables 
	keep iso weosubjectcode weo*
	rename iso countrycode
	// Fix countrycode discrepancies
	replace countrycode="PSE" if countrycode=="WBG"
	replace countrycode="XKX" if countrycode=="UVK"
	// Reshape long by year
	reshape long weo_gdp, i(countrycode weosubjectcode) j(year)
	drop if inlist(weo_gdp,"n/a","--")
	destring weo_gdp, replace
	// Dropping data for current year, last year and future years
	local currentyear = substr("$S_DATE",-4,.)
	drop if year >= `currentyear'-1
	// Reshape wide by gdp variables
	reshape wide weo_gdp, i(countrycode year) j(weosubjectcode) string
	// Merge popoulation data to convert gdp_lcu_weo series into per capita terms
	preserve
	pcn master, load(population)
	keep if coveragetype=="National"
	keep countrycode year population
	tempfile pop
	save    `pop'
	restore
	merge 1:1 countrycode year using `pop', nogen keep(1 3)
	// Fill out missings in the per capita variable
	replace weo_gdp_lcu = weo_gdp_lcu_notpc/pop if missing(weo_gdp_lcu)
	// No longer need non per capita series nor population data
	drop weo_gdp_lcu_notpc population
	tempfile weo_gdp
	save    `weo_gdp'

	*****************************
	*** PREPARE MADDISON DATA ***
	*****************************
	
	// Load data from website
	use "https://www.rug.nl/ggdc/historicaldevelopment/maddison/data/mpd2020.dta", clear
	// The ancient Maddison data are not needed
	keep if year>=1960
	// Keep relevant variables
	keep countrycode year gdppc
	rename gdppc mdp_gdp
	tempfile mdp_gdp
	save    `mdp_gdp'

	**************************************
	*** PREPARE SPECIAL COUNTRY SERIES ***
	**************************************

	// Find and load most recent version
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

	// Only keep relevant data
	keep countrycode year gdp
	drop if missing(gdp)
	rename gdp sna_gdp

	tempfile sna_gdp
	save `sna_gdp'

	*************************
	*** MERGE ALL SOURCES ***
	*************************
	
	use `wdi_gdp', clear
	merge 1:1 countrycode year using `weo_gdp', nogen
	merge 1:1 countrycode year using `mdp_gdp', nogen
	merge 1:1 countrycode year using `sna_gdp', nogen
	// Only keeping the 218 economies we care about
	merge m:1 countrycode using `countrylist', nogen keep(3)

	*******************************
	*** CREATE PREFERRED SERIES ***
	*******************************
	
	// We start with the WDI series
	gen new_gdp = wdi_gdp
	// Now we chain on the other sources in this order of importance:
	// 1. weo_gdp_ppp2017
	// 2. weo_gdp_lcu
	// 3. mdp_gdp
	foreach var of varlist weo_gdp_ppp2017 weo_gdp_lcu mdp_gdp {
	// If all data for a country is missing so far, use the looping-variable as the baseline
	bysort countrycode: egen nonmissing = count(new_gdp)
	bysort countrycode: replace new_gdp = `var' if nonmissing == 0
	drop nonmissing
	// Chain forwards
	bysort countrycode (year): replace new_gdp = `var'/`var'[_n-1]*new_gdp[_n-1] if missing(new_gdp)
	// Chain backwards
	gsort countrycode -year
	bysort countrycode       : replace new_gdp = `var'/`var'[_n-1]*new_gdp[_n-1] if missing(new_gdp)
	}
	sort countrycode year

	********************************
	*** FINAL MANUAL ADJUSTMENTS ***
	********************************
	
	// There should be no data for Venezuela after 
	replace new_gdp = . if countrycode=="VEN" & year>2014
	// Syria should be replaced with country specific-sources from 2010
	replace new_gdp = . if countrycode=="SYR" & year>2010
	bysort countrycode (year): replace new_gdp = sna_gdp/sna_gdp[_n-1]*new_gdp[_n-1] if countrycode=="SYR" & year>2010
	// So far everything is national
	// For IDN, IND, and CHN duplicate the series for urban and rural
	expand 3 if inlist(countrycode, "IND", "IDN", "CHN")
		bysort countrycode year: egen coverage = seq()
		tostring coverage, replace
		replace coverage =cond(coverage == "1", "National", /*
		*/                cond(coverage == "2", "Urban", "Rural"))
	// Only keep data from 1960
	drop if year<1960

	
	
	
    //------------ Save metadata
    merge m:1 countrycode using `countrylist', keep(2 3 4 5) update replace 
    levelsof _merge, local(mms) sep(,)
    if inlist(2, `mms') {
      noi disp "The following countries are not available"
      noi list countrycode if _merge == 2
    }
    drop if _merge == 2
    drop _merge
    
    pause after merge with country list
    
    local msheet = upper("`update'")
    cap datasignature confirm using "`masterdir'/03.metadata/`msheet'"
    if (_rc == 0 & "`force'" == "") {
      noi disp in y "Sheet `msheet' has not changed since last time. No update will be made."
      exit
    }
    
    datasignature set, reset saving("`masterdir'/03.metadata/`msheet'", replace)
    save "`masterdir'/03.metadata/_vintage/`msheet'_`date_time'.dta", replace
    save "`masterdir'/03.metadata/`msheet'.dta", replace
    
    //------------ arrange code.
    keep countryname countrycode coverage year new_gdp
    
    //--vector of available years
    sum year, meanonly
    local ymin = r(min)
    local ymax = r(max)
    tempname C
    mata: C = `ymin'..`ymax'; /*
    */  st_matrix("`C'", C)
    
    *##e
    rename new_gdp y
    reshape wide y, i(countryname countrycode coverage) j(year)
    
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
  if (inlist(lower("`update'"),"pce", "hfce")) {
    
    ************************
	*** PREPARE WDI DATA ***
	************************
	
	set checksum off
    wbopendata, indicator(NE.CON.PRVT.PC.KD) long clear
    ren ne_con_prvt_pc_kd wdi_pce
    keep countrycode countryname year wdi_pce
    
	// Expand by three for IDN, IND and CHN
	 expand 3 if inlist(countrycode, "IND", "IDN", "CHN")
    bysort countrycode year: egen coverage = seq()
    tostring coverage, replace
    replace coverage =cond(coverage == "1", "National", /*
    */                cond(coverage == "2", "Urban", "Rural"))
	
	tempfile wdi_pce
	save    `wdi_pce'
	
	**************************************
	*** PREPARE SPECIAL COUNTRY SERIES ***
	**************************************

	// Find and load most recent version
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

	// Only keep relevant data
	keep countrycode coverage year pce
	drop if missing(pce)
	rename pce sna_pce

	tempfile sna_pce
	save `sna_pce'
	
	*************************
	*** MERGE ALL SOURCES ***
	*************************
	
	cap pcn master, load(CountryList) `pause'
	keep countryname countrycode
	tempfile countrylist
	save `countrylist'
	
	use `wdi_pce', clear
	merge 1:1 countrycode coverage year using `sna_pce', nogen
	// Make sure all 218 economies we care about are there
	merge m:1 countrycode using `countrylist', gen(nopce) keep(2 3)
	// If not, create blank series
	levelsof year
	expand	r(r) if nopce==2
	replace coverage = "National" if nopce==2
	// Bad code trying to fill out blank series for with relevant years. The code wouldn't work if the country with no pce data is the first alphabetically. However, it is Taiwan, so it works for now
	sort countrycode coverage year
	replace year = year[_n-r(r)] if nopce==2
	

	*******************************
	*** CREATE PREFERRED SERIES ***
	*******************************
	
	// We start with the WDI series
	gen new_pce = wdi_pce

	********************************
	*** FINAL MANUAL ADJUSTMENTS ***
	********************************
	
	// There should be no data for Venezuela after 
	replace new_pce = .       if countrycode=="VEN" & year>2014
	// India should be replaced with country specific-sources from 2011
	replace new_pce = sna_pce if countrycode=="IND" & year>2010
	// Only keep data from 1960
	keep if inrange(year,1960, `maxyear')	
    missings dropobs, force
    
	
	
    //------------ Save metadata
    pause PCE: after merge with country list
    merge m:1 countrycode using `countrylist', keep(2 3 4 5) update replace
    
    levelsof _merge, local(mms) sep(,)
    if inlist(2, `mms') {
      noi disp "The following countries are not available"
      noi list countrycode if _merge == 2
    }
    pause PCE: after merge with country list
    drop if _merge == 2
    drop _merge
    
    
    local msheet = upper("`update'")
    cap datasignature confirm using "`masterdir'/03.metadata/`msheet'"
    if (_rc == 0 & "`force'" == "") {
      noi disp in y "Sheet `msheet' has not changed since last time. No update will be made."
      exit
    }
    
    datasignature set, reset saving("`masterdir'/03.metadata/`msheet'", replace)
    save "`masterdir'/03.metadata/_vintage/`msheet'_`date_time'.dta", replace
    save "`masterdir'/03.metadata/`msheet'.dta", replace
    
    //------------ arrange code.
    keep countryname countrycode coverage year new_pce
    
    //--vector of available years
    sum year, meanonly
    local ymin = r(min)
    local ymax = r(max)
    tempname C
    mata: C = `ymin'..`ymax'; /*
    */  st_matrix("`C'", C)
    
    rename new_pce y
    reshape wide y, i(countryname countrycode coverage) j(year)
    
    pause before drop obs
    // cleaning
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
    local msheet "PCE"
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
    
    //------------Merge with year data
    merge m:1 col using `fyear', keep(match) nogen
	
	//------------Merge with special country data
	/* Note for PSE, KWT and SXM, some years of population data are missing in Emi's main file and hence in WDI.
	   Here we are complementing the main file with an additional file she shared to assure complete coveage.
	   This file contains historical data and will not need to be updated every year. 
	   Hence, here we are just calling the version we received. Should we receive a new version, 
	   the import line below should be updated to reflect the accurate file.
	*/
	preserve
	import excel using "`popdir'/population_missing_2020-12-01.xlsx", clear firstrow sheet("Long")
	drop SCALE
	rename Data pop
	replace Time = substr(Time,3,.)
	destring Time, replace
	rename Time year
	tempfile specialcases
	save `specialcases'
	restore
	merge 1:1 Country Series year using `specialcases', update nogen
	
	//-----------clean
	replace pop = pop/1e6   // divide by million
	rename *, lower
    gen coverage = cond(series == "SP.POP.TOTL", "National", /*
    */            cond(series == "SP.RUR.TOTL", "Rural","Urban"))
    
    drop if series == "SP.URB.TOTL.IN.ZS"
    drop series_name col series
    drop if year > `maxyear'
    sort country year
    
    drop if year < 1977
    
    pause POP: after merge with country list
    rename country countrycode 
    merge m:1 countrycode using `countrylist', keep(2 3 4 5) update replace
    
    levelsof _merge, local(mms) sep(,)
    if inlist(2, `mms') {
      noi disp "The following countries are not available"
      noi list countrycode if _merge == 2
    }
    pause POP: after merge with country list
    drop if _merge == 2
    drop _merge
    
    
    local msheet = upper("`update'")
    cap datasignature confirm using "`masterdir'/03.metadata/`msheet'"
    if (_rc == 0 & "`force'" == "") {
      noi disp in y "Sheet `msheet' has not changed since last time. No update will be made."
      exit
    }
    
    datasignature set, reset saving("`masterdir'/03.metadata/`msheet'", replace)
    save "`masterdir'/03.metadata/_vintage/`msheet'_`date_time'.dta", replace
    save "`masterdir'/03.metadata/`msheet'.dta", replace
    
    
    
    //------------Matrix with years available
    sum year, meanonly
    local ymin = r(min)
    local ymax = r(max)
    tempname C
    mata: C = `ymin'..`ymax'; /*
    */  st_matrix("`C'", C)
    
    local idvars "countryname coverage countrycode"
    reshape wide pop, i(`idvars') j(year)
    order `idvars'
    sort `idvars'
    label var coverage     "Coverage"
    label var countryname  "Country Name"
    label var countrycode  "Country Code"
    
    pause after reshape to wide
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
    
    noi disp in y "sheet(`msheet') in Master data has been update." _n /*
    */ "{stata pcn master, load(`msheet'):Load data}"
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


