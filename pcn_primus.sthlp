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

{center:{bf:pcn primus}}

{hline}
{center:({help pcn:Go back to Intro page})}


{p2colset 5 30 29 2}{...}
{p 4 4 2}
The {cmd:load} subcommand allows to manage with ease both the pending and approved data on PRIMUS. 
{p_end}


{p 4 4 2}
Two different kinds of data be used, accordingly to the chosen companion word:{p_end}

                {hline 73}
                Subcommand + Companion{col 45}Action
                {hline 25}{col 45}{hline 45}
                primus approved	{col 45}Works with approved data on primus
                primus pending	{col 45}Works with the pending (not yet approved) data.
                {hline 73}

{p 4 4 2}
Options and overall structure is similar independent of the companion word, please keep in mind the following:{p_end}

{p 8 17 2}
{cmdab:pcn:} primus [approved | pending], [ down(estimates|transactions) | load(estimates|transactions) ] {it:{help pcn_full##options:Options}}

		
{p 4 4 2} 
Either {opt load} or {opt down} is required.

{col 5}Option{col 30}Description
{space 4}{hline}
	{p2col:{opt load:(estimates|trans)}}If selected the either the primus estimates or transactions IDs will be loaded into memory.{p_end}
	{p2col:{opt down:(estimates|trans)}}If selected the either the primus estimates or transactions IDs will be downloaded or updated.{p_end}
	{p2col:{opt version:}}If set a particular version of the estimates or transacions will be load on basis
	of the date given by the user. If unsure of the date, by writing "choose" or "pick", a list of the versions available will be lunch and the user may select the one to use
	trought a clickcable menu. If not set the latest version is used.{p_end}
{space 4}{hline}
{p 4 4 2}

{center:{hline 16}}
{center:{bf:Examples}}
{center:{hline 16}}

{space 4}{hline 15}

{p 4 4 2}
Getting the latest approved estimates:{p_end}

{phang2}
{stata pcn primus approved, load(estimates)}

{p 4 4 2}
Getting the latest approved transactions:{p_end}

{phang2}
{stata pcn primus approved, load(transactions)}

{p 5 4 2}
which is the same as:

{phang2}
{stata pcn primus approved, load(trans)}

{p 4 4 2}
If you need pending data the same holds:{p_end}

{phang2}
{stata pcn primus pending, load(estimates)}

{phang2}
{stata pcn primus pending, load(trans)}

{p 4 4 2}
If you need to load a particular version, keep in mind the {opt version} option:

{phang2}
{stata pcn primus pending, load(trans) version(list)}

{p 4 4 2}
If you need to update the information just use the {opt down} option:

{phang2}
{stata pcn primus pending, down(estimates)}


{phang2}
{stata pcn primus approved, down(trans)}


{center:({help pcn_primus:Go back to top})}
{center:({help pcn:Go back to Intro page})}
