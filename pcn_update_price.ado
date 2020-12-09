/*==================================================
project:       Create price framework based on datalibweb file
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     5 Mar 2020 - 14:54:05
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
program define pcn_update_price, rclass
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
	local outdir "p:/01.PovcalNet/01.Vintage_control/_aux/price_framework"
	
	
	//========================================================
	// Reading from PIP folder now
	//========================================================
	
	use "y:\PIP-Data\_aux\pfw\pfw.dta", clear
	* keep region code year survname ref_year survey_coverage datatype rep_year comparability
	rename country_code countrycode
	
	//------------Characteristics
	char _dta[pcn_datetimeHRF]    "`datetimeHRF'"
	char _dta[pcn_datetime]       "`date_time'"
	char _dta[pcn_user]           "`user'"

	//========================================================
	// Save
	//========================================================
	compress 

	cap mkdir "`outdir'/vintage"

	cap noi datasignature confirm using "`outdir'/price_framework", strict
	if (_rc | "`replace'" != "") {
		datasignature set, reset saving("`outdir'/price_framework", replace)
		save "`outdir'/vintage/price_framework_`date_time'.dta"
		noi save "`outdir'/price_framework.dta", replace
	}

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


