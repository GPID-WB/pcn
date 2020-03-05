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

	pcn_primus_query, countries(`countries') years(`years') ///
	`pause' vermast("`vermast'") veralt("`veralt'") gpwg

	local varlist = "`r(varlist)'"
	local n = _N

	/*==================================================
	2:  Loop over surveys
	==================================================*/
	noi disp as txt ". " in y "= saved successfully"
	noi disp as txt "s " in y "= skipped - already exists"
	noi disp as err "e " in y "= error reading"
	noi disp as err "x " in y "= error in datalibweb"


	mata: P  = J(0,0, .z)   // matrix with information about each survey
	local i = 0
	local previous ""
	noi _dots 0, title(Creating PCN files) reps(`n')
	while (`i' < `n') {
		local ++i

		mata: pcn_ind(R)

		/* if ("`previous'" == "`country'-`year'") continue
		else local previous "`country'-`year'" */

		//------------ get metadata
		cap pcn_load, country(`country') year(`year') type(`type') /*
		*/ maindir("`maindir'") vermast(`vermast') veralt(`veralt')  /*
		*/ survey("`survey'") `pause' `clear' `options' noload
		if (_rc) {
			noi _dots `i' 2
			continue
		}

		local filename = "`r(filename)'"
		local survin   = "`r(survin)'"
		local survid   = "`r(survid)'"
		local surdir   = "`r(surdir)'"
		return add

		cap confirm new file "`surdir'/`survid'/Data/`survid'_PCN.dta"
		if (_rc & "`replace'" == "") {  //  File exists
			noi _dots `i' -1
			continue // there is not need to load data and check datasignature
		}
		*--------------------2.2: Load data
		cap pcn_load, country(`country') year(`year') type(`type') /*
		*/ maindir("`maindir'") vermast(`vermast') veralt(`veralt')  /*
		*/ survey("`survey'") `pause' `clear' `options'
		if (_rc) {
			noi _dots `i' 2
			continue
		}

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
		replace welfare=welfare/12

		keep weight welfare urban

		* special treatment for IDN and IND
		if inlist("`country'", "IND", "IDN") {
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
			
			// Create welfare in daily PPP terms
			replace welfare = welfare*12/365/cpi/ppp

			// Rescaling weights
			forvalues x = 0/1 {
				sum weight if urban==`x'
				replace weight = weight*pop/`r(sum)'*10^6 if urban==`x'
			}
			
			label var welfare "Welfare in 2011 USD PPP per day"
			
			char _dta[cov]  "N"
			tempfile wfile
			save `wfile'


			local cfiles "`rfile' `ufile' `wfile'"
		} // end of special cases
		else {
			tempfile wfile
			char _dta[cov]  ""
			save `wfile'
			local cfiles "`wfile'"
		}

		foreach file of local cfiles {

			use `file', clear
			local cc: char _dta[cov]  // country coverage
			if ("`cc'" == "") {
				local cc "N"
				local cov ""
			}
			else {
				local cov "-`cc'"
			}

			* keep weight and welfare
			keep weight welfare
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
			if (`dsrc' == 9) {
				cap mkdir "`surdir'/`survid'/Data/_vintage"
				preserve   // I cannot use  copy because I need the pcn_datetime char

				use "`surdir'/`survid'/Data/`survid'_PCN`cov'.dta", clear
				save "`surdir'/`survid'/Data/_vintage/`survid'_PCN`cov'_`:char _dta[creationdate]'", replace

				restore
			}
			if (`dsrc' != 0 | "`replace'" != "") {
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
				export delimited using "`surdir'/`survid'/Data/`survid'_PCN`cov'.txt", ///
				novarnames nolabel delimiter(tab) `replace'


				//------------ collapse data
				collapse (sum) weight, by(welfare)

				save "`surdir'/`survid'/Data/`survid'_PCNc`cov'.dta", `replace'

				export delimited using "`surdir'/`survid'/Data/`survid'_PCNc`cov'.txt", ///
				novarnames nolabel delimiter(tab) `replace'
				noi _dots `i' 0
			}
			else {
				noi _dots `i' -1
				continue
			}
		} // end of files loop

		* mata: P = pcn_info(P)

	} // end of while

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


