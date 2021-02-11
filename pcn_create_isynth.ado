/*==================================================
project:       create synthetic files
Author:        wb384996 
----------------------------------------------------
Creation Date:    11 Feb 2021 - 15:04:53
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pcn_create_isynth, rclass
syntax [anything(name=subcmd id="subcommand")],  ///
[                                                ///
country(string)                                ///
Year(numlist)                                   ///
maindir(string)                                  ///
survey(string)                                   ///
server(string)                                   ///
newsynth					                               ///
replace                                          ///
clear                                            ///
pause                                            ///
*                                                ///
]

version 16

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


//========================================================
// call isynth
//========================================================

cap isynth distribution, count(`country') year(`year') server(`server') natppp /*
*/ `pause' `clear' `options'

if ("`survey'" != "")		loc survid = `survey'
else						mata: st_local("survm", S[`i'])

if ("`country'" == "CHN"){
	mata: st_local("iscover", CV[`i'])
	if ("`iscover'" == "N")			loc iscover "A"
	if ("`iscover'" != "") 			loc iscoverpr "-`iscover'"
}
local survid "`survm'"
local survid = "`country'_`year'_`survid'"
local surdir = "`maindir'/`country'/`survid'"
local survey_id = "`survid'"
di "`survid'"
di  "`surdir'"


*noi di "`year'"
// if synth folder does not exist create 
capture mkdir "`surdir'"

// check versions 
local subdirs : dir "`surdir'" dirs "`survid'*"
loc j = 0
foreach ver of local subdirs{
	loc ++j
	if regexm("`ver'", ".+_v([0-9]+)_[M|m]_v([0-9]+)_[A|a]") {
		loc m_v_`j' = regexs(1)
		loc a_v_`j' = regexs(2)
		
		if (`j' == 1) {
			loc m_v = `m_v_`j''
			loc a_v = `a_v_`j''
		}
		
		if (`j' > 1) {
			if (`m_v_`j'' > `m_v') {
				loc m_v = `m_v_`j''
				loc a_v = `a_v_`j''
			}
			
			if (`m_v_`j'' == `m_v') {
				if (`a_v_`j'' > `a_v')	 loc a_v = `a_v_`j''
			}
		}
		di "`ver'"
		di "`m_v'"
		di "``m_v'_`j''"
		di "`a_v'"
		di "``a_v'_`j''"
	}
	else {
		loc m_v = 1
		loc a_v = 1
	}
}

if (`j' == 0){
	loc m_v = 1
	loc a_v = 1
}

if (strlen("`m_v'") == 1) 	loc m_v "0`m_v'"
if (strlen("`a_v'") == 1) 	loc a_v "0`a_v'"

loc survid = "`survid'_v`m_v'_M_v`a_v'_A_GMD"
cap mkdir "`surdir'/`survid'"
cap mkdir "`surdir'/`survid'/Data"

//  if newsynth is declarated
cap confirm new file "`surdir'/`survid'/Data/`survid'_PCN.dta"
if (_rc & "`newsynth'" != ""){
	
	loc survid "`survey_id'"
	
	loc a_v = `a_v' + 1
	
	if (strlen("`a_v'") == 1) 	loc a_v "0`a_v'"
	
	loc survid = "`survid'_v`m_v'_M_v`a_v'_A_GMD"
	cap mkdir "`surdir'/`survid'"
	cap mkdir "`surdir'/`survid'/Data"
}


cap confirm new file "`surdir'/`survid'/Data/`survid'_PCN.dta"

if ("`allvars'" == ""){
	if !regexm("`addvar'", "coveragetype") 		local addvar "coveragetype `addvar'"
}

cap isynth distribution, count(`country') year(`year') addvar(`addvar') server(AR) natppp /*
*/ `pause' `clear' `options' 			
if (_rc) {
	
	local status "error. loading"
	local dlwnote "isynth distribution, count(`country') year(`year') addvar(`addvar') `pause' `clear' `options'"				
}
else{
	// condition for synth
	replace welfare = welfare*(365/12) //to monthly
	if ("`country'"== "CHN"){
		if ("`iscover'" == "R") 	keep if coverage == "Rural"
		if ("`iscover'" == "U") 	keep if coverage == "Urban"
	}
	
	gen urban = inlist(coveragetype, "urban", "Urban")
}		


if inlist("`country'", "IND", "IDN") {
	keep weight welfare urban
	preserve
	keep if urban==0
	tempfile rfile
	char _dta[cov]  "R"
	save `rfile'
	
	restore, preserve
	
	keep if urban==1
	char _dta[cov]  "U"
	tempfile ufile
	save `ufile'
	
	restore
	
	
	
	// This section is problably not longer neeed, but as I'm unsure I leave it there. DV
	// Loading PPPs, population data and CPI data
	preserve
	
	// PPPs
	pcn master, load(ppp) qui
	keep if countrycode == "`country'" & lower(coveragetype) != "national"
	gen urban = lower(coveragetype) == "urban"
	keep urban ppp2011
	tempfile ppp
	save    `ppp'
	
	// Population
	pcn master, load(population) qui
	if "`country'"=="IDN" { 
		keep if countrycode=="`country'" & lower(coveragetype) != "national" & year==`year'
	}
	// Need to account for decimal years with India
	if "`country'"=="IND" { 
		keep if countrycode=="`country'" & lower(coveragetype) != "national" & inlist(year,`year',`year'+1)
		bysort coverage (year): replace pop = (pop+pop[_n+1])/2 
		keep if year==`year'
	}
	gen urban = lower(coveragetype) == "urban"
	keep urban population
	tempfile pop
	save    `pop'
	
	// CPI
	// Special treatment for India 2011.5 where the CPIs are in the 2012 column:
	if "`country'"=="IND" & `year'==2011 {
		local year= `year'+1 
	}
	pcn master, load(cpi) qui
	keep if countrycode=="`country'" & lower(coveragetype) != "national" & year==`year'
	gen urban = lower(coveragetype) == "urban"
	keep urban cpi
	tempfile cpi
	save    `cpi'
	// Undo special treatment for India 2011.5:
	if "`country'"=="IND" & `year'==2011 {
		local year= `year-+1'
	}
	
	restore
	
	// Merge with raw data
	merge m:1 urban using `ppp', nogen
	merge m:1 urban using `pop', nogen
	merge m:1 urban using `cpi', nogen
	
	// Rescaling weights
	forvalues x = 0/1 {
		sum weight if urban==`x'
		replace weight = weight*pop/`r(sum)'*10^6 if urban==`x'
	}
	
	// Converting into 2011 PPPs (needed to compute the right national inequality 	statitsics and for getting the right median)
	if ("`module'" != "isynth")			replace welfare = welfare/cpi/ppp
	label var welfare "Welfare in 2011 USD PPP per month"
	
	
	
	keep welfare weight urban
	compress
	
	local urban "urban"
	char _dta[cov]  "A"
	tempfile wfile
	save `wfile'
	
	
	local cfiles "`rfile' `ufile' `wfile'"
} // end of special cases


char _dta[cov]  "`iscover'"

cap confirm new file "`surdir'/`survid'/Data/`survid'_PCN`cov'.dta"
if (_rc & "`newsynth'" != ""){
	
	loc survid "`survey_id'"
	
	loc a_v = `a_v' + 1
	
	if (strlen("`a_v'") == 1) 	loc a_v "0`a_v'"
	
	loc survid = "`survid'_v`m_v'_M_v`a_v'_A_GMD"
	cap mkdir "`surdir'/`survid'"
	cap mkdir "`surdir'/`survid'/Data"
}



end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
