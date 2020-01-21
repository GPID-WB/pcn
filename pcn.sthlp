{smcl}
{* *! version 1.0.0 8jan2020}{...}
{cmd:help pcn}{right: WB:PovcalNet Team}{* {right: ({browse "some link":SJ: ???})}}
{hline}

{vieweralsosee "" "--"}{...}
{vieweralsosee "Install wbopendata" "ssc install wbopendata"}{...}
{vieweralsosee "Help wbopendata (if installed)" "help wbopendata"}{...}
{viewerjumpto   "Command description"   "pcn##desc"}{...}
{viewerjumpto "Parameters description"   "pcn##param"}{...}
{viewerjumpto "Options description"   "pcn##options"}{...}
{viewerjumpto "Subcommands"   "pcn##subcommands"}{...}
{viewerjumpto "Stored results"   "pcn##return"}{...}
{viewerjumpto "Examples"   "pcn##Examples"}{...}
{viewerjumpto "Disclaimer"   "pcn##disclaimer"}{...}
{viewerjumpto "How to cite"   "pcn##howtocite"}{...}
{viewerjumpto "References"   "pcn##references"}{...}
{viewerjumpto "Acknowledgements"   "pcn##acknowled"}{...}
{viewerjumpto "Authors"   "pcn##authors"}{...}
{viewerjumpto "Regions" "pcn_countries##regions"}{...}
{viewerjumpto "Countries" "pcn_countries##countries"}{...}
{title:Title}

{p2colset 10 17 16 2}{...}
{p2col:{cmd:pcn} {hline 2}}Stata package to manage {ul:{it:PovcalNet}} files and folders.{p_end}

{p 4 4 2}{bf:{ul:Description (short)}}{p_end}
{p 4 4 2}
The {cmd:pcn} command, throughout a series of subcommands, allows Stata users to manage the PovcalNet files and folders in a comprensive way. Using the command the user will be able to load data into stata, get the main aggregates, and keep up with updates.{p_end}

{p 4 4 2}
A more comprensive {it:{help pcn##description:description}} is available {help pcn##description:below}.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:pcn:} [{it:{help pcn##subcommands:subcommand}}] [{cmd:,} {it:{help pcn##subcommands:Parameters}} {it:{help pcn##options:Options}}]

{p 4 4 2} Where parameters identify the characteristics of the file to be used. {p_end}

{p 4 4 2} {ul:{title:Subcommands}}
The available subcommands are the following:

{col 5}Subcommand{col 30}Description
{space 4}{hline}
{p2colset 5 30 29 2}{...}
{p2col:{opt load}}Loads into memory the file corresponding to the parameters given by the user.{p_end}
{p2col:{opt create}}Creates a dataset containing weights and welfare. (Relevant for PovcalNet tools.){p_end}
{p2col:{ul:{opt group}}{opt data}}Creates group data files from raw information and update master file with means.{p_end}
{p2col:{opt download}}(Rarely used). Downloads the latest file(s) available. Should be only used when mayor updates are released.{p_end}
{space 4}{hline}
{p 4 4 2}
Further explanation on the {help pcn##subcommands:subcommands} is found {help pcn##subcommands:below}.{p_end}


{p 4 4 2} {ul:{title:Parameters}}
The {bf:pcn} command requires the following parameters:

{col 5}Parameter{col 30}Description
{space 4}{hline}
{p2col:{opt country:}(3-letter code)}List of country codes (accepts multiples) [{it:all} is not accepted]{p_end}
{p2col:{opt years:}(numlist|string)}Four-digit year [all is not accepted] {p_end}
{p2col:{opt type:}(string)}Type of ONE collection requested. Currently the only COLLECTIONS available are: eappov, ecapov, ecaraw, eu-lfs, udb-c or eusilc, udb-l (panel eusilc), mnapov, mnaraw, {it:sa t:ssapov}, gmd, sarraw, eapraw, ssaraw, sedlac, lablac, conlac and many more.{p_end}
{space 4}{hline}
{p 4 4 2}
Further explanation on the {help pcn##param:parameters} is found {help pcn##param:below}.{p_end}

{p 4 4 2} {ul:{title:Options}}
The {bf:pcn} command has the following main options available:

{col 5}Option{col 30}Description
{space 4}{hline}
{p2col:{opt clear:}}Replaces data in memory.{p_end}
{space 4}{hline}
{p 4 4 2}
Further explanation on the {help pcn##options:Options} is found {help pcn##options:below}. {p_end}

{p 4 4 2}
{bf: Note: pcn} requires {help missings:missings}, {help datalibweb:datalibweb} and {help primus:primus}. [Notice {help datalibweb:datalibweb} and {help primus:primus} may require World Bank internal resources]

{marker sections}{...}
{title:Sections}

{pstd}
Sections are presented under the following headings:

                {it:{help pcn##description:Command description}}
                {it:{help pcn##subcommands:Parameters description}}
                {it:{help pcn##param:Parameters description}}
                {it:{help pcn##options:Options description}}
                {it:{help pcn##examples:Examples}}
                {it:{help pcn##disclaimer:Disclaimer}}
                {it:{help pcn##termsofuse:Terms of use}}
                {it:{help pcn##howtocite:How to cite}}

{marker description}{...}
{title:Description}

{pstd}
PovcalNet is tool that allows to compute poverty and inequality indicators for more than 160 countries and regions in the World Bank's database of household surveys (check {help povcalnet:povcalnet} command). The {cmd:pcn} command(s) allows Stata to easly navigate trought the PovcalNet files and folders. In other words the {cmd:pcn} command allows to work directly with the underlining data used by the PovcalNet tool, therefore giving quick and easy access to up data for more than 160 countries' household surveys and aggregate data. {p_end}


{marker subcommands}{...}
{title:Subcommands}

{dlgtab:load}

{p 4 4 2}
This subcommand loads the PovcalNet data into memory (this requires acces to the P drive). In general terms, the commnad check the conditions given by the user, mainly {opt countries} and {opt year}, and either loads the existing data that fullfils the user request or deploys a list with the surveys in stock that meets the conditions. If further conditions such as {type} or version options are specified then the seach is refined. {p_end}

{dlgtab:create}

{p 4 4 2}
This subcommand creates text file and other povcalnet files. The file collpases the information generating the required weights and welfare for working with {browse "http://iresearch.worldbank.org/PovcalNet/PovCalculator.aspx":PovcalNet tools}. {p_end} 

{dlgtab:groupdata}

{p 4 4 2}
This subcommand check for existing group data information and updates (or generates) the information. {p_end}

{dlgtab:download}

{p 4 4 2}
This subcommand downloads the survey data. Check available surveys (given the user parameters) and downloads GPWG data from datalibweb. The file(s) is load in memory and save in the specified folder.{p_end}


{marker param}{...}
{title:Parameters}

{p 4 4 2}
The parameters are the main input to define the data source to work with. Beyond the chosen sucommand the parameters work in a similar fashion:{p_end}

{p 8 17 2}
{cmdab:pcn:} [{it:{help pcn##subcommands:subcommand}}] [{cmd:,} {opt countr:ies(3-letter code)} {opt year(####)} {opt type(string)} {it:{help pcn##options:Options}}]{p_end}

{p 4 4 2}
The {opt countr:ies} and {opt year} are (in general) mandatory, nonetheless in some cases the omision will not result in an error, but insted it will deploy a list of the available data given the parameters input. The {opt type} parameter determines the collection in which the data will be search.{p_end}

{p 4 4 2}
The {opt countr:ies} parameter requires a list of country code(s) to be lookup in the available Povcalnet files. The country codes correspond to the standard World Bank three letter codes.{p_end}

{p 4 4 2}
The {opt year} parameter requires a year to be lookup in the available Povcalnet files. The year must be provided as a four-digit number or string (ex. 2016, 1990 or 2008).{p_end}


{marker options}{...}
{title:Options}

{p 4 4 2}
The complete list of options is as follows:{p_end}

{dlgtab:Main}

{p2col:{opt clear:}}Replaces data in memory{p_end}

{dlgtab:Versions}

{p2col:{opt verm:aster(#)}}Specifies the master version to be used. By default, the latest version is selected if it is omitted.{p_end}

{p2col:{opt vera:lt(#)}}Specifies the harmonization version to be used. By default, the latest harmonization version is selected for the latest master version if it is omitted.{p_end}

{p2col: {opt lis}}If specified then only LIS surveys will be taken into account. If not specified then the GMD collection will be used.{p_end}

{p2col: {opt w:orking}}Calls the working version. This version contains updates and editions to the latest version available but not released.(NOT YET available, BUT MAY BE USEFULL WHEN THE UPDATE KICKS IN){p_end}


{marker examples}{...}
{title:Examples}


{marker disclaimer}{...}
{title:Disclaimer}


{marker termsofuse}{...}
{title:Terms of use}

{marker howtocite}{...}
{title:How to cite}

{hline}
{hline}

{marker technotes}{...}
{title:Technical Notes - for further development}

{p 4 4 2}
The following are technical notes than may ease further development of the {cmd:pcn} command.{p_end}


{bf: 1. Subjacent functions}
{space 1}{hline 30}

{p 4 4 2}
Each subcommand is actually carried on by a separate function that is not "visible" to the end user:{p_end}

                {hline 43}
                Subcommand{col 40}Subjacent function
                {hline 20}{col 40}{hline 20}
                load 		{col 40}pcn_load
                create		{col 40}pcn_create
                download		{col 40}pcn_download
                groupdata	{col 40}pcn_groupdata
                {hline 43}

{p 4 4 2}
In addition an adittional function ({cmd:pcn_primus_query}) is used; alongside a series of mata functions to ease the coding process.{p_end}

{dlgtab:pcn_load}

{p 4 4 2}
This function is called when the subcommand load is set. The function structure is as follows:{p_end}

{p 8 17 2}
{cmdab:pcn_load:}, {opt country:(3-letter code list)} {opt year:(years list)} [{opt type:(string)} {opt maindir:(string)} {opt vermast:(#)} {opt veralt:(#)} {opt module(string)} {opt survey(string)} {opt lis} {opt pause} {opt clear} {it:{help pcn##options:Options}} ]{p_end}

{p 4 4 2}
Naturally the parameters and options set for {cmd:pcn} are inherited into {cmd:pcn_load}.{p_end}

{p 4 4 2}
{bf: Function walkthrough:}{p_end}

{p 7 7 2}
1. The function starts by checking that the {opt type} or {opt module} are set correctly. The possible types are either "GMD" or "GPWG" (GMD collection), if the type is missing it will be set as default to "GMD". In case the {opt lis} option is listed then the module will be set to "LIS".{p_end}

{p 7 7 2}
2. The function will seach in the P drive for the path specified by the user. The funtion will go to "01.PovcalNet/01.Vintage_control", unless the path is changed (by changing {opt maindir:(string)}).{p_end}

{p 7 7 2}
3. Given the {opt country} parameter input, the function will seach for the country's folder. Once the folder is found, if {opt year} is missing it will take the last year for which data is available. {p_end}

{p 7 7 2}
4. If the {opt survey} option is not set, then it checks for the available surveys for the given year. If the {opt module} is given, it will search accordingly for those either "LIS" or "GPWG" surveys. If multiple surveys fill the criteria a list of surveys will be deployed. {p_end}

{p 7 7 2}
5. Once the survey has been defined, the version is checked. If the user species the version ({opt vermast} or {opt veralt} options), the specific version of the survey is looked up; otherwise the lastest master and alternative versions are set as default.{p_end}

{p 7 7 2}
6. The file corresponding to the request is loaded.{p_end}

{p 7 7 2}
{bf: Note:} At any point between steps 1 to 5 if a parameter results in an inexisting file (folder), this will be notified to the user and the function will stop. {p_end}

{dlgtab:pcn_create}

{p 4 4 2}
This function is called when the subcommand create is set. The function structure is as follows:{p_end}

{p 8 17 2}
{cmdab:pcn_create:}, {opt countries:(3-letter code list)} {opt year:(years list)} [{opt type:(string)} {opt maindir:(string)} {opt vermast:(#)} {opt veralt:(#)} {opt module(string)} {opt survey(string)} {opt pause} {opt clear} {it:{help pcn##options:Options}} ]{p_end}

{p 4 4 2}
Naturally the parameters and options set for {cmd:pcn} are inherited into {cmd:pcn_create}.{p_end}

{p 4 4 2}
{bf: Function walkthrough:}{p_end}

{p 7 7 2}
1. The function starts by calling the function {cmd:pcn_primus_query}, the parameters {opt countries}, {opt years}, {opt varmast} and {opt veralt}, are inherited. The varlist and number of observations are keeped after running the function.{p_end} 

{p 7 7 2}
2. Following, a loop over the surveys is carried on.  {p_end}

{p 7 7 2}
3. (Inside the loop) taking adventage of the {cmd: pcn_load} the dataset is loaded. {p_end}

{p 7 7 2}
4. (inside the loop) Check if weights variable exists. Set to double welfare and weight variables, and divide welfare into months (divide by 12).{p_end}

{p 7 7 2}
5. Keep weight and welfare, and drop missing values.{p_end}

{p 7 7 2}
6. Save uncollapsed data.{p_end}


{p 7 7 2}
6. Collapse data keeping the sum of weight by welfare. Save collapsed data.{p_end}

{dlgtab:pcn_download}

{p 4 4 2}
This function is called when the subcommand download is set. The function structure is as follows:{p_end}

{p 8 17 2}
{cmdab:pcn_download:}, {opt countries:(3-letter code list)} {opt year:(years list)} [{opt maindir:(string)} {opt region(3-letter code)} {opt pause} {opt clear} {it:{help pcn##options:Options}} ]{p_end}

{p 4 4 2}
Naturally the parameters and options set for {cmd:pcn} are inherited into {cmd:pcn_download}.{p_end}

{p 4 4 2}
{bf: Function walkthrough:}{p_end}

{p 7 7 2}
1. The function starts by calling the function {cmd:pcn_primus_query}, the parameters {opt countries} and {opt years} are inherited. The varlist and number of observations are keeped after running the function.{p_end} 

{p 7 7 2}
2. Following, a loop over the surveys is carried on. {p_end}

{p 7 7 2}
3. (Inside the loop). Taking adventage of the {cmd: datalibweb} the GMD/GMWG dataset for the given {cmd:year} and {cmd:countries} is loaded. {p_end}

{p 7 7 2}
4. (Inside the loop).  Check that the file does exist on the P drive. If the files does not exist the rute is created and the file saved. If the files exist the signature date is check, if the siganture is diferent then is replaced if the option {opt replace} was set.{p_end}

{p 7 7 2}
5. A matrix containing the results is saved (Check mata funtions for data on {cmd: pcn_info}).{p_end}
 
{p 7 7 2}
6. The results are loaded and the exported to a file.{p_end}

{p 7 7 2}
{bf: Note:} At any point between steps 1 to 3 if a parameter results in an inexisting file, folder or survey, this will be notified to the user and the function will stop. {p_end}

{dlgtab:pcn_groupdata}

{p 4 4 2}
This function is called when the subcommand groupdata is set. The function structure is as follows:{p_end}

{p 8 17 2}
{cmdab:pcn_groupdata:}, {opt country:(3-letter code list)} {opt year:(years list)} [{opt type:(string)} {opt maindir:(string)} {opt vermast:(#)} {opt veralt:(#)} {opt pause} {opt clear} {it:{help pcn##options:Options}} ]{p_end}

{p 4 4 2}
Naturally the parameters and options set for {cmd:pcn} are inherited into {cmd:pcn_groupdata}.{p_end}

{p 4 4 2}
{bf: Function walkthrough:}{p_end}

{p 7 7 2}
1. The function searches in the P drive for the path specified by the user. The funtion goes to "p:\01.PovcalNet\03.QA\01.GroupData", unless the path is changed (by changing {opt maindir:(string)}). This is set as the working directory.{p_end}

{p 7 7 2}
2. Checks for the existing <<master>> fies in "..\01.PovcalNet\00.Master\02.vintage" {p_end}

{p 7 7 2}
3. "raw_GroupData.xlsx" is loaded into memory, minor cleanup are done. A new ID variable is generated in terms of country code, year, coverage, datatype, format and survey.{p_end}

{p 7 7 2}
4. For each ID, the corresponding weight and welfare is keeped.{p_end}

{p 7 7 2}
5. For each combination of country code, year, coverage, datatype, format and survey (Vintages), a directory is created. (if it does not exist already.)  {p_end}

{p 7 7 2}
6. The mean for each country, year and coverage is stored. (if it does not exist already.)  {p_end}

{p 7 7 2}
7. Other characteristics as are added to the file such as the date time of the file. Then the file is saved both as dta and text.{p_end}

{p 7 7 2}
8. Checks if the files are on the most recent folder, and copies them if needed.{p_end}

{p 7 7 2}
9. The master file is updated with the new mean, stored in step 7. For this initiallly a temporal file is generated and later on it is merged with the original master file.{p_end}

{p 7 7 2}
10. Missing data is replaced with the previous observation.{p_end}

{p 7 7 2}
11. If there is changes (siganture check), the vintage control is updated, the signature reset, the surveyMeanSheet is changed and the master file is modified to include the latest sheet.{p_end}

{bf: 1.2 <<Deep>> subfunctions}
------------------------------

{dlgtab:pcn_primus_query}

{p 4 4 2}
This function is called in other subfunctions when a query in primus is required. The function structure is as follows:{p_end}

{p 8 17 2}
{cmdab:pcn_primus_query:}, {opt countries:(3-letter code list)} {opt years:(years list)} [{opt regions(string)} {opt type:(string)} {opt maindir:(string)} {opt vermast:(#)} {opt veralt:(#)} {opt module(string)} {opt survey(string)} {opt pause} {opt clear} {it:{help pcn##options:Options}} ]{p_end}

{p 4 4 2}
Naturally the parameters and options set for the subcommands are inherited into {cmd:pcn_primus_query}.{p_end}

{p 4 4 2}
{bf: Function walkthrough:}{p_end}

{p 7 7 2}
1. The function starts by performing a {help primus##primus:primus} {help  primus_query:query}, for the approved transactions. {p_end}

{p 7 7 2}
2. The survey ID's are clean up. {p_end}

{p 7 7 2}
3. The survey name, the master and alternative version are recoverd from the survey ID as individual variables. {p_end}

{p 7 7 2}
4. The user inputs are check, if missing default options are settle. For each condition, the <<query base>> is reduced to the observations that fulfill the conditions.{p_end}

{p 7 7 2}
5. The varlist of approved surveys that meet the condions are send to mata. A copy of the <<base of available surveys>> is keeped in a matrix (R), and the varlist is returned as a macro. 


{bf: 2. Mata functions}
{space 1}{hline 30}

{dlgtab:pcn_ind}

{p 7 7 2}
The function structure is as follows:{p_end}

{p 8 17 2}
{cmdab:pcn_ind:}(matrix R){p_end}

{p 7 7 2}
Here the matrix R, is a string matrix of surveys' info (as the one generated by {cmdab:pcn_primus_query}).

{p 4 4 2}
{bf: Function description:}{p_end}

{p 7 7 2}
Each macro for the <<varlist>> is rewritten to refelct the infomation in the R matrix. {p_end}


{dlgtab:pcn_info}

{p 7 7 2}
The function structure is as follows:{p_end}

{p 8 17 2}
{cmdab:pcn_ind:}(matrix P){p_end}

{p 7 7 2}
Here the matrix P, is a matrix with information about each survey.

{p 4 4 2}
{bf: Function walkthrough:}{p_end}

{p 7 7 2}
1. The values of survey_id, status and dlwnote are keeped in new vectors. {p_end}

{p 7 7 2}
2. If the rows of P are 0 (ie. P is empty), P is filled with the values saved on the vectors from the 1 step. {p_end}

{p 7 7 2}
3. If P it's not empty the value of the vectors are added to the existing data. {p_end}





