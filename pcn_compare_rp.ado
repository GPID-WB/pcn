/*==================================================
project:       graph pcn compare results
Author:        David L. Vargas
E-email:       dvargasm@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    15 Jun 2020 - 12:41:59
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
program define pcn_compare_rp, rclass
syntax  [anything(name=subcmd id="subcommand")], ///
[                                              ///
server(string)                                  ///
VARiables(string)                               ///
DIRSave(string)								  ///
SDLevel(string)								  ///
TOLerance(integer 3)                           /// decimal places
]

version 16


//========================================================
// Start
//========================================================

	/*================================================
	1: Check options definition and declare macros
	==================================================*/
	// Check for sepscatter packg
	cap which sepscatter
	if (_rc) noi ssc install sepscatter
	
	cap which confirmdir
	if (_rc) noi ssc install confirmdir
	
	// relevant macros 
	if ("`variables'"=="") loc variables = "headcount"
	else                  loc variables = lower("`variables'")
	
	if ("`server'" == "") loc server "AR"
	else                  loc server = lower("`server'")
	
	if ("`sdlevel'" == "") loc sdlevel = 2
	
	cap loc sdlevel = real("`sdlevel'")
	if (_rc){
		noi di as err "The SD level must be a real number" char(10)
		noi di "SD level set to default"
	}
	
	if ("`dirsave'" != "") {
		if (lower("`dirsave'") == "wd")   loc dirsave "`c(pwd)'"
		else                       confirmdir "`dirsave'"
	}
	else{
	noi dis as err "No saving directory specified. STOP" char(10) as text "Either provide a directory or set dirsave(wd) to use working directory."
	err
	}
	
	/*================================================
	2: Get comparison data and graphs
	==================================================*/

	pcn compare, mainv(`variables') server(`server') check("main")
	pcn_compare_gr, variables(`variables') dirsave(`dirsave') ///
	   sdlevel(`sdlevel') tolerance(`tolerance')

	/*================================================
	3: Report 
	==================================================*/
	putdocx begin

	// Add a title
	putdocx paragraph, style(Title) 
	putdocx text ("Report: Current vs Testing Povcalnet")
	
	putdocx paragraph
	putdocx text ("This report compares the currently publish povacalnet to the unpublish version on the testing server. This file was generated by the PCN command, with the following user given conditions:"), linebreak(1)
	putdocx text ("- variables: `variables'"), linebreak(1)
	putdocx text ("- server: `server'"), linebreak(1)
	putdocx text ("- SD level: `sdlevel'"), linebreak(1)
	putdocx text ("- Decimal points tolerance: `tolerance'"), linebreak(1)
	
	// Overview
	putdocx paragraph, style(Heading1)
	putdocx text ("Overview of changes")
	
	putdocx paragraph
	putdocx text ("The `_N' year-country points, have the following status:"), linebreak(1)
	
	preserve
	contract status	
	rename _freq occurences
	putdocx table mytable = data(status _freq), varnames width(50%)
	restore
	
	
	// by variable
	putdocx text ("Analysing by varible we have the following"), linebreak(1)
	
	foreach v of local variables{
	putdocx paragraph, style(Heading1)
	putdocx text ("Changes on `var'")
	
	putdocx paragraph
	putdocx text ("The `_N' year-country points, have the following status:"), linebreak(1)
	
	}
	
	
	
	
	
	
	
	
	putdocx save "`dirsave'/pcn_report.docx", replace
	
end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:

cd "C:\Users\wb562350\OneDrive - WBG\Desktop"
pcn_compare_rp, dirs(wd)

