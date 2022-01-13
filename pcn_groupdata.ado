/*==================================================
project:       Create group data files from raw information
and update master file with means
Author:        R.Andres Castaneda Aguilar
E-email:       acastanedaa@worldbank.org
url:
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    23 Oct 2019 - 09:04:24
Modification Date:
Do-file version:    01
References:
Output:
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pcn_groupdata, rclass
syntax [anything(name=subcmd id="subcommand")],  ///
COUNtry(string)                      ///
[                                    ///
Years(numlist)                      ///
maindir(string)                     ///
replace								              ///
*                                   ///
]
version 16.0

*---------- conditions
if ("`pause'" == "pause") pause on
else                      pause off


if (wordcount("`country'") != 1) {
	noi disp in red "{it: country()} must have only one countrycode"
	error
} 

//------------set up
if ("`maindir'" == "") local maindir "//wbntpcifs/povcalnet/01.PovcalNet/01.Vintage_control"


*------------------ Time and system Parameters ------------
local date      = c(current_date)
local time      = c(current_time)
local datetime  = clock("`date'`time'", "DMYhms")   // number, not date
local user      = c(username)
local dirsep    = c(dirsep)
local vintage:  disp %tdD-m-CY date("`c(current_date)'", "DMY")


cwf default
local frame_list "area"
foreach fr of local frame_list {
	cap frame drop `fr'
	frame create `fr'
}

foreach year of local years {
	
	datalibweb, countr(`country') year(`year') t(GMD) mod(GROUP)  files clear
	
	local fileid "`r(surveyid)'"
	if regexm("`fileid'", "(.+)_[Vv][0-9]+_M") {
		local id = regexs(1) 
	}
	
	* get some info 
	levelsof welfare_type, local(dt)
	levelsof gd_type, local(gd_type)
	
	sort urban welfare
	levelsof urban, loca(areas)
	
	if ("`areas'" == "")  {
		replace urban = 2
		local areas = 2
	}
	
	foreach area of local areas {
		
		frame copy default area, replace
		frame area {
			keep if urban == `area'
			keep weight  welfare
			replace welfare = welfare/12
			
			* suffix 
			if      (`area' == 0) local cov "R" 
			else if (`area' == 1) local cov "U" 
			else                  local cov "N"
			
			cap makedir "`maindir'/`country'/`id'/`fileid'/Data"
			
			
			//------------Include Characteristics
			
			local datetimeHRF: disp %tcDDmonCCYY_HH:MM:SS `datetime'
			local datetimeHRF = trim("`datetimeHRF'")
			
			char _dta[filename]        `fileid'_GD-`cov'.dta
			char _dta[id]              `fileid'
			char _dta[welfaretype]     `dt'
			char _dta[weighttype]      "PW"
			char _dta[countrycode]     `country'
			char _dta[year]            `year'
			char _dta[survey_coverage] `cov'
			char _dta[groupdata]        1
			char _dta[datetime]        `datetime'
			char _dta[datetimeHRF]     `datetimeHRF'
			char _dta[gdtype]          "`gd_type'"
			char _dta[datatype]        "`dt'"
			
			save "`maindir'/`country'/`id'/`fileid'/Data/`fileid'_GD-`cov'.dta", `replace'
			
			
		}
		
	}
	
	
}// end of years loop 

end


//========================================================
// Aux programs
//========================================================


program define makedir
syntax anything(name=dir id="subcommand")

local  dir: subinstr local dir "\" "/", all
local  dir: subinstr local dir "//" "++" // just the first one

disp "`dir'"

local parse "/"
tokenize "`dir'", parse("`parse'")


local i = 1
while ("``i''" != "") {
	local folder = "``i''"
	
	if ("`folder'" == "`parse'") {
		local i = `i' + 1
		continue
	}
	
	local  folder: subinstr local folder  "++" "//" 
	
	
	local fulldir "`fulldir'`folder'/"
	cap mkdir "`fulldir'"
	
	local todisp "`todisp', `i'= ``i''|"
	local i = `i' + 1
}

return local fulldir = "`fulldir'"

end 

exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:

