capture program drop across
program across 
	version 13.1
	// --- Copy across values from one group of rows to another
	// --- e.g. across stratum, from(round==2) by(school_id) to(round==3)
	// school_id has to uniquely identify the data within round == 2
	// Copies across the listed variables for each value of school_id where
	// round==2, to the case with each value of school_id where round==3
	
	/* to do:
	/ - add a postfix option equivalent to
	gen x`postfix' = x if `from'
	across y, from(`from') by(`school_id') to(`to')
	/ - make to optional; default is !`from'
	- add a replace option which has to be specified if no postfix is given, i.e.
	replace the existing variable
	- alternatively: postfix defaults to a sanitised version of `from' 
	eg. from(round == 2) => round2, but this seems less transparent
	
	- Also want to deal with cases where from and by do not uniquely identify cases
	but do uniquely identify values of varlist. In these cases, the function should still be able to work.
	
	Workaround:
	egen tag = tag(`from' `by')
	across `var', from(`from' & tag) by(`by') etc.
	
	*/
	
	syntax varlist, from(string asis) by(varlist) [to(string asis)] [postfix(string)]
	if `"`to'"' == `""' {
		local to !(`from')
	}
	display `"from: `from', to: `to', by: `by', postfix: `postfix'"'
	if `"`postfix'"' != `""' {
		local newvarlist
		foreach v of varlist `varlist' {
			gen `v'`postfix' = `v' if `from'
			local newvarlist `newvarlist' `v'`postfix'
			local label: variable label `v'
			label variable `v'`postfix' `"`label' (`from')"'
		}
		local varlist `newvarlist'
	}
	duplicates report `by' if `from'
	if r(unique_value) != r(N) {
		display as error `"`by' and `from' do not uniquely identify cases"'
		//TODO: drop generated variables
		exit
	}
	duplicates report `by' if `to'
	local unique = r(unique_value) == r(N)
	if !`unique' {
		display as error `"Warning: `by' and `to' do not uniquely identify cases. Copying to all cases."'
	}
	tempvar flag
	gen `flag' = `to'
	preserve
		keep if `from'
		keep `by' `varlist'
		gen `flag' = 1
		tempfile f
		save `f'
	restore
	capture drop merge_across
	merge m:1 `by' `flag' using `f', keepusing(`varlist') update replace ///
		keep(master match match_update match_conflict) generate(merge_across)
end
