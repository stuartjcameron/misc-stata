capture program drop corsc
program corsc
	//--- Scatter plot showing regression line, CI and p-value
	syntax varlist(min=2 max=2) [if], [export(string)] [output(string)]
	local a: word 1 of `varlist'
	local b: word 2 of `varlist'
	correlate `a' `b' `if'
	scalar df = r(N) - 2
	scalar t = r(rho) / sqrt((1 - r(rho) * r(rho)) / df)
	scalar pvalue = min(ttail(df, t), ttail(df, -t)) * 2
	local r: display %4.3f r(rho)
	local pvalue: display %4.3f pvalue
	graph twoway ///
		(lfitci `a' `b', subtitle("correlation `r' (p-value `pvalue')")) ///
		(scatter `a' `b') `if'
	if `"`export'"' != `""' {
		graph export "`export'/scatter_`a'_`b'2.png", as(png) replace
		graph twoway ///
			(scatter `a' `b') `if'
		graph export "`export'/scatter_`a'_`b'1.png", as(png) replace
	}
	if `"`output'"' != "" {
		file write `output' "<h2>Scatter plot of `a' against `b'</h2>"
		file write `output' "<img src=" _char(34) "scatter_`a'_`b'.png" _char(34) "/>"
	}
end
