/*==================================================
project:       Load data stored in P drive
Author:        R.Andres Castaneda
E-email:       acastanedaa@worldbank.org
url:
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     8 Aug 2019 - 08:54:29
Modification Date:
Do-file version:    01
References:
Output:
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pcn_load, rclass
syntax [anything(name=subcmd id="subcommand")],  ///
[                                   ///
country(string)               ///
Year(numlist)                 ///
REGions(string)               ///
maindir(string)               ///
type(string)                  ///
survey(string)                ///
replace                       ///
vermast(string)               ///
veralt(string)                ///
MODule(string)                ///
clear                         ///
pause                         ///
lis                           ///
cpi                           ///
noLOAD                        ///
]

version 14

*---------- pause
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
// conditions
//========================================================

qui {
	* ----- Initial conditions
	
	local country = upper("`country'")
	local lis = upper("`lis'")
	
	/* The `lis` option is an inelegant solution because it is too specific and does not
	allow the code to be generalized. Yet, it works fine for now. Also, we should add
	a condition that automates the identification of module. Right now it is hardcoded.
	See for instance the following cases:
	
	pcn load, countr(EST) year(2004) clear              // works
	pcn load, countr(EST) year(2004) clear module(GPWG) // does not work
	pcn load, countr(EST) year(2004) clear module(BIN)  // does not work
	pcn load, countr(EST) year(2004) clear lis          // works
	
	*/
	
	
	*---------- conditions
	if ("`type'" == "") local type "GMD"
	if ("`lis'" == "LIS") local module "BIN"
	
	
	if (inlist("`type'", "GMD", "GPWG")) {
		local collection "GMD"
	}
	else {
		noi disp as error "type: `type' is not valid"
		error
	}
	
	
	
	/*==================================================
	1: Find path
	==================================================*/
	
	*----------1.1: Country and Year
	
	/* for testing purposes
	local maindir "p:\01.PovcalNet\01.Vintage_control"
	local country "MEX"
	local year "2012"
	local survey "ENIGH"
	*/
	
	mata: st_local("direxists", strofreal(direxists("`maindir'/`country'")))
	
	if (`direxists' != 1) { // if folder does not exist
		noi disp as err "`country' (`type') not found"
		error
	}
	
	if ("`year'" == "") {
		local dirs: dir "`maindir'/`country'" dirs "`country'*", respectcase
		
		foreach dir of local dirs {
			if regexm(`"`dir'"', "(.+)_([0-9]+)_(.+)") local a = regexs(2)
			local years = "`years' `a'"
		}
		local years = trim("`years'")
		local years: subinstr local years " " ", ", all
		
		local year = max(0, `years')
		
	}
	
	*----------1.2: Path
	
	if ("`survey'" == "") {
		
		//------------very inefficient solution to pick surveys
		/*
		This section is part of the inefficiencies mentioned above. It is hardcoded and
		inelegant. We need to find a better solution.
		*/
		
		if ("`module'" == "BIN") local lis "LIS"
		local dirs: dir "`maindir'/`country'" dirs "`country'_`year'*`lis'", respectcase
		
		if ("`module'" == "GPWG") {
			local dirs1: dir "`maindir'/`country'" dirs "`country'_`year'*LIS", respectcase
			local dirs2: dir "`maindir'/`country'" dirs "`country'_`year'*", respectcase
			local dirs: list dirs2 - dirs1
		}
		//------------------------------------------
		
		
		if (wordcount(`"`dirs'"') == 0) {
			noi disp in r "no survey in `country'-`year'"
			error
		}
		else if (wordcount(`"`dirs'"') == 1) {
			if regexm(`dirs', "([0-9]+)_(.+)$") local survey = regexs(2)
		}
		else {  // if more than 1 survey per year
			foreach dir of local dirs {
				if regexm(`"`dir'"', "([0-9]+)_(.+)") local a = regexs(2)
				local surveys = "`surveys' `a'"
			}
			
			noi disp as text "list of available surveys for `country'- `year'"
			
			local i = 0
			foreach survey of local surveys {
				local ++i
				noi disp `"   `i' {c |} {stata `survey'}"'
			}
			noi disp _n "select survey to load" _request(_survey)
		}
	} // end of survey == ""
	else {
		local survey = upper("`survey'")
	}
	
	if ("`module'" == "") {
		if regexm("`survey'", "LIS$") local module "BIN"
		else                          local module "GPWG"
	}
	
	*-------- 1.3 version
	local surdir "`maindir'/`country'/`country'_`year'_`survey'"
	
	* vermast
	
	if ("`vermast'" == "") {
		local dirs: dir "`surdir'" dirs "*`type'", respectcase
		
		if (`"`dirs'"' == "") {
			noi disp as err "no GMD collection for the following combination: " ///
			as text "`country'_`year'_`survey'"
			error
		}
		
		foreach dir of local dirs {
			if regexm(`"`dir'"', "_[Vv]([0-9]+)_[Mm]_") local a = regexs(1)
			local vms = "`vms' `a'"
		}
		
		local vms = trim("`vms'")
		local vms: subinstr local vms " " ", ", all
		local vm = max(0, `vms')
		
		if (length("`vm'") == 1) local vermast = "0`vm'"
		else                     local vermast = "`vm'"
	}
	
	else {
		if regexm("`vermast'", "^[Vv]([0-9]+)") local vermast = regexs(1)
		if (length("`vermast'") == 1) local vermast = "0`vermast'"
	}
	
	if ("`veralt'" == "") {
		local dirs: dir "`surdir'" dirs "*`vermast'_M_*_A_`collection'", respectcase
		foreach dir of local dirs {
			if regexm(`"`dir'"', "_[Vv]([0-9]+)_[Aa]_") local a = regexs(1)
			local vas = "`vas' `a'"
		}
		
		local vas = trim("`vas'")
		local vas: subinstr local vas " " ", ", all
		local va = max(0, `vas')
		
		if (length("`va'") == 1) local veralt = "0`va'"
		else                     local veralt = "`va'"
	}
	
	
	/*==================================================
	2: Loading according to type
	==================================================*/
	
	
	*----------2.2: Load data
	local survid = "`country'_`year'_`survey'_v`vermast'_M_v`veralt'_A_`collection'"
	
	if ("`module'" != "") {
		local filename = "`survid'_`module'"
	}
	else {
		local filename = "`survid'"
	}
	
	return local surdir = "`surdir'"
	return local survid = "`survid'"
	return local survin = "`country'_`year'_`survey'_v`vermast'_M_v`veralt'_A"
	return local filename = "`filename'"
	confirm file "`surdir'/`survid'/Data/`filename'.dta" 
	
	if ("`load'" == "") {
		use "`surdir'/`survid'/Data/`filename'.dta", clear
		noi disp as text "`filename'.dta" as res " successfully loaded"
		
		if ("`cpi'" == "cpi") {
			if regexm("`module'", "\-U$") {
				local datalevel = 1
			} 
			else if regexm("`module'", "\-R$") {
				local datalevel = 0
			}
			else {
				local datalevel = 2
			}
			gen datalevel = `datalevel'
			gen countrycode = "`country'"
			
			preserve
			pcn load pf, clear
			keep if countrycode == "`country'" & year == `year' /* 
			*/      & survname == "`survey'" & datalevel == `datalevel'
			drop coverage 
			tempfile pf
			save `pf'
			
			pcn load cpi, clear
			if inlist("`country'", "IND", "IDN", "CHN") {
				merge m:1 countrycode year survname datalevel using `pf', ///
				keep( 3 4 5) nogen update replace
			}
			else {
				merge m:1 countrycode ref_year survname datalevel using `pf', ///
				keep( 3 4 5) nogen update replace
			}
			
			keep if countrycode == "`country'" & year == `year' & survname == "`survey'"
			tempfile cpipf
			save `cpipf'
			
			restore
			
			merge m:1 countrycode datalevel using `cpipf', keep(3) nogen
		}
	}
	
}
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
		
		
				