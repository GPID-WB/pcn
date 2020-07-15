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
lyear						 ///
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
	
	return local years = "`years'"
	
	** if list years
	if ("`lyear'"!= ""){
		noi di "years: `years'"
		exit
	}
	
	
	*----------1.2: check for valid data given the module
	
	
	
	
	local dirs: dir "`maindir'/`country'" dirs "`country'_`year'*", respectcase
	
	if(!inlist("`module'","")) {
		loc textm " and module `module'"
		loc moduleregex "`module'*"
	}
	
	loc validf ""
	loc routes ""
	foreach dir of local dirs {
		local dirsB: dir "`maindir'/`country'/`dir'" dirs "`dir'*", respectcase
		foreach dirr of local dirsB{
			cap local filess: dir "`maindir'/`country'/`dir'/`dirr'/Data" files "*.dta", respectcase
			if _rc{
				local filess: dir "`maindir'/`country'/`dir'/`dirr'/data" files "*.dta", respectcase
			}
			if regexm(`"`filess'"', "(.+[Vv][0-9]+_[Mm].+`moduleregex'.dta)") local a = regexs(1)
			loc a = subinstr(`"`a'"', `"""', "",.)
			loc a = subinstr(`"`a'"', `".dta"', "",.)
			if !regexm(`"`validf'"', "`a'") local routes "`routes' `maindir'/`country'/`dir'/`dirr'/Data/`a'.dta"
			if !regexm(`"`validf'"', "`a'") local validf "`validf' `a'"
		}
	}
	
	// recover module if not given 
	if ("`module'" == ""){
		if (wordcount(`"`validf'"') == 0) {
			noi disp in r "no survey in `country'-`year'"
			error
		}
		else if (wordcount(`"`validf'"') == 1) {
			if regexm(`"`validf'"',"`collection'_(.+)") local module = regexs(1)
		}
		else {  // if more than 1 valid file per country-year
			foreach file of local validf {
				if regexm(`"`file'"', "`collection'_(.+)") local a = regexs(1)
				if !regexm(`"`modules'"', "`a'") local modules = "`modules' `a'"
			}
			if (wordcount(`"`modules'"') > 1) {
				noi disp as text "list of available modules for `country'- `year'"
				
				local i = 0
				foreach module of local modules {
					local ++i
					noi disp `"   `i' {c |} {stata `module'}"'
				}
				noi disp _n "select module to load" _request(_module)
			}
			else {
				loc module = subinstr(`"`modules'"'," ", "", .)
				
			}
		}
	}
	
	// only keep routes for the selected survey
	local aroutes ""
	local avalidf ""
	foreach route of local routes {
		if regexm(`"`route'"', "(`collection'_`module')") local aroutes "`aroutes' `route'"
	}
	foreach vfile of local validf {
		if regexm(`"`vfile'"', "(`collection'_`module')") local avalidf "`avalidf' `vfile'"
	}
	loc routes "`aroutes'"
	loc validf "`avalidf'"
	
	* ---------- Check survey 
	
	if (wordcount(`"`validf'"') == 0) {
		noi disp in r "no survey in `country'-`year' `textm'"
		error
	}
	
	
	if ("`survey'" == "") {
		if (wordcount(`"`validf'"') == 1) {
			if regexm(`"`validf'"', "([0-9]+)_(.+)_[Vv]([0-9]+_[Mm].+)") local survey = regexs(2)
		}
		else {  // if more than 1 valid file per country-year module
			foreach file of local validf {
				if regexm(`"`file'"', "([0-9]+)_(.+)_[Vv]([0-9]+_[Mm].+)") local a = regexs(2)
				if !regexm(`"`surveys'"', "`a'")  local surveys = "`surveys' `a'"
			}			
			if (wordcount(`"`surveys'"') > 1) {
				noi disp as text "list of available surveys for `country'- `year' `textm'"
				
				local i = 0
				foreach survey of local surveys {
					local ++i
					noi disp `"   `i' {c |} {stata `survey'}"'
				}
				noi disp _n "select survey to load" _request(_survey)
			}
			else {
				loc survey = subinstr(`"`surveys'"'," ", "", .)
			}
		}
	} // end of survey == ""
	else {
		local survey = upper("`survey'")
	}
	
	// only keep routes for the selected survey
	local aroutes ""
	foreach route of local routes {
		if regexm(`"`route'"', "(.+_`survey'_.+)") local aroutes "`aroutes' `route'"
	}
	loc routes "`aroutes'"
	
	
	if (`"`routes'"' == "") {
		noi disp as err "no data for the following combination: " ///
		as text "`country' `year' `survey' `textm'"
		error
	}
	
	
	*-------- 1.3 version
	
	** Master Version
	
	if ("`vermast'" == "") {
		
		foreach route of local routes {
			if regexm(`"`route'"', "_[Vv]([0-9]+)_[Mm]_") local a = regexs(1)
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
	
	// only keep routes for the selected master version
	local aroutes ""
	foreach route of local routes {
		if regexm(`"`route'"', "(_[Vv]`vermast'_[Mm]_)") local aroutes "`aroutes' `route'"
	}
	loc routes "`aroutes'"
	
	** Alternative Version
	
	if ("`veralt'" == "") {
		foreach route of local routes {
			if regexm(`"`route'"', "_[Vv]([0-9]+)_[Aa]_") local a = regexs(1)
			local vas = "`vas' `a'"
		}
		
		local vas = trim("`vas'")
		local vas: subinstr local vas " " ", ", all
		local va = max(0, `vas')
		
		if (length("`va'") == 1) local veralt = "0`va'"
		else                     local veralt = "`va'"
	}
	
	// only keep routes for the selected master version
	local aroutes "" 
	foreach route of local routes {
		if regexm(`"`route'"', "(_[Vv]`veralt'_[Aa]_)") local aroutes "`aroutes' `route'"
	}
	loc routes "`aroutes'"
	
	
	/*==================================================
	2: Loading according to type
	==================================================*/
	
	*----------2.2: Load data
	local surdir "`maindir'/`country'/`country'_`year'_`survey'"
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
			if ("`country'" == "ARG") {
				replace datalevel = 1
			}
			if ("`country'" == "URY" & inrange(`year', 1992, 2005)) {
				replace datalevel = 1
			}
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


