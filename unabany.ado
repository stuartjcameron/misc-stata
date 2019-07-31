capture program drop unabany
program unabany
//--- Unabbreviate a list of tokens that may include both variable names and other items
// e.g. unabany tokens: x1-x5 "This is a title" y z
// stores "x1 x2 x3 x4 x5 `"This is a title"' y z" in the local variable `tokens'
	syntax anything
	tokenize `"`anything'"', parse(":")
	local output
	foreach token in `3' {
		*display `"Adding token: `token'"'
		noisily capture unab unabbreviated: `token'
		*display "Error: " _rc `"--`unabbreviated'"'
		if _rc == 111 | _rc == 198 {
			if strpos(`"`token'"', " ") > 0 {
				local output `output' `"`token'"'
			}
			else {
				local output `output' `token'
			}
		}
		else {
			local output `output' `unabbreviated'
		}
		*display `"Token: `token'; output: `output'"'
	}
	display `"Storing in local "`1'", "`output'""'
	c_local `1' `output'
end
		
