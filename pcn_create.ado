/*==================================================
project:       Create text file and other povcalnet files
Author:        R.Andres Castaneda Aguilar
E-email:       acastanedaa@worldbank.org
url:
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     9 Aug 2019 - 08:51:26
Modification Date:
Do-file version:    01
References:
Output:
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pcn_create, rclass
syntax [anything(name=subcmd id="subcommand")],  ///
[                                   ///
countries(string)               ///
Years(numlist)                 ///
maindir(string)               ///
type(string)                  ///
survey(string)                ///
replace                       ///
vermast(string)               ///
veralt(string)                ///
MODule(string)                ///
clear                         ///
pause                         ///
*                             ///
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
1: primus query
==================================================*/
qui  {
	
	/*
	pcn_primus_query, countries(`countries') years(`years') ///
	`pause' gpwg
	pause after primus query
	*/
	
	pcn load price, clear `pause'
	rename countrycode country
	tostring _all, replace
	
	pause create - after loading price framework data
	
	/*==================================================
	2: Condition to filter data
	==================================================*/
	
	
	* Countries
	if (lower("`countries'") != "all" ) {
		local countrylist ""
		local countries = upper("`countries'")
		local countrylist: subinstr local countries " " "|", all
		keep if regexm(country, "`countrylist'")
	}
	
	** years
	if ("`years'" != "") {
		numlist "`years'"
		local years  `r(numlist)'
		local yearlist: subinstr local years " " "|", all
		keep if regexm(year, "`yearlist'")
	}
	
	if ("`vermast'" != "") {
		local vmlist: subinstr local vermast " " "|", all
		keep if regexm(vermast, "`vmlist'")
	}
	
	if ("`veralt'" != "") {
		local valist: subinstr local veralt " " "|", all
		keep if regexm(veralt, "`valist'")
	}
	
	
	
	qui ds
	local varlist = "`r(varlist)'"
	
	mata: R = st_sdata(.,tokens(st_local("varlist")))
	local n = _N
	
	/*==================================================
	2:  Loop over surveys
	==================================================*/
	noi disp as txt ". " in y "= saved successfully"
	noi disp as txt "s " in y "= skipped - already exists"
	noi disp as err "e " in y "= error reading"
	noi disp as err "x " in y "= error in process"
	
	
	mata: P  = J(0,0, .z)   // matrix with information about each survey
	local i = 0
	local previous ""
	noi _dots 0, title(Creating PCN files) reps(`n')
	while (`i' < `n') {
		local ++i
		local status   ""
		local dlwnote  ""
		
		mata: pcn_ind(R)
		
		/* if ("`previous'" == "`country'-`year'") continue
		else local previous "`country'-`year'" */
		
		//------------ get metadata
		
		pause create - before searching for data 
		local module "GPWG"
		cap pcn load, count(`country') year(`year') type(GMD) /*
		*/  module(`module')  survey("`survey'") /*
		*/ `pause' `clear' `options' noload
		
		if (_rc) {
			local module "BIN"
			cap pcn load, count(`country') year(`year') type(GMD) /*
			*/ module(`module')  survey("`survey'") /*
			*/ `pause' `clear' `options' noload
			
			if (_rc) {
				local module "HIST"
				cap pcn load, count(`country') year(`year') type(GMD) /*
				*/ module(`module')  survey("`survey'") /*
				*/ `pause' `clear' `options' noload
				
				if (_rc) {
					local status "error. loading"
					local dlwnote "pcn load, count(`country') year(`year') type(`type') survey("`survey'")  module(`module') `pause' `clear' `options' noload"
					mata: P = pcn_info(P)
					
					noi _dots `i' 2
					continue
				}
			}
		}
		
		
		local filename  = "`r(filename)'"
		local survin    = "`r(survin)'"
		local survid    = "`r(survid)'"
		local survey_id = "`survid'"
		local surdir    = "`r(surdir)'"
		return add
		
		pause create - after having searched for data 
		
		cap confirm new file "`surdir'/`survid'/Data/`survid'_PCN.dta"
		if (_rc & "`replace'" == "") {  //  File exists
			
			local status "skipped"
			local dlwnote "File exists. Not replaced"
			mata: P = pcn_info(P)
			
			noi _dots `i' -1
			continue // there is not need to load data and check datasignature
		}
		*--------------------2.2: Load data
		cap pcn load, count(`country') year(`year') type(GMD) /*
		*/ module(`module') survey("`survey'")  /*
		*/ `pause' `clear' `options'
		
		if (_rc) {
			
			local status "error. loading"
			local dlwnote "pcn load, count(`country') year(`year') type(`type') survey("`survey'")  module(`module') `pause' `clear' `options'"
			mata: P = pcn_info(P)
			noi _dots `i' 2
			continue
			
		}
		
		pause after loading data 
		/*==================================================
		3:  Clear and save data
		==================================================*/
		*----------1.1: clean weight variable
		
		cap confirm var weight, exact
		if (_rc) {
			cap confirm var weight_p, exact
			if (_rc == 0) rename weight_p weight
			else {
				cap confirm var weight_h, exact
				if (_rc == 0) rename weight_h weight
				else {
					noi disp in red "no weight variable found for country(`country') year(`year') veralt(`veralt') "
					local status "error. cleaning"
					local dlwnote "no weight variable found for country(`country') year(`year') "
					mata: P = pcn_info(P)
					noi _dots `i' 1
					continue
				}
			}
		}
		
		
		* make sure no information is lost
		svyset, clear
		recast double welfare
		recast double weight
		
		* monthly data
		// Already monthly data for IDN 1993, 1996, 1998 and 1999
		if ("`country'"!="IDN") | !inlist(`year',1993,1996,1998,1999)	{
			replace welfare=welfare/12
		}
		
		* special treatment for IDN and IND
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
			keep if countrycode=="`country'" & lower(coveragetype) != "national" & year==`year'
			gen urban = lower(coveragetype) == "urban"
			keep urban population
			tempfile pop
			save    `pop'
			
			// CPI
			pcn master, load(cpi) qui
			keep if countrycode=="`country'" & lower(coveragetype) != "national" & year==`year'
			gen urban = lower(coveragetype) == "urban"
			keep urban cpi
			tempfile cpi
			save    `cpi'
			
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
			replace welfare = welfare/cpi/ppp
			label var welfare "Welfare in 2011 USD PPP per month"
			
			local urban "urban"
			char _dta[cov]  "A"
			tempfile wfile
			save `wfile'
			
			
			local cfiles "`rfile' `ufile' `wfile'"
		} // end of special cases
		else {
			keep weight welfare 
			local urban ""
			tempfile wfile
			char _dta[cov]  ""
			save `wfile'
			local cfiles "`wfile'"
		}
		
		foreach file of local cfiles {
			
			use `file', clear
			local cc: char _dta[cov]  // country coverage
			if ("`cc'" != "") {
				local cov "-`cc'"
			}
			else {
				local cc "N"
				local cov ""
			}
			
			* keep weight and welfare
			keep weight welfare `urban'
			sort welfare
			
			* drop missing values
			drop if welfare < 0 | welfare == .
			drop if weight <= 0 | weight == .
			
			order weight welfare
			
			//========================================================
			// Check if data is the same as the previous one and save.
			//========================================================
			
			cap datasignature confirm using  "`surdir'/`survid'/Data/`survid'_PCN`cov'"
			local dsrc = _rc
			if (`dsrc' == 9) {  // if signature does not exist
				cap mkdir "`surdir'/`survid'/Data/_vintage"
				preserve   // I cannot use  copy because I need the pcn_datetime char
				
				use "`surdir'/`survid'/Data/`survid'_PCN`cov'.dta", clear
				cap save "`surdir'/`survid'/Data/_vintage/`survid'_PCN`cov'_`:char _dta[creationdate]'", replace
				if (_rc) {
					save "`surdir'/`survid'/Data/_vintage/`survid'_PCN`cov'_`date_time'", replace
				}
				
				restore
			}
			if (`dsrc' != 0 | "`replace'" != "") { // if different signature or replace
				cap datasignature set, reset /*
				*/ saving("`surdir'/`survid'/Data/`survid'_PCN`cov'", replace)
				
				char _dta[filename]         "`filename'"
				char _dta[survin]           "`survin'"
				char _dta[survid]           "`survid'"
				char _dta[surdir]           "`surdir'"
				char _dta[creationdate]     "`date_time'"
				char _dta[survey_coverage]  "`cc'"
				
				// Special case for IDN 2018 (should be deleted later)
				if ("`country'" == "IDN") {
					char _dta[welfaretype]  "CONS"
  				char _dta[weighttype]   "aw"
				}
				
				
				//------------Uncollapsed data
				save "`surdir'/`survid'/Data/`survid'_PCN`cov'.dta", `replace'
				local status "saved"
				local dlwnote "OK. country(`country') year(`year') veralt(`veralt') cov `cc'"
				noi _dots `i' 0
				
			}
			else { // Skipped data has not change. 
				local status "skipped. data has not changed"
				local dlwnote "skipped. country(`country') year(`year') veralt(`veralt') cov `cc'"
				noi _dots `i' -1
				continue
			}
			
			mata: P = pcn_info(P)
		} // end of files loop
		
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
	noi disp _n ""
	cap noi datasignature confirm using "`maindir'/_aux/pcn_create/pcn_create"
	if (_rc) {
		
		datasignature set, reset saving("`maindir'/_aux/pcn_create/pcn_create", replace)
		save "`maindir'/_aux/pcn_create/_vintage/pcn_create_`date_time'.dta"
		save "`maindir'/_aux/pcn_create/pcn_create.dta", replace
		
	}
	noi disp as result "Click {stata br:here} to see results"
	
} // end of qui
noi disp _n(2) ""

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


