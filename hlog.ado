capture program drop hlog
program hlog
	syntax [namelist(min=1 max=2 name=input)] [using/], [append|replace] [title(string)] [dir(string)]
	// --- Outputs charts to an html file. Need to specify the directory for storing images
	local command: word 1 of `input'
	local handle: word 2 of `input'
	if "`command'" == "graph" {
		// Write a graph to the html file
		if "`append'" != "" {
			display as error "invalid options for hlog graph"
			error 198
		}
		if "`using'" == "" {
			local using `dir'/`: display %tcCCYYNNDDHHMMSS clock("$S_DATE $S_TIME", "DMY hms")'_$hlog_serial
			global hlog_serial = $hlog_serial + 1
		}
		// *** Note that this can produce hundreds of graph files that may be unwanted. Instead,
		// organise them all in a folder with the hlog file name, that will get deleted and replaced each time.
		// (Unless you are appending.)
		
		if "`handle'" == "" {
			local handle hlog_handle
		}
		graph export "`using'.png", as(png) replace	
			// *** adapt so user can name the chart and decide which to export;
			// also want to be able to export all open charts at once. The titles could be the assigned names.
		if "`title'" != "" {
			file write `handle' "<h2>`title'</h2>"	// *** may also be possible to grab title from the graph itself?
		}
		file write `handle' "<img src=" _char(34) "`using'.png" _char(34) "/>"
	}
	else if "`command'" == "close" {
		// Close the html log
		if "`using'" != "" | "`append'" != "" | "`replace'" != "" | "`title'" != "" {
			display as error "invalid syntax for hlog close"
			error 198
		}
		if "`handle'" == "" {
			local handle hlog_handle
		}
		file write `handle' "</body></html>"
		file close `handle'	
	}
	else {
		// Start a new hlog
		if "`handle'" != "" {
			display as error "hlog: command not recognised `command' `handle'"
			error 198
		}
		local handle `command'
		if "`title'" == "" {
			local title "Stata output"
		}
		if "`using'" == "" {
			local using hlog
			local replace replace
		}
		if "`handle'" == "" {
			local handle hlog_handle
		}
		capture file close `handle'
		file open `handle' using "`using'.html", write text all `replace' `append'
		file write `handle' "<html><head><title>`title'</title></head><body>"
		display "Started hlog `using'.html"
		global hlog_serial 0
	}
end

// *** For help file
// Note you can add any other information the same file. The default file handle is hlog_handle.
// Note shell hlog.html on windows will open the file to read in your browser.
// Would want to add other 

