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
[]

version 15


/*==================================================
              1: 
==================================================*/


cap which sepscatter
if (_rc) ssc install sepscatter

global var = "headcount"

bysort regioncode: egen mn_d_${var} = mean(d_${var})
bysort regioncode: egen sd_d_${var} = sd(d_${var})

foreach x in 1 2 3 {
	// higher than variables
	gen ht_`x'sd = abs(d_${var}) > (mn_d_${var} +   `x'*sd_d_${var})
	tab ht_`x'sd
}

foreach x in 1 2 3 {
	// higher than variables
	tab regioncode ht_`x'sd 
}

global ifht "if ht_2sd  == 1"

histogram d_${var}  ${ifht}

histogram d_headcount  ${ifht}, ///
by(region, title("Frequency of difference in ${var}")) ///
	bin(10) freq note("")

sepscatter  ${var} test_${var}  ${ifht},  separate(regioncode) ///
    addplot(function y=x)  legend(pos(11) col(2) ring(0))  
		

* tw  (scatter ${var} test_${var} ) ///
    * (function y=x, range(0 1))   ${ifht}

* tw  (scatter ${var} test_${var}, by(regioncode) ) ///
    * (function y=x, range(0 1))  ${ifht}




/*==================================================
              2: 
==================================================*/


/*==================================================
              3: 
==================================================*/





end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


