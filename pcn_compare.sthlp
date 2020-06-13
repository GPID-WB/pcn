{smcl}
{* *! version 1.0.0 8jan2020}{...}
{cmd:help pcn}{right: WB:PovcalNet Team}{* {right: ({browse "some link":SJ: ???})}}
{hline}

{vieweralsosee "" "--"}{...}
{vieweralsosee "Install wbopendata" "ssc install wbopendata"}{...}
{vieweralsosee "Help wbopendata (if installed)" "help wbopendata"}{...}
{viewerjumpto   "Command description"   "pcn_full##desc"}{...}
{viewerjumpto "Parameters description"   "pcn_full##param"}{...}
{viewerjumpto "Options description"   "pcn_full##options"}{...}
{viewerjumpto "Subcommands"   "pcn_full##subcommands"}{...}
{viewerjumpto "Stored results"   "pcn_full##return"}{...}
{viewerjumpto "Examples"   "pcn_full##Examples"}{...}
{viewerjumpto "Disclaimer"   "pcn_full##disclaimer"}{...}
{viewerjumpto "How to cite"   "pcn_full##howtocite"}{...}
{viewerjumpto "References"   "pcn_full##references"}{...}
{viewerjumpto "Acknowledgements"   "pcn_full##acknowled"}{...}
{viewerjumpto "Authors"   "pcn_full##authors"}{...}
{viewerjumpto "Regions" "pcn_countries##regions"}{...}
{viewerjumpto "Countries" "pcn_countries##countries"}{...}
{center:{cmd:pcn} {hline 2} Stata package to manage {ul:{it:PovcalNet}} files and folders.}

{center:{bf:pcn compare}}

{hline}
{center:({help pcn:Go back to Intro page})}


{p2colset 5 30 29 2}{...}
{p 4 4 2}
The {cmd:compare} subcommand allows to compare the current povcalnet with
 the version on the testing server. It reports back to the user the status
 of the points; whether it was dropped, is a new point, is unchanged,
 changed a value from a missing or changed a non-missing value. Also, a
 comparison dataset is loaded, which contains the status information for
 each point. 
{p_end}


{p 4 4 2}
Please keep in mind the following structure:{p_end}

{p 8 17 2}
{cmdab:pcn:} compare, {it:Options}

{col 5}Option{col 30}Description
{space 4}{hline}
	{p2col:{opt id:var(varlist)}} List of variables that identify each single observation. 
	By default countrycode, year, povertyline, coveragetype and datatype are used. {p_end}
	{p2col:{opt main:v(varlist)}} List of variables of special interest. The comparison dataset contains the difference of current minus testing for these variables.
	By default {it:headcount} is used.{p_end}
	{p2col:{opt dis:var(diff|main|all)}} Variables to display in the comparability dataset. 
	Three options are available: diff, main and all. If all is set all variables are shown, 
	if diff is set only the differences are shown,
	and if main is set only the main variables and their differences are shown.
  Default is {it:main}{p_end}
	{p2col:{opt check(main|all)}} Determines which variables are check for changes.
	If main is set only checks for changes in the main variables, otherwise if all is set checks for changes in any variable.{p_end}
	{p2col:{opt pov:line(list)}}Poverty lines to be used on the povacalnet query. The 1.9 line is set to default.{p_end}
	{p2col:{opt server(string)}}Server to be used. By default the AR server is employed. {p_end}
{space 4}{hline}
{p 4 4 2}

{center:{hline 16}}
{center:{bf:Examples}}
{center:{hline 16}}

{space 4}{hline 15}

{p 4 4 2}
Check differences between the current and the AR server,
using the defauls:{p_end}

{phang2}
{stata pcn compare}

{p 4 4 2}
Using a different server:{p_end}

{phang2}
{stata pcn compare, server(testing)}

{p 5 4 2}
Setting only ppp as main variable:

{phang2}
{stata pcn compare, main(ppp)}

{p 4 4 2}
Reporting status by only checking changes in ppp:{p_end}

{phang2}
{stata pcn compare, main(ppp) check(ppp)}

{p 4 4 2}
Only displaying the differences in the main variables{p_end}

{phang2}
{stata pcn compare, disvar(diff)}

{p 4 4 2}
Using different povertylines{p_end}

{phang2}
{stata pcn compare, povline(3.2)}


{center:({help pcn_primus:Go back to top})}
{center:({help pcn:Go back to Intro page})}
