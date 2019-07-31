capture program drop pack
program pack
//--- For the ado files in a named sub-folder, creates pkg and toc files,
// and optionally installs the packages
// To do: 
// Avoid over-writing existing pkg files (unless option to overwrite is specified)
// (more complex) Create template help files based on the command syntax, and perhaps on notes
// embedded in the ado file.
	syntax anything(id=path equalok), [install]
	local path: word 1 of `anything'
	local files: dir "`path'" files "*.ado"
	tempname toc pkg
	file open `toc' using `"`path'/stata.toc"', write replace
	file write `toc' "v 3" _newline ///
		"d Automatically packaged utlities for this project" _newline
	display as text "Making package files:"
	foreach file in `files' {
		local name = substr(`"`file'"', 1, length(`"`file'"') - 4)
		file open `pkg' using `"`path'/`name'.pkg"', write replace
		file write `pkg' "v 3" _newline "d Automatically created utility" ///
			_newline "f `name'.ado" _newline
		file write `toc' "p `name'" _newline
		file close `pkg'
		display as text `"`path'/`name'.pkg"'
	}
	file close `toc'
	display as text `"Made table of contents file at `path'/stata.toc"'
	if `"`install'"' != `""' {
		foreach file in `files' {
			local name = substr(`"`file'"', 1, length(`"`file'"') - 4)
			net install `name', from(`"`path'"') replace
			display as text `"Installed package `name'"'
		}
	}	
end
