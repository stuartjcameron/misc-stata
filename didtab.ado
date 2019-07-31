capture program drop didtab
program didtab, rclass
	// Produce DID table over a 0/1 treatment variable
	// comparing round 3 to the round specified in base (either 1 or 2)
	version 13.1
	syntax varname, over(varname) base(integer) sheet(string asis) [subpop(string)] [round(real .1)]
	display "varname: `varlist', over: `over', base: `base', round: `round'"
	if `"`subpop'"' == `""' {
		display `"svy: mean `varlist', over(round `over', nolabel)"'
		svy: mean `varlist', over(round `over', nolabel)
	}
	else {
		display `"svy, subpop(`subpop'): mean `varlist', over(round `over', nolabel)"'
		svy, subpop(`subpop'): mean `varlist', over(round `over', nolabel)
	}
	local round_number `round'
	local L = e(over_labels)
	
	matrix R = r(table)
	matrix M = J(4, 3, .)
	matrix list R
	foreach round in 1 2 3 {
		foreach group in 0 1 {
			findtoken `round' `group', in(`L')
			matrix M[`round', `=`group' + 1'] = R[1, r(P)]
			local v`round'`group' _subpop_`=r(P)'
			disp "v`round'`group' = `v`round'`group''"
		}
		matrix M[`round', 3] = M[`round', 2] - M[`round', 1]
	}
	forvalues i = 1/3 {
		matrix M[4, `i'] = M[3, `i'] - M[`base', `i']
	}
	if round {
		mata: st_matrix("M", round(st_matrix("M"), `round_number'))		// round to nearest .1
	}
	test `v31' - `v`base'1' = `v30' - `v`base'0'
	local stars = $stars
	local did = M[4, 3]
	display `"DID`did'--STARS`stars'"'
	if (`base' == 1) {
		putexcel B1=("Intervention during 2011/12-2014/15") ///
			B2=("0-1 years") C2=("2-3 years") D2=("Difference") ///
			A3=("2012 (CS1)") B3=matrix(M) /// 
			A4=("2014 (CS2)") A5=("2016 (CS3)") A6=("Difference (2012-2016)") ///
			D6=("`did' `stars'"), sheet(`sheet')
	}
	else if (`base' == 2) {
		matrix M = M[2..4, 1...]		// chop off top row of matrix
		putexcel B1=("Intervention during 2013/14-2014/15") ///
			B2=("0-1 years") C2=("2 years") D2=("Difference") ///
			A3=("2014 (CS2)") B3=matrix(M) /// 
			A4=("2016 (CS2)") A5=("Difference (2012-2016)") ///
			D5=("`did' `stars'"), sheet(`sheet')	
	}
	return matrix M = M
	return local result `did' `stars'
end
