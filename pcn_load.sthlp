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

{center:{bf:pcn load}}

{hline}
{center:({help pcn:Go back to Intro page})}


{p2colset 5 30 29 2}{...}
{p 4 4 2}
The {cmd:load} subcommand loads the PovcalNet data into memory (this requires access to the P drive).
In overall terms, the command checks the conditions given by the user, chiefly 
{opt countries} and {opt year}, and load the existing data that satisfies the user's request, 
or deploys a list with the surveys in stock that meets the conditions. If additional 
conditions, such as {opt type} or {opt version} options, are listed then the search is refined.
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

    {hline 87}
    Companion{col 25}Basic recommended structure
    {hline 15}{col 25}{hline 67}
    gpwg		{col 20}{cmd:pcn load [gpwg]}, {opt countr(3-letter code)} {opt year(####)} [{opt veralt(##)} {opt vermast(##)}]
    wrk			{col 20}{cmd:pcn laod wrk}, {opt countr(3-letter code)} {opt year(####)}
    cpi			{col 20}{cmd:pcn load cpi} [, {opt version( date |"choose"|"pick")} ]
    {hline 87}
		
{p 4 4 2} 
The different options and parameters may be described:

{col 5}Option{col 30}Description
{space 4}{hline}
	{p2col:{opt country:}(3-letter code)}List of country codes (accepts multiples) [{it:all} is not accepted]{p_end}
	{p2col:{opt years:}(numlist|string)}Four-digit year [all is not accepted] {p_end}
	{p2col:{opt version:}}If set a particular version of the file will be used on basis
	of the date given by the user. If unsure of the date, by writing "choose" or "pick", a list of the versions available will be lunch and the user may select the one to use
	trought a clickcable menu. If not set the latest version is used.{p_end}
	{p2col:{opt clear:}}Replaces data in memory.{p_end}
	{p2col:{opt lis:}}Only LIS surveys will be taken into account.{p_end}
	{p2col:{opt module:}}It will search accordingly for those either "BIN" or "GPWG"\"GMD" surveys.{p_end}
	{p2col:{opt veralt(##)}}If given it will use surveys with the given alternative version.{p_end}
	{p2col:{opt vermast(##)}}If given it will use surveys with the given master version.{p_end}

{space 4}{hline}
{p 4 4 2}
	
	

{center:{hline 16}}
{center:{bf:Examples}}
{center:{hline 16}}

{p 7 4 2} {bf:load gpwg}{p_end}
{space 4}{hline 15}

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
 always set. Nonetheless, only setting the country is possible, in such case the lastest 
 survey year is set as default.{p_end}
 
{phang2}
{stata pcn load, countries(chl) clear}

{p 4 4 2}
The same is not true is the missing parameter is {opt countries}. This parameter is 
compulsory.{p_end}

{center:({help pcn_load:Go back to top})}
{center:({help pcn:Go back to Intro page})}


{p 7 4 2} {bf:load wrk}{p_end}
{space 4}{hline 15}

{p 4 4 2}
One of the most simple queries possible is only setting the country and a year:{p_end}

{phang2}
{stata pcn load wrk, countries(ury) year(2011) clear}

{p 4 4 2}
It is strongly recommended that, both main parameters, {opt year} and {opt countries}, are
 always set. Nonetheless, only setting the year is possible, in such case the lastest 
 survey year is set as default.{p_end}
 
{phang2}
{stata pcn load wrk, countries(ury) clear}

{p 4 4 2}
The same is not true is the missing parameter is {opt countries}. This parameter is 
compulsory.{p_end}

{center:({help pcn_load:Go back to top})}
{center:({help pcn:Go back to Intro page})}

{p 7 4 2} {bf:load cpi}{p_end}
{space 4}{hline 15}

{p 4 4 2}
The cpi structure is quite simple. Just run:{p_end}

{phang2}
{stata pcn load cpi, clear}

{p 4 4 2}
if you need to use a different version, insted of the latest one, use the {opt version}. If you write pick, a clickcable list will be deployed:{p_end}

{phang2}
{stata pcn load cpi, version(pick) clear}



{center:({help pcn_load:Go back to top})}
{center:({help pcn:Go back to Intro page})}
