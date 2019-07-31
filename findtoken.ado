capture program drop findtoken
program findtoken, rclass
//--- Find the position of a token in a series of tokens 
// Returns the position (or 0 if not found) as r(P)
	version 13.1
	syntax anything, in(string asis)
	local tokens: word count `in'
	local r = 0
	*display `"Looking for --`anything'-- in --`tokens'--`in'"'
	forvalues i = 1 /`tokens' {
		local token: word `i' of `in'
		*display `"Checking against `i': --`token'--"'
		if (`"`token'"' == `"`anything'"') {
			local r = `i'
			continue, break
		}
	}
	/*if `r' {
		display "Found `anything' at position `r'"
	}
	else {
		display "`anything' not found"
	}
	*/
	return scalar P = `r'
end
