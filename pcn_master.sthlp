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

{center:{bf:pcn master}}

{hline}
{center:({help pcn:Go back to Intro page})}


{p2colset 5 30 29 2}{...}

{p 4 4 2}
This subcommand allows to work with the master file. You may load the different
 sheets from the master file into memory or modify the master file using the current data on memory.
 
{p 4 4 2}
The basic structure is as follows:
 
 {p 8 17 2}
{cmdab:pcn:} master, {bf:action}(sheet) shape(long) version(pick\choose\select) options  

{p 4 4 2}
Two actions are possible:{p_end}
                {hline 73}
                action{col 33}Description
                {hline 25}{col 30}{hline 45}
                load(sheet)	{col 30}loads the selected sheet.
                upload(sheet)	{col 30}Modifies selected sheet (This is restricted).
                {hline 73}

{p 4 4 2}
{bf:load}{p_end}
{p 4 4 2}
This option can be used to load each spreadsheet of the most recent version of the master file into memory.
Each spreadsheet is loaded in long format. The user can choose the spreadsheet 
to load by specifying one of the following: cpi, ppp, gdp, population, pce, 
currencyconversion, regionlookup, countrylist, countrylookup, surveyinfo, surveymean. 
The load option also accepts: pick, select, choose and sheetslist. Specifying one of these allows
the users to pick each sheet manually. 
The load option can be combined with the option version to choose among different versions of the master file. The user can indicate pick, select or choose within the version option.{p_end}

{p 4 4 2}
{bf:sheets}{p_end}
{p 4 4 2}
The following sheets are available:{p_end}
                {hline 73}
                Sheet{col 40}description
                {hline 25}{col 30}{hline 45}
                cpi	{col 40}cpi sheet.
                ppp	{col 40}ppp sheet.
                gdp	{col 40}gdp sheet.
                population {col 40}population sheet.
                pce	{col 40}pce sheet.
                currencyconversion	{col 35}currrency ratios sheet.
                regionlookup	{col 40}region lookup sheet.
                countrylist	{col 40}country list sheet.
                countrylookup	{col 40}countries lookup sheet.
                surveyinfo	{col 40}Survey info sheet.
                surveymean	{col 40}Survey mean sheet.
                {hline 73}
{space 4}{hline}
{p 4 4 2}

{p 4 4 2} {ul:{title:Options}}
The {bf:pcn} command has the following main options available:

{col 5}Option{col 30}Description
{space 4}{hline}
{p2col:{opt shape:(long|wide)}}Replaces data in memory.{p_end}
{p2col:{opt version:}} If set a particular version of the file will be used on basis of the date given by the user. If unsure of the date, by writing "choose" or "pick", a list of the versions available will be lunch and the user may select the one to use trought a clickcable menu. If not set the latest version is used.
{p_end}
{space 4}{hline}

{center:{hline 16}}
{center:{bf:Examples}}
{center:{hline 16}}


{p 4 4 2}
The following loads the spreadsheet of the master file containing the cpi data:{p_end}

{phang2}
{stata pcn master, load(cpi)}{p_end}

{p 4 4 2}
The following loads the spreadsheet of the master file containing the cpi data and allows the user to pick a version of the master file:{p_end}

{phang2}
{stata pcn master, load(cpi) version(pick)}{p_end}

{p 4 4 2}
The following allows the user to select a version of the master file and a sheet to use:{p_end}

{phang2}
{stata pcn master, load(pick) version(select)}{p_end}

{center:({help pcn_load:Go back to top})}
{center:({help pcn:Go back to Intro page})}
