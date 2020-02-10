/*================================================== 
project:       Load working data stored in P drive 
Author:        David L. Vargas 
E-email:       acastanedaa@worldbank.org 
url:            
Dependencies:  The World Bank 
---------------------------------------------------- 
Creation Date:     5 Feb 2020 - 
Modification Date:    
Do-file version:    01 
References:           
Output:              
==================================================*/ 
 
/*================================================== 
              0: Program set up 
==================================================*/ 
program define pcn_load_wrk, rclass 
syntax [anything(name=subcmd id="subcommand")],  /// 
[                                   /// 
			country(string)               /// 
			Year(numlist)                 /// 
			REGions(string)               /// 
			maindir(string)               /// 
			survey(string)                /// 
			replace                       /// 
			vermast(string)               /// 
			clear                         /// 
			pause                         /// 
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
// Check version of pending data 
//======================================================== 
 
qui { 
	* working month 
	local cmonth: disp %tdnn date("`c(current_date)'", "DMY") 
	 
	*Working year 
	local wkyr:  disp %tdCCyy date("`c(current_date)'", "DMY") 
	 
	* Either Annual meeting (AM) or Spring meeting (SM) 
	 
	if inrange(`cmonth', 1, 4) | inrange(`cmonth', 11, 12)  local meeting "SM" 
	if inrange(`cmonth', 5, 10) local meeting "AM" 
	 
	if inrange(`cmonth', 11, 12) { 
		local wkyr = `wkyr' + 1  // workign for the next year's meeting 
	} 
	 
	return local wkyr = `wkyr' 
	return local meeting = "`meeting'" 
 
local maindir "`maindir'/`wkyr'_`meeting'/wrk" 
 
//======================================================== 
// conditions 
//======================================================== 
 
* ----- Initial conditions 
 
local country = upper("`country'") 
 
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

	local dirs: dir "`maindir'/`country'" dirs "`country'_`year'*", respectcase
 
*----------1.2: Path 
 
if ("`survey'" == "") { 
	 
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
} 
else { 
	local survey = upper("`survey'") 
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
 
 
/*================================================== 
       2: Loading according to type 
==================================================*/ 
 
 
*----------2.2: Load data 
local survid = "`country'_`year'_`survey'_V`vermast'_M_WRK_A_GMD" 
 
local dirname "`maindir'/`country'/`country'_`year'_`survey'/`survid'/Data" 
 
local files: dir "`dirname'"  files "*.dta", respectcase 
 
 
** serch for the ending 
local k = 0 
foreach file of local files { 
	local ++k 
	if regexm("`file'", "`survid'_(.+)\.dta"){ 
		local e = regexs(1) 
		local endings "`endings' `e'" 
	} 
	else{ 
		local endings "`endings'"  
	} 
} 
 
* select file ending  
if (`k' == 0) { 
	noi disp in r "no survey in `country'-`year'" 
		error 
} 
else if (`k' == 1) { 
	local ending = subinstr("`endings'"," ","",.) 
} 
else{ 
	foreach ending of local endings { 
			local ++i 
			noi disp `"   `i' {c |} {stata `survey' GMD `ending'}"' 
		} 
		noi disp _n "select survey to load" _request(_ending) 
		 
} 
 
 
if ("`ending'" != "") local filename "`survid'_`ending'" 
else 				  local filename "`survid'" 
 
return local surdir = "`surdir'" 
return local survid = "`survid'" 
return local survin = "`country'_`year'_`survey'_v`vermast'_M_WRK_A" 
return local filename = "`filename'" 
 
use "`surdir'/`survid'/Data/`filename'.dta", clear 
noi disp as text "`filename'.dta" as res " successfully loaded" 
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
 
 
if (wordcount(`"`files'"') == 0) { 
		noi disp in r "no survey in `country'-`year'" 
		error 
	} 
	else if (wordcount(`"`files'"') == 1) { 
		if regexm(`files', "_v`vermast'_M_WRK_A_GMD_(.+).dta") local ending = regexs(1) 
	} 
	else {  // if more than 1 survey per year 
		foreach file of local files { 
			if regexm(`"`file'"', "_v`vermast'_M_WRK_A_GMD_(.+).dta") local a = regexs(1) 
			local ending = "`ending' `a'" 
		} 
 
		noi disp as text "list of available surveys for `country'- `year'" 
 
		local i = 0 
		foreach e of local ending { 
			local ++i 
			noi disp `"   `i' {c |} {stata `survey' GMD `e'}"' 
		} 
		noi disp _n "select survey to load" _request(_ending) 
	} 
 
 
 
