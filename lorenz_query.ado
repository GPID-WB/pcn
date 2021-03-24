/*==================================================
project:  Query data for lorenz curve
Author:   David L. Vargas
E-email:  dvaragsm@worldbank.org
url:
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:    23 Jul 2020
Modification Date:
Do-file version:    01
References:
Output:
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define lorenz_query, rclass
syntax [anything(name=subcommand)] ,  ///
COUNtry(string)						///
ppp(real)							///				
[                                   ///
server(string)						///
LEvel(string)						///
POVLine(real 1.90)					///
Year(string)							///
]
version 14

qui {
	*---------- conditions

	local str_opt "server country level" // A list of string options for some ease 

	// set all to lower case
	foreach optt of local str_opt{
		if ("``optt''"!="")		local `optt' = lower("``optt''")
	}

	// check the server, is it testing?
	if ("`server'" == "testing"){
		local root "http://wbgmsrech001/povcalnet-testing" 
	}
	else if ("`server'" == "int" | "`sever'" == "dev"){
		local root "http://wbgmsrech001/povcalnet" 
	}
	else if ("`server'" == "ar"){
		local root "http://wbgmsrech001/PovcalNet-AR/api" 
	}
	else{
		local root "http://iresearch.worldbank.org/PovcalNet"
	}

	// check the datalevel - Urban or Rural 
	if (inlist("`level'","rural")) {
		local lvl "1"
	}
	else {
		local lvl "2"
		local level "urban"
	}

	local country = upper("`country'")

	/*==================================================
	1: define queery
	==================================================*/

	local queery "`root'/Detail.aspx?Format=Detail&C0=`country'_`lvl'&PPP0=`ppp'&PL0=`povline'&Y0=`year'&NumOfCountries=1"

	/*==================================================
	1: queery data
	==================================================*/

	// Next line for testing proposes 
	*loc queery"http://iresearch.worldbank.org/PovcalNet/Detail.aspx?Format=Detail&C0=IND_1&PPP0=14.9752&PL0=1.90&Y0=1983&NumOfCountries=1%22"
	*loc queery "http://wbgmsrech001/povcalnet-AR/Detail.aspx?Format=Detail&C0=CHN_2&PPP0=3.0392219&PL0=1.9&Y0=1981&NumOfCountries=1"
	*loc queery "http://wbgmsrech001/PovcalNet-AR/api/Detail.aspx?Format=Detail&C0=CHN_2&PPP0=3.0392219&PL0=1.9&Y0=1981&NumOfCountries=1"
	
	scalar page = fileread(`"`queery'"')
	scalar page = subinstr(page, `"""', "",.)
	
	if regexm(page, "The server has encountered an error which prevents it from fulfilling your request.") {
		noi di "Server error  for `country' - `year' - `level'"
		error
	
	}
	/*==================================================
	1: Extract data
	==================================================*/

	/***** Dataset information *****/
	if regexm(page, "Economy: ([A-Z|a-z]+)")	 scalar countryname = regexs(1)
	if regexm(page, "Economy [a-z]ode: ([A-Z|a-z]+)") scalar country_code = regexs(1)
	if regexm(page, "Data Year: ([0-9]+)") scalar year = regexs(1)
	if regexm(page, "Coverage: ([A-Z|a-z]+)") scalar coverage = regexs(1)
	if regexm(page, "Welfare measurement: ([A-Z|a-z]+)") scalar data_type = regexs(1)
	if regexm(page, "Data source: ([A-Z|a-z]+_[A-Z|a-z|0-9]+)") scalar data_source = regexs(1)

	/***** General Quadratic Lorenz curve *****/
	if regexm(page, "Quadratic Lorenz curve(.+)Beta Lorenz curve") scalar GQ = regexs(1)
	/***** Beta Lorenz curve *****/
	if regexm(page, "Beta Lorenz curve(.+)Final Result") scalar beta = regexs(1)
	/***** Final result *****/
	if regexm(page, "Final Result(.+)</pre>") scalar final = regexs(1)

	/***** Extraction coefficients *****/

	/** Lorenz curve **/
	foreach sec in GQ beta final {
		// - coefficients - //
		if regexm(`sec'," A[ ]+([0-9|\.|-]+)") scalar `sec'c_A = regexs(1)
		if regexm(`sec'," B[ ]+([0-9|\.|-]+)") scalar `sec'c_B = regexs(1)
		if regexm(`sec'," C[ ]+([0-9|\.|-]+)") scalar `sec'c_C = regexs(1)
		
		if ("`sec'" == "beta"){
			if regexm(`sec'," Theta:[ ]+([0-9|\.|-]+)") scalar `sec'_theta = regexs(1)
			if regexm(`sec'," Gamma:[ ]+([0-9|\.|-]+)") scalar `sec'_gamma = regexs(1)
			if regexm(`sec'," Delta:[ ]+([0-9|\.|-]+)") scalar `sec'_delta = regexs(1)
		}

		// - summary - //
		if regexm(`sec'," Mean:[ ]+([0-9|\.|-]+)") scalar `sec'_mean = regexs(1)
		if regexm(`sec'," Validity of lorenz curve:[ ]+([A-Z|a-z]+)") scalar `sec'_validity = regexs(1)
		if regexm(`sec'," Normality of poverty estimate:[ ]+([A-Z|a-z]+)") scalar `sec'_normal = regexs(1)

		// - Distributional Estimation - //
		if regexm(`sec'," Gini index\(%\):[ ]+([0-9|\.|-]+)") scalar `sec'_gini = regexs(1)
		if regexm(`sec'," median income\(or expenditure\):[ ]+([0-9|\.|-]+)") scalar `sec'_median = regexs(1)
		if regexm(`sec'," MLD index:[ ]+([0-9|\.|-]+)") scalar `sec'_MLD = regexs(1)
		if regexm(`sec'," polarization index\(%\):[ ]+([0-9|\.|-]+)") scalar `sec'_polar = regexs(1)
		if regexm(`sec'," distribution corrected mean:[ ]+([0-9|\.|-]+)") scalar `sec'_dcmean = regexs(1)
		if regexm(`sec'," mean income/expenditure of the poorest 50%:[ ]+([0-9|\.|-]+)") scalar `sec'_mean50 = regexs(1)
		
		// - Deciles - //
		if regexm(`sec'," Decile \(%\) [-]+(.+)[-]+ P") scalar `sec'_deciles = regexs(1)
		if regexm(`sec'_deciles,"([0-9][0-9|\.| ]+)") scalar `sec'_deciles = regexs(1)
		loc i = 0
		foreach dc in `=scalar(GQ_deciles)'{
			loc ++i
			scalar `sec'_dec_`i' = `dc'
		}
		
		// - Poverty Estimates - //
		if regexm(`sec'," Poverty line:[ ]+([0-9|\.|-]+)") scalar `sec'_povl = regexs(1)
		if regexm(`sec'," Headcount\(HC\):[ ]+([0-9|\.|-]+)") scalar `sec'_hc = regexs(1)
		if regexm(`sec'," Poverty gap \(PG\):[ ]+([0-9|\.|-]+)") scalar `sec'_povg = regexs(1)
		if regexm(`sec'," PG squared \(FGT2\):[ ]+([0-9|\.|-]+)") scalar `sec'_povgsq = regexs(1)
		if regexm(`sec'," Watt index:[ ]+([0-9|\.|-]+)") scalar `sec'_watt = regexs(1)
	}
	
	/** Final **/
	if regexm(final,"Distributional estimates use[ ]+([A-Z|a-z]+) ") scalar fdise = regexs(1)
	if regexm(final,"Poverty estimates use[ ]+([A-Z|a-z]+) ") scalar fpove = regexs(1)
		
	/*==================================================
	4: return values
	==================================================*/
	return local query = "`queery'"
	
	foreach s in countryname country_code coverage data_type data_source{
		return local `s' = "`=scalar(`s')'"
		loc scalars = "`scalars' `s'"
	}
	
	foreach s in year{
		return scalar `s' = `=scalar(`s')'
		loc scalars = "`scalars' `s'"
	}
	
	
	foreach sec in GQ beta final{
	
		if ("`sec'" != "final"){
			return scalar `sec'coeffA = `=scalar(`sec'c_A)'
			return scalar `sec'coeffB = `=scalar(`sec'c_B)'
			return scalar `sec'coeffC = `=scalar(`sec'c_C)'
			loc scalars = "`scalars' `sec'coeffA `sec'coeffB `sec'coeffC"
		}
		
		if ("`sec'" == "beta"){
			return scalar `sec'theta = `=scalar(`sec'_theta)'
			return scalar `sec'delta = `=scalar(`sec'_delta)'
			return scalar `sec'gamma = `=scalar(`sec'_gamma)'
			loc scalars = "`scalars' `sec'theta `sec'delta `sec'gamma"
		}
		
		return scalar `sec'mean = 	       `=scalar(`sec'_mean)'
		return local `sec'validity =       "`=scalar(`sec'_validity)'"
		return local `sec'normality =      "`=scalar(`sec'_normal)'"
		return scalar `sec'gini =          `=scalar(`sec'_gini)'
		return scalar `sec'median =        `=scalar(`sec'_median)'
		return scalar `sec'mld =           `=scalar(`sec'_MLD)'
		return scalar `sec'polarization =   `=scalar(`sec'_polar)'
		return scalar `sec'mean_bottomhalf = `=scalar(`sec'_mean50)'
		
		forv i = 1/10{
			return scalar `sec'decile`i' = `=scalar(`sec'_dec_`i')'
			loc scalars = "`scalars' `sec'decile`i'"
		}
		
		return scalar `sec'povertyline = `=scalar(`sec'_povl)'
		return scalar `sec'headcount = `=scalar(`sec'_hc)'
		return scalar `sec'povertygap = `=scalar(`sec'_povg)'
		return scalar `sec'pgsqd = `=scalar(`sec'_povgsq)'
		return scalar `sec'watt = `=scalar(`sec'_watt)'
		
		// local with a list of the scalars 
		loc scalars = "`scalars' `sec'mean `sec'validity `sec'normality `sec'gini `sec'median `sec'mld `sec'polarization `sec'mean_bottomhalf `sec'povertyline `sec'headcount `sec'povertygap `sec'pgsqd `sec'watt"
	}

	
	return local distestimate = "`=scalar(fdise)'"
	return local povestimate = "`=scalar(fpove)'"
	return scalar ppp = `ppp'
	loc scalars = "`scalars' distestimate povestimate ppp" 
	
	return local returned "`scalars'"
	
} // end qui


end
exit
/* End of do-file */

/* some testing
lorenz_query, country(CHN) year(2002) ppp(3.69611) level(rural)
return list