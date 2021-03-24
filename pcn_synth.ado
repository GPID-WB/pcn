/*==================================================
project:  create synthetic files
Author:   David L. Vargas
E-email:  dvaragsm@worldbank.org
url:
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    March 2020
Modification Date:
Do-file version:    01
References:
Output:
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pcn_synth, rclass
syntax [anything(name=subcommand)] ,  ///
COUNtry(string)						///
Year(string)							///
[                                   ///
platform(string)						///
ppp(string)							///				
pppyear(string)						///	
natppp								///			
server(string)						///
POVLine(real 1.90)					///
SObs(integer 100000)					///
addvar(string)						///
allvars								///
version(string)						///
]
version 14

qui {
drop _all

	*---------- conditions

	// -- country -- //
	loc country = upper("`country'")
	
	// check number of year and country make senses
	if (wordcount("`country'") != 1){
		noi di as error "Only one country can be set at a time"
		error
	}
	if (wordcount("`year'") != 1){
		noi di as error "only one year can be set at a time"
		error
	}
	
	// ppp year
	if ("`pppyear'" == "")	loc pppyear = "2011"
	
	// lorenz query options 
	if ("`server'" != "")	loc servercall = "server(`server')"
	if ("`povline'" != "")	loc povlinecall = "povline(`povline')"
	
	/*==================================================
	1: get ppp - population
	==================================================*/
	
	if ("`ppp'" == "") 			loc ivs "ppp population"
	else if ("`natppp'" != "")	loc ivs "population"	
	else						loc ivs "population"					
	
	if ("`platform'" == "pcn"){
		foreach iv in `ivs'{
			pcn master, load(`iv') version(`version')

			keep if inlist(countrycode, "`country'")
			drop if coveragetype == "National"
			
			if ("`iv'" == "ppp"){
				rename ppp`pppyear' ppp
			}
			else {
				if ("`iv'" == "population" & "`country'" == "IND" & "`year'" == "1987"){
					keep if inlist(year, 1987, 1988)
					tempvar _temp
					bys coveragetype: egen `_temp' = mean(population)
					replace population = `_temp'
				}
				
				keep if year == `year'
					
			}
			
			keep countrycode coveragetype `iv'
			
			levelsof coveragetype if countrycode == "`country'", local(cover)
			foreach cv of local cover{
				levelsof `iv' if countrycode == "`country'" & coveragetype == "`cv'", local(val)
				loc cvl = substr("`cv'", 1,1)
				scalar `iv'_`cvl' = `val'
			}
		}
		
		// if national PPPs
		if ("`natppp'" != ""){
			pcn master, load(ppp) version(`version')
			
			keep if inlist(countrycode, "`country'")
			keep if coveragetype == "National"
			rename ppp`pppyear' ppp
			keep countrycode coveragetype ppp
			
			foreach cv of local cover{
				levelsof ppp if countrycode == "`country'", local(val)
				loc cvl = substr("`cv'", 1,1)
				scalar ppp_`cvl' = `val'
			}
			
		}

		drop _all
	}
	else{
		loc ivs = subinstr("`ivs'", "population", "pop", .)
		foreach iv in `ivs'{
			pip_aux_load, load(`iv') version(`version') clear
			drop if `iv' == .
			tostring `iv'_domain, replace
			tostring `iv'_data_level, replace
			drop if `iv'_domain == "1" // drop if national
			keep if inlist(country_code, "`country'")
			
			if ("`iv'" == "pop")	loc ivn "population"
			else					loc ivn "`iv'"
			
			if ("`iv'" == "ppp"){
				keep if ppp_default == 1
			}
			else {
				if ("`iv'" == "pop" & "`country'" == "IND" & "`year'" == "1987"){
						keep if inlist(year, 1987, 1988)
						tempvar _temp
						bys `iv'_data_level: egen `_temp' = mean(pop)
						replace pop = `_temp'
				}
					
				keep if year == `year'
			}
			
			keep country_code `iv'_data_level `iv'_domain `iv' 
			
			// this should be tiddier from data ask A.C.
			cap replace `iv'_data_level = "rural" if `iv'_data_level == "0"
			cap replace `iv'_data_level = "urban" if `iv'_data_level == "1"
			
			levelsof `iv'_data_level if country_code == "`country'", local(cover)
			foreach cv of local cover{
				levelsof `iv' if country_code == "`country'" & `iv'_data_level == "`cv'", local(val)
				loc cvl = substr("`cv'", 1,1)
				scalar `ivn'_`cvl' = `val'
			}
		}
		
		// if national PPPs
		if  ("`natppp'" != ""){
			pipdp_aux_load, load(ppp) version(`version') clear
			drop if ppp == .
			keep if inlist(country_code, "`country'")
			keep if ppp_default == 1
			keep country_code ppp_data_level ppp
			
			keep if ppp_data_level == "national"
			
			*levelsof ppp_data_level if country_code == "`country'", local(cover)
			foreach cv of local cover{
				levelsof ppp if country_code == "`country'", local(val)
				loc cvl = substr("`cv'", 1,1)
				scalar ppp_`cvl' = `val'
			}	
		}		
		
		drop _all	
	}
	
	/*==================================================
	3: query lorenz parameters
	==================================================*/
	foreach cv of local cover{
		loc cvl = substr("`cv'", 1,1) // level_sufix
		
		if ("`ppp'" != "") 		scalar ppp_`cvl' = `ppp'
		
		// Actual query
		cap lorenz_query, country(`country') year(`year') ///
					ppp(`=scalar(ppp_`cvl')') level(`cv') ///
					`servercall' `povlinecall'
		
		if _rc {
			noi di as error "Error while querying data from the server"
			error
		}
		
		// parameters store
		foreach v in `r(returned)'{
			scalar `v'_`cvl' = "`r(`v')'"		
		}
		
		loc parameters = "`r(returned)'"
		
	}
	
	/*==================================================
	4: Slope parameters
	==================================================*/
	foreach cv of local cover{
		loc cvl = substr("`cv'", 1,1) // level_sufix
		
		// - Create parameters to calculate the slope of the GQ lorenz curve 
		scalar e_`cvl' = -(`=scalar(GQcoeffA_`cvl')' + `=scalar(GQcoeffB_`cvl')' + `=scalar(GQcoeffC_`cvl')' + 1)
		scalar m_`cvl' = (`=scalar(GQcoeffB_`cvl')')^2 - 4*`=scalar(GQcoeffA_`cvl')'
		scalar n_`cvl' =2*`=scalar(GQcoeffB_`cvl')'*`=scalar(e_`cvl')'-4*`=scalar(GQcoeffC_`cvl')'
		scalar r_`cvl' =((`=scalar(n_`cvl')')^2-4*`=scalar(m_`cvl')'*((`=scalar(e_`cvl')')^2))^(0.5)
		
		// - Convert GQ mean from monthly to daily 
		scalar GQmean_`cvl' = `=scalar(GQmean_`cvl')' * 12 / 365
		scalar betamean_`cvl' = `=scalar(betamean_`cvl')' * 12 / 365
	}
	
	/*==================================================
	5: Simulation 
	==================================================*/
	
	// --- simulation by coveragetype --- //
	foreach cv of local cover{
		
		// cumulative distribution
		clear
		set type double
		set seed 12345

		scalar nobs=100000
		scalar first=1/(2*`=nobs')
		scalar last=1-(1/(2*`=nobs'))
		set obs `=nobs'                 
		range _F  `=first' `=last'

		
		loc cvl = substr("`cv'", 1,1) // level_sufix	
		tempfile simul_`cvl'
		
		//-- vars form lorenz query --//
		gen countrycode = "`=scalar(country_code_`cvl')'"
		gen year = `=scalar(year_`cvl')'
		gen coveragetype = "`=scalar(coverage_`cvl')'"
		gen distestimate =  "`=scalar(distestimate_`cvl')'"
			
		// -- Slope calulations -- //
		
		** Calculate the slope of GQ lorenz curve and income (= mu * slope of LC)
		gen double x_F_GQ = `=scalar(GQmean_`cvl')'*(-(`=scalar(GQcoeffB_`cvl')')/2 -(2*`=scalar(m_`cvl')'*(_F)+`=scalar(n_`cvl')')*(`=scalar(m_`cvl')'*(_F)^2+`=scalar(n_`cvl')'*(_F)+(`=scalar(e_`cvl')')^2)^(-0.5)/4)
		
		* Calculate the slope of beta lorenz curve and income (= mu * slope of LC)
		gen double x_F_beta = `=scalar(betamean_`cvl')'*(1-`=scalar(betatheta_`cvl')'*((_F)^`=scalar(betagamma_`cvl')')*((1-(_F))^`=scalar(betadelta_`cvl')')*((`=scalar(betagamma_`cvl')'/(_F)) - (`=scalar(betadelta_`cvl')'/(1-(_F)))))
		
		// -- Add population -- //
		gen population = `=scalar(population_`cvl')'*10
		
		save `simul_`cvl'', replace
	}
	
	// append simulations
	clear
	loc i = 0
	foreach cv of local cover{
		loc cvl = substr("`cv'", 1,1) // level_sufix
		loc ++i
		if ("`i'" == "1")	use `simul_`cvl'', clear
		else 				append using `simul_`cvl''
	}
	
	// destring 
	destring, replace
	
	// -- Define welfare -- //
	gen double welfare = .
	replace welfare = x_F_GQ if distestimate == "GQ"  
	replace welfare = x_F_beta if distestimate == "Beta"
	
	// -- keep only welfare and weights -- //	
	if ("`allvars'" == ""){
	keep welfare population `addvar'
	}
	rename population weight
	
	
	
	/*=========================================
	6. return parameters
	==========================================*/
	
	// parameters store
	foreach v in `parameters' {	
		foreach cv of local cover{
			loc cvl = substr("`cv'", 1,1)
			cap confirm number `v'_`cvl'
			if _rc{
				return local `v'_`cvl' = "`=scalar(`v'_`cvl')'"
			}
			else{
				return scalar `v'_`cvl' = `=scalar(`v'_`cvl')'
			}
		}
	}
	
	
	

		/*local filename  = "`country'_`year'"
		return local survin    = "`country'_`year'_synth"
		return local survid    = "`country'_`year'_synth"
		return local survey_id = "`country'_`year'_synth"
		return local surdir    = "P:/01.PovcalNet/01.Vintage_control/`country'/`country'_`year'_synth"
		*/
} // end qui
end
exit
/* End of do-file */

* some testing */

*synth_distribution, country(CHN) year(2002)