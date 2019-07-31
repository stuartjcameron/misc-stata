capture program drop cstab
program cstab
	//--- Create standard composite survey tables including full disaggregation
	// for annex and tables showing change over time and differences between groups
	
	// todo: add cell option to place top of table
	version 13.1
	syntax anything using/, [modify] [replace] over(varname) [subpop(string)] [name(string)] [dose(name)] [round(real 0)] [heading(string asis)]
	unabany varlist: `anything'
	local round_number `round'
	local l: display _column(10) _dup(30) "*"
	if `"`heading'"' == `""' {
		local heading1 min
		local heading2 med
		local heading3 max
	}
	else {
		local heading1: word 1 of `heading'
		local heading2: word 2 of `heading'
		local heading3: word 3 of `heading'
	}
	display `"Headings: 1 `heading1' 2 `heading2' 3 `heading3'"'
	display "`l'" _newline "`l'" _newline "`l'"
	display _column(10) "PAUSE YOUR DROPBOX & CLOSE YOUR EXCEL WORKBOOKS" 
	display "`l'" _newline "`l'" _newline "`l'"
	display "Initialising CS tables"
	quietly labelsof `over'
	local colnames = (r(labels) + "ave ") * 3
	levelsof `over', local(over_levels)
	local groups: word count `over_levels'
	local variables: word count `varlist'
	
	// subpop can be in the form 'if state==14'. Separate the 'if' part from 
	// the condition
	local subif = cond(`"`subpop'"' == `""', "", "if")
	local subcond `subpop'
	if strpos(`"`subpop'"', "if ") == 1 {
		local subcond: subinstr local subpop "if " ""
	}
	
	// Check how many states in subgroup
	display `"Subadj is: `subcond'; subif is: `subif'"'
	quietly levelsof state `subif' `subcond', local(states)
	local nstates: word count `states'
	
	// Write headings
	putexcel set "`using'", `modify' `replace'
	putexcel C1=("2012 (CS1)") G1=("2014 (CS2)") K1=("2016 (CS3)") ///
		O1=("Change in average over time") ///
		Q1=("Estimated effect of 1 year of full intervention") ///
		C2=("`heading1'") D2=("`heading2'") E2=("`heading3'") F2=("ave") ///
		G2=("`heading1'") H2=("`heading2'") I2=("`heading3'") J2=("ave") ///
		K2=("`heading1'") L2=("`heading2'") M2=("`heading3'") N2=("ave") ///
		O2=("2012-16") P2=("2014-16"), sheet("`name'_full", replace)	

	// Table for main text comparing averages across time
	putexcel C2=("2012 (CS1)") D2=("2014 (CS2)") E2=("2016 (CS3)") ///
		F1=("Change in average over time") ///
		F2=("2012-16") G2=("2014-16"), sheet("`name'_rounds", replace)	

	// Table for main text comparing groups within CS3
	putexcel C1=("`heading1'") D1=("`heading2'") E1=("`heading3'") ///
		F1=("Estimated effect of 1 year of full intervention"), ///
		sheet("`name'_CS3", replace)	
	local i 1
	foreach original in `varlist' {
		capture levelsof `original', local(levels)
		if _rc == 198 | _rc == 111 {
			// The item is not a variable - interpret it as a heading
			local ++i		// leave 1 line blank
			local r = `i' * 3
			putexcel B`=`r'+1'=("`original'"), sheet("`name'_full")
			local r = `i' + 2
			putexcel B`r'=("`original'"), sheet("`name'_rounds")
			local r = `i' + 1
			putexcel B`r'=("`original'"), sheet("`name'_CS3")
			local ++i
			continue	// continue to next variable
		}
		
		tempvar min max
		egen `min' = min(`original')
		egen `max' = max(`original')
		local minv = `min'[1]
		local maxv = `max'[1]
		display "Analysis of variable `original' (min `minv' max `maxv' levels)"
		// If original is a binary variable or 0-1 proportion, convert it to a percentage
		// Note, it is possible that some variables whose values always lie between 0 and 1
		// are not actually proportions - if so these will have to be flagged manually
		if "`levels'" == "0 1" | (`minv' >= 0 & `maxv' <=1) {
			tempvar v
			gen `v' = `original' * 100
			local sign (%)
		}
		else {
			local v `original'
			local sign
		}
		// Estimate effect of one year of intervention on v. Use linear regression for now, though logit more appropriate
		// for binary variables
		if "`dose'" == "" {
			local effect not estimated
		}
		else {
			local state_dummy = cond(`nstates' == 1, "", "i.state")
			local cond = cond(`"`subpop'"' == `""', "if round == 3", `"if round == 3 & `subcond'"')
			display `"Estimating dose effect for: `cond'"'
			quietly count `cond' & !missing(`v') & !missing(`dose')
			if r(N) {
				if "`levels'" == "0 1" {
					display "Binary variable - logit regression: svy, subpop(`cond'): logit `original' `dose' `state_dummy'"
					capture svy, subpop(`cond'): logit `original' `dose' `state_dummy'
					
					// Logit may throw an error, for example due to all schools meeting a particular standard
					// As it's hard to predict what errors will occur, I just capture this and add n/a in the table
					// Also capture case where dose is omitted (predicts outome perfectly / collinearity)
					if _rc | ("`=r(label1)'" == "(omitted)") {	
						local effect n/a
						display "Error in logit: " _rc
					}
					else {
						margins, dydx(`dose')
						matrix B = r(table)
						returnas scalar p = B[4, 1]
						local effect: display %3.1f 100 * B[1, 1] $stars
					}
					// *** would also be useful to try adjrr to see what adjusted effects are produced
					
					/* 
					// The following uses OLS to estimate same effect, and reports both estimates in the log file
					svy, subpop(`cond'): regress `v' `dose' `state_dummy'
					matrix B = e(b)
					quietly test `dose'
					local effect_r: display %3.1f B[1, 1] $stars
					display "!!! Comparing OLS to logit for C:`cond' V:`original' D:`dose' S:`state_dummy'. Logit: `effect'; OLS: `effect_r'"
					*/
				}
				else {
					display "Continuous variable - OLS regression: svy, subpop(`cond'): regress `v' `dose' `state_dummy'"
					svy, subpop(`cond'): regress `v' `dose' `state_dummy'
					matrix B = e(b)
					quietly test `dose'
					local effect: display %3.1f B[1, 1] $stars
				}
				display "Effect estimated as `effect'"
			}
			else {		// If there are no observations where cond is true
				display `"Could not estimate because no observations where `cond' and nonmissing `v'"'
				local effect "n/a"
			}				
		}
		
		
		// Estimate means over round and intervention group
		csmeans `v', over(`over') subpop(`subpop') round(`round_number')
		
		// Write to Excel sheets
		local L `: variable label `original'' `sign'
		local r = `i' * 3
		putexcel A`r'=("`original'") B`r'=("`L'") ///
			B`=`r'+1'=("s.e.") B`=`r'+2'=("N") ///
			C`r'=matrix(r(Full)) O`r'=(r(ch1)) P`r'=(r(ch2)) Q`r'=("`effect'"), ///
			sheet("`name'_full")
		local r = `i' + 2
		putexcel A`r'=("`original'") B`r'=("`L'") C`r'=matrix(r(Rounds)) ///
			F`r'=(r(ch1)) G`r'=(r(ch2)), sheet("`name'_rounds")
		local r = `i' + 1
		putexcel A`r'=("`original'") B`r'=("`L'") C`r'=matrix(r(Groups)) ///
			F`r'=("`effect'"), sheet("`name'_CS3")
		local ++i
	}
end
