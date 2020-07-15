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

{center:{bf:pcn production}}

{hline}
{center:({help pcn:Go back to Intro page})}


{p2colset 5 30 29 2}{...}
{p 4 4 2}
This subcommand allows the user the load or create PovcalNet production vintages.
{p_end}

{p 4 4 2}
Two actions are available:{p_end}

                {hline 73}
                Subcommand + Action{col 45}Result
                {hline 25}{col 45}{hline 45}
                production load	  {col 45}Loads specific vintage.
                production create	{col 45}Create vintage in pre-existing folder in P drive.
                {hline 73}

{p 4 4 2}
Options and overall structure changes according to the companion word, please keep in mind the following:{p_end}

    {hline 87}
    Action{col 25}Basic recommended syntax
    {hline 15}{col 25}{hline 67}
    load	{col 25}{cmd:pcn production load} [, {it:vintage(YYYY_VT) clear}]
    create {col 25}{cmd:pcn production create} [, {it:vintage(YYYY_VT) server(string) clear}]
    {hline 87}
		
{p 4 4 2} 
Where {it:YYYY} refers to the year and {it:VT} refers to the vintage of the year, which may be a three-letter word for the month of the update (e.g, JUL for July) or a two-letter word for the WB meeting (e.g., SM for Spring meetings). 

{col 5}Option{col 30}Description
{space 4}{hline}
	{p2col:{opt vintage:}(YYYY_VT)}Vintage of the data{p_end}
	{p2col:{opt clear:}}Replaces data in Stata memory{p_end}
	{p2col:{opt replace:}}Replaces vintage file in P drive. Only available with {it:create} action. {p_end}

{space 4}{hline}
{p 4 4 2}
	
	

{center:{hline 16}}
{center:{bf:Examples}}
{center:{hline 16}}

{p 5 4 2} {bf:Load production vintage}{p_end}
{space 4}{hline 15}

{p 4 4 2}
Display list of available ("clickable") vintages:{p_end}

{phang2}
{stata pcn production load}

{p 4 4 2}
Load a specific vintage:{p_end}

{phang2}
{stata pcn production load, vintage(2020_JUL)}

{p 5 4 2} {bf:Create production vintage}{p_end}
{space 4}{hline 15}

{p 4 4 2}
Create a new vintage version. Only available for some members of the PovcalNet Team. {p_end}

{phang2}
{stata pcn production create, vintage(2020_JUL)}


{center:({help pcn_production:Go back to top})}
{center:({help pcn:Go back to Intro page})}
