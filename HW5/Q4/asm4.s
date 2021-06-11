	EXPORT SystemInit
    EXPORT __main

	AREA Mycode,CODE,READONLY 

SystemInit FUNCTION
	; initialization code
 ENDFUNC


; main logic of code
__main FUNCTION
	MOV r0, #0xA0000000  
	MOV r1, #0 	; holds reversed value	
	MOV r2, #32 ; 32 iterations		
		
rev_loop
	LSLS r0, r0, #1	
	RRX  r1, r1 ; shift to right and move C flag into r1[31]
	SUBS r2, #1
	BNE  rev_loop

	MOV r10, #1
fact_loop
	CMP r1, #1
	MULGT r10, r10, r1
	SUBGT r1, r1, #1
	BGT fact_loop

	B OUT
OUT
	B OUT

 ENDFUNC	
 END