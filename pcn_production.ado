/*==================================================
project:       Create a load Povcalnet production vintages
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    15 Jul 2020 - 09:03:17
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pcn_production, rclass
syntax anything(name=subcmd id="action of pcn_production"),     ///
[                                                               ///
vintage(string)                                                 ///
clear                                                           ///
server(string)                                                  ///
replace                                                         ///
]

version 15

*##s
qui {
	
	local maindir "\\wbntpcifs\povcalnet\01.PovcalNet\02.Production"
	local subcmdok 0

	* ---- Initial parameters
	local date        = date("`c(current_date)'", "DMY")  // %tdDDmonCCYY
	local time        = clock("`c(current_time)'", "hms") // %tcHH:MM:SS
	local date_time   = `date'*24*60*60*1000 + `time'     // %tcDDmonCCYY_HH:MM:SS
	local datetimeHRF: disp %tcDDmonCCYY_HH:MM:SS `date_time'
	local datetimeHRF = trim("`datetimeHRF'")
	local user        = c(username)

	
	/*==================================================
	1: Load
	==================================================*/
	
	*----------1.1: Read current versions
	if ("`subcmd'" == "load") {
		
		// If vintage is not selected
		if ("`vintage'" == "") {
			noi _disp_dirs `subcmd' , maindir("`maindir'")
			return add
			
		}
		
		*----------1.2: If vintage is selected
		else {
			mata: st_local("direx", strofreal(direxists("`maindir'/`vintage'")))
			if (`direx' == 0) {
				noi disp in red "Vintage `vintage' folder does not exist"
				error
			}
			
			confirm file "`maindir'/`vintage'/PovcalNet_`vintage'.dta"
			
			use "`maindir'/`vintage'/PovcalNet_`vintage'.dta", `clear'
			
		}
		
		
		local subcmdok 1
	}
	*##e
	
	
	
	/*==================================================
	2: Create version
	==================================================*/
	
	*----------2.1: check folder existence 
	if ("`subcmd'" == "create") {
		
		if ("`vintage'" == "") {
			noi disp in red "You must select a pre-existing vintage folder"
			noi _disp_dirs `subcmd' , maindir("`maindir'") server(`server') `clear'
			return add
		}
		else {
			mata: st_local("direx", strofreal(direxists("`maindir'/`vintage'")))
			if (`direx' == 0) {
				noi disp in red "Vintage `vintage' folder does not exist"
				error
			}
			
	*----------2.2: download data
			povcalnet, server(`server') `clear'
			
			cap noi datasignature confirm using "`maindir'/`vintage'/PovcalNet_`vintage'"
			if (_rc | "`replace'" != "") {
				datasignature set, reset saving("`maindir'/`vintage'/PovcalNet_`vintage'", replace)
				
				cap mkdir "`maindir'/`vintage'/_vintage"  // create vintage folder 
				save "`maindir'/`vintage'/_vintage/PovcalNet_`vintage'_`date_time'.dta"
				noi save "`maindir'/`vintage'/PovcalNet_`vintage'.dta", replace
			}
			
		}
		
		
		local subcmdok 1
	} // end of create
	
	
	
	
	/*==================================================
	3: closing conditions
	==================================================*/
	
	*----------3.1:
	
	if (`subcmdok' == 0) {
		noi disp in red `"pcn_production action "`subcmd'" is not allowed. "' _n ///
		"please one of the following: " in green " load | create "
		error
	}
	
	
	*----------3.2:
	
	
	
	
} // end of qui 

end

//========================================================
// Aux programs
//========================================================

program define _disp_dirs, rclass
syntax anything(name=subcmd), maindir(string) *


local dirs: dir "`maindir'" dirs "*", respectcase 

local i = 0
noi disp in y "Available PovcalNet Production vintages"
noi disp in g "{hline 40}"
foreach dir of local dirs {
	local ++i
	if regexm("`dir'", "^_|\.git") continue
	local pcncmd "pcn_production `subcmd', vintage(`dir') `options'"
	
	noi disp in y _col(2) `i' _col(5) "{c |} {stata `pcncmd':`dir'}" 
} // end of dirs loop 

return local production_vtgs = `"`dirs'"'

end 


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


