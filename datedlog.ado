capture program drop datedlog
program datedlog
	// Syntax: datedlog name [path]
	// Saves a log with the date in its file name
	// Uses the global variable $log if path is not specified
	gettoken n p: 0					// Parse name and path from syntax
	if `"`p'"' == `""' {
		local p $log
	}
	else {
		local p = substr(`"`p'"', 2, .)	// Remove space at start of path
	}
	local d: display %tcYYNNDD-HHMMSS clock("$S_DATE $S_TIME", "DMY hms")	// Format the date
	capture log close `n'				// Close the log if it's already open
	log using "`p'/`d'-`n'", name(`n')		// Log using the date and name
end
