/*==================================================
project:       graph pcn compare results
Author:        R.Andres Castaneda Aguilar 
E-email:       acastanedaa@worldbank.org
url:           
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    13 Jun 2020 - 17:41:59
Modification Date:   
Do-file version:    01
References:          
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
program define pcn_compare_gr, rclass
syntax  [anything(name=subcmd id="subcommand")], ///
[                                              ///	
VARiables(string)                                ///
DIRSave(string)								   ///
SDLevel(string)										///
*FILESave(string)							   	   ///					
]

version 15


//========================================================
// Start
//========================================================

qui { 

	/*================================================
	1: Check options definition and declare macros
	==================================================*/
	// Check for sepscatter packg
	cap which sepscatter
	if (_rc) noi ssc install sepscatter
	
	cap which confirmdir
	if (_rc) noi ssc install confirmdir
	
	// check proper variables definition 
	if ("`variables'"=="") loc variables = "headcount"
	
	foreach var of local variables{
		confirm var `var'
	}
	
	// Save directory
	if ("`dirsave'" != "") {
		confirmdir "`dirsave'"
	}
	else{
	noi dis as err "Warning: no saving directory specified" char(10) as text "plots will be only kept on memory"
	loc filesave = "no"
	}
	
	// htsd 
	
	if ("`sdlevel'" == "") loc sdlevel = 2
	
	cap loc sdlevel = real("`sdlevel'")
	if (_rc){
		noi di as err "The SD level must be a real number" char(10)
		noi di "SD level set to default"
	}
	
	// file save
	*loc filesave = lower("`filesave'")
	*if ("`filesave'" == "") loc filesave = "no"
	

	/*================================================
	2: Organize data 
	==================================================*/
	
	foreach var of local variables{
	
		foreach v in mn_d_`var' sd_d_`var'{
			cap drop `v'
		}

		bysort regioncode: egen mn_d_`var' = mean(d_`var')
		bysort regioncode: egen sd_d_`var' = sd(d_`var')

		forv x = 1/`sdlevel' {
			// higher than variables
			cap drop ht_`x'sd_`var'
			gen ht_`x'sd_`var' = abs(d_`var') > (mn_d_`var' +   `x'*sd_d_`var')
			tab ht_`x'sd_`var'
		}

		forv x = 1/`sdlevel' {
			// higher than variables
			tab regioncode ht_`x'sd_`var'
		}
		
		/*================================================
		2: Plotting
		==================================================*/
		
		local ifht "if ht_`sdlevel'sd_`var'  == 1"
		
		histogram d_`var' `ifht', name(hist_d_`var', replace)
		noi di as result "hist_d_`var' saved on memory"

		histogram d_`var'  `ifht', ///
		by(region, title("Frequency of difference in `var'")) ///
			bin(10) freq note("") name(histR_d_`var', replace)
		noi di as result "histR_d_`var' saved on memory"

		sepscatter  `var' test_`var'  `ifht',  separate(regioncode) ///
			addplot(function y=x)  legend(pos(11) col(2) ring(0))  ///
			 name(sc_`var', replace)
		noi di as result "sc_`var' saved on memory"
	
		if ("`dirsave'"!=""){
			graph export "`dirsave'/hist_d_`var'.png", name(hist_d_`var') as(png) replace
			graph export "`dirsave'/histR_d_`var'.png", name(histR_d_`var') as(png) replace
			graph export "`dirsave'/sc_`var'.png", name(sc_`var') as(png) replace
		}
	}
	
} // end qui
end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


