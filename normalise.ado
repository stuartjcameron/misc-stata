capture program drop normalise
program normalise
//--- Normalise with svy weights, optionally within groups
	syntax varlist, postfix(string) [by(varlist)] [svy] [subpop(string)] [mean(real 0)] [sd(real 1)]
	/* to do:
	- option to preserve means and sds
	/- do not use svy if option not selected
	*/
	local svyprefix
	local meanif
	local if
	if strpos(`"`subpop'"', "if ") == 1 {
		local if `subpop' 
	}
	else if `"`subpop'"' != `""' {
		local if if `subpop' & !missing(`subpop')
	}
	if "`svy'" == "" {
		local meanif `if'
	}
	else {
		local svyprefix svy, subpop(`subpop'): 
	}
	*display `"svy: `svy', if: `if', meanif: `meanif', svyprefix: `svyprefix', by: `by'"'
	if `"`by'"' == `""' {
		foreach v in `varlist' {
			`svyprefix' mean `v' `meanif'
			matrix M = r(table)
			matrix N = e(_N)
			gen `v'`postfix' = `mean' + `sd' * (`v' - M[1, 1]) / (M[2, 1] * sqrt(N[1, 1])) `if'
		}
	}
	else {
		tempvar group
		egen `group' = group(`by')
		quietly sum `group'
		local groups = r(max)
		foreach v in `varlist' {
			`svyprefix' mean `v' `meanif', over(`group', nolabel)
			local labels = e(over_labels)
			matrix M = r(table)
			matrix N = e(_N)
			matrix S = J(`groups', 2, .)
			forvalues i=1/`: word count `labels'' {
				display "Label `i': `: word `i' of `labels''"
				matrix S[`: word `i' of `labels'', 1] = M[1, `i'], M[2, `i'] * sqrt(N[1, `i'])
			}
			gen `v'`postfix' = `mean' + `sd' * (`v' - S[`group', 1]) / S[`group', 2] `if'
		}
	}
end
