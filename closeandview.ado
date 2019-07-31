capture program drop closeandview
program closeandview
	//--- Close a log by name and view it
	syntax anything
	log query `anything'
	view "`=r(filename)'"
	log close `anything'
end
