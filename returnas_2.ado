/*** DO NOT EDIT THIS LINE -----------------------------------------------------

Version: 0.0.0


Intro Description
=================

packagename -- A new module for ... 


Author(s)
=================

Author name ...
Author affiliation ...
to add more authors, leave an empty line between authors' information

Second author ...
For more information visit {browse "http://www.haghish.com/markdoc":MarkDoc homepage}


Syntax
=================

{opt exam:ple} {depvar} [{indepvars}] {ifin} using 
[{it:{help filename:filename}}]
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt rep:lace}}replace this example{p_end}
{synopt :{opt app:end}}work further on this help file{p_end}
{synopt :{opt addmore}}you can add more description for the options; Moreover, 
       the text you write can be placed in multiple lines {p_end}
{synopt :{opt learn:smcl}}you won't make a loss learning
{help smcl:SMCL Language} {p_end}
{synoptline}
----------------------------------------------------- DO NOT EDIT THIS LINE ***/

* Note: If you like to leave the "Intro Description" or "Author(s) section
* empty, erase the text but KEEP THE HEADINGS



capture program drop returnas
program returnas, rclass
// --- Just sets any return value
	return add
	return `0'
end

/***
Example
=================

    explain what it does
        . example command

    second explanation
        . example command
***/



