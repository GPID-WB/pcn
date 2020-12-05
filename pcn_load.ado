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

version 16

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
	
	qui pcn inventory, countries(`country') years(`year') maindir(`maindir') `pause' /* 
	*/  survey(`survey') `replace' vermast(`vermast') veralt(`veralt')   /* 
	*/  module(`module')                
	
*##e
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

* findfile "pcn_functions.mata"
* include "`r(fn)'"

exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


