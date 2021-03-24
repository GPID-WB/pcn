{smcl}
{* *! version 1.0.0 15march2021}{...}
{cmd:help pcn_synth} {right: WB:PovcalNet Team}{* {right: ({browse "some link":SJ: ???})}}
{hline}
{center: Inequality Synthetics - pcn_synth}
{hline}

{p2colset 10 17 16 2}{...}
{p2col:{cmd:pcn_synth}}PIP command to create synthetic distributions{p_end}

{p 4 4 2}{bf:{ul:Description (short)}}{p_end}
{p 4 4 2}
The {cmd:pcn_synth} command, allows Stata users to generate synthetic distributions using povcalnet's fitted lorenz curves{p_end}

{hline}

{marker description}{...}
{title:Description}

{pstd}
The {cmd:pcn_synth} command allows Stata users to
generate with synthetic distributions using povcalnet's fitted lorenz curves{p_end}

{center:(Go up to {it:{help pcn_synth##sections:Sections Menu}})}


{marker syntax}{...}
{title:Overall Syntax}

{p 4 4 2}
The {cmd:pcn_synth} subcommand syntax is as follows:{p_end}

{p 8 17 2}
{cmdab:pcn_synth:} {cmd:,} {opt country(3-letter code)} {opt year(numlist)} [parameters options]
	
{p 4 4 2} 
The different options and parameters may be described:

{col 5}Option{col 30}Description
{space 4}{hline}

{p2col:{opt country(3-letter code):}} Single 3-letter code.{p_end}
{p2col:{opt pppyear(####):}} PPP year to be used. [povcalnet]{p_end}
{p2col:{opt ppp(real):}} PPP to be used.{p_end}
{p2col:{opt natppp:}}[selected subcommands] Uses national PPPs insted of urban and rural.{p_end}
{p2col:{opt year(numlist):}} Years to query. A numlist per country is allowed, they must be separared by a comma ","{p_end}
{p2col:{opt povline(real):}} Poverty line to be used.{p_end}
{p2col:{opt level(string):}} Call a particular level: urban or rural{p_end}
{p2col:{opt server(string):}}[Only for povcalnet] PovcalNet server to be used.{p_end}
{p2col:{opt platform(string):}}Platform used to get ppp and population numbers. Either "pcn" or "pip". Default "pip"{p_end}
{p2col:{opt SO:bs(integer):}}Number of observations per level. Default 100,000{p_end}
{p2col:{opt addvar(varlist):}}Keep an set of additional variables{p_end}
{p2col:{opt allvars:}}Keep all additional variables{p_end}
{p2col:{opt version:(string)}} [pcn only] PPP and population data vintage to be used{p_end}
{space 4}{hline}
{p 4 4 2}
	
{center:{hline 16}}
{center:{bf:Examples}}
{center:{hline 16}}

{p 4 4 2}
{bf: Note: pcn_synth} requires {help missings:missings}, {help pcn:pcn} 
and/or {help pip:pip}. [Notice: {help datalibweb:datalibweb}
may require World Bank internal resources]

{p 4 4 2}
One of the most simple queries possible is only setting a country and a ppp:{p_end}

{phang2}
{stata pcn_synth, countries(CHN) years(1981) natppp}

{p 4 4 2}
A pcn query:{p_end}

{phang2}
{stata pcn_synth, countries(CHN) years(1981) platform(pcn) addvar(coveragetype) natppp}

{center:(Go up to {it:{help pcn_synth##sections:Sections Menu}})}
{center:(Go up to {it:{help pcn_synth##sections:Sections Menu}})}


{marker contact}{...}
{title:Contact}
{pstd}
Any comments, suggestions, or bugs can be reported in the 
{browse "https://github.com/worldbank/pipdp_synth_unique/issues":GitHub issues page}.
All the files are available in the {browse "https://github.com/worldbank/pipdp_synth_unique":GitHub repository}

{title:Author}
{p 4 4 4}R.Andres Castaneda, The World Bank{p_end}
{p 6 6 4}Email {browse "acastanedaa@worldbank.org":acastanedaa@worldbank.org}{p_end}
{p 6 6 4}GitHub: {browse "https://github.com/randrescastaneda":randrescastaneda }{p_end}

{title:Maintainer}