capture program drop spliti
program spliti
// --- Split a series of words into local macros, e.g. spliti a b c, local(x y z) sets local macros x y z to a, b, c respectively
	syntax anything(name=from), Local(string)
	display "Splitting local variables: " _continue
	local L: word count `local'
	forvalues i = 1/`L' {
		display "`: word `i' of `local'': `: word `i' of `from''" cond(`i' < `L', "; ", "") _continue
		c_local `: word `i' of `local'' `: word `i' of `from''
	}
	display "."
end

capture program drop getreturns
program getreturns
	syntax namelist(name=values)
	foreach v in `values' {
		c_local `v' = r(`v')
	}
end
	
capture program drop sumby
program sumby
	syntax varlist, by(string)
	local max_length 0
	foreach v of varlist `varlist' {
		if length("`v'") > `max_length' {
			local max_length = length("`v'")
		}
	}
	* display "Max length is `max_length'"
	display %-`max_length's "variable" "  " %~12s "observations" %~12s "mean" %~12s "min" %~12s "max"
	display %-`max_length's "" %6s "0" %6s "1" %6s "0" %6s "1" %6s "0" %6s "1" %6s "0" %6s "1"
	foreach v of varlist `varlist' {
		display %-`max_length's "`v'" _continue
		if (substr("`: type `v''", 1, 3) == "str") {
			quietly count if !missing(`v') & `by' == 0
			getreturns N
			quietly count if !missing(`v') & `by' == 1
			display %6.0f `N' %6.0f r(N) %12s "(text)"
		}
		else {
			quietly sum `v' if `by' == 0
			getreturns N mean min max
			quietly sum `v' if `by' == 1
			display %6.0f `N' %6.0f r(N) %6.1f `mean' %6.1f r(mean) %6.1f `min' %6.1f r(min) %6.1f `max' %6.1f r(max) %6s cond(`min' == r(min) & `max' == r(max), "==", "")
		}
	}	
end
