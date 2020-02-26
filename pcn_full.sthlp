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

{center:({help pcn:Go back to Intro page})}

{p2colset 10 17 16 2}{...}
{p2col:{cmd:pcn} {hline 2}}Stata package to manage {ul:{it:PovcalNet}} files and 
folders.{p_end}

{p 4 4 2}{bf:{ul:Description (short)}}{p_end}
{p 4 4 2}
The {cmd:pcn} command,command, through a set of subcommands, allows Stata users to
 comprehensively manage the PovcalNet files and folders. By using the command,
 the user will be able to, load data into stata, get the main aggregates,
 and keep up with updates.{p_end}

{p 4 4 2}
A more extensive {it:{help pcn_full##description:description}} is available {help pcn_full##description:below}.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:pcn:} [{it:{help pcn_full##subcommands:subcommand}}] [{cmd:,} {it:{help pcn_full##subcommands:Parameters}} {it:{help pcn_full##options:Options}}]

{p 4 4 2} Where parameters, identify the characteristics of the file to be used. {p_end}

{p 4 4 2} {ul:{title:Subcommands}}
The available subcommands are the following:

{col 5}Subcommand{col 30}Description
{space 4}{hline}
{p2colset 5 30 29 2}{...}
{p2col:{opt load}}Loads into memory the file corresponding to the parameters given by
 the user.{p_end}
{p2col:{opt master}}Loads or updates the master file sheets.{p_end}
{p2col:{opt create}}Creates a dataset containing weights and welfare. 
(Relevant for PovcalNet tools.){p_end}
{p2col:{ul:{opt group}}{opt data}}Creates group data files from raw information and 
updates the master file with means.{p_end}
{p2col:{opt download}}(Rarely used). Downloads the latest file(s) available. Should 
be only used when major  updates are released.{p_end}
{p2col:{opt primus}}Allow you to manage with ease both the pending and approved data on PRIMUS.{p_end}
{space 4}{hline}
{p 4 4 2}
Further explanation of the {help pcn_full##subcommands:subcommands} is found {help pcn_full##subcommands:below}.{p_end}


{p 4 4 2} {ul:{title:Parameters}}
The {bf:pcn} command requires the following parameters:

{col 5}Parameter{col 30}Description
{space 4}{hline}
{p2col:{opt country:}(3-letter code)}List of country codes (accepts multiples) [{it:all} is not accepted]{p_end}
{p2col:{opt years:}(numlist|string)}Four-digit year [all is not accepted] {p_end}
{p2col:{opt type:}(string)}Type of collection requested, only GMD request are accepted.{p_end}
{space 4}{hline}
{p 4 4 2}
Further explanation of the {help pcn_full##param:parameters} is found {help pcn_full##param:below}.{p_end}

{p 4 4 2} {ul:{title:Options}}
The {bf:pcn} command has the following main options available:

{col 5}Option{col 30}Description
{space 4}{hline}
{p2col:{opt clear:}}Replaces data in memory.{p_end}
{p2col:{opt lis:}}Only LIS surveys will be taken into account.{p_end}
{p2col:{opt module:}}It will search accordingly for those either "BIN" or "GPWG"\"GMD" surveys.{p_end}
{p2col:{opt load:}}[Only for master subcommand] If selected the selected sheet will be load from the master.{p_end}
{p2col:{opt upload:}}[Only for master subcommand] If selected the selected sheet will be modified in the master. [Use restricted for the time being.]{p_end}
{space 4}{hline}
{p 4 4 2}
Further explanation of the {help pcn_full##options:Options} is found {help pcn_full##options:below}. {p_end}

{p 4 4 2}
{bf: Note: pcn} requires {help missings:missings}, {help datalibweb:datalibweb} 
and {help primus:primus}. [Notice: {help datalibweb:datalibweb} and {help primus:primus} 
may require World Bank internal resources]

{hline}

{marker sections}{...}
{title:Sections}

{pstd}
Sections are presented under the following headings:

                {it:{help pcn_full##description:Command description}}
                {it:{help pcn_full##subcommands:Subcommands description}}
		  - {it:{help pcn_full##subload:load}}
		  - {it:{help pcn_full##subcreate:create}}
		  - {it:{help pcn_full##subgd:groupdata}}
		  - {it:{help pcn_full##subdownload:download}}
		  - {it:{help pcn_full##submaster:master}}
		  - {it:{help pcn_full##subprimus:primus}}
                {it:{help pcn_full##param:Parameters description}}
                {it:{help pcn_full##options:Options description}}
                {it:{help pcn_full##examples:Examples}}
                {it:{help pcn_full##disclaimer:Disclaimer}}
                {it:{help pcn_full##termsofuse:Terms of use}}
                {it:{help pcn_full##howtocite:How to cite}}

{marker description}{...}
{title:Description}

{pstd}
PovcalNet is a tool that allows computing poverty and inequality indicators for more than
 160 countries and regions, inside the World Bank's database of household surveys
 (check {help povcalnet:povcalnet} command). The {cmd:pcn} command(s) 
 allows Stata users to easly navigate the PovcalNet files and folders. In other words, 
 the {cmd:pcn} command allows working directly with the underlining data used by the PovcalNet 
 tool. Therefore, giving quick and easy access to, up to date, data for more than 160 
 countries' household surveys and aggregate data. {p_end}

{center:(Go up to {it:{help pcn_full##sections:Sections Menu}})}
{center:({help pcn:Go back to Intro page})}

{marker subcommands}{...}
{title:Subcommands}

{center: {hline 3}{it:{help pcn_full##subload:load}} - {it:{help pcn_full##subcreate:create}} - {it:{help pcn_full##subgd:groupdata}} - {it:{help pcn_full##subdownload:download}}} 
{center: - {it:{help pcn_full##submaster:master}} - {it:{help pcn_full##subprimus:primus}} {hline 3}}

{center:(Go up to {it:{help pcn_full##sections:Sections Menu}})}
{center:({help pcn:Go back to Intro page})}

{marker subload}{...}
{dlgtab:load}

{p 4 4 2}
This subcommand loads the PovcalNet data into memory (this requires access to the P drive).
In overall terms, the command checks the conditions given by the user, chiefly 
{opt countries} and {opt year}, and load the existing data that satisfies the user's request, 
or deploys a list with the surveys in stock that meets the conditions. If additional 
conditions, such as {type} or version options, are listed then the search is refined.
{p_end}


{p 4 4 2}
Four different kinds of data can be loaded, accordingly to the chosen companion word:{p_end}

                {hline 73}
                Subcommand + Companion{col 45}Action
                {hline 25}{col 45}{hline 45}
                load [gpwg]	{col 45}loads the GPWG surveys (approved).
                load wrk		{col 45}loads the working data (Not yet approved).
                laod cpi		{col 45}loads the CPI data (datalibweb's).
                {hline 73}

{p 4 4 2}
Options and overall structure changes according to the companion word, please keep in mind the following:{p_end}

    {hline 93}
    Companion{col 25}Basic recommended structure
    {hline 15}{col 25}{hline 73}
    gpwg		{col 20}pcn load, countr(3-letter code) year(####) [veralt(##) vermast(##)]
    wrk			{col 20}pcn laod wrk, countr(3-letter code) year(####) 
    cpi			{col 20}pcn load estimates [, version( date |"choose"|"pick")) ]
    {hline 93}

{p 4 4 2}
{bf:{ul:Examples}}

{p 4 4 2}
One of the most simple queries possible is only setting the country and a year:{p_end}

{phang2}
{stata pcn load, countries(col) year(2016) clear}

{p 4 4 2}
 In this example, as there is more than one survey that fulfils the conditions, a list 
 with available options is displayed, and the user must choose among the options.{p_end}

{p 4 4 2}
Even if sometimes useful, the list is not always ideal. The user may be more specific
 in order to get the specific file that she/he has in mind. For example, if the 
 desired file is the LIS collection the user shall use the following command line:{p_end}

{phang2}
{stata pcn load, countries(col) year(2016) lis clear}

{p 4 4 2}
The same result is obtained with:{p_end}

{phang2}
{stata pcn load, countries(col) year(2016) module(BIN) clear}

{p 4 4 2}
The use of the option {opt lis} implies {opt module(BIN)}. If options {opt lis} 
and {opt module(GPWG)}, {opt lis} would take predominance.{p_end}

{p 4 4 2}
 Notice that the latest master version is the one loaded in the previous examples. 
 Nonetheless, it may be the case that a different master or an alternative version
 is the one needed. This is mainly the case for replication exercises.
 The options {opt vermast} and {opt veralt} allows to retrive this particular set(s) of infomation, as follows:{p_end}

{phang2}
{stata pcn load, countries(chl) year(2000) vermast(01) veralt(04) module(GPWG)}

{p 4 4 2}
You may also specify the survey needed:{p_end}

{phang2}
{stata pcn load, countries(nor) year(2010) survey(His-lis)}

{p 4 4 2}
Finally, it is strongly recommended that, both main parameters, {opt year} and {opt countries}, are
 always set. Nonetheless, only setting the year is possible, in such case the lastest 
 survey year is set as default.{p_end}
 
{phang2}
{stata pcn load, countries(chl) clear}

{p 4 4 2}
The same is not true is the missing parameter is {opt countries}. This parameter is 
compulsory.{p_end}

{center:(Go up to {it:{help pcn_full##subcommands:Subcommand top}})}
{center:(Go up to {it:{help pcn_full##sections:Sections Menu}})}
{center:({help pcn:Go back to Intro page})}

{marker subcreate}{...}
{dlgtab:create}

{p 4 4 2}
This subcommand creates a text file and other povcalnet files. The file collapses the
 information generating the required weights and welfare for working with 
 {browse "http://iresearch.worldbank.org/PovcalNet/PovCalculator.aspx":PovcalNet tools}. {p_end}

{p 4 4 2}
{bf:{ul:Examples}}

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

{center:(Go up to {it:{help pcn_full##subcommands:Subcommand top}})}
{center:(Go up to {it:{help pcn_full##sections:Sections Menu}})}
{center:({help pcn:Go back to Intro page})}

{marker subgd}
{dlgtab:groupdata}

{p 4 4 2}
This subcommand check for existing group data information and updates (or generates) 
the information. {p_end}

{p 4 4 2}
{bf:{ul:Examples}}

{p 4 4 2}
To check for exiting daa or to update just run:{p_end}

{phang2}
{stata pcn groupdata, clear}

{phang2}
{stata pcn gd, clear}

{phang2}
{stata pcn group, clear}

{p 4 4 2}
Please notice that the lines above are all the same. Some of them take advantage of the
 possible abbreviations to call the subcommand.{p_end}

{center:(Go up to {it:{help pcn_full##subcommands:Subcommand top}})}
{center:(Go up to {it:{help pcn_full##sections:Sections Menu}})}
{center:({help pcn:Go back to Intro page})}

{marker subdownload}
{dlgtab:download}

{p 4 4 2}
This subcommand downloads the survey data. Check available surveys (given the user 
parameters) and downloads GPWG data from datalibweb. The file(s) is load in memory 
and save in the specified folder.{p_end}

{p 4 4 2}
{bf:{ul:Examples}}

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

{center:(Go up to {it:{help pcn_full##subcommands:Subcommand top}})}
{center:(Go up to {it:{help pcn_full##sections:Sections Menu}})}
{center:({help pcn:Go back to Intro page})}

{marker submaster}{...}
{dlgtab:master}

{center:(Go up to {it:{help pcn_full##sections:Sections Menu}})}
{center:(Go up to {it:{help pcn_full##sections:Sections Menu}})}
{center:({help pcn:Go back to Intro page})}

{marker subprimus}{...}
{dlgtab:primus}

{center:(Go up to {it:{help pcn_full##sections:Sections Menu}})}
{center:(Go up to {it:{help pcn_full##sections:Sections Menu}})}
{center:({help pcn:Go back to Intro page})}

{marker param}{...}
{title:Parameters}

{p 4 4 2}
The parameters are the key input to determine the source of the working data. Aside from 
the cast subcommand, the parameters work similarly:{p_end}

{p 8 17 2}
{cmdab:pcn:} [{it:{help pcn_full##subcommands:subcommand}}] [{cmd:,} 
{opt countr:ies(3-letter code)} {opt year(####)} {opt type(string)} 
{it:{help pcn_full##options:Options}}]{p_end}

{p 4 4 2}
The {opt countr:ies} and {opt year} are in general mandatory. Although in some cases,
 the omission will not result in an error, instead, it will deploy a list of the
 available data given the parameters input. The {opt type} parameter parameter
 determines the collection in which the data will be searched.{p_end}

{p 4 4 2}
The {opt countr:ies} parameter requires a list of country code(s) to be lookup in the
 available Povcalnet files. The country codes correspond to the standard World Bank 
 three-letter codes.{p_end}

{p 4 4 2}
The {opt year} parameter requires a year to be lookup in the available Povcalnet 
files. The year must be provided as a four-digit number or string 
(ex. 2016, 1990 or 2008).{p_end}

{center:(Go up to {it:{help pcn_full##sections:Sections Menu}})}
{center:({help pcn:Go back to Intro page})}

{marker options}{...}
{title:Options}

{p 4 4 2}
The complete list of options is as follows:{p_end}

{dlgtab:Main}

{p2col:{opt clear:}}Replaces data in memory{p_end}

{dlgtab:Versions}

{p2col:{opt verm:aster(#)}}Specifies the master version to be used. If ommited, by 
default the latest version is selected.{p_end}

{p2col:{opt vera:lt(#)}}Specifies the harmonization version to be used. By default, 
the latest harmonization version is selected for the latest master version.{p_end}

{p2col: {opt lis}}If specified, then only LIS surveys will be taken into account. 
If not specified, then the GMD collection will be used.{p_end}

{p2col: {opt w:orking}}Calls the working version. This version contains updates and 
editions to the latest version available but not released.(NOT YET available, 
BUT MAY BE USEFULL WHEN THE UPDATE KICKS IN){p_end}

{p2col:{opt module}}It will search, accordingly, for either "BIN" or "GPWG"|"GMD" surveys.{p_end}

{center:(Go up to {it:{help pcn_full##sections:Sections Menu}})}
{center:({help pcn:Go back to Intro page})}

{marker examples}{...}
{title:Examples}

{dlgtab:load}

{p 4 4 2}
One of the most simple queries possible is only setting the country and a year:{p_end}

{phang2}
{stata pcn load, countries(col) year(2016) clear}

{p 4 4 2}
In this example as there are more than one survey that full fills the conditions a list
is deployed, and the user must choose among the options.{p_end}

{p 4 4 2}
Even if sometimes useful, the list is not always ideal. The user may be more specific
in order to get the specifc file that she/he has in mind. For example if the desired
file is the LIS collection the user shall use the following command lines:{p_end}

{phang2}
{stata pcn load, countries(col) year(2016) lis clear}

{p 4 4 2}
The same result is obtained with:{p_end}

{phang2}
{stata pcn load, countries(col) year(2016) module(BIN) clear}

{p 4 4 2}
Notice the following, the use of the option {lis} implies {opt module(BIN)}. Under any
circumstance combine {opt lis} and {opt module(GPWG)}.{p_end}

{p 4 4 2}
Notice that the latest master version is the one loaded in the previous examples.
Nontheless, it may be the case that a different master version or an alternative version 
is the one needed. This is mainly the case for replication exercises. The options {opt vermast}
and {opt veralt} allows to retrive this particular set of infomation, as follows:{p_end}

{phang2}
{stata pcn load, countries(chl) year(2000) vermast(01) veralt(04) module(GPWG)}


{p 4 4 2}
Is strongly recommended that, both main parameters, {opt year} and {opt countries} are
 always set. Nontheless only setting the year is possible, in such case the lastest 
 survey year is set as default.{p_end}
 
{phang2}
{stata pcn load, countries(chl) clear}

{p 4 4 2}
The same is not true is the missing parameter is {opt countries}. This parameter is 
compulsory.{p_end}

{dlgtab:create}

{p 4 4 2}
A simple query would be:{p_end}

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

{dlgtab:groupdata}

{p 4 4 2}
To check for exiting daa or to update just run:{p_end}

{phang2}
{stata pcn groupdata, clear}

{phang2}
{stata pcn gd, clear}

{phang2}
{stata pcn group, clear}

{p 4 4 2}
Please notice that the lines above are all the same, but some of them take adventage
of the posible abbreviations to call the subcommand.{p_end}

{dlgtab:download}

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
If you intend to replace the exising file(s) for the newer version(s) you must
 declare the option {opt replace}{p_end}

{phang2}
{stata pcn download, countries(chl) year(2013), replace} 

{center:(Go up to {it:{help pcn_full##sections:Sections Menu}})}
{center:({help pcn:Go back to Intro page})}

{marker disclaimer}{...}
{title:Disclaimer}

The term country, used interchangeably with economy, does not imply political independence but refers to
any territory for which authorities report separate social or economic statistics.


{center:(Go up to {it:{help pcn_full##sections:Sections Menu}})}
{center:({help pcn:Go back to Intro page})}

{marker termsofuse}{...}
{title:Terms of use}

{center:(Go up to {it:{help pcn_full##sections:Sections Menu}})}
{center:({help pcn:Go back to Intro page})}

{marker howtocite}{...}
{title:How to cite}

{center:(Go up to {it:{help pcn_full##sections:Sections Menu}})}
{center:({help pcn:Go back to Intro page})}

{hline}
{hline}

{marker technotes}{...}
{title:Technical Notes - for further development}

{p 4 4 2}
The following are technical notes than may ease further development of the {cmd:pcn}
 command.{p_end}


{bf: 1. Subjacent functions}
{space 1}{hline 30}

{p 4 4 2}
Each subcommand is actually carried on by a separate function that is not "visible"
 to the end user:{p_end}

                {hline 43}
                Subcommand{col 40}Subjacent function
                {hline 20}{col 40}{hline 20}
                load 		{col 40}pcn_load
                create		{col 40}pcn_create
                download		{col 40}pcn_download
                groupdata	{col 40}pcn_groupdata
                {hline 43}

{p 4 4 2}
In addition an adittional function ({cmd:pcn_primus_query}) is used; alongside a 
series of mata functions to ease the coding process.{p_end}

{dlgtab:pcn_load}

{p 4 4 2}
This function is called when the subcommand load is set. The function structure is 
as follows:{p_end}

{p 8 17 2}
{cmdab:pcn_load:}, {opt country:(3-letter code list)} {opt year:(years list)}
 [{opt type:(string)} {opt maindir:(string)} {opt vermast:(#)} {opt veralt:(#)} 
 {opt module(string)} {opt survey(string)} {opt lis} {opt pause} {opt clear} 
 {it:{help pcn_full##options:Options}} ]{p_end}

{p 4 4 2}
Naturally the parameters and options set for {cmd:pcn} are inherited into {cmd:pcn_load}.{p_end}

{p 4 4 2}
{bf: Function walkthrough:}{p_end}

{p 7 7 2}
1. The function starts by checking that the {opt type} or {opt module} are
 set correctly. The possible types are either "GMD" or "GPWG" (GMD collection), 
 if the type is missing it will be set as default to "GMD". In case the {opt lis} 
 option is listed then the module will be set to "LIS".{p_end}

{p 7 7 2}
2. The function will seach in the P drive for the path specified by the user. 
The funtion will go to "01.PovcalNet/01.Vintage_control", unless the path is 
changed (by changing {opt maindir:(string)}).{p_end}

{p 7 7 2}
3. Given the {opt country} parameter input, the function will seach for the 
country's folder. Once the folder is found, if {opt year} is missing it will take 
the last year for which data is available. {p_end}

{p 7 7 2}
4. If the {opt survey} option is not set, then it checks for the available surveys
 for the given year. If the {opt module} is given, it will search accordingly for 
 those either "LIS" or "GPWG" surveys. If multiple surveys fill the criteria a list 
 of surveys will be deployed. {p_end}

{p 7 7 2}
5. Once the survey has been defined, the version is checked. If the user species 
the version ({opt vermast} or {opt veralt} options), the specific version of the 
survey is looked up; otherwise the lastest master and alternative versions are set 
as default.{p_end}

{p 7 7 2}
6. The file corresponding to the request is loaded.{p_end}

{p 7 7 2}
{bf: Note:} At any point between steps 1 to 5 if a parameter results in an inexisting
 file (folder), this will be notified to the user and the function will stop. {p_end}

{dlgtab:pcn_create}

{p 4 4 2}
This function is called when the subcommand create is set. The function structure is
 as follows:{p_end}

{p 8 17 2}
{cmdab:pcn_create:}, {opt countries:(3-letter code list)} {opt year:(years list)} 
[{opt type:(string)} {opt maindir:(string)} {opt vermast:(#)} {opt veralt:(#)} 
{opt module(string)} {opt survey(string)} {opt pause} {opt clear} 
{it:{help pcn_full##options:Options}} ]{p_end}

{p 4 4 2}
Naturally the parameters and options set for {cmd:pcn} are inherited into 
{cmd:pcn_create}.{p_end}

{p 4 4 2}
{bf: Function walkthrough:}{p_end}

{p 7 7 2}
1. The function starts by calling the function {cmd:pcn_primus_query}, the parameters 
{opt countries}, {opt years}, {opt varmast} and {opt veralt}, are inherited. 
The varlist and number of observations are keeped after running the function.{p_end} 

{p 7 7 2}
2. Following, a loop over the surveys is carried on.  {p_end}

{p 7 7 2}
3. (Inside the loop) taking adventage of the {cmd: pcn_load} the dataset is loaded. {p_end}

{p 7 7 2}
4. (inside the loop) Check if weights variable exists. Set to double welfare and 
weight variables, and divide welfare into months (divide by 12).{p_end}

{p 7 7 2}
5. Keep weight and welfare, and drop missing values.{p_end}

{p 7 7 2}
6. Save uncollapsed data.{p_end}


{p 7 7 2}
6. Collapse data keeping the sum of weight by welfare. Save collapsed data.{p_end}

{dlgtab:pcn_download}

{p 4 4 2}
This function is called when the subcommand download is set. The function structure
 is as follows:{p_end}

{p 8 17 2}
{cmdab:pcn_download:}, {opt countries:(3-letter code list)} {opt year:(years list)} 
[{opt maindir:(string)} {opt region(3-letter code)} {opt pause} {opt clear} 
{it:{help pcn_full##options:Options}} ]{p_end}

{p 4 4 2}
Naturally the parameters and options set for {cmd:pcn} are inherited into 
{cmd:pcn_download}.{p_end}

{p 4 4 2}
{bf: Function walkthrough:}{p_end}

{p 7 7 2}
1. The function starts by calling the function {cmd:pcn_primus_query}, the parameters
 {opt countries} and {opt years} are inherited. The varlist and number of observations
 are keeped after running the function.{p_end} 

{p 7 7 2}
2. Following, a loop over the surveys is carried on. {p_end}

{p 7 7 2}
3. (Inside the loop). Taking adventage of the {cmd: datalibweb} the GMD/GMWG dataset
 for the given {cmd:year} and {cmd:countries} is loaded. {p_end}

{p 7 7 2}
4. (Inside the loop).  Check that the file does exist on the P drive. If the files 
does not exist the rute is created and the file saved. If the files exist the signature 
date is check, if the siganture is diferent then is replaced if the option 
{opt replace} was set.{p_end}

{p 7 7 2}
5. A matrix containing the results is saved (Check mata funtions for data on
 {cmd: pcn_info}).{p_end}
 
{p 7 7 2}
6. The results are loaded and the exported to a file.{p_end}

{p 7 7 2}
{bf: Note:} At any point between steps 1 to 3 if a parameter results in an inexisting 
file, folder or survey, this will be notified to the user and the function will stop. {p_end}

{dlgtab:pcn_groupdata}

{p 4 4 2}
This function is called when the subcommand groupdata is set. The function structure 
is as follows:{p_end}

{p 8 17 2}
{cmdab:pcn_groupdata:}, {opt country:(3-letter code list)} {opt year:(years list)} 
[{opt type:(string)} {opt maindir:(string)} {opt vermast:(#)} {opt veralt:(#)} 
{opt pause} {opt clear} {it:{help pcn_full##options:Options}} ]{p_end}

{p 4 4 2}
Naturally the parameters and options set for {cmd:pcn} are inherited into 
{cmd:pcn_groupdata}.{p_end}

{p 4 4 2}
{bf: Function walkthrough:}{p_end}

{p 7 7 2}
1. The function searches in the P drive for the path specified by the user. 
The funtion goes to "p:\01.PovcalNet\03.QA\01.GroupData", unless the path is changed 
(by changing {opt maindir:(string)}). This is set as the working directory.{p_end}

{p 7 7 2}
2. Checks for the existing <<master>> fies in "..\01.PovcalNet\00.Master\02.vintage" {p_end}

{p 7 7 2}
3. "raw_GroupData.xlsx" is loaded into memory, minor cleanup are done. A new ID 
variable is generated in terms of country code, year, coverage, datatype, format 
and survey.{p_end}

{p 7 7 2}
4. For each ID, the corresponding weight and welfare is keeped.{p_end}

{p 7 7 2}
5. For each combination of country code, year, coverage, datatype, format and survey 
(Vintages), a directory is created. (if it does not exist already.)  {p_end}

{p 7 7 2}
6. The mean for each country, year and coverage is stored. (if it does not exist already.)  {p_end}

{p 7 7 2}
7. Other characteristics as are added to the file such as the date time of the file. 
Then the file is saved both as dta and text.{p_end}

{p 7 7 2}
8. Checks if the files are on the most recent folder, and copies them if needed.{p_end}

{p 7 7 2}
9. The master file is updated with the new mean, stored in step 7. For this initiallly 
a temporal file is generated and later on it is merged with the original master file.{p_end}

{p 7 7 2}
10. Missing data is replaced with the previous observation.{p_end}

{p 7 7 2}
11. If there is changes (siganture check), the vintage control is updated, the 
signature reset, the surveyMeanSheet is changed and the master file is modified to
 include the latest sheet.{p_end}

{bf: 1.2 <<Deep>> subfunctions}
------------------------------

{dlgtab:pcn_primus_query}

{p 4 4 2}
This function is called in other subfunctions when a query in primus is required. 
The function structure is as follows:{p_end}

{p 8 17 2}
{cmdab:pcn_primus_query:}, {opt countries:(3-letter code list)} {opt years:(years list)} 
[{opt regions(string)} {opt type:(string)} {opt maindir:(string)} {opt vermast:(#)} 
{opt veralt:(#)} {opt module(string)} {opt survey(string)} {opt pause} {opt clear} 
{it:{help pcn_full##options:Options}} ]{p_end}

{p 4 4 2}
Naturally the parameters and options set for the subcommands are inherited into
 {cmd:pcn_primus_query}.{p_end}

{p 4 4 2}
{bf: Function walkthrough:}{p_end}

{p 7 7 2}
1. The function starts by performing a {help primus##primus:primus} 
{help  primus_query:query}, for the approved transactions. {p_end}

{p 7 7 2}
2. The survey ID's are clean up. {p_end}

{p 7 7 2}
3. The survey name, the master and alternative version are recoverd from the survey 
ID as individual variables. {p_end}

{p 7 7 2}
4. The user inputs are check, if missing default options are settle. For each
 condition, the <<query base>> is reduced to the observations that fulfill the conditions.{p_end}

{p 7 7 2}
5. The varlist of approved surveys that meet the condions are send to mata. 
A copy of the <<base of available surveys>> is keeped in a matrix (R), and the varlist is returned as a macro. 


{bf: 2. Mata functions}
{space 1}{hline 30}

{dlgtab:pcn_ind}

{p 7 7 2}
The function structure is as follows:{p_end}

{p 8 17 2}
{cmdab:pcn_ind:}(matrix R){p_end}

{p 7 7 2}
Here the matrix R, is a string matrix of surveys' info (as the one generated by
 {cmdab:pcn_primus_query}).

{p 4 4 2}
{bf: Function description:}{p_end}

{p 7 7 2}
Each macro for the <<varlist>> is rewritten to refelct the infomation in the R matrix. {p_end}


{dlgtab:pcn_info}

{p 7 7 2}
The function structure is as follows:{p_end}

{p 8 17 2}
{cmdab:pcn_info:}(matrix P){p_end}

{p 7 7 2}
Here the matrix P, is a matrix with information about each survey.

{p 4 4 2}
{bf: Function walkthrough:}{p_end}

{p 7 7 2}
1. The values of survey_id, status and dlwnote are keeped in new vectors. {p_end}

{p 7 7 2}
2. If the rows of P are 0 (ie. P is empty), P is filled with the values saved on 
the vectors from the 1 step. {p_end}

{p 7 7 2}
3. If P it's not empty the value of the vectors are added to the existing data. {p_end}

{marker contact}{...}
{title:Contact}
{pstd}
Any comments, suggestions, or bugs can be reported in the 
{browse "https://github.com/worldbank/pcn/issues":GitHub issues page}.
All the files are available in the {browse "https://github.com/worldbank/pcn":GitHub repository}

{title:Author}
{p 4 4 4}R.Andres Castaneda, The World Bank{p_end}
{p 6 6 4}Email {browse "acastanedaa@worldbank.org":acastanedaa@worldbank.org}{p_end}
{p 6 6 4}GitHub: {browse "https://github.com/randrescastaneda":randrescastaneda }{p_end}

{title:Maintainer}
{p 4 4 4}David L. Vargas Mogollon, The World Bank{p_end}
{p 6 6 4}Email: {browse "dvargasm@worldbank.org":dvargasm@worldbank.org}{p_end}
{p 6 6 4}GitHub: {browse "https://github.com/davidlvargas":davidlvargas }{p_end}


