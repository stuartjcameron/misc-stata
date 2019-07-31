capture program drop save13
program save13
	if c(version) >= 14 & c(version) < 15 {
		saveold `0'
	}
	else if c(version) >=13 {
		save `0'
	}
	else {
		display "Unable to save in version 13 format"
	}		
end

