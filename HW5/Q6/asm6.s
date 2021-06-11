
	EXPORT SystemInit
    EXPORT __main


	AREA Mycode,CODE,READONLY 

SystemInit FUNCTION
	; initialization code
 ENDFUNC


; main logic of code
__main FUNCTION
	MOV r1, #0x444
	
	MOV r2, #4 ;i
	MOV r3, #8 ;j
	
	CMP r2, r3 			;these lines swap r2 & r3 if r2>r3
	ADDGT r2, r2, r3
	SUBGT r3, r2, r3
	SUBGT r2, r2, r3
	
	MOV r0, #0
	SUB r2, r3, r2
	ADD r2, r2, #1 ;number of bits from i to j	
	
middle_ones
	MOV r4, #0xFFFFFFFF
	ADDS r4, r4, #1 ;to set C = 1
	RRX  r0, r0 ; shift to right and move C flag (1) into r0[31]
	SUBS r2, r2, #1
	BNE middle_ones
	
	RSB r3, r3, #31 ;r3 = 31-r3 = number of bits from left til j
left_zeros
	LSR  r0, r0, #1 ; shift to right
	SUBS r3, r3, #1
	BNE left_zeros
	
	EOR r1, r1, r0
	B OUT
OUT
	B OUT

 ENDFUNC	
 END
	 
