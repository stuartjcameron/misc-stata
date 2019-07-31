capture program drop multresp
program multresp
// --- Convert a response to a multiple option question coded e.g. q25 = "ABDF"
// to a series of labelled dummies e.g. q25A = 1, q25B = 1, q25C = 0, q25D = 1, q25E = 0, q25F = 1
// Syntax: 
//		multresp q25
//		multresp q25, options(all)	-- same as above (options(all) is default if no labels are given)
//		multresp q25, options(ABCD)	-- only makes options for abcd
//		multresp q25 A "First option name" B "Second option name" Z "None of the above"
//			-- if labels are given then options default to the listed letters
//		multresp q25 A "First option name" B "Second option name", options(all)	-- adds the other options that are found
//		multresp q25, count(all)		-- count all options (= length of string)
//		multresp q25, count(ABC)		-- create a count variable for ABC
//		multresp q25, options(all) count(all)

// *** To do:
// / 1. add an option where labels do not need to be specified; it just creates a dummy for every variable present
// / 2. add an option that counts how many are ticked
// / 3. refine the above so that some options (e.g. Z = don't know) are ignored in the count
// / 4. allow interfix to be specified in options
// 5. allow more than 52 options, i.e. goes to double letters, and perhaps numbers as well as letters?
// / 6. Adjust whether options where the letter is never found should be dropped. This should happen if we
// specify options(all) but not if options are specified with/without labels.

	syntax anything(name=args id="Option labels") [, options(string) count(string) infix(string) postfix(string)]
	local var: word 1 of `args'
	local length: word count `args'
	local stem `var'`infix'
	local drop_empty 0			// Don't drop variables that are all zero
	// If no labels are provided, options defaults to 'all' (= lower case + upper case alphabets)
	if ("`options'" == "all" | ("`options'" == "" & `length' == 1 & "`count'" == "")) {
		local options abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ
		local drop_empty 1		// Do drop those variables that are all zero
	}
	if ("`postfix'" == "") {
		local cv `stem'count
	}
	else {
		local cv `stem'`postfix'
	}
	if "`options'" != "" {		// Add all the options specified in options()
		forvalues i = 1/`: length local options' {
			local letter = substr("`options'", `i', 1)
			gen `stem'`letter' = strpos(`var', "`letter'") > 0
			quietly count if `stem'`letter' == 1
			if `drop_empty' & r(N) == 0 {
				drop `stem'`letter'
			}
			else {
				label variable `stem'`letter' "`var' has option `letter'"
				local created `created'`letter'
				display "Created variable `stem'`letter'"
			}
		}
	}
	if `length' > 1 {					// Value labels provided
		forvalues i = 2(2)`length' {
			// display "i `i'"
			local letter: word `i' of `args'
			local label: word `=`i'+1' of `args'
			// Create the variable if not already created
			if strpos("`created'", "`letter'") == 0 {
				// display "creating"
				gen `stem'`letter' = strpos(`var', "`letter'") > 0
			}
			label variable `stem'`letter' `"`label'"'
		}
	}
	if "`count'" == "all" {
		gen `cv' = length(`var')
		label variable `cv' "Number of options specified in `var'"
	}
	else if "`count'" != "" {
		gen `cv' = 0
		forvalues i = 1/`: length local count' {
			local letter = substr("`count'", `i', 1)
			// display "counting `i' - letter `letter' - in `cv'"
			replace `cv' = `cv' + (strpos(`var', "`letter'") > 0)
		}
		label variable `cv' "Number of options specified in `var'"
	}
end
