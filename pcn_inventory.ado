/*==================================================
project:       Generate inventory of povcalnet data
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     5 Dec 2020 - 08:16:47
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pcn_inventory, rclass
syntax [anything(name=subcmd id="subcommand")],  ///
[                                   ///
COUNtry(string)               ///
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
lyear						              ///
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

if ("`maindir'" == "") {
	local maindir "//wbntpcifs/povcalnet/01.PovcalNet/01.Vintage_control"
}

qui {
  /*==================================================
  1: 
  ==================================================*/
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
	else {
		local years "`year'"
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
	* local maindir = "//wbntpcifs/povcalnet/01.PovcalNet/01.Vintage_control"
	* local country = "PHL"
	* local year    = "1988"
	* local veralt  = ""
	
	local dirs: dir "`maindir'/`country'" dirs "`country'_`year'*", respectcase
		
	loc validf ""
	loc routes ""
	foreach dir of local dirs {
		
		local dirsB: dir "`maindir'/`country'/`dir'" dirs "`dir'*"
		
		foreach dirr of local dirsB {
			
			local filess: dir "`maindir'/`country'/`dir'/`dirr'/Data" files "`dirr'*.dta"
			
			local filess = subinstr(`"`filess'"', `"""', "",.)
			local filess = subinstr(`"`filess'"', `".dta"', "",.)
			local filess = upper("`filess'")
			
			foreach file of local filess {
				if !regexm(`"`file'"', "[Vv][0-9]+_M_[Vv][0-9]+_A") continue
				
				if !regexm(`"`validf'"', "`file'") local validf "`validf' `file'"
			}
			
		}
	}
	
	//------------data to mata
	cap mata: validf = pcn_split_id("`validf'")
	if (_rc) {
		if (_rc == 3499) {
			noi disp in red "function pcn_split_id not fount. Error " _rc
		}
		else {
			noi disp in red "Error in function {cmd:pcn_split_id} of Mata. check " _n /* 
			*/ " local validf, " _n " `validf'"
		}
		error _rc
	}
*##e
	//------------ clean data
	drop _all
	getmata (id countrycode year survey vermast veralt  collection module) = validf
	gen vermast_int = regexs(1) if regexm(vermast, "[Vv]([0-9]+)")
	gen veralt_int  = regexs(1) if regexm(veralt, "[Vv]([0-9]+)")
	destring vermast_int veralt_int, replace force
	
	* create paths
	gen dir1  = countrycode + "_" + year + "_" + survey
	gen dir2  = regexr(id, "_[A-Z\-]+$", "")
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

	
	//------------ filter by module and survey
	
	if ("`module'" != "") {
		keep if module == upper("`module'")
	}
	
	if ("`survey'" != "") {
		keep if survey == upper("`survey'")
	}
	
	if (_N  == 0) {
		noi disp "the combination `country'-`year' - vermast(`vermast') " _n/* 
		*/  "- veralt(`veralt') - survey(`survey') - module(`module') does not exist"
	}

}

/*==================================================
3: Mata functions
==================================================*/
end

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


