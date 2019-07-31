{smcl}
{* *! version 1.2.1  07mar2013}{...}
{vieweralsosee "[D] display" "help display"}{...}
{vieweralsosee "[D] putexcel" "help putexcel"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}

{phang}
{bf:multresp} {hline 2} Recode text multiple response variable to dummy or count variables


{marker syntax}{...}
{title:Syntax}

{phang}
Create dummies for all option codes

{p 8 17 2}
{cmdab:multresp} {varname} 


{phang}
Create dummies for selected option codes only

{p 8 17 2}
{cmdab:multresp} {varname}, options({it:codes})


{phang}
Create dummies for selected option codes with labels

{p 8 17 2}
{cmdab:multresp} {varname} [{it:code1 label1} [{it:code2 label2} [...]]]


{phang}
Create a variable counting how many options have been selected

{p 8 17 2}
{cmdab:multresp} {varname}, count(all)


{phang}
Create a variable counting how many of the listed codes have been selected

{p 8 17 2}
{cmdab:multresp} {varname}, count({it:codes})


{phang}
Full syntax

{p 8 17 2}
{cmdab:multresp}
{varname} [{it:code1} {it:label1} [...]]
[, [{cmdab:options(}{it:codes} | all{cmdab:)}] [{cmdab:infix()}] [{cmdab:count(}{it:codes} | all{cmdab:)} [{cmdab:postfix()}]]]


{marker description}{...}
{title:Description}

{pstd}
{cmd:multresp} takes a string variable and converts it into a series of dummies indicating whether
each letter is present in the string or not, or a variable counting how many of the letters are 
present. It can also label the created variables. It is designed for analysis of survey responses
from  software such as CSPro, where a string of letters is used to represent responses to a 
multiple-choice question where multiple options can be selected. 


{marker options}{...}
{title:Options}

{phang}
{cmd:options(}{it:codes} | all{cmd:)}
allows you to list the codes for which you want to create dummies

{phang}
{cmd:count(}{it:codes} | all{cmd:)}
allows you to list the codes for which you want to create dummies

{phang}
{cmd:infix()}
allows you to insert additional characters into the middle of the names of all the created variables

{phang}
{cmd:postfix()}
allows you to specify a postfix at the end of the names of the count variable. If not specified, 
this defaults to "count"

{cmd:postfix} is ignored if {cmd:count} is not specified.

If no list of codes and labels is given, and neither {cmd:options} nor {cmd:count} are specified,
then {cmd:options} defaults to all.


{marker examples}{...}
{title:Examples}

{pstd}
Consider the following survey question coded as a text variable q234:

Q234. Which of the following do you own? Select all that apply.

A. sofa..................[ ]
B. computer..............[ ]
C. bicycle...............[ ]
D. none of the above.....[ ]

{pstd}For a respondent owning a sofa and computer, your interviewing or data entry software codes 
the answer as "AB", while an individual owning none of the things listed would be coded as "D".{p_end}


{pstd}Create dummy variables q234A, q234B, q234C, and q234D, indicating respectively whether the 
respondent owns a sofa, copmuter, bicycle or none of them.{p_end}
{phang2}{cmd:. multresp q234}{p_end}

{pstd}Call the dummies q234_optionA, q234_optionB, q234_optionC instead.{p_end}
{phang2}{cmd:. multresp q234, infix(_option)}{p_end}

{pstd}Create dummies for sofa, computer, and bicycle, but not for option D ('none of the above'){p_end}
{phang2}{cmd:. multresp q234, options(ABC)}{p_end}

{pstd}Create labelled dummies for sofa, computer and bicycle{p_end}
{phang2}{cmd:. multresp q234 A "sofa" B "computer" C "bicycle"}{p_end}

{pstd}Create a variable q234count, containing the number of objects owned by each respondent{p_end}
{phang2}{cmd:. multresp q234, count(ABC)}{p_end}

{pstd}Create a variable q234_responses_ticked, containing the number of objects owned by each respondent{p_end}
{phang2}{cmd:. multresp q234, count(ABC) postfix(_responses_ticked)}{p_end}



{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:options(all)} checks the string for any options from a-z (lowercase) or A-Z (uppercase). Dummies 
will be created for all letters that are found at least once. If you want to ensure that dummies are
also created for options that are never selected, you need to specify the codes.{p_end}

