capture program drop check
program check
	syntax anything(name=args)
	gettoken var args: args
	gettoken label args: args
	gen `var' = `args'
	label define `var' 0 "" 1 "`label'"
	label values `var' `var'
	label variable "`label'"
end
