/*==================================================
project:       Update current CPI data base
Author:        R.Andres Castaneda
E-email:       acastanedaa@worldbank.org
url:
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     7 Feb 2020 - 18:01:05
Modification Date:
Do-file version:    01
References:
Output:
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pcn_update_cpi, rclass
syntax [anything], [ ///
replace              ///
]

version 14

*---------- conditions
if ("`pause'" == "pause") pause on
else                      pause off

qui {
	
	*##s
	* ---- Initial parameters
	local date = date("`c(current_date)'", "DMY")  // %tdDDmonCCYY
	local time = clock("`c(current_time)'", "hms") // %tcHH:MM:SS
	local date_time = `date'*24*60*60*1000 + `time'  // %tcDDmonCCYY_HH:MM:SS
	local datetimeHRF: disp %tcDDmonCCYY_HH:MM:SS `date_time'
	local datetimeHRF = trim("`datetimeHRF'")
	local user=c(username)
	
	// Output directory
	local outdir "p:/01.PovcalNet/01.Vintage_control/_aux/cpi"
	
	
	/*=================================================
	1: Load CPI and add CPI_time variable to
	make it match with povcalnet
	==================================================*/
	
	*------------------ Initial Parameters  ------------------
	local masterdir "p:/01.PovcalNet/00.Master/02.vintage"
	
	local mfiles: dir "`masterdir'" files "Master_*.xlsx", respect
	local vcnumbers: subinstr local mfiles "Master_" "", all
	local vcnumbers: subinstr local vcnumbers ".xlsx" "", all
	local vcnumbers: list sort vcnumbers
	
	mata: VC = strtoreal(tokens(`"`vcnumbers'"')); /*
	*/ st_local("maxvc", strofreal(max(VC), "%15.0f"))
	
	//------------Load Master CPI
	
	import excel using "`masterdir'/Master_`maxvc'.xlsx", /*
	*/ sheet("CPI") clear firstrow case(lower)
	missings dropvars, force
	missings dropobs, force
	
	ds
	local varlist = "`r(varlist)'"
	foreach v of local varlist {
		local n: variable label `v'
		cap confirm number `n'
		if (_rc) continue
		rename `v' cpi`n'
	}
	
	reshape long cpi, i(countrycode coverqge) j(year)
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
	
	rename year cpi_time
	
	tempfile fcpi
	save `fcpi'
	
	//------------Load data with cpi_time variable
	import excel using "`masterdir'/Master_`maxvc'.xlsx", /*
	*/ sheet("SurveyMean") clear firstrow case(lower)
	missings dropvars, force
	missings dropobs, force
	
	duplicates drop countrycode  surveytime  cpi_time, force
	keep countrycode  surveytime  cpi_time
	
	rename surveytime datayear
	replace datayear = round(datayear, .01)
	tostring datayear, replace force
	
	tempfile fkey
	save `fkey', replace
	
	//------------Load povcalnet make coincide data year and cpi_time
	povcalnet, clear
	replace datayear = round(datayear, .01)
	tostring datayear, replace force format(%8.0g)
	
	merge m:1 countrycode datayear using `fkey', keep(match) nogen
	
	gen data_coverage = cond(coveragetype == 1, "Rural", /*
	*/            cond(coveragetype == 2, "Urban", "National"))
	
	keep countrycode cpi_time data_coverage year datayear
	merge m:1 countrycode cpi_time data_coverage using `fcpi', nogen
	replace coveragetype = data_coverage if  coveragetype == ""
	
	tempfile stage1
	save `stage1'
	
	/*==================================================
	2: Incorporate PPP data
	==================================================*/
	
	import excel using "`masterdir'/Master_`maxvc'.xlsx", /*
	*/ sheet("PPP") clear firstrow case(lower)
	
	missings dropvars, force
	missings dropobs, force
	
	tempfile fppp
	save `fppp'
	
	use `stage1', clear
	merge m:1 countrycode coveragetype using `fppp', update nogen
	
	tempfile stage2
	save  `stage2'
	
	/*==================================================
	3: Incorporate Currency conversion factor
	==================================================*/
	
	import excel using "`masterdir'/Master_`maxvc'.xlsx", /*
	*/ sheet("CurrencyConversion") clear firstrow case(lower)
	
	missings dropvars, force
	missings dropobs, force
	
	ds
	local varlist = "`r(varlist)'"
	foreach v of local varlist {
		local n: variable label `v'
		cap confirm number `n'
		if (_rc) continue
		rename `v' cf`n'
	}
	
	//------------Rename variables
	drop country coverage
	rename code countrycode
	rename (year ratio) cf=
	
	foreach u in oldunit newunit {
		replace `u' =   ustrtrim(`u')
	}
	
	reshape long cf, i(countrycode cfyear cfratio oldunit newunit) j(cpi_time)
	tempfile cf
	save `cf'
	
	use `stage2', clear
	merge m:1 countrycode cpi_time using `cf', nogen
	
	local varord "countrycode countryname  year cpi_time datayear  coveragetype data_coverage"
	order `varord'
	sort `varord'
	
	//------------ update PPP value
	/* Very inefficient way to update ppp values, but I need to make sure the 
	 order of the data is not messed up by the sorting of Stata. Let's think
	 on a more efficient way to do it with clever sorting*/
	 
	 levelsof countrycode, local(codes)
	 ds ppp*, has(type numeric)
	 local pppvars = "`r(varlist)'"
	 
	 foreach code of local codes {
			foreach pvar of local pppvars {
				sum `pvar' if countrycode  == "`code'", meanonly
				local p = r(mean)
				replace `pvar' = `p' if (countrycode  == "`code'" & `pvar' == .)
			} 
	 }
	
	
*##e
	
	//========================================================
	// label variables and chracteristics
	//========================================================
	
	/*  Code to create labels
	ds
	local as = "`r(varlist)'"
	foreach a of local as {
	disp "label var" _col(12) "`a'" _col(30) `""`: variable label `a''""'
	}
	
	*/
	
	//------------Labels
	
	label var  countrycode       "Country Code"
	label var  countryname       "Country Name"
	label var  year              "Year of point estimate"
	label var  datayear          "Survey year"
	label var  cpi_time          "year of the CPI used in PovcalNet"
	label var  coveragetype      "Coverqge"
	label var  data_coverage     "Covarage of the survey"
	label var  cpi               "CPI"
	label var  ppp1993           "PPP1993"
	label var  ppp2005           "PPP2005"
	label var  ppp2011           "PPP2011"
	label var  pppyear           "PPPYear"
	label var  estimationmethod  "EstimationMethod"
	label var  cfyear            "Year"
	label var  cfratio           "Ratio"
	label var  oldunit           "Old Currency Unit"
	label var  newunit           "New Currency Unit"
	label var  cf                "Currency conversion factor"
	
	//------------Characteristics
	
	char _dta[masterdate]         "`maxvc'"
	char _dta[pcn_datetimeHRF]    "`datetimeHRF'"
	char _dta[pcn_datetime]       "`date_time'"
	char _dta[pcn_user]           "`user'"
	
	//========================================================
	// Save
	//========================================================
	
	cap mkdir "`outdir'/vintage"
	
	cap noi datasignature confirm using "`outdir'/povcalnet_cpi"
	if (_rc | "`replace'" != "") {
		datasignature set, reset saving("`outdir'/povcalnet_cpi", replace)
		save "`outdir'/vintage/povcalnet_cpi_`date_time'.dta"
		noi save "`outdir'/povcalnet_cpi.dta", replace
	}
	
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


import excel using "p:/01.PovcalNet/00.Master/02.vintage/Master_${maxvc}.xlsx", /*
*/ sheet("CurrencyConversion") clear firstrow case(lower)
