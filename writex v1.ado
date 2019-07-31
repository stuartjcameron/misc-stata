*! 1.0.1 Stuart Cameron 18jul2018 program writex
capture program drop writex
program writex
	version 13.1
	syntax anything(name=input) [using/], [MODify|replace] [SHeet(string asis)] [Format(string asis)]
	/*
	TODO
	- change so it compiles output to a local macro before a single putexcel
	- incorporate newer putexcel directives
	- remove putexcel set (so I won't have to reset the settings at the end either)
	
	BUGS
	- Following currently doesn't work:
		local headings "mean" "standard error" "sub-sample"
		writex f(word 2 of `headings')
		
	*/
	local workbook $PUTEXCEL_FILE_NAME
	local initial_sheet $PUTEXCEL_SHEET_NAME
	local initial_mode $PUTEXCEL_FILE_MODE
	local initial_format `format'
	local bracket 0
	local quote 0
	local c
	local i 1
	local height 1				// height of the current line
	local bottom 1				// bottom row of the sheet
	local input `"`input'"'
	local just_advanced 
	if "`using'" == "" {
		if "$PUTEXCEL_FILE_NAME" == "" {
			display as error "writex: no Excel file specified"
			error 198
		}
		if "`modify'" != "" {
			display as error "writex: option modify not allowed because no file name has been specified"
			error 198
		}
		if "`replace'" != "" {
			display as error "writex: option replace not allowed because no file name has been specified"
			error 198
		}
	}
	else {
		putexcel set `using', `modify' `replace' sheet(`sheet')
	}
	local changed_sheet = "$WRITEX_FILE_NAME" != "$PUTEXCEL_FILE_NAME" | "$WRITEX_SHEET_NAME" != "$PUTEXCEL_SHEET_NAME"
	local row = cond("$WRITEX_ROW" == "" | `changed_sheet', 1, 0$WRITEX_ROW)
	local column = cond("$WRITEX_COLUMN" == "" | `changed_sheet', 1, 0$WRITEX_COLUMN)
	global WRITEX_FILE_NAME $PUTEXCEL_FILE_NAME
	global WRITEX_SHEET_NAME $PUTEXCEL_SHEET_NAME
	foreach w in `input' {
		//local w `"``i''"'
		local command none
		local have_put 0							// whether anything has been put in the current cycle
		if length(`"`c'"') == 0 {
			local c `"`w'"'
		}
		else {
			local c `"`c' `w'"'	// add word to the current part
		}
		// Resolve brackets within the current segment
		forvalues j = 1/`: length local w' {	// resolve quotes & brackets in current word
			local ch = substr(`"`w'"', `j', 1)
			if `"`ch'"' == `"""' {
				local quote = !`quote'
			}
			else if !`quote' {
				if `"`ch'"' == "(" {
					local ++bracket
				}
				else if `"`ch'"' == ")" {
					local --bracket
					if `bracket' < 0 {
						display as error _newline "Too many closing parentheses"
						error 132
					}
				}
			}
		}
		if !`bracket' {	
			
			// Write the output to excel
			local put putexcel `=char(64+`column')'`row'=
			display as text `"Output `=char(64+`column')'`row' = `c'"'
			if substr(`"`c'"', -1, 1) == ")" {
				local inner
				foreach p in "" matrix f e r cell up down left right sheet file row column {
					local L = length("`p'")
					if substr(`"`c'"', 1, `L' + 1) == "`p'(" {
						local inner = substr(`"`c'"', `L' + 2, length(`"`c'"') - `L' - 2)
						local command `p'
						continue, break
					}
				}
				if `"`command'"' == "none" {
					display as error _newline `"Invalid command in `c'"'
					error
				}
				else if `"`inner'"' == "" {			// no content found inside opening brackets (but continue with programme)
					display as error _newline `"No content found in: `c'"'
				}
				else if "`command'" == "" | "`command'" == "matrix" {	// expression or matrix
					if "`format'" == "" {
						capture: `put'`c'
					}
					else {
						capture: `put'(`: display `format' `c'')
					}
					if _rc {	
						`put'("`c'")
					}
					local have_put 1
				}
				else if "`command'" == "f" {		// extended macro function
					local function = substr(`"`c'"', 3, length(`"`c'"') - 3)
					if "`format'" == "" {
						`put'("`: `function''")
					}
					else {
						`put'("`: display `format' `function''")
					}
					local have_put 1
				}
				else if "`command'" == "e" | "`command'" == "r" {		// return value
					local inner `command'(`inner')
					if "`format'" == "" {
						capture `put'(`inner')
					}
					else {
						capture `put'("`: display `format' `inner''")
					}
					if _rc == 509 | _rc == 109 {				// return value is a matrix
						`put'matrix(`inner')
						local command matrix
					}
					local have_put 1
				}
			}
			else if `"`c'"' == "_newrow" | `"`c'"' == "_clear" | `"`c'"' == "_continue" {
				local command = substr(`"`c'"', 2, length(`"`c'"') - 1)
			}
			else if `"`c'"' == "_newline" | `"`c'"' == "\" {
				local command newline
			}
			else if substr(`"`c'"', 1, 1) == "%" {
				quietly display `"`c'"'			// interrupt programme if invalid format
				local format `"`c'"'
				local command format
			}
			else {													// text or number
				if "`format'" == "" {
					`put'("`c'")
				}
				else {
					`put'("`: display `format' `c''")
				}
				local have_put 1
			}
			local go_back `just_advanced'
			local just_advanced 0
			
			// Update workbook, sheet and cursor position 
			if "`command'" == "matrix" {
				matrix __M = `inner'
				local column = `column' + colsof(__M)
				local height = max(`height', rowsof(__M))
			}
			else if "`command'" == "cell" {	// move to cell in A1 format
				local row
				local column 0
				forvalues p = 1/`= length("`inner'")' {
					local ch = substr("`inner'", `p', 1)
					if inrange("`ch'", "A", "Z") {
						forvalues k = 1/26 {
							if "`ch'" == char(64 + `k') {
								local column = 26 * `column' + `k'
								continue, break
							}
						}
					}
					else {
						local row `row'`ch'
					}
				}
				local height 1
			}
			else if "`command'" == "row" | "`command'" == "column" {	// move to given row and column
				local `command' = `inner'
				local height 1
			}
			else if "`command'" == "left" {
				local column = `column' - `inner' - `go_back'	// go back if advanced 1 sq to right in previous move
			}
			else if "`command'" == "right" {
				local column = `column' + `inner' - `go_back'
			}
			else if "`command'" == "up" {
				local row = `row' - `inner'
				local column = `column' - `go_back'
				local height 1
			}
			else if "`command'" == "down" {
				local row = `row' + `inner'
				local column = `column' - `go_back'
				local height 1
			}
			else if "`command'" == "newline" {
				local row = `row' + `height'
				local column 1
				local height 1
			}
			else if "`command'" == "newrow" {
				local ++row
				local column 1
				local height = max(1, `height' - 1)
			}
			else if "`command'" == "clear" {
				local row `bottom'
				local column 1
			}
			else if "`command'" != "continue" & "`command'" != "format" {
				local ++column
				local just_advanced 1
			}
			if `have_put' {
				local bottom = max(`bottom', `row' + `height' + 1)
				local format `initial_format'
			}
			local c
		}
		local ++i
	}
	if `bracket' > 0 {
		display as error _newline "Too many opening parentheses"
		error 132
	}
	if `quote' {
		display as error _newline "Unmatched quotation marks"
		break
	}
	if "`command'" != "continue" {
		local row = `row' + `height'
		local column 1
	}
	
	// Save position
	global WRITEX_COLUMN `column'
	global WRITEX_ROW `row'
	
	// Restore original values if putexcel set was changed
	if "`using'" != "" {
		putexcel set `workbook', sheet(`sheet_name') `initial_mode'
	}
end