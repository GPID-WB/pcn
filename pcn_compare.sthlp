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
{cmdab:pcn:} compare [companion], {it:Options}

{p 4 4 2}
Different tools will be provided accordingly to the chosen companion word:{p_end}

    {hline 85}
    Subcommand + Companion{col 30}Action
    {hline 22}{col 30}{hline 60}
    compare 		{col 30}Creates a dataset comparing the current and testing server
    compare graph	{col 30}Creates a set of graphs to better understand the differences
    compare report	{col 30}Creates a report in MS word of the differences across servers
    {hline 85}

{p 4 4 2}	
To use {pcn compare graph} is compulsory to run {pcn compare} first.
However, {pcn compare report} can and must be run as a standalone. {p_end}

{col 5}Option{col 30}Description
{space 4}{hline}
	{cmd:pcn compare}
	{hline 22}
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
	{p2col:{opt tol:erance(integer)}}Number of decimal places for tolerance in the comparison. 
	Default is 3{p_end}
	{p2col:{opt sd:level(integer)}}Number of standard deviations from the mean to be considered as large.Default is 2{p_end}
	{p2col:{opt countries(3-letter country-code)}}Analyse a particualar country. Default all.{p_end}
	{p2col:{opt years(list)}}Set of year for analysis. Default all.{p_end}
	{p2col:{opt region(3-letter region-code)}}Analyse a particualar region. Default all.{p_end}
	{p2col:{opt fill:gaps}}Uses all countries employed to create regional aggregates{p_end}
	{p2col:{opt agg:regate}}as directed on povcalnet{p_end}
	{p2col:{opt wb}}Uses regional and global aggregates.{p_end}
	{p2col:{opt listc(yes|no)}}Prints in console a list of the problematic obsevations. Do not combine with {opt aggregate}{p_end}
	
	{cmd:pcn compare graph}
	{hline 22}
	{p2col:{opt var:iables(varlist)}}Variables to be compared across servers.Default is {it:headcount}{p_end}
	{p2col:{opt dirs:ave(string)}}Path to save graphs. Can be set to dirsave(wd) to use the current working directory. If not provided the graphs will remain only in memory.{p_end}
	{p2col:{opt sd:level(integer)}}Number of standard deviations from the mean to be considered as large.Default is 2{p_end}
	{p2col:{opt level(country|region)}}Level to group. Default region{p_end}
	
	{cmd:pcn compare report}
	{hline 22}
	{p2col:{opt var:iables(varlist)}}Variables to be compared across servers.Default is {it:headcount}{p_end}
	{p2col:{opt dirs:ave(string)}}Path to save the report. Can be set to dirsave(wd) to use the current working directory. {bf:Must be provided}.{p_end}
	{p2col:{opt sd:level(integer)}}Number of standard deviations from the mean to be considered as large.Default is 2{p_end}
	{p2col:{opt tol:erance(integer)}}Number of decimal places for tolerance in the comparison. 
	Default is 3{p_end}
	{p2col:{opt countries(3-letter code)}}Analyse a particular country. Default all.{p_end}
	{p2col:{opt years(list)}}Set of year for analysis. Default all.{p_end}
	{p2col:{opt region(3-letter code)}}Analyse a particular country. Default all.{p_end}
	{p2col:{opt level(country|region)}}Level to group. Default region{p_end}
	{p2col:{opt fill:gaps}}Uses all countries employed to create regional aggregates{p_end}
	{p2col:{opt wb}}Uses regional and global aggregates.{p_end}


{space 4}{hline}
{p 4 4 2}

{center:{hline 16}}
{center:{bf:Examples}}
{center:{hline 16}}

{cmd:pcn compare}
{hline 22}

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
{stata pcn compare, main(ppp) check(main)}

{p 4 4 2}
Only displaying the differences in the main variables{p_end}

{phang2}
{stata pcn compare, disvar(diff)}

{p 4 4 2}
Using different povertylines{p_end}

{phang2}
{stata pcn compare, povline(3.2)}

{p 4 4 2}
Calling a particular country{p_end}

{phang2}
{stata pcn compare, countries("USA")}

{p 4 4 2}
Calling a particular year{p_end}

{phang2}
{stata pcn compare, years(2012)}

{p 4 4 2}
Calling a particular region{p_end}

{phang2}
{stata pcn compare, regions(EAP)}

{p 4 4 2}
Listing large differeces in the console{p_end}

{phang2}
{stata pcn compare, regions(EAP) listc(yes)}

{p 4 4 2}
Using the regional and global estimates{p_end}

{phang2}
{stata pcn compare, wb}

{p 4 4 2}
Using the povacalnet aggregates{p_end}

{phang2}
{stata pcn compare, agg}

{p 4 4 2}
Using the lineup data used on regional aggregates{p_end}

{phang2}
{stata pcn compare, fill}

{cmd:pcn compare graph}
{hline 22}

{p 4 4 2}
The most basic call, will comapre the data on memory (always run {cmd:pcn compare} first):{p_end}

{phang2}
{stata pcn compare graph}

{p 4 4 2}
The variable comapred as default is the headcount, but you may compare other (remember to adjust the {cmd:pcn compare} accordingly):{p_end}

{phang2}
{stata pcn compare, mainv(headcount ppp)}

{phang2}
{stata pcn compare graph, variables(headcount ppp)}

{p 4 4 2}
Depending on the {cmd:pcn compare} call you may need the plots at a different level :{p_end}

{phang2}
{stata pcn compare, regions(EAP)}

{phang2}
{stata pcn compare graph, level(country)}

{p 4 4 2}
You can set a save directory to save the graphs as PNGs:{p_end}

{phang2}
{stata pcn compare graph, dirs(path)}


{cmd:pcn compare report}
{hline 22}

{p 4 4 2}
You must set a directory to save the report. If you set dirsave(wd) it will use the working directory:{p_end}

{phang2}
{stata pcn compare report, dirs(wd)}

{p 4 4 2}
Similar to {cmd:pcn compare} you can define a region, year, country and level:{p_end}

{phang2}
{stata pcn compare report, regions(OHI) level(country) dirs(wd)}

{phang2}
{stata pcn compare report, countries(USA) level(country) dirs(wd)}

{phang2}
{stata pcn compare report, years(2012) level(region) dirs(wd)}

{p 4 4 2}
You can set the variables to compare:{p_end}

{phang2}
{stata pcn compare report, region("LAC") level(country) variables(ppp) dirs(wd)}


{center:({help pcn_primus:Go back to top})}
{center:({help pcn:Go back to Intro page})}


