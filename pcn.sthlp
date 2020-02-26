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

{title:Intro}

 {marker top}{...}
 {p 4 4 2}{bf:{ul:Description (short)}}{p_end}
 {p 4 4 2}
 The {cmd:pcn} command through a set of subcommands, allows Stata users to
 comprehensively manage the PovcalNet files and folders. By using the command,
 the user will be able to, load data into stata, get the main aggregates,
 and keep up with updates.{p_end}
 
    {c TLC}{hline 62}{c TRC}
    {c |}{col 68}{c |}
    {c |} Get ahead with single module help:{col 68}{c |}
    {c |}{col 68}{c |}
    {c |}    1.  To load the povcalnet files into memory, see{col 68}{c |}
    {c |}        {bf:{help pcn_load: [PCN] pcn load}}{col 68}{c |}    
    {c |}{col 68}{c |}
    {c |}    2.  To work with the master file, see{col 68}{c |}
    {c |}        {bf:{help pcn_master: [PCN] pcn master}}{col 68}{c |}
    {c |}{col 68}{c |}
    {c |}    3.  To work with primus estimates{col 68}{c |}
    {c |}    	  and transactions, see{col 68}{c |}
    {c |}        {bf:{help pcn_primus:[PCN] pcn primus}}{col 68}{c |}
    {c |}{col 68}{c |}
    {c |}    4.  To work with group data, see{col 68}{c |}
    {c |}        {bf:{help pcn_gd:[PCN] pcn groupdata}}{col 68}{c |}
    {c |}{col 68}{c |}
    {c |}    5.  To create the weights and welfare{col 68}{c |}
    {c |}    	  for povcalnet engine, see{col 68}{c |}
    {c |}        {bf:{help pcn_create:[PCN] pcn create}}{col 68}{c |}
    {c |}{col 68}{c |}
    {c |}    6.  To update the povcalnet files, see{col 68}{c |}
    {c |}        {bf:{help pcn_download:[PCN] pcn download}}{col 68}{c |}
    {c |}{col 68}{c |}
    {c |} Or check out the {bf:{help pcn_full:pcn full help file}}{col 68}{c |}
    {c |}{col 68}{c |}
    {c BLC}{hline 62}{c BRC}
	
	

{hline}
{center: {title:Cheat Sheat}}
{hline}

	

{hline}
{center: {title:Cheat Sheat}}
{hline}

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:pcn:} [{it:{help pcn##subcommands:subcommand}}] [{cmd:,} {it:{help pcn##subcommands:Parameters}} {it:{help pcn##options:Options}}]

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
See the {help pcn_full:pcn full help file} for further explanation of the {help pcn##subcommands:subcommands}.{p_end}


{p 4 4 2} {ul:{title:Parameters}}
The {bf:pcn} command requires the following parameters:

{col 5}Parameter{col 30}Description
{space 4}{hline}
{p2col:{opt country:}(3-letter code)}List of country codes (accepts multiples) [{it:all} is not accepted]{p_end}
{p2col:{opt years:}(numlist|string)}Four-digit year [all is not accepted] {p_end}
{p2col:{opt type:}(string)}Type of collection requested, only GMD request are accepted.{p_end}
{space 4}{hline}
{p 4 4 2}
See the {help pcn_full:pcn full help file} for further explanation of the {help pcn##param:parameters}.{p_end}

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
See the {help pcn_full:pcn full help file} for further explanation of the {help pcn##options:Options}.{p_end}

{hline}

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


