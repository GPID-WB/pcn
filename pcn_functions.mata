// ------------------------------------------------------------------------
// MATA code to loop over primus results
// ------------------------------------------------------------------------

cap mata: mata drop pcn_*()

mata:

mata set mataoptimize on
mata set matafavor speed
mata set matadebug off // (on when debugging; off in production)
mata set matalnum  off // (on when debugging; off in production)


void pcn_ind(string matrix R) {
	i = strtoreal(st_local("i"))
	vars = tokens(st_local("varlist"))
	for (j =1; j<=cols(vars); j++) {
		//printf("j=%s\n", R[i,j])
		st_local(vars[j], R[i,j] )
	}
} // end of IDs variables

string matrix pcn_info(matrix P) {

	survey = st_local("survey_id")

	status = st_local("status")

	dlwnote = st_local("dlwnote")


	if (rows(P) == 0) {
		P = survey, status, dlwnote
	}
	else {
		P = P \ (survey, status, dlwnote)
	}

	return(P)
}

string matrix pcn_split_id(string scalar invs) {
	string colvector Y
	string matrix    A
	
	Y = tokens(invs)'
	
	A = J(0,0, .z)
	
	for (i =1; i<=rows(Y); i++) {
		//printf("i=%s\n", Y[i])
		
		if (rows(A) == 0) {
			A = tokens(Y[i], "_")
		}
		else {
			A = A \ tokens(Y[i], "_")
		}
		
	}
	
	A = select(A,  !regexm(A[1,.],"^(_|M|A)$"))
	
	A = Y, A
	return(A)
}


end

exit

