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
[                                         ///
			COUNtries(string)                   ///
			Years(numlist)                      ///
			maindir(string)                     ///
			type(string)                        ///
			clear                               ///
			pause                               ///
			vermast(string)                     ///
			veralt(string)                      ///
			replace
			*                                   ///
] 
version 14

*---------- conditions
if ("`pause'" == "pause") pause on
else                      pause off


//------------set up
if ("`maindir'" == "") cd "p:\01.PovcalNet\03.QA\01.GroupData"
else                   cd "`maindir'"


*------------------ Time and system Parameters ------------
local date      = c(current_date)
local time      = c(current_time)
local datetime  = clock("`date'`time'", "DMYhms")   // number, not date
local user      = c(username)
local dirsep    = c(dirsep)
local vintage:  disp %tdD-m-CY date("`c(current_date)'", "DMY")



*------------------ Initial Parameters  ------------------
local mfiles: dir "../../00.Master/02.vintage/" files "Master_*.xlsx", respect
local vcnumbers: subinstr local mfiles "Master_" "", all
local vcnumbers: subinstr local vcnumbers ".xlsx" "", all
local vcnumbers: list sort vcnumbers

mata: VC = strtoreal(tokens(`"`vcnumbers'"')); /* 
	 */ st_local("maxvc", strofreal(max(VC), "%15.0f"))

* exDate = Format(Now(), "yyyymmddHhNnSs") // VBA name


//------------load data
import excel "raw_GroupData.xlsx", sheet("raw_GroupData") firstrow clear
tostring survey, replace  // in case survey is unknown

gen id = countrycode + " " + strofreal(year)  + " " + /* 
*/ strofreal(coverage)  + " " + datatype  + " 0" + /* 
*/ strofreal(formattype) + " " + survey


//------------saving data vintages
levelsof id, local(ids) 

qui foreach id of local ids {
	local cc:  word 1 of `id'
	local yr:  word 2 of `id'
	local cg:  word 3 of `id'
	local dt:  word 4 of `id'
	local ft:  word 5 of `id'
	local sy:  word 6 of `id'
	
	if      (`cg' == 1) local cov = "R"
	else if (`cg' == 2) local cov = "U"
	else if (`cg' == 3) local cov = "N"
	else                local cov = "A"
	
	local l2y = substr("`yr'", 3,.)
	
	if (inlist("`sy'", "", ".")) local sy = "USN" // Unknown Survey Name
	
	//------------Create directories
	local cc = upper("`cc'")
	
	cap mkdir "../../01.Vintage_control/`cc'"
	
	local sydir "../../01.Vintage_control/`cc'/`cc'_`yr'_`sy'"
	cap mkdir "`sydir'"
	
	
	preserve 
	keep if id == "`id'"
	keep weight  welfare 
	
	local signature "`cc'_`yr'_`sy'_GMD_GROUP-`cg'"
	cap datasignature confirm using /* 
	*/ "02.datasignature/`signature'", strict // deberia ir a la misma carpeta de la data
	local dsrc = _rc
	if (`dsrc' == 601) {
		local fileid "`cc'_`yr'_`sy'_v01_M_v01_A_GMD"
	}
	if (`dsrc' == 9) {
		
		local dirs: dir "`sydir'" dirs "*GMD", respect
		
		local fe = ""  // file exists
		local va = ""
		foreach dir of local dirs {
			
			if regexm("`dir'", "v([0-9]+)_A") local va = "`va' " + regexs(1)
			
			local exfile: dir "`sydir'/`dir'/Data" files "*GMD-`cg'.dta", respect
			if (`"`exfile'"' != "") continue
			else local fe = "`dir'"  // file does not exists
		}
		
		local va: subinstr local va " " ",", all
		local va = "0" + "`va'"
		
		if ("`fe'"  == "") local va = max(`va') + 1
		else               local va = max(`va') 
		
		if length("`va'") == 1 local va = "0"+"`va'"
		local fileid "`cc'_`yr'_`sy'_v01_M_v`va'_A_GMD"
	}
	if (`dsrc' != 0) {
		local verid "`sydir'/`fileid'"
		cap mkdir "`verid'"
		cap mkdir "`verid'/Data"
		
		noi datasignature set, reset /* 
		*/ saving("02.datasignature/`signature'", replace)
		
		
		//------------Include Characteristics
		
		local datetimeHRF: disp %tcDDmonCCYY_HH:MM:SS `datetime'
		local datetimeHRF = trim("`datetimeHRF'")
		
		char _dta[filename]     `fileid'-`cg'.dta
		char _dta[id]           `fileid'
		char _dta[datatype]     `dt'
		char _dta[countrycode]  `cc'
		char _dta[year]         `yr'
		char _dta[coverage]     `cov'
		char _dta[groupdata]     1
		char _dta[formattype]   `ft'
		char _dta[datetime]     `datetime'
		char _dta[datetimeHRF]  `datetimeHRF'
		
		
		save "03.vintage/`signature'_`datetime'.dta", replace
		save "`verid'/Data/`fileid'-`cg'.dta", replace
		
		export delimited using "`verid'/Data/`fileid'-`cg'.txt", ///
		novarnames nolabel delimiter(tab) `replace'
		
		export delimited using "`verid'/Data/`cc'`cov'`l2y'.T`ft'", ///
		novarnames nolabel delimiter(tab) `replace'
		
	}
	else {
		noi disp in y "File " in w "`fileid'-`cg'.dta" in /* 
		*/ y " is up to date."
	}
	
	*get the mean
	sum welfare [w = welfare], meanonly
	local `cc'`yr'`cg'm = r(mean)
	
	restore 
}

//------------ Check both files are in the most recent folder
qui foreach id of local ids {
	local cc:  word 1 of `id'
	local yr:  word 2 of `id'
	local cg:  word 3 of `id'
	local dt:  word 4 of `id'
	local ft:  word 5 of `id'
	local sy:  word 6 of `id'
	
	if      (`cg' == 1) local cov = "R"
	else if (`cg' == 2) local cov = "U"
	else if (`cg' == 3) local cov = "N"
	else                local cov = "A"
	
	local l2y = substr("`yr'", 3,.)
	
	if (inlist("`sy'", "", ".")) local sy = "USN" // Unknown Survey Name
	
	local cc = upper("`cc'")
	local sydir "../../01.Vintage_control/`cc'/`cc'_`yr'_`sy'"
	
	local dirs: dir "`sydir'" dirs "*GMD", respect
	
	local fe = ""  // file exists
	local va = ""
	foreach dir of local dirs {
		
		if regexm("`dir'", "v([0-9]+)_A") local va = "`va' " + regexs(1)
		
		local exfile: dir "`sydir'/`dir'/Data" files "*GMD-`cg'.dta", respect
		if (`"`exfile'"' != "") continue
		else local fe = "`dir'"  // file does not exists
	}
	
	if ("`fe'" != "") {
	
		local mfiles: dir "03.vintage" files "`signature'*.dta", respect
		disp `"`mfiles'"'
		local vcs: subinstr local mfiles "`signature'_" "", all
		local vcs: subinstr local vcs ".dta" "", all
		local vcs: list sort vcs
		disp `"`vcs'"'
		
		mata: VC = strtoreal(tokens(`"`vcs'"'));  /* 
		*/	  st_local("mvc", strofreal(max(VC), "%15.0f"))
		
		copy "03.vintage/`signature'_`mvc'.dta" "`sydir'/`fe'/Data/`fe'-`cg'.dta"
		
		use "`sydir'/`fe'/Data/`fe'-`cg'.dta", clear
		
		local datetimeHRF: disp %tcDDmonCCYY_HH:MM:SS `datetime'
		local datetimeHRF = trim("`datetimeHRF'")
		
		char _dta[filename]     `fe'-`cg'.dta
		char _dta[id]           `fe'
		char _dta[datetime]     `datetime'
		char _dta[datetimeHRF]  `datetimeHRF'

		save, replace
		
		export delimited using "`sydir'/`fe'/Data/`fileid'-`cg'.txt", ///
		novarnames nolabel delimiter(tab) `replace'
		
		export delimited using "`sydir'/`fe'/Data/`cc'`cov'`l2y'.T`ft'", ///
		novarnames nolabel delimiter(tab) `replace'
	
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


local date      = c(current_date)
local time      = c(current_time)
local datetime  = clock("`date'`time'", "DMYhms")
disp "`datetime'"

disp %tcDDmonCCYY_HH:MM:SS `datetime'

disp %tcCCYYmonDDHHMMSS `datetime'

disp %tcCCYYNNDDHHMMSS `datetime'

local a: disp %tcCCYYNNDDHHMMSS `datetime'

local b  = clock("`a'", "YMDhms")

disp %tcDDmonCCYY_HH:MM:SS `datetime'
disp %tcDDmonCCYY_HH:MM:SS `b'

local vcnumbers: dir "." files "zzz*"
local vcnumbers: subinstr	 local vcnumbers "zzz" "", all








local exfile: dir "../../01.Vintage_control/CHN/CHN_2016_USN/chn_2016_usn_v01_m_v01_a_pcngd/Data" files "*PCNGD-2.dta"
disp `"`exfile'"'



