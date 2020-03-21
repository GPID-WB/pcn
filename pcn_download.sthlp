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

{center:{bf:pcn download}}

{hline}
{center:({help pcn:Go back to Intro page})}


{p2colset 5 30 29 2}{...}
{p 4 4 2}
This subcommand downloads the survey data. Check available surveys (given the user 
parameters) and downloads GPWG data from datalibweb. The file(s) is load in memory 
and save in the specified folder.{p_end}

{p 4 4 2}
Four different kinds of data can be downloaded, accordingly to the chosen companion word:{p_end}

                {hline 73}
                Subcommand + Companion{col 45}Action
                {hline 25}{col 45}{hline 45}
                download [gpwg]	{col 45}Downloads the GPWG surveys (approved).
                download wrk		{col 45}Downloads the working data (Not yet approved).
                {hline 73}

{p 4 4 2}
Options and overall structure changes according to the companion word, please keep in mind the following:{p_end}

    {hline 87}
    Companion{col 25}Basic recommended structure
    {hline 15}{col 25}{hline 67}
    gpwg		{col 20}{cmd:pcn download [gpwg]} [, {opt countr(3-letter code)} {opt year(####)} {opt veralt(##)} {opt vermast(##)}]
    wrk			{col 20}{cmd:pcn downlaod wrk} [, {opt countr(3-letter code)} {opt year(####)}]
    {hline 87}
		
{p 4 4 2} 
The different options and parameters may be described:

{col 5}Option{col 30}Description
{space 4}{hline}
	{p2col:{opt country:}(3-letter code)}List of country codes (accepts multiples) [{it:all} is not accepted]{p_end}
	{p2col:{opt years:}(numlist|string)}Four-digit year [all is not accepted] {p_end}
	{p2col:{opt replace:}}Replaces data the existing file(s).{p_end}
	{p2col:{opt veralt(##)}}If given it will use surveys with the given alternative version.{p_end}
	{p2col:{opt vermast(##)}}If given it will use surveys with the given master version.{p_end}

{space 4}{hline}
{p 4 4 2}
	
	

{center:{hline 16}}
{center:{bf:Examples}}
{center:{hline 16}}

{p 5 4 2} {bf:Download gpwg}{p_end}
{space 4}{hline 15}

{p 4 4 2}
One of the most simple queries possible is only setting the country and a year:{p_end}

{phang2}
{stata pcn download, countries(chl) year(2013)}

{p 4 4 2}
Request for different versions of the surveys is posible as well:{p_end}

{phang2}
{stata pcn download, countries(ben) year(2015) veralt(02)}

{phang2}
{stata pcn download, countries(ben) year(2015) veralt(01)}

{p 4 4 2}
If you intend to replace the exising file(s) for the newer version(s), you must
 declare the option {opt replace}{p_end}

{phang2}
{stata pcn download, countries(chl) year(2013), replace} 

{p 6 4 2} {bf:Download wrk}{p_end}
{space 4}{hline 15}

{p 4 4 2}
One of the most simple queries possible is only setting the country and a year:{p_end}

{phang2}
{stata pcn download wrk, countries(ury) year(2011)}


{center:({help pcn_load:Go back to top})}
{center:({help pcn:Go back to Intro page})}
