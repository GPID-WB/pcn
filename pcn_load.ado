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
lyear						              ///
INVentory                     ///
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

qui {
	
	//========================================================
	// conditions
	//========================================================
	tempfile orig
	save `orig'
	preserve
	
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
	
	
	if ("`type'" == "")          local type "GMD"
	if (upper("`lis'") == "LIS") local module "BIN"
	
	
	if (inlist("`type'", "GMD", "GPWG")) {
		local collection "GMD"
	}
	else {
		noi disp as error "type: `type' is not valid"
		error
	}
	
	
	* load and inventory
	if ("`inventory'" != "") {
		local load = "noload"
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
	
	
	//========================================================
	// Get data available 
	//========================================================
	*##s
	local maindir = "//wbntpcifs/povcalnet/01.PovcalNet/01.Vintage_control"
	local country = "DEU"
	local year    = "2010"
	local veralt  = ""
	
	local dirs: dir "`maindir'/`country'" dirs "`country'_`year'*", respectcase
	
	if(!inlist("`module'","")) {
		loc textm " and module `module'"
	}
	
	loc validf ""
	loc routes ""
	foreach dir of local dirs {
		
		local dirsB: dir "`maindir'/`country'/`dir'" dirs "`dir'*"
		
		foreach dirr of local dirsB {
			
			local filess: dir "`maindir'/`country'/`dir'/`dirr'/Data" files "`dirr'*.dta"
			
			local filess = subinstr(`"`filess'"', `"""', "",.)
			local filess = subinstr(`"`filess'"', `".dta"', "",.)
			local filess = upper("`filess'")
			
			if !regexm(`"`validf'"', "`filess'") local validf "`validf' `filess'"
		}
	}
	
	//------------data to mata
	drop _all
	cap noi mata: validf = pcn_split_id("`validf'")
	if (_rc) {
		noi disp in red "Error in Mata. check, local validf" _n /* 
		*/ "`validf'"
	}
	
	//------------ clean data
	getmata (id countrycode year survey vermast veralt  collection module) = validf
	gen vermast_int = regexs(1) if regexm(vermast, "[Vv]([0-9]+)")
	gen veralt_int  = regexs(1) if regexm(veralt, "[Vv]([0-9]+)")
	destring vermast_int veralt_int, replace force
	
	* create paths
	gen dir1  = countrycode + "_" + year + "_" + survey
	gen dir2  = regexr(id, "_[A-Z]+$", "")
	gen strL path = "`maindir'/" + countrycode + "/" + dir1 + "/" /* 
	*/ + dir2 + "/Data/" + id + ".dta"
	
	//========================================================
	// Filter depending on user options
	//========================================================
	
	//------------ filter if vermast or veralt are provided
	
	local vers "vermast veralt"
	foreach v of local vers {
		if ("``v''" != "") {
			local `v' = regexr("``v''", "[Vv]", "")
			keep if `v'_int == ``v''
		}
	}
	
	
	//------------ Make sure there is only one vintage
	tempvar uniq
	qui bysort vermast veralt: gen byte `uniq' = (_n==_N)
  cap summ `uniq', meanonly
	if (_rc) {
		noi disp in r "the combination `country'-`year'-vermast(`vermast') " _n/* 
		*/  "and veralt(`veralt') does not exist"
		error
	}
	
	
	if (r(sum) > 1) {
		tempvar mmast malt
		bysort survey: egen `mmast' = max(vermast_int)
		keep if `mmast' == vermast_int
		
		bysort survey: egen `malt'  = max(veralt_int)
		keep if `malt'  == veralt_int
	}
	*##e
	
	//------------ filter by module and survey
	
	if ("`module'" != "") {
		keep if module == upper("`module'")
	}
	
	if ("`survey'" != "") {
		keep if survey == upper("`survey'")
	}
	
	//========================================================
	// Load or display results
	//========================================================
	
	* error if there is not data
	if (_N  == 0) {
		noi disp in r "the combination `country'-`year' - vermast(`vermast') " _n/* 
		*/  "- veralt(`veralt') - survey(`survey') - module(`module') does not exist"
		error
	}
	* load is there is one data
	else if (_N == 1) {
		local dta2use = path[1]
		if ("`load'" == "") {
			local fid = id[1]
			restore
			use "`dta2use'", `clear'
			noi disp as text "`fid'" as res " successfully loaded"
			
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
			exit
		}
	}
	* display option if there is more than one file
	else {
		if ("`inventory'" == "") {
			levelsof id , local(ids)
			local i = 0
			noi disp as text "list of available surveys `country'- `year'"
			foreach id of local ids {
				local ++i
				local path = path[`i']
				noi disp `"   `i' {c |} {stata use "`path'", clear: `id'}"'
			}
		}
	}
	
	
	//========================================================
	// Load inventory of most recent vintage
	//========================================================
	
	* display inventory
	if ("`inventory'" != "") {
		tempfile inv
		save `inv'
		restore
		use `inv', `clear'
		exit 
	}
	
} // end of qui
*----------3.1:


*----------3.2:

end

/*==================================================
3: Mata functions
==================================================*/

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


