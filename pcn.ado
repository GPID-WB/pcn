/*==================================================
* project:       Stata package to manage PovcalNet files and folders
* Author:        R.Andres Castaneda
* E-email:       acastanedaa@worldbank.org
               
* Author:				 David Leonardo Vargas Mogollon
* E-email:       dvargasm@worldbank.org

* url:           https://github.com/randrescastaneda/pcn
* Dependencies:  The World Bank
----------------------------------------------------
Creation Date:      29 Jul 2019 - 09:18:01
Modification Date:  25 feb 2020 
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
	
	if regexm("`subcmd'", "^download") {
		local dldb  "gpwg pending wrk" // download databases
		if wordcount("`subcmd'") != 2 {
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
			local db: word 2 of `subcmd'
			local dldb_: subinstr local dldb " " "|", all
			
			if !(regexm(lower("`db'"), "`dldb_'")) {
				noi disp in red " Options available to download are "
				foreach db of local dldb {
					noi disp `"   `i' {c |}`db'"'
				}
				error
			}
		}
	}
	
	
	// ------------------------------------------------------------------------------
	// Download GPWG
	// -------------------------------------------------------------------------------
	
	if regexm("`subcmd'", "download[ ]+gpwg") {
		
		noi pcn_download_gpwg, countries(`countries') years(`years') /*
		*/ maindir("`maindir'")  `pause' `options'
		return add
		exit
	}
	
	//========================================================
	// Data in primus
	//========================================================
	
	if regexm("`subcmd'", "primus[ ]+approved") {
		if regexm("`options'", "down\(.*\)") {
			noi pcn_primus_download, countries(`countries') years(`years')  /*
			*/ status(approved) `pause' `options'
		}
		else if regexm("`options'", "load\(.*\)"){
			noi pcn_primus_load, s(approved) `pause' `options'
		}
		else err
		
		return add
		exit
	}
	
	if regexm("`subcmd'", "primus[ ]+pending") {
		if regexm("`options'", "down\(.*\)") {
			noi pcn_primus_download, countries(`countries') years(`years')  /*
			*/  status(pending) `pause' `options'
		}
		else if regexm("`options'", "load\(.*\)"){
			noi pcn_primus_load, s(pending) `pause' `options'
		}
		else err
		
		return add
		exit
	}
	
	//========================================================
	// Download wrk version data
	//========================================================
	if regexm("`subcmd'", "download[ ]+wrk") {
		local maindir "p:\01.PovcalNet\03.QA\02.PRIMUS\pending"
		noi pcn_download_wrk, countries(`countries') years(`years')  /*
		*/ `pause'  `options' maindir("`maindir'")
		return add
		exit
	}
	
	// -------------------------------------------------------------------------------
	// Load
	// -------------------------------------------------------------------------------
	
	if ("`subcmd'" == "load" | "`subcmd'" == "load[ ]+gpwg") {
		
		noi pcn_load, country(`countries') year(`years') type(`type')  /*
		*/ maindir("`maindir'") vermast(`vermast') veralt(`veralt')  /*
		*/ `pause'  `options'
		return add
		exit
	}
	
	//========================================================
	// load wrk version data
	//========================================================
	if regexm("`subcmd'", "load[ ]+wrk") {
		
		local maindir "p:\01.PovcalNet\03.QA\02.PRIMUS\pending"
		
		noi pcn_load_wrk, country(`countries') year(`years')  /*
		*/ maindir("`maindir'") vermast(`vermast')  /*
		*/ `pause' `clear' `options'
		return add
		exit
	}
	
	//========================================================
	// load estimates data
	//========================================================
	if regexm("`subcmd'", "load[ ]+estimates") {
		
		local maindir "p:\01.PovcalNet\03.QA\02.PRIMUS\pending"
		
		noi pcn_load_estimates, maindir("`maindir'") /*
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
		*/ `pause'  `options'
		return add
		exit
	}
	
	
	//========================================================
	// Group data
	//========================================================
	
	if inlist(lower("`subcmd'"), "group", "groupdata", "gd", "groupd") {
		
		noi pcn_groupdata, countries(`countries') years(`years') type(`type')  /*
		*/  vermast(`vermast') veralt(`veralt')  /*
		*/ `pause'  `options'
		return add
		exit
	}
	
	//========================================================
	// Update CPI
	//========================================================
	if regexm("`subcmd'", "update[ ]+cpi") {
		if !inlist("`c(username)'", "wb384996") {
			noi disp in r "You're not authorized to execute this command"
			error
		}
		
		noi pcn_update_cpi,  `pause' `options'
		return add
		exit
	}
	
	//========================================================
	// Load CPI
	//========================================================
	
	if regexm("`subcmd'", "load[ ]+cpi") {
		noi pcn_load_cpi,  `pause' `options'
		return add
		exit
	}
	
	
	//========================================================
	// Master File
	//========================================================
	if regexm("`subcmd'", "master") {
		if regexm("`options'", "update\(.*\)") {
			if !inlist("`c(username)'", "wb384996") {
				noi disp in r "You're not authorized to execute this command"
				error
			}
			
			noi pcn_master_update,  `pause' `options'
			return add
		}
		if regexm("`options'", "load\(.*\)") {
			noi pcn_master_load,  `pause' `options'
			return add
		}
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

//------------download

pcn download gpwg
pcn download pending
pcn download wrk
pcn update cpi
pcn master, update(gdp)
pcn master, update(pce)



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
