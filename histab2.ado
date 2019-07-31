capture program drop histab2
program histab2, rclass
// --- Output a table of frequency percentages by interval that can be used to make
// a banded histogram for composite surveys
// histab2 is a simplified version generating data for a single histogram
/*
to do:
- add ability to include labels for some of the bands (return these as local macro? ultimately want to output to excel)
- refactor to make more usable for other projects
*/
	syntax varname [aweight] [if], band(varname) ///
		[interval(real 0)] [label(varlist)] [bins(integer 0)]
	preserve
	keep `if'
	display "Weight: `weight'; Weight expression: `exp'; cont variable: `varlist'; band: `band';"
	local s `varlist'
	tempvar group
	tempname T M R S 
	if `interval' == 0 {
		if `bins' == 0 {
			local bins 40
		}
		sum `s' `if'
		local interval = (r(max) - r(min)) / `bins'
	}
	
	gen `group' = int(`s' / `interval') * `interval'	
	quietly sum `group'
	local min = r(min)
	local max = r(max)
	local cats = (`max' - `min') / `interval' + 1
	matrix `T' = J(`cats', 2, 0)
	local rownames
	local last_band = -1
	forvalues i = 1/`cats' {
		local group_bottom = (`i' - 1) * `interval' + `min'
		matrix `T'[`i', 1] = `group_bottom'
		quietly sum `band' if `s' >= `group_bottom'
		local minband = r(min)
		if `minband' == `last_band' {
			local rownames `"`rownames' ",,""'
		}
		else {
			local rownames `"`rownames' "Band `minband'""'
		}
		local last_band `minband'
	}
	quietly tab `group' [`weight'`exp'] `if', matcell(`M') matrow(`R')
	local N = r(N)
	local rows = rowsof(`M')
	forvalues i=1/`rows' {
		local groupi = `R'[`i', 1]
		matrix `T'[(`groupi' - `min') / `interval'  + 1, 2] = 100 * `M'[`i', 1] / `N'
	}
	
	matrix colnames `T' = "Scale score" "% of learners"
	matrix rownames `T' = `rownames'
	matrix list `T'
	
	// Add round 3 labels if specified
	if `"`label'"' != `""' {
		foreach v in `label' {
			mean `s' [`weight'`exp'] if `v' == 1
			matrix `M' = r(table)
			local groupi = int((`M'[1, 1] - `min') / `interval') + 1
			local labeltext: variable label `v'
			if `"`labeltext'"' == `""' {
				local labeltext `v'
			}
			local label`groupi' `label`groupi'' `labeltext'
		}
		local labels
		forvalues i=1/`cats' {
			display "Group `i' score: " `T'[`i', 1] `" - label: `label`i''"'
			return local label`i' `label`i''
			local labels `"`labels' "`label`i''""'
			disp `"Labels -`i'--`labels'--"'
		}
		return local labels = substr(`"`labels'"', 2, .)
	}
	return matrix T = `T'
end
