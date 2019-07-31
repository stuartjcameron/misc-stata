  /*
Project: UNESCO Institute of Statistics handbook on measuring education equity
Purpose: Calculate basic ratio indices of equity in education
Author: Stuart Cameron
Contact: stuart.cameron@opml.co.uk
*/
capture program drop impartial
program impartial, rclass
	//--- Present impartiality (inter-group equity) measures of a given binary outcome
	/* TODO:
		- Present relevant measures for continuous outcomes too (though gap and ratio should be fine as they are)
		? Present other appropriate statistics for a continuous class variable, e.g. Pearson's rho, bivariate regression coefficient and R2
		- remove irrelevant measures for continuous outcomes (odds ratio - should it be called something else?)
		? Version for multiple categorical measure; ordinal measures?
		- Make weights work (pass them to mean)
		- allow if, in
		? Make svy work
		/ Focus is 1st category found if not specified
		/ Add adjusted parity index
		/ Add odds ratio
		/ Add effect size (Phi = Pearson's rho)
		? Add something like t-test or proportion test - could add standard error and significance test of each measure
		(i.e. whether different from 0 for gap or correlation coefficient, different from 1 for ratio, adj parity ratio, odds ratio)
		- alternatively provide confidence intervals
		/ Return the values as well as displaying them
		
		? Compare quantiles of a continuous class variable
		e.g. impartial EC5=Yes No, over(wscore=Q1 Q5)
		/ alternative syntax like impartial, outcome(EC5=Yes No) over(HL4=Female Male)
		? allow plausible values
		/- to treat outcome as continuous, simply don't provide categories: impartial books, over(HL4=Female Male)
		
	*/
	//syntax [fweight aweight iweight pweight], outcome(string) over(string) 
	//syntax varname [=/exp], over(string) // [fweight aweight iweight pweight], over(string) 
	version 13.1
	syntax anything(name=outcome equalok) [fweight aweight iweight pweight], over(string) [bar] [hbar] [graphoptions(string asis)]
	set varabbrev off 			// alternatively use novarabbrev 
	
	// Parse outcome and over into variable name and, if present, labels/values
	gettoken outcomevar rest: outcome, parse("=")
	gettoken _ outcomevals: rest, parse("=")
	gettoken overvar rest: over, parse("=")
	gettoken _ overvals: rest, parse("=")
	if "`bar'" == "bar" & "`hbar'" == "hbar" {
		display as error "Only one type of bar chart may be shown"
		exit
	}
	local graph = "`bar'" == "bar" | "`hbar'" == "hbar"
	if `graph' {
		local graph_type = "`bar'`hbar'"
	}
	local noutcomevals: word count `outcomevals'
	local novervals: word count `overvals'
	local outcomelabel: variable label `outcomevar'
	local overlabel: variable label `overvar'
	local overhaslabels = `"`: value label `overvar''"' != `""'
	local outcomehaslabels = `"`: value label `outcomevar''"' != `""'
	quietly levelsof `outcomevar', local(outcomelevels)
	quietly levelsof `overvar', local(overlevels)
	local binaryoutcome = `: word count `outcomelevels'' == 2
	local binaryover = `: word count `overlevels'' == 2
	forvalues i = 1/`noutcomevals' {
		quietly getlevel `outcomevar', value(`: word `i' of `outcomevals'') local(outcome`i')
	}
	forvalues i = 1/`novervals' {
		quietly getlevel `overvar', value(`: word `i' of `overvals'') local(over`i')
	}
	/*
	// Debugging info
	display `"outcomevar: `outcomevar'; outcomevals: `outcomevals' noutcomevals: `noutcomevals'"'
	display `"overvar: `overvar'; overvals: `overvals'; novervals: `novervals'"'
	display `"levels: `outcomelevels' / `overlevels' "'
	display `"values: outcome `outcome1', `outcome2' over `over1', `over2'"'
	display `"has labels: outcome `outcomehaslabels' over `overhaslabels'"'
	*/
	
	/* Parsing over variable:
	1. If 1 label or value is given, compare this to other non-missing.
	2. If 2 labels or values are given, compare the two corresponding values
	3. If no labels or values given, compare the first category found to other non-missing
	(Then later: allow quintiles etc.)
	*/
	tempvar overrec
	if `novervals' == 0 {
		local over1: word 1 of `overlevels'
		local over2 nonmissing
		//recode `overvar' (`over1'=1) (nonmissing=0) (missing=.), gen(`overrec')
		local over1_label: label (`overvar') `over1'
		local over2_label "other non-missing values"
		quietly recode `overvar' (`over1'=1) (`over2'=0) (missing=.), gen(`overrec')
	}
	else if `novervals' == 1 {
		local over2 nonmissing
		local over1_label: label(`overvar') `over1'
		local over2_label "other non-missing values"
		quietly recode `overvar' (`over1'=1) (`over2'=0) (missing=.), gen(`overrec')
	}
	else if `novervals' == 2 {
		local over1_label: label(`overvar') `over1'
		local over2_label: label(`overvar') `over2'
		//display `"RECODING recode `overvar' (`over1'=1) (`over2'=0) (else=.), gen(`overrec')	"'
		quietly recode `overvar' (`over1'=1) (`over2'=0) (else=.), gen(`overrec')	
	}
	else {
		display as error `"Too many values given for the over variable `over'"'
		exit
	}
	
	// If the comparison group is 'nonmissing' but there is only one other 
	// nonmissing value, then label the value appropriately in output
	if `binaryover' & `"`over2'"' == `"nonmissing"' {
		foreach level of local overlevels {
			if `over1' != `level' {
				local over2 `level'
				local over2_label: label(`overvar') `over2'
				continue, break
			}
		}
	}
	
	
	/*Parsing outcome variable:
	1. If no label or value is given, treat the outcome as continuous
	2. If 1 label or value is given, treat it as binary, comparing the given category to other non-missing
	3. If 2 labels or values are given, treat it as binary, comparing the two given categories (treating the first as 'positive')
	*/
	tempvar outcomerec
	if `noutcomevals' == 0 {
		generate `outcomerec' = `outcomevar'
		local outcometype continuous
	}
	else if `noutcomevals' == 1 {
		local outcome1_label: label (`outcomevar') `outcome1'
		local outcome2 nonmissing
		local outcome2_label "other non-missing values" 
		local outcometype binary
		quietly recode `outcomevar' (`outcome1'=1) (nonmissing=0) (missing=.), gen(`outcomerec')
	}
	else if `noutcomevals' == 2 {
		local outcome1_label: label (`outcomevar') `outcome1'
		local outcome2_label: label (`outcomevar') `outcome2'	
		local outcometype binary
		quietly recode `outcomevar' (`outcome1'=1) (`outcome2'=0) (else=.), gen(`outcomerec')
	}
	else {
		display as error `"Too many values given for the outcome variable `outcome'"'
		exit
	}
	/*
	if "`outcometype'" == "binary" {
		//display `"RECODING `outcomevar' (`outcome1'=1) (`outcome2'=0) (else=.), gen(`outcomerec')"'
		if `"`outcome2'"' == `"nonmissing"' {
			quietly recode `outcomevar' (`outcome1'=1) (nonmissing=0) (missing=.), gen(`outcomerec')
		}
		else {
			quietly recode `outcomevar' (`outcome1'=1) (`outcome2'=0) (else=.), gen(`outcomerec')
		}
	}
	*/
	
	// If the second outcome is 'nonmissing' but there is only one other 
	// nonmissing value, then label the value appropriately in output
	if `binaryoutcome' & `"`outcome2'"' == `"nonmissing"' {
		foreach level of local outcomelevels {
			if `outcome1' != `level' {
				local outcome2 `level'
				local outcome2_label: label(`outcomevar') `outcome2'
				continue, break
			}
		}
	}
	
	quietly mean `outcomerec' if !missing(`overrec')
	matrix M = r(table)
	scalar overall = M[1, 1]
	quietly mean `outcomerec' if `overrec' == 0
	matrix M = r(table)
	scalar c = M[1, 1]
	quietly mean `outcomerec' if `overrec' == 1
	matrix M = r(table)
	scalar f = M[1, 1]

	local colon = cond(`"`outcomelabel'"' == `""', "", ": ")
	display as text _newline `"Comparing `outcometype' outcome `outcomevar'`colon'`outcomelabel'"'
	local label = cond(`overhaslabels', ", `over1_label'", "")
	display "for " as result `"Group A (`overvar'=`over1'`label')"' _continue
	if `"`over2'"' == `"nonmissing"' {
		local valuepart "other non-missing values"
	}
	else if `overhaslabels' {
		local valuepart `over2', `over2_label'
	}
	else {
		local valuepart `over2'
	}
	display as text " compared to " as result `"Group B (`overvar'=`valuepart')"'
	display 
	local graph_labelA = cond(`overhaslabels', "`over1_label'", "`over1'")
	local graph_labelB = cond(`overhaslabels', "`over2_label'", "`over2'")
	local h display %-40s as text
	local r as result %4.3f
	
		
	if `"`outcometype'"' == `"binary"' {
		display as text `"Proportion with outcome `outcome1'"' _continue
		local graph_outcome_label "outcomevar=`outcome1'"
		if `outcomehaslabels' & `"`outcome1_label'"' != `""' & `"`outcome1_label'"' != `"`outcome1'"' {
			display `" (`outcome1_label')"' _continue
			local graph_outcome_label `"`outcome1_label'"'
		}
		display " versus " _continue
		if "`outcome2'" == "nonmissing" {
			display "other nonmissing values"
		}
		else {
			display `"`outcome2'"' _continue
			if `outcomehaslabels' & `"`outcome2_label'"' != `""' & `"`outcome2_label'"' != `"`outcome2'"' {
				display `" (`outcome2_label')"'
			}
			else {
				display
			}
		}
		`h' "% in group A or B" `r' (overall * 100)
		`h' `"% in group A"' `r' (f * 100)
		`h' `"% in group B"' `r' (c * 100)
	}
	else {
		display "Average value of outcome variable"
		`h' "In group A or B" `r' overall
		`h' `"In group A"' `r' f
		`h' `"In group B"' `r' c
	}
	
	
	scalar gap = 100 * (f - c)
	scalar ratio = f / c
	//scalar gap = abs(vgap)
	scalar minratio = min(ratio, 1/ratio)
	// scalar odds_ratio = (c * (1 - f)) / (f * (1 - c)) // report the reverse, i.e. odds of good outcome
	scalar odds_ratio = (f * (1 - c)) / (c * (1 - f))
	scalar adjusted_ratio = cond(f <= c, f / c, 2 - c / f)
	quietly correlate `outcomerec' `overrec'
	scalar phi = r(rho)
	display
	`h' "Gap (A - B)" `r' gap 
	`h' "Ratio (A / B)" `r' ratio
	//disp %-40s as text "Absolute gap |F - C|" as result  %4.3f gap  // No point in displaying this as it can easily be read by removing the sign from the gap
	`h' "Min ratio (min(A / B, B / A))" `r' minratio
	`h' "Adjusted parity ratio" `r' adjusted_ratio
	`h' "Odds ratio" `r' odds_ratio
	`h' "Pearson's correlation coefficient" `r' phi
	
	// Display bar charts if requested
	if `graph' {
		if `"`outcometype'"' == `"binary"' { 		
			tempvar graphover
			label variable `outcomerec' `"`outcomelabel'"'
			quietly replace `outcomerec' = `outcomerec' * 100
			quietly recode `overrec' (0 = 2 "Group B (`graph_labelB')") (1 = 1 "Group A (`graph_labelA')"), gen(`graphover') 
			local cattitle = cond("`graph_type'" == "bar", "b1title", "l1title")
			graph `graph_type' (mean) `outcomerec', over(`graphover') `cattitle'(`"`overlabel'"') ytitle(`"`graph_outcome_label' (%)"') `graphoptions'
		} 
		else {		
			tempvar graphover
			label variable `outcomerec' `"`outcomelabel'"'
			quietly recode `overrec' (0 = 2 "Group B (`graph_labelB')") (1 = 1 "Group A (`graph_labelA')"), gen(`graphover') 
			local cattitle = cond("`graph_type'" == "bar", "b1title", "l1title")
			graph `graph_type' (mean) `outcomerec', over(`graphover') `cattitle'(`"`overlabel'"') ytitle(`"`outcomelabel'"') `graphoptions'
		}		
	}
	
	
	// Return values	
	return scalar gap = gap
	return scalar absgap = abs(gap)
	return scalar ratio = ratio
	return scalar minratio = minratio
	return scalar adjratio = adjusted_ratio
	return scalar or = odds_ratio
	return scalar rho = phi
	
end


capture program drop getlevel
program getlevel, rclass
	//--- Given a level (value) or label, return the level for a given variable
	// optionally return the level in a local macro
	// note, if the given value is both a value and a label, the value associated with the label will be returned
	version 13.1
	syntax varname, value(string) [local(string)]
	local v `varlist'
	capture confirm number `value'
	if _rc == 0 {		// If value is a number, then by default just return the same number
		local r = `value'
	}
	
	local haslabels = `": value label `v'"' != `""'
	//display `"`v'; `value'; `local'; `haslabels'"'
	
	if `haslabels' {
		
		// Variable has labels, so first check if value is found there
		quietly levelsof `v', local(levels)
		/* Note, we end up repeatedly calling levelsof. It would be more optimal
		to pass the levels (rather than the variable name) to getlevel to avoid this */
		foreach level of local levels {
			if `"`value'"' == `"`: label (`v') `level''"' {
				local r = `level'
				display `"Found `value' in the labels of `v' for value `level'"'
				continue, break
			}
		}
	}
	if `"`r'"' == `""' {
		display as error `"Value `value' is non-numeric and "' _continue
		display as error cond(`haslabels', "was not found in labels of `v'", "`v' does not have labels")
		exit
	}
	if `"`local'"' != `""' {
		c_local `local' `r'
	}
	return local level `r'	
end 
	




