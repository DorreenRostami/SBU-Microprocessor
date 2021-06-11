
	EXPORT SystemInit
    EXPORT __main


	AREA Mycode,CODE,READONLY 

SystemInit FUNCTION
	; initialization code
 ENDFUNC


; main logic of code
__main FUNCTION
	MOV r1, #12
	MOV r2, #6

loop
    CMP r1, r2
    BEQ exit_loop	
    SUBGT r1, r1, r2
    SUBLE r2, r2, r1
    B loop
exit_loop	
	MOV r0, r2

	B OUT
OUT
	B OUT

 ENDFUNC	
 END
	 


