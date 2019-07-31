capture program drop csmeans
program csmeans, rclass
	//--- Return simple and full matrices of disaggregated means 
	// by round (time) and an additional specified variable
	version 13.1
	syntax varname, over(varname) [subpop(string)] [round(real 0)]
	if `"`subpop'"' == `""' {
		local sub
	}
	else {
		local sub , subpop(`subpop')
	}
	local round_number `round'
	local v `varlist'
	quietly levelsof `over', local(over_levels)
	local groups: word count `over_levels'
	svy `sub': mean `v', over(round, nolabel)
	matrix Mean = e(b) \ vecdiag(e(V)) \ e(_N)
	local mean_labels = e(over_labels)
			
	// Statistical tests of change in average over time
	// Note, the indicator may not be available in all 3 rounds
	local format display cond(d > 0, "+", "") %3.1f d $stars
	if "`mean_labels'" == "1 2 3" {
		test [`v']3 - [`v']1 = 0
		scalar d = Mean[1, 3] - Mean[1, 1]
		local ch1: `format'
		test [`v']3 - [`v']2 = 0
		scalar d = Mean[1, 3] - Mean[1, 2]
		local ch2: `format'
	}
	else if "`mean_labels'" == "2 3" {
		local ch1 n/a
		test [`v']3 - [`v']2 = 0
		scalar d = Mean[1, 2] - Mean[1, 1]
		local ch2: `format'
	}
	else {
		local ch1 n/a
		local ch2 n/a
	}
	
	tempname F T D G
		
	// Disaggregated means
	svy `sub': mean `v', over(round `over', nolabel)
	matrix `D' = e(b) \ vecdiag(e(V)) \ e(_N)
	local disag_labels = e(over_labels)

	// Construct one-row matrix of the means by round and by round and level
	matrix `F' = J(3, `= 4 * `groups'', .)
	matrix `T' = J(1, 3, .)
	local j 1
	foreach round in 1 2 3 {
		foreach level in `over_levels' {
			findtoken `round' `level', in(`disag_labels')
			if r(P) {
				matrix `F'[1, `j'] = `D'[1, r(P)]
				matrix `F'[2, `j'] = sqrt(`D'[2, r(P)])
				matrix `F'[3, `j'] = `D'[3, r(P)]
			}
			local ++j
		}
		findtoken `round', in(`mean_labels')
		if r(P) {
			matrix `F'[1, `j'] = Mean[1, r(P)]
			matrix `T'[1, `round'] = Mean[1, r(P)]
			matrix `F'[2, `j'] = sqrt(Mean[2, r(P)])
			matrix `F'[3, `j'] = Mean[3, r(P)]
		}
		local ++j
	}
	matrix colnames `F' = `colnames'
	matrix `G' = `F'[1, `groups' * 3..`groups' * 4 - 1]
	if `round_number' {
		mata: st_matrix("`F'", round(st_matrix("`F'"), `round_number'))
		mata: st_matrix("`T'", round(st_matrix("`T'"), `round_number'))
		mata: st_matrix("`G'", round(st_matrix("`G'"), `round_number'))
	}
	return matrix Full = `F'
	return matrix Rounds = `T'
	return matrix Groups = `G'
	return local ch1 `ch1'
	return local ch2 `ch2'
end
