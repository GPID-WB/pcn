/*==================================================
project:       create comparability database
Author:        David L. Vargas
E-email:       dvargasm@worldbank.org
url:
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     2020-05-14  
Do-file version:    01
References:
Output:
==================================================*/

/*========================================================
 0: Program set up
========================================================*/

program define pcn_compare, rclass
syntax [anything(name=subcmd id="subcommand")], ///
[                                             ///
IDvar(string)                                  ///
MAINv(string)                                  ///
server(string)                                 ///
DISVar(string)                                 ///
check(string)                                  ///
POVline(string)                                 ///
]

version 14

*---------- pause
if ("`pause'" == "pause") pause on
else                      pause off

//========================================================
// Start
//========================================================

qui { 

/*================================================
1: Check options definition and declare macros
==================================================*/

// relevant macros 
if ("`idvar'" == "") loc idvar "countrycode year povertyline coveragetype datatype"
else 				 loc idvar = lower("`idvar'")

if ("`mainv'" == "")  loc mainv "ppp mean headcount"
else                  loc mainvar = lower("`mainv'")

if ("`server'" == "") loc server "AR"
else                  loc server = lower("`server'")

if ("`check'" == "") loc check "all"
else                 loc check = lower("`check'")

if ("`disvar'" == "") loc disvar "all"
else                 loc disvar = lower("`disvar'")

if !inlist("`check'","main","all") {
    noi di as err "Check varibables must be set to: main or all"
	noi di as text "Check option forced to default"
	loc check "all"
}

if !inlist("`disvar'","diff","main","all") {
    noi di as err "Check varibables must be set to: main, diff or all"
	noi di as text "Check option forced to default"
	loc check "all"
}

/*================================================
2: Get data
==================================================*/

// get testing data
povcalnet, server(`server') povline(`povline') clear

cap isid `idvar'
if _rc {
	duplicates tag `idvar', gen(duplicate)
	keep if duplicate > 0
	lab var duplicate "Number of duplicities in case"
	noi di as err "The testing server has unnexpected duplicates" char(10)  as text "The process has stop, no duplicities should exist, check" char(10) as result "The data on memory contains the cases with duplicates"	
	noi tab duplicate
	qui err 459
	exit
}

if ("`check'" == "main"){
    keep `idvar' `mainv'
}

tempfile serverd
save `serverd'

// Get current data
povcalnet, povline(`povline') clear 

if ("`check'" == "main"){
    keep `idvar' `mainv'
}

tempfile PCN
save `PCN'

// Determine point status
merge 1:1 `idvar' using `serverd', update gen(status)

keep `idvar' status
lab define statusl 1 "Dropped" 2 "New point" 3 "Unchanged" 4 "Udpade from missing" 5 "Changed (conflict)"
lab values status statusl

preserve 

/*================================================
3: Trace back changes                             
==================================================*/

keep if inlist(status,4,5)

merge 1:1 `idvar' using `serverd', keep(match) nogen

loc vlist 
loc vlistt
foreach var of varlist _all {
	if (!regexm("`idvar'","`var'") & "`var'" != "status"){
		cap confirm string var `var'
		if _rc {
			loc vlab: var label `var'
			rename `var' test_`var'
			lab var test_`var' "Testing: `vlab'"
			loc vlist "`vlist' `var'"
			loc vlistt "`vlistt' test_`var'"
			loc tvlist "`tvlist' `var' test_`var'"
		}
		else{
			drop `var'
		}
	}
}

merge 1:1 `idvar' using `PCN', keep(match) nogen

keep `idvar' status `vlist' `vlistt'

// difference in main values

if ("`mainv'" == "all")  loc mainv "`vlist'"

loc dvars
foreach var of local mainv{
	cap confirm var `var'
	if (_rc == 0){
		gen d_`var' = `var' - test_`var'
		lab var d_`var' "difference in `var'"
		loc dvars "`dvars' d_`var'"
		loc mcall "`var' test_`var'"
	}
}

tempfile changes
save `changes'

restore 


// join to get the final dataset 
merge 1:1 `idvar' using `changes', nogen

order `idvar' status `dvars' `tvlist'

if ("`disvar'" != "all") {
    if ("`disvar'" == "diff") {
	    keep `idvar' status `dvars'
	}
	if ("`disvar'" == "main"){
	    keep `idvar' status `dvars' `mcall'
	}
}

/*================================================
4: Report results and return values
==================================================*/

// report back to user
noi di as text "The status of observations is as follows:"
noi tab status
noi di as result "Comparison data load in memory"

}

end
exit