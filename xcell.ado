capture program drop xcell
program xcell, rclass
// --- Provide row and col information on an Excel cell
// Optionally offset by 'right' columns and 'down' rows
// If no cell is provided, it takes r(cell) from the previous call.
// Optionally provide a global macro name to store the cell, e.g.
// xcell my_cell = A3 -- stores A3 in $my_cell
	version 13.1
	syntax [anything(equalok)], [right(integer 0)] [down(integer 0)] [row(integer 0)] ///
		[COLumn(integer 0)] [local(name local)]
	local anything = subinstr(`"`anything'"', `"="', `" "', .)
	local words: word count `anything'
	if `words' == 0 {
		local xcell = r(xcell)
	}
	else if `words' == 1 {
		if regexm(`"`anything'"', "^[A-Za-z][A-Za-z]?[A-Za-z]?[0-9][0-9]?[0-9]?[0-9]?[0-9]?[0-9]?[0-9]?$") {
			local xcell = upper(`"`anything'"')
		}
		else {
			local global `anything'
			local xcell $`global'
		}
	}
	else if `words' == 2 {
		local global: word 1 of `anything'
		local xcell: word 2 of `anything'
	}
	else {
		display "Syntax is xcell [global] [cell ref], ..."
		error 198
	}
	if (`row' & `down') | (`column' & `right') {
		display "Cell was not specified correctly"
		error 198
	}
	local cell_column 0
	*display "Cell `xcell'"
	forvalues i = 1 / `= length(`"`xcell'"')' {
		local ch = substr(`"`xcell'"', `i', 1)
		*display `"Find `ch' in `c(ALPHA)'"'
		quietly findtoken `ch', in(`c(ALPHA)')
		if r(P) > 0 {
			local cell_column = `cell_column' * 26 + r(P)
		}
		else {
			local n = substr(`"`xcell'"', `i', length(`"`xcell'"') - `i' + 1)
			local cell_row = real("`n'")
			continue, break
		}
	}
	if `column' {
		local new_column = `column'
	}
	else {
		local new_column = `cell_column' + `right'
	}
	if `row' {
		local new_row = `row'
	}
	else {
		local new_row = `cell_row' + `down'
	}
	local c `new_column'
	local letters
	while `c' > 0 {
		local r = mod(`c' - 1, 26) + 1
		local c = int((`c' - `r') / 26)
		local letter: word `r' of `c(ALPHA)'
		local letters `letter'`letters'
	}
	display "From cell `xcell' (column `cell_column', row `cell_row')," ///
		"right `right', down `down' => `letters'`new_row' (column `new_column', row `new_row')"
	return scalar row = `new_row'
	return scalar column = `new_column'
	local new_cell `letters'`new_row'
	return local xcell = `"`letters'`new_row'"'
	if `"`local'"' != `""' {
		c_local `local' `new_cell'
	}
	if `"`global'"' != `""' {
		global `global' `new_cell'
	}
end
	

