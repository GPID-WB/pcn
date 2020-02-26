/*==================================================
project:       Load master file sheets
Author:        R.Andres Castaneda Aguilar
E-email:       acastanedaa@worldbank.org
url:
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    13 Feb 2020 - 18:31:49
Modification Date:
Do-file version:    01
References:
Output:
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pcn_master_load, rclass
syntax [anything], load(string) ///
[                               ///
version(string)                 ///
pause                           ///
shape(string)                   ///
]

version 15 // this is really important

*---------- conditions
if ("`pause'" == "pause") pause on
else                      pause off

*##s
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


//========================================================
// Conditions
//========================================================

if ("`shape'" == "") local shape "long"

//========================================================
// Find most recent data.
//========================================================

qui {
	
	local mfiles: dir "`mastervin'" files "Master_*.xlsx", respect
	local vcnumbers: subinstr local mfiles "Master_" "", all
	local vcnumbers: subinstr local vcnumbers ".xlsx" "", all
	local vcnumbers: list sort vcnumbers
	
	mata: VC = strtoreal(tokens(`"`vcnumbers'"')); /*
	*/ st_local("maxvc", strofreal(max(VC), "%15.0f"))
	
	* return local vcnumbers = "`vcnumbers'"
	if (inlist("`version'" , "pick", "choose", "select")) {
		noi disp in y "list of available vintage control dates of" in g "Master file"
		local i = 0
		
		foreach vc of local vcnumbers {
			
			local ++i
			if (length("`i'") == 1 ) local i = "00`i'"
			if (length("`i'") == 2 ) local i = "0`i'"
			
			local svc = clock("`vc'", "YMDhms")   // stata readable form
			local dispdate: disp %tcDDmonCCYY_HH:MM:SS `svc'
			local dispdate = trim("`dispdate'")
			
			noi disp `"   `i' {c |} {stata `vc':`dispdate'}"'
			
		}
		
		noi disp _n "select vintage control date from the list above" _request(_vcnumber)
	}
	else if inlist(lower("`version'"), "maxvc", "max", "") {
		local vcnumber = `maxvc'
	}
	else {
		cap confirm number `version'
		if (_rc ==0) {
			local vcnumber  `version'
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
			local vcnumber: disp %tcCCYYNNDDHHMMSS `vcnumber'
		}
	}  // end of checking version format
	*##e
	local svc = clock("`vcnumber'", "YMDhms")   // stata readable form
	local dispdate: disp %tcDDmonCCYY_HH:MM:SS `svc'
	
	noi disp in y "File:"  _col(8) "{stata br:Master_`vcnumber'.xlsx} " /*
  */ in y "will be loaded. " _n "Date: " _col(8) in w  "`dispdate'"
	
	
	//========================================================
	// Pick sheet
	//========================================================
	if inlist(lower("`load'"), "pick", "choose", "select", "sheetslist") {
		
		import excel using "`mastervin'/Master_`vcnumber'.xlsx", describe
		
		// store in local name of sheet
		local nsheets = r(N_worksheet)
		
		noi disp in y "list of available sheets in the selected version of " /* 
		   */ in g "Master file"
		
		noi disp as text _col(7) "N {c |} Sheet Name" 
		noi disp as text "{hline 8}{c +}{hline 20}"

		foreach i of numlist 1/`nsheets' {
			
			if (length("`i'") == 1 ) local j = "0`i'"
			if (length("`i'") == 2 ) local j = "`i'"
			
			noi disp _col(6) `"`j' {c |} {stata `r(worksheet_`i')'}"'
			
		}
		
		noi disp _n "select Sheet to load into Stata" _request(_load)
		exit 
	}
	
	//========================================================
	//  CPI
	//========================================================
	if (lower("`load'") == "cpi") {
		import excel using "`mastervin'/Master_`vcnumber'.xlsx", /*
		*/ sheet("CPI") clear firstrow case(lower)
		
		missings dropvars, force
		missings dropobs, force
		
		ds
		local varlist = "`r(varlist)'"
		foreach v of local varlist {
			local n: variable label `v'
			cap confirm number `n'
			if (_rc) continue
			rename `v' y`n'
		}
		
		if ("`shape'" == "long") {
			reshape long y, i(countrycode coverqge) j(year)
			rename y cpi
			drop if cpi == .
			
			* fix mismatches between the two dataset
			rename coverqge coveragetype
			clonevar data_coverage = coveragetype
			
			replace data_coverage = "Urban" if countrycode == "ARG"
			replace data_coverage = "Rural" if countrycode == "ETH" & year == 1981
			replace data_coverage = "Urban" if countrycode == "BOL" & year == 1992
			replace data_coverage = "Urban" if countrycode == "ECU" & year == 1995
			replace data_coverage = "Urban" if countrycode == "FSM" & year == 2000
			replace data_coverage = "Urban" if countrycode == "HND" & year == 1986
			replace data_coverage = "Urban" if countrycode == "COL" & inrange(year, 1980,1991)
			replace data_coverage = "Urban" if countrycode == "URY" & inrange(year, 1990,2005)
			label var year "Year"
			label var cpi "CPI"
		}
		
		* if ("`shape'" == "long") rename year cpi_time
	}
	
	
	//========================================================
	//PPP
	//========================================================
	if (lower("`load'") == "ppp") {
		import excel using "`mastervin'/Master_`vcnumber'.xlsx", /*
		*/ sheet("PPP") clear firstrow case(lower)
		
		missings dropvars, force
		missings dropobs, force
		
	}
	
	//========================================================
	//POP
	//========================================================
	if (lower("`load'") == "pop" | lower("`load'") == "population")  {
		import excel using "`mastervin'/Master_`vcnumber'.xlsx", /*
		*/ sheet("Population") clear firstrow case(lower)
		
		missings dropvars, force
		missings dropobs, force
		
		ds
		local varlist="`r(varlist)'"
		foreach v of local varlist {
			local n: variable label `v'
			cap confirm number `n'
			if (_rc) continue
			rename `v' y`n'
		}
		
		if ("`shape'" == "long") {
			reshape long y, i(countrycode coverage) j(year)
			rename y population
			drop if population == .
			ren coverage coveragetype
			label var year "Year"
			label var population "Population"
			
		}
		
	}
	
	
	
	//========================================================
	//GDP
	//========================================================
	if (lower("`load'") == "gdp") {
		import excel using "`mastervin'/Master_`vcnumber'.xlsx", /*
		*/ sheet("GDP") clear firstrow case(lower)
		
		missings dropvars, force
		missings dropobs, force
		
		ds
		local varlist="`r(varlist)'"
		foreach v of local varlist {
			local n: variable label `v'
			cap confirm number `n'
			if (_rc) continue
			rename `v' y`n'
		}
		
		if ("`shape'" == "long") {
			reshape long y, i(countrycode coverage) j(year)
			rename y gdp
			drop if gdp == .
			label var year "Year"
			label var gdp "GDP"
			ren coverage coveragetype
		}
		
	}
	
	
	//========================================================
	//PCE
	//========================================================
	if (lower("`load'") == "pce") {
		import excel using "`mastervin'/Master_`vcnumber'.xlsx", /*
		*/ sheet("PCE") clear firstrow case(lower)
		
		missings dropvars, force
		missings dropobs, force
		
		ds
		local varlist = "`r(varlist)'"
		foreach v of local varlist {
			local n: variable label `v'
			cap confirm number `n'
			if (_rc) continue
			rename `v' y`n'
		}
		
		if ("`shape'" == "long") {
			reshape long y, i(countrycode coverage) j(year)
			rename y pce
			drop if pce == .
			label var year "Year"
			label var pce "PCE"
			
		}
	}
	
	
	//========================================================
	//CURRENCY CONVERSION
	//========================================================
	if (lower("`load'") == "currencyconversion") {
		import excel using "`mastervin'/Master_`vcnumber'.xlsx", /*
		*/ sheet("CurrencyConversion") clear firstrow case(lower)
		
		missings dropvars, force
		missings dropobs, force
		
		ds
		local varlist = "`r(varlist)'"
		foreach v of local varlist {
			local n: variable label `v'
			cap confirm number `n'
			if (_rc) continue
			rename `v' y`n'
		}
		
		if ("`shape'" == "long") {
			rename year baseyear
			reshape long y, i(code coverage ratio oldunit newunit baseyear) j(year)
			rename y currencyconv
			drop if currencyconv == .
			label var baseyear "Base Year"
			label var year "Year"
			label var currencyconv "Currency Conversion"
			ren code countrycode
			ren coverage coveragetype
		}
		
	}
	
	
	//========================================================
	//REGION LOOKUP
	//========================================================
	if (lower("`load'") == "regionlookup") {
		import excel using "`mastervin'/Master_`vcnumber'.xlsx", /*
		*/ sheet("RegionLookup") clear firstrow case(lower)
		
		missings dropvars, force
		missings dropobs, force
		
		ds
	}
	
	//========================================================
	//COUNTRY LIST
	//========================================================
	if (lower("`load'") == "countrylist") {
		import excel using "`mastervin'/Master_`vcnumber'.xlsx", /*
		*/ sheet("CountryList") clear firstrow case(lower)
		
		missings dropvars, force
		missings dropobs, force
		
		ds
	}
	//========================================================
	//SURVEY INFO
	//========================================================
	if (lower("`load'") == "surveyinfo") {
		import excel using "`mastervin'/Master_`vcnumber'.xlsx", /*
		*/ sheet("SurveyInfo") clear firstrow case(lower)
		
		missings dropvars, force
		missings dropobs, force
		ren coverage coveragetype
		ds
	}
	//========================================================
	//SURVEY MEAN
	//========================================================
	if (lower("`load'") == "surveymean") {
		import excel using "`mastervin'/Master_`vcnumber'.xlsx", /*
		*/ sheet("SurveyMean") clear firstrow case(lower)
		
		missings dropvars, force
		missings dropobs, force
		ren cpi_time year
		ren coverage coveragetype
		ds
	}
	
	
} // end qui

end


//========================================================
//  Auxiliary programs
//========================================================


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


