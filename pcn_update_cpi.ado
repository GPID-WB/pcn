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
cpivin(string)       ///
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


	//========================================================
	// Load latest data on datalibweb
	//========================================================

	// The version that is loaded should automaticallly be the most recent one. 
	// Not quite sure how to do that so here I specified v05.
	cap datalibweb, country(Support) year(2005) type(GMDRAW) fileserver /*
	*/	surveyid(Support_2005_CPI_v05_M) filename(Final_CPI_PPP_to_be_used.dta)

	replace levelnote = lower(levelnote)

	* collapse (mean) cpi* icp* cur_adj, by(code countryname region year ref_year levelnote survname)
	rename code countrycode
	gen ccf = 1/cur_adj // Currency Conversion Factor
	label var ccf  "Currency conversion factor"
	note ccf: 1/cur_adj
	
	replace cur_adj = 1 if cur_adj == .
	replace ccf = 1 if ccf == .

	order region countrycode countryname levelnote year ref_year cpi2011 icp2011  ccf cur_adj

	gen coverage = cond(levelnote == "urban", 1, /*
	            */ cond(levelnote == "rural", 0 , 2))

	label define coverage 0 "Rural" 1 "Urban" 2 "National"
	label values coverage coverage
	
	replace datalevel = 1 if countrycode == "ARG"
	replace datalevel = 1 if countrycode == "URY" & inrange(year, 1992, 2005)
	

	//------------Characteristics

	char _dta[dlwversion]         "`cpivin'"
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
