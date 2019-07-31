capture program drop gendummies
program gendummies
	//--- Generate and label dummies
	// 'label' option uses a template to assign variable labels:
	// {variable label} is replaced by the variable label
	// {value label} is replaced by the label of the value each dummy represents
	// {value} is replaced by the numerical value it represents
	
	syntax varlist, [PREFIXes(string)] [label(string)]
	if `"`prefixes'"' == `""' {
		local prefixes `varlist'
	}
	if `"`label'"' == `""' {
		local label "{variable label} = {value} ({value label})"
	}
	local vars: word count `varlist'
	local output
	forvalues i=1/`vars' {
		local v: word `i' of `varlist'
		local p: word `i' of `prefixes'
		quietly levelsof `v', local(levels)
		foreach level in `levels' {
			quietly gen `p'`level' = `v' == `level' if !missing(`v')
			local L `label'
			local L = subinstr(`"`L'"', "{variable label}", `"`: variable label `v''"', .)
			local L = subinstr(`"`L'"', "{value}", "`level'", .)
			local L = subinstr(`"`L'"', "{value label}", `"`: label (`v')`level''"', .)
			label variable `p'`level' `"`L'"'
			*label variable `p'`level' "`: variable label `v'' = `level' (`: label (`v')`level'')"
			local output `output' `p'`level'
		}
	}
	display "Dummy variables generated: `output'"
end
