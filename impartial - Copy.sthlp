{smcl}
{* *! version 1.2.1  07mar2013}{...}
{vieweralsosee "[D] mean" "help mean"}{...}
{vieweralsosee "[D] gini" "help gini"}{...}
{vieweralsosee "[D] correlate" "help correlate"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}

{phang}
{bf:impartial} {hline 2} Analyse equality between two groups


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:impartial} {it:{help varname:outcomevar}}[{cmdab:=}{it:value1} [{it:value2}]], {cmdab:over(}{it:{help varname:groupvar}}[{cmdab:=}{it:groupA} [{it:groupB}]]{cmdab:)} 

{marker description}{...}
{title:Description}

{pstd}
{cmd:impartial} outputs some simple indicators of "impartiality", that is, equality between two groups for a given outcome indicator.

{phang}{it:{help varname:outcomevar}} is the name of an outcome variable, which can be either continuous or categorical. {it:{help varname:groupvar}} should be a categorical variable whose values indicate the two groups across which we want to compare outcomes.

{phang}
{cmd:impartial} behaves slightly differently depending on what values and groups are supplied:

{phang}
If no outcome values are given, {cmd:impartial} treats the outcome as a continuous variable.

{phang}
If {it:value1} is given, {cmd:impartial} treats the outcome as a binary variable. It treats {it:value1} as the positive outcome, and all other non-missing values as negative outcomes.

{phang}
If both {it:value1} and {it:value2} are given, {cmd:impartial} treats the outcome as a binary variable. It treats {it:value1} as the positive outcome, and {it:value2} as the negative outcome.

{phang}
If no group values are given, {cmd:impartial} compares the group represented by the first level found of {help varname:groupvar} to the group represented by all other non-missing values.

{phang}
If {it:groupA} is given, {cmd:impartial} compares {it:groupA} to all other non-missing values.

{phang}
If {it:groupA} and {it:groupB} are given, {cmd:impartial} compares {it:groupA} to {it:groupB}.

{phang}{it:value1}, {it:value2}, {it:groupA}, and {it:groupB} can be either category values of the outcome or group variables, or the labels applied to these values. See examples below.


{marker Background}{...}
{title:Background}

{pstd}
Measurement of differences between groups is a common task in research on social and economic inequalities and important to international monitoring for the Sustainable Development Goals. In a handbook on measuring equity in learning (UIS, forthcoming) indicators of parity or disparity between two groups in an outcome such as literacy skills is labelled {it:impartiality}. The indicators can be calculated either on percentages meeting a particular standard (e.g. who reach basic proficiency in a reading test) or on the average level of a continuous outcome variable (e.g. the average of individuals' test scores).

{pstd}
The {cmd:impartial} command provides a convenient way to output several common impartiality measures for two groups of interest.

{marker Output}{...}
{title:Output}

{phang}
Given groups A and B, {cmd:impartial} outputs six indicators based on the average values of the outcome in the two groups:

{phang}
{it:Gap}: the arithmetic difference between the average value of the outcome in the two groups (B - A). If the outcome is binary then this returns the percentage point difference in the frequencies of the outcome in each group.

{phang}
{it:Ratio}: the ratio of the average value of the outcome in the two groups (B / A). The group ratio is commonly used to calculate parity indices such as the gender parity index (see links below).

{phang}
{it:Minimum ratio}: the ratio B / A if A is larger, or the ratio A / B if A is larger

{phang}
{it:Adjusted parity ratio} or {index}: If A is less than or equal to B, the adjusted parity index is the same as the parity index. If A is greater than B, the adjusted parity index is 2 - A / B.

{phang}
{it:Odds ratio}: the ratio of the odds of an outcome occurring in one group to the odds of it occurring in another, calculated as A(1 - B) / B(1 - A)

{phang}
{it:Pearson's correlation coefficient}: The coefficient of correlation between the {help varname:outcomevar} and {help varname:groupvar}. This is calculated using Stata's {help correlate} command. 
When the {help varname:outcomevar} is a binary categorical variable, Pearson's correlation coefficient is the same as the Phi coefficient, a measure of association between binary variables (Guilford, 1936).

{marker examples}{...}
{title:Examples}

{pstd}
These examples use Stata's example data set nslw88.dta:

	{cmd:. sysuse nlsw88, clear}
	
{pstd}
To examine whether a continuous variable (wages) is impartial between two groups:

	{cmd:. impartial wage, over(race=2 1)}
	{cmd:. impartial wage, over(race=black white)} 	// these two are equivalent

{pstd}
To examine the proportion in those who work in Professional/technical occupations, versus other occupations, between the two groups:

	{cmd:. impartial occupation=1, over(race=black white)}
	{cmd:. impartial occupation=Professional/technical, over(race=black white)}		// these two are equivalent
	
{pstd}
To examine the proportions of college graduates between those not living in a central city and those who do:
	
	{cmd:. impartial collgrad=1, over(c_city)}
	
{pstd}
To examine the proportions working in professional services vs. manufacturing, in the south compared to in the north:

	{cmd:. impartial industry="Professional Services" "Manufacturing", over(south)}


{marker storedresults}{...}
{title:Stored results}

{pstd}
{cmd:impartial} stores the following in {cmd:r()}:
	
{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(gap)}}the gap measure (B - A){p_end}
{synopt:{cmd:r(ratio)}}the ratio measure (B/A){p_end}
{synopt:{cmd:r(minratio)}}the minimum ratio (B/A or A/B){p_end}
{synopt:{cmd:r(adjratio)}}the adjusted ratio (B/A or 2 - A/B){p_end}
{synopt:{cmd:r(or)}}the odds ratio (A(1 - B) / B(1 - A)){p_end}
{synopt:{cmd:r(rho)}}Pearson's correlation coefficient{p_end}
{p2colreset}{...}
	
{marker usefullinks}{...}
{title:Useful Links}

{pstd}{browse "http://uis.unesco.org/en/glossary":UNESCO Institute of Statistics Glossary}, including pages on:
{browse "http://uis.unesco.org/en/glossary-term/gender-parity-index-gpi":gender parity index} | 
{browse "http://uis.unesco.org/en/glossary-term/parity-index":other parity indices} | 
{browse "http://uis.unesco.org/en/glossary-term/adjusted-parity-index":adjusted parity index}

{pstd}Wikipedia pages on {browse "https://en.wikipedia.org/wiki/Phi_coefficient":Phi coefficient} | {browse "https://en.wikipedia.org/wiki/Odds_ratio":odds ratio}

{marker references}{...}
{title:References}

{pstd}
Guilford, J. (1936) Psychometric Methods. New York: McGraw Hill

{pstd}
UIS (forthcoming) Handbook on Measuring Equity in Learning. Montreal: UNESCO Institute of Statistics

{pstd}
UIS (n.d.) Glossary. Montreal: UNESCO Institute of Statistics. Available online at http://uis.unesco.org/en/glossary


