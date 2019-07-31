capture program drop petab
program petab
	// svy means in a twoway table and output results to Excel sheet using putexcel
	// later: add options for other statistics (SEs, CIs etc.)
	// / add option of one-way tables
	// x alter syntax to resemble tab x y, sum(z)
	// add option for other statistics as in tab	
	// add option of specifing multiple variables (tabulate one after the other or all in same table...)
	// / Add col/row means by default 
	// Consider options to remove col/row means
	// Default: variable labels in col A, left sub-group labels in col B
	// return cell below bottom of table
	// option to suppress top header -- so that user can continue below.
	// Adjust so that it works for non-labelled variables
	// Requires: findtoken; labelsof
	
	syntax varname, [top(varname)] [left(varname)] [subpop(string)] sheet(string) [cell(string)] [round(real 0)]
	if `"`subpop'"' == `""' {
		local sub
	}
	else {
		local sub , subpop(`subpop')
	}
	if "`cell'" == "" {
		local cell A1
	}
	
	local type = cond(`"`top'"' == `""', ///
		cond(`"`left'"' == `""', "single", "column"), ///
		cond(`"`left'"' == `""', "row", "table"))
	
	// Overall mean
	svy `sub': mean `varlist'
	matrix T = r(table)
	matrix T = T[1, 1]
	
	if `"`top'"' != `""' {
		labelsof `top'
		local toplabels = r(labels)
		local toplevels = r(values)
		local topn: word count `toplevels'
		
		// Total row
		matrix TR = J(1, `topn', .)
		svy `sub': mean `varlist', over(`top', nolabel)
		matrix R = r(table)
		local outputlevels = e(over_labels)
		forvalues i = 1/`topn' {
			local toplevel: word `i' of `toplevels'
			findtoken `toplevel', in(`outputlevels')
			matrix TR[1, `i'] = R[1, r(P)]		
		}
	}
	
	if `"`left'"' != `""' {
		labelsof `left'
		local leftlabels = r(labels)
		local leftlevels = r(values)
		local leftn: word count `leftlevels'
		matrix TC = J(`leftn', 1, .)
		
		// Total column
		svy `sub': mean `varlist', over(`left', nolabel)
		matrix R = r(table)
		local outputlevels = e(over_labels)
		forvalues i = 1/`leftn' {
			local leftlevel: word `i' of `leftlevels'
			findtoken `leftlevel', in(`outputlevels')
			matrix TC[`i', 1] = R[1, r(P)]
		}
	}
	
	if "`type'" == "table" {
		matrix M = J(`leftn', `topn', .)
		* display `"--svy `sub': mean `varlist', over(`top' `left', nolabel)--"'
		
		// Disaggregated table
		svy `sub': mean `varlist', over(`top' `left', nolabel)
		local outputlevels = e(over_labels)
		matrix R = r(table)
		forvalues i = 1/`leftn' {
			local leftlevel: word `i' of `leftlevels'
			forvalues j = 1/`topn' {
				local toplevel: word `j' of `toplevels'
				* display `"Looking for --`toplevel' `leftlevel'-- in --`meanlabels'--"'
				findtoken `toplevel' `leftlevel', in(`outputlevels')
				matrix M[`i', `j'] = R[1, r(P)]
				* display "Found M[`i', `j'] = R[1, `=r(P)']"
			}
		}
	}
	
	
	if "`type'" == "table" {
		matrix F = M, TC \ TR, T
		local colnames `"`toplabels' "Total""'
		local rownames `"`leftlabels' "Total""'
	}
	else if "`type'" == "column" {
		matrix F = TC \ T
		local rownames `"`leftlabels' "Total""'
		local colnames Total	// Could omit or use variable label here instead
	}
	else if "`type'" == "row" {
		matrix F = TR, T
		local rownames Total	// Could omit or use variable label here instead
		local colnames `"`toplabels' "Total""'
	}
	else {
		matrix F = T
		local rownames Total
		local colnames Total
	}
	
	if `round' {
		 mata: st_matrix("F", round(st_matrix("F"), `round'))
	}
	
	matrix rownames F = `rownames'
	matrix colnames F = `colnames'

	matrix list F
	putexcel `cell'=matrix(F, names), sheet(`sheet') 	
end
