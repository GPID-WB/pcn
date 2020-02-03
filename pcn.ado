/*==================================================
project:       Stata package to manage PovcalNet files and folders
Author:        R.Andres Castaneda 
E-email:       acastanedaa@worldbank.org
url:           https://github.com/randrescastaneda/pcn
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    29 Jul 2019 - 09:18:01
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pcn, rclass
syntax anything(name=subcmd id="subcommand"),  ///
[                                         ///
			COUNtries(string)                   ///
			Years(numlist)                      ///
			REGions(string)                     ///
			maindir(string)                     ///
			type(string)                        ///
			clear                               ///
			pause                               ///
			vermast(string)                     ///
			veralt(string)                      ///
			*                                   ///
] 
version 14

*---------- conditions
if ("`pause'" == "pause") pause on
else                      pause off


qui {
	/*==================================================
	Dependencies         
	==================================================*/
	if ("${pcn_ssccmd}" == "") {
		*--------------- SSC commands
		local cmds missings
		
		noi disp in y "Note: " in w "{cmd:pcn} requires the packages below: " /* 
		*/ _n in g "`cmds'"
		
		foreach cmd of local cmds {
			capture which `cmd'
			if (_rc != 0) {
				ssc install `cmd'
				noi disp in g "{cmd:`cmd'} " in w _col(15) "installed"
			}
		}
		adoupdate `cmds', ssconly
		if ("`r(pkglist)'" != "") adoupdate `r(pkglist)', update ssconly
		global pcn_ssccmd = 1  // make sure it does not execute again per session
	}
	
	
	
	// ---------------------------------------------------------------------------------
	//  initial parameters
	// ---------------------------------------------------------------------------------
	
	* Directory path
	if ("`drive'" == "") {
		if ("`c(hostname)'" == "wbgmsbdat002") local drive "Q"
		else                                   local drive "P"
	}
	
	if ("`root'" == "") local root "01.PovcalNet/01.Vintage_control"
	
	if ("`maindir'" == "") local maindir "`drive':/`root'"
	
	
	//------------ Download functions
	
	if regexm("`subcmd'", "download") {
		local dldb  "gpwg pending" // download databases
		if length("`subcmd'") != 2 {
				noi disp as text "Options available to download"

				local i = 0
				noi disp _n "select survey to load" _request(_survey)
				foreach db of local dldb {
					local ++i
					noi disp `"   `i' {c |} {stata `db'}"'
				}
				noi disp _n "Select Database to download" _request(_db)
		}
		else {
			local db: word 2 `subcmd'
			local dldb_: subinstr local dldb " " "|", all
			cap regexm(lower("`db'"), "`dldb_'")
			if (_rc) {
				noi disp in red " Options available to download are "
				foreach db of local dldb {
					noi disp `"   `i' {c |}`db'"'
				}
				error
			}
		}
	}
	
	
	// ----------------------------------------------------------------------------------
	// Download GPWG
	// ----------------------------------------------------------------------------------
	
	if ("`subcmd'" == "download" & "`db'" == "gpwg") {
		
		pcn_download_gpwg, countries(`countries') years(`years') /*
		*/ maindir("`maindir'")  `pause' `clear' `options'
		return add
		exit
	}
	
	// ----------------------------------------------------------------------------------
	// Load
	// ----------------------------------------------------------------------------------
	
	if ("`subcmd'" == "load") {
		
		noi pcn_load, country(`countries') year(`years') type(`type')  /*
		*/ maindir("`maindir'") vermast(`vermast') veralt(`veralt')  /*
		*/ `pause' `clear' `options'
		return add
		exit
	}
	
	
	// ----------------------------------------------------------------------------------
	//  create text file (collapsed)
	// ----------------------------------------------------------------------------------
	
	if ("`subcmd'" == "create") {
		
		noi pcn_create, countries(`countries') years(`years') type(`type')  /*
		*/ maindir("`maindir'") vermast(`vermast') veralt(`veralt')  /*
		*/ `pause' `clear' `options'
		return add
		exit
	}
	
	
	//========================================================
	// Group data
	//========================================================
	
	if inlist(lower("`subcmd'"), "group", "groupdata", "gd", "groupd") {
		
		noi pcn_groupdata, countries(`countries') years(`years') type(`type')  /*
		*/  vermast(`vermast') veralt(`veralt')  /*
		*/ `pause' `clear' `options'
		return add
		exit
	}
	
	//========================================================
	// Pending data in primus
	//========================================================
	if ("`subcmd'" =="pending" & "`db'" == "pending") {
		
		noi pcn_download_pending, countries(`countries') years(`years')  /*
		*/ `pause' `clear' `options'
		return add
		exit
	}
	
	// ----------------------------------------------------------------------------------
	//  create text file (collapsed)
	// ----------------------------------------------------------------------------------
	
	if ("`subcmd'" == "test") {
		
		noi pcn_test
		exit
	}
	
	
	
	
} // end of qui

end

// ------------------------------------------------------------------------
// Mata functions
// ------------------------------------------------------------------------


exit

/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


//========================================================
// executables
//========================================================

//------------Create
pcn create, countries(all) replace


Version Control:


/*====================================================================
Create repository
====================================================================*/
*--------------------1.1: Load repository data
if ("`createrepo'" != "" & "`calcset'" == "repo") {
	cap confirm file "`reporoot'\repo_gpwg2.dta"
	if ("`gpwg2'" == "gpwg2" | _rc) {
		indicators_gpwg2, out("`out'") datetime(`datetime')
	}
	local dt: disp %tdDDmonCCYY date("`c(current_date)'", "DMY")
	local dt = trim("`dt'")
	if ("`repofromfile'" == "") {
		cap datalibweb, repo(erase `repository', force) reporoot("`reporoot'") type(GMD)
		datalibweb, repo(create `repository') reporoot("`reporoot'") /* 
		*/         type(GMD) country(`countries') year(`years')       /* 
		*/         region(`regions') module(`module')
		noi disp "repo `repository' has been created successfully."
		use "`reporoot'\repo_`repository'.dta", clear
		append using "`reporoot'\repo_gpwg2.dta"			
	}
	else {
		use "`reporoot'\repo_`repository'.dta", clear
	}
	* Fix names of surveyid and files
	local repovars filename surveyid
	foreach var of local repovars {
		replace `var' = upper(`var')
		replace `var' = subinstr(`var', ".DTA", ".dta", .)
		foreach x in 0 1 2 {
			while regexm(`var', "_V`x'") {
				replace `var' = regexr(`var', "_V`x'", "_v`x'")
			}	
		}
	}
	
	duplicates drop filename, force
	save "`reporoot'\repo_`repository'.dta", replace
	* confirm file exists
	cap confirm file "`reporoot'\repo_vc_`repository'.dta"
	if (_rc) {
		gen vc_`dt' = 1
		save "`reporoot'\repo_vc_`repository'.dta", replace
		noi disp "repo_vc_`repository' successfully updated"
		exit 
	}
	use "`reporoot'\repo_vc_`repository'.dta", clear
	* Fix names of surveyid and files
	local repovars filename surveyid
	foreach var of local repovars {
		replace `var' = upper(`var')
		replace `var' = subinstr(`var', ".DTA", ".dta", .)
		foreach x in 0 1 2 {
			while regexm(`var', "_V`x'") {
				replace `var' = regexr(`var', "_V`x'", "_v`x'")
			}	
		}
	}
	
	duplicates drop filename, force
	merge 1:1 filename using "`reporoot'\repo_`repository'.dta"
	cap confirm new var vc_`dt'
	if (_rc) drop vc_`dt'
	recode _merge (1 = 0 "old") (3 = 1 "same") (2 = 2 "new"), gen(vc_`dt')
	sum vc_`dt', meanonly
	if r(mean) == 1 {
		noi disp in r "variable {cmd:vc_`dt'} is the same as previous version. No update"
		drop vc_`dt' _merge
		error
	}
	else {
		noi disp in y "New vintages:"
		noi list filename if vc_`dt' == 2
	}
	drop _merge
	save "`reporoot'\repo_vc_`repository'.dta", replace
	exit
}
