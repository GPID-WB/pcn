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

cap 

*##s
* ---- Initial parameters
local date = date("`c(current_date)'", "DMY")  // %tdDDmonCCYY
local time = clock("`c(current_time)'", "hms") // %tcHH:MM:SS
local date_time = `date'*24*60*60*1000 + `time'  // %tcDDmonCCYY_HH:MM:SS
local datetimeHRF: disp %tcDDmonCCYY_HH:MM:SS `date_time'
local datetimeHRF = trim("`datetimeHRF'")
local user=c(username)

// Output directory 
local outdir "p:\01.PovcalNet\01.Vintage_control\_aux\cpi\"


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
gen id = countrycode + "-" + strofreal(cpi_time)

tempfile stage1
save `stage1'


*##e


coveragetype 


rename coverqge coverage
char _dta[masterdate]   "`maxvc'"








*----------2.1:


*----------2.2:


/*==================================================
              3: 
==================================================*/


*----------3.1:


*----------3.2:





end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


