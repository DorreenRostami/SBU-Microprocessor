
	EXPORT SystemInit
    EXPORT __main


	AREA Mycode,CODE,READONLY 

SystemInit FUNCTION
	; initialization code
 ENDFUNC


; main logic of code
__main FUNCTION
	LDR r10, =97243034
	
	MOV r0, r10
	MOV r1, #0 ;answer
	B loop2
	
loop1
	LSL r10, r10, #1
	CMP r10, #0
	BEQ OUT
	MOV r0, r10
loop2
	LSLS r0, r0, #1
	BCC loop1 ;branch if c = 0
	LSLS r0, r0, #1
	BCS loop1 ;branch if c = 1
	LSLS r0, r0, #1
	BCC loop1 ;branch if c = 0
	
	ADD r1, r1, #1
	B loop1
	

	B OUT
OUT
	B OUT

 ENDFUNC	
 END
