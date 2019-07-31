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
{bf:writex} {hline 2} Write to Excel spreadsheets more easily


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:writex}
[{it:content_expression} [{it:content_expression} [...]]]
[{cmd:using} {it:{help filename}}] [, [{it:{help putexcel##set_options_tbl:putexcel_set_options}}] [{cmdab:f:ormat}({it:{help format:%fmt}})}]]



{marker description}{...}
{title:Description}

{pstd}
{cmd:writex} outputs a sequence of content to an Excel spreadsheet. It starts in cell A1
(the top-left cell) and adds items from left to right along a row. Next time you call the command 
(or use \ or _newline) it moves to the next row. {cmd:writex} is based on {help putexcel:putexcel} 
and has similar options, but allows for content to be listed in a more convenient way.

{pstd}
{cmd:writex}'s {it:content_expression}s can be any of the following:

{synoptset 32}
{synopt:{it:plain expression}}outputs a word, number or arithmetic expression (must not contain spaces) {p_end}

{synopt:{cmd:"}{it:double-quoted string}{cmd:"}}outputs the string without
              the quotes{p_end}

{synopt:{cmd:(}{it:expression in parentheses}{cmd:)}}outputs a string, number, or expression{p_end}

{synopt:{cmd:""}}outputs an empty cell{p_end}
			  
{synopt:[{cmd:%}{it:fmt}] {cmd:exp}}allows results to be formatted;
         see {bf:{mansection U 12.5FormatsControllinghowdataaredisplayed:[U] 12.5 Formats: Controlling how data are displayed}}{p_end}

{synopt:{cmd:_newline} or {cmd:\}}goes to a new empty line{p_end}

{synopt:{cmd:_newrow}}goes to the next row and sets the column to 1{p_end}

{synopt:{cmd:_clear}}goes to the first empty row in the sheet and sets the column to 1{p_end}

{synopt:{cmd:cell(}A3{cmd:)}}move to cell A3{p_end}

{synopt:{cmd:column(}{it:#}{cmd:)}}move to column {it:#} of the current row{p_end}

{synopt:{cmd:row(}{it:#}{cmd:)}}move to row {it:#} while staying in the current column{p_end}

{synopt:{cmd:up(}{it:#}{cmd:)}}move up {it:#} rows{p_end}

{synopt:{cmd:down(}{it:#}{cmd:)}}move down {it:#} rows{p_end}

{synopt:{cmd:left(}{it:#}{cmd:)}}move left {it:#} columns{p_end}

{synopt:{cmd:right(}{it:#}{cmd:)}}move right {it:#} columns{p_end}

{synopt:{cmd:f(}{it:extended function}{cmd:)}}insert an {help extended_fcn:extended macro function}{p_end}

{synopt:{cmd:r(}{it:name}{cmd:)} or {cmd:e(}{it:name}{cmd:)}}insert {help stored_results:results} 
stored by a previous command; see {findalias frresult}{p_end}

{synopt:{cmd:_continue}}suppresses automatic newline at end of {cmd:writex}
         command{p_end}

{p2colreset}{...}

{marker examples}{...}
{title:Examples}

{pstd}
It is usually easiest to precede {cmd:writex} with a {cmd:putexcel set} to set the file that you 
want to output to.

	{cmd:. putexcel set "my_output.xlsx", replace}
	{cmd:. matrix M = 1, 2, 3 \ 4, 5, 6}
	{cmd:. writex "Here is the matrix:" matrix(M)}

{pstd}
To insert the 2nd word of a series of words:

	{cmd:. local headings "mean" "standard error" "sub-sample"}
	{cmd:. writex f(word 2 of `headings')}
	
{pstd}
To output the value label associated with a value:

	{cmd:. writex f(label (foreign) 0)}

{pstd}
The following will run a series of regressions on the in-built data set auto.dta and write the 
coefficients to a table in the current spreadsheet.

	{cmd:. sysuse auto}
	{cmd:. writex \ \ "Coefficients from regression models" \ \ "variable" "coefficient on variable" "coefficient on constant term"}
	{cmd:. foreach v of varlist price-gear_ratio {c -(}}
	{cmd:	regress `v' foreign}
	{cmd:	writex f(variable label `v') e(b)}
	{cmd:  {c )-}}

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:writex} saves the position in the current spreadsheet as global macros:

	$WRITEX_FILE	the name of the file (workbook) that writex last wrote to
	$WRITEX_SHEET	the name of the worksheet that writex last wrote to
	$WRITEX_ROW	the row number of the current cell
	$WRITEX_COLUMN	the column number of the current cell

{pstd}
In Windows, putexcel and writex will not work if the file is currently open in Excel. File sharing 
systems such as Dropbox will also often access the file in synchronising, which can prevent 
putexcel and writex from working. Pausing synchronisation or temporarily exiting the file sharing 
software will usually fix this.

{pstd}
It is often useful to view the contents of the spreadsheet after outputting to it. In Windows this 
can be done using the shell command:

	{cmd:. shell my_output.xlsx}		opens the file using Excel or your default software for handling XLSX files

