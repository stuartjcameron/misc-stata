capture program drop commandedit
program commandedit
//--- Find the command and open the ado file (if it exists) in the do-file editor
	tempfile f
	tempname n
	display as text "Editing"
	quietly capture log close `n'
	quietly log using `f', replace name(`n') text
	which `0'
	quietly log close `n'
	file open `n' using `f', read
	quietly file read `n' line
	file close `n'
	if strpos("`line'", "built-in command") {
		display as error "It is not possible to edit this built-in command"
	}
	else {
		doedit "`line'"
	}
end
