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

{center:{bf:pcn create}}

{hline}
{center:({help pcn:Go back to Intro page})}


{p2colset 5 30 29 2}{...}
{p 4 4 2}
This subcommand creates a text file and other povcalnet files. The file collapses the
 information generating the required weights and welfare for working with 
 {browse "http://iresearch.worldbank.org/PovcalNet/PovCalculator.aspx":PovcalNet tools}. {p_end}

{center:{hline 16}}
{center:{bf:Examples}}
{center:{hline 16}}

{p 4 4 2}
A simple query is:{p_end}

{phang2}
{stata pcn create, countries(dnk) year(2013) clear}

{p 4 4 2}
Further options may be applied. In particular, is possible to include version options, such as:{p_end}

{phang2}
{stata pcn create, countries(tgo) year(2015) vermast(01) veralt(02)}

{p 4 4 2}
Also, if desired, one may specify the module as well. Nontheless, only GMD or GPWG 
may be admissable.{p_end}

{phang2}
{stata pcn create, countries(tgo) year(2015) vermast(01) veralt(02) module(GMD)}

{center:({help pcn_create:Go back to top})}
{center:({help pcn:Go back to Intro page})}
