*! ivreg2out 1.0
*BQ: 2013-09-24 removed the N_Unique ereturn 
* (had a problem with my setup. I think my est's didn't have e(r))
* Combines the two stage estimates into a single estimate
* Originally from roywada@hotmail.com http://www.stata.com/statalist/archive/2009-09/msg00043.html
prog define ivreg2out, eclass
	version 8.0
	qui {
		args one two
		local name1=subinstr("`one'","_ivreg2_","",1)
		local name2=subinstr("`two'","_ivreg2_","",1)

		est restore `one'
		tempname b1 V1 b2 V2 v1 v2 b v V
		mat `b1'=e(b)
		mat `V1'=e(V)
		matrix coleq `b1' = `name1'
		matrix coleq `V1' = `name1'
		local r2_first=e(r2)

		est restore `two'
		mat `b2'=e(b)
		mat `V2'=e(V)
		matrix coleq `b2' = `name2'
		matrix coleq `V2' = `name2'
		mat `b'=`b1',`b2'
		mat `v1'=vecdiag(`V1')
		mat `v2'=vecdiag(`V2')
		mat `v'=`v1',`v2'
		mat `V'=diag(`v')
		local r2_second=e(r2)
		local N=e(N)
		local widstat=e(widstat)
		local N_unique=e(r)

		eret post `b' `V'
		eret scalar N=`N'
		eret scalar r2_1=`r2_first'
		eret scalar r2_2=`r2_second'
		eret scalar widstat=`widstat'
*		eret scalar N_unique=`N_unique'
		eret loc cmd="ivreg2out"
		eret loc eqnames= "`name1' `name2'"
		eret loc depvar= "`name1' `name2'"
	}
end