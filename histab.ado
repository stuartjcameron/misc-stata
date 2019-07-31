capture program drop histab
program histab, rclass
// --- Output a table of frequency percentages by interval that can be used to make
// a banded histogram for composite surveys
// Uses a 'round' variable for change over time
/*
to do:
- add ability to include labels for some of the bands (return these as local macro? ultimately want to output to excel)
- refactor to make more usable for other projects
*/
	syntax varname [aweight], band(varname) intervention(varname) [interval(real 20)] [label(varlist)]
	display "Weight: `weight'; Weight expression: `exp'; cont variable: `varlist'; band: `band'; intervention: `intervention'"
	local s `varlist'
	tempvar group
	tempname T M R S 
	gen `group' = int(`s' / `interval') * `interval'	
	quietly sum `group'
	local min = r(min)
	local max = r(max)
	local cats = (`max' - `min') / `interval' + 1
	matrix `T' = J(`cats', 6, 0)
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
	foreach round in 1 2 3 {
		quietly tab `group' [`weight'`exp'] if round == `round', matcell(`M') matrow(`R') 
		local N = r(N)
		local rows = rowsof(`M')
		forvalues i=1/`rows' {
			local groupi = `R'[`i', 1]
			matrix `T'[(`groupi' - `min') / `interval'  + 1, 5 - `round'] = 100 * `M'[`i', 1] / `N'
		}
	}
	quietly tab `group' `intervention' [`weight'`exp'] if round == 3, matcell(`M') matrow(`R') 
	mata: st_matrix("`S'", colsum(st_matrix("`M'")))
	local rows = rowsof(`M')
	forvalues i = 1/`rows' {
		local groupi = `R'[`i', 1]
		matrix `T'[(`groupi' - `min') / `interval' + 1, 6] = 100 * `M'[`i', 1] / `S'[1, 1] 
		matrix `T'[(`groupi' - `min') / `interval' + 1, 5] = 100 * `M'[`i', 2] / `S'[1, 2]
	}
	matrix colnames `T' = "Scale score" "2016 (CS3)" "2014 (CS2)" "2012 (CS1)" "Intervention" "No intervention"
	matrix rownames `T' = `rownames'
	matrix list `T'
	
	// Add round 3 labels if specified
	if `"`label'"' != `""' {
		foreach v in `label' {
			mean `s' if `v' == 1 & round == 3
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
