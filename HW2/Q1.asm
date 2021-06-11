ORG 100H
.DATA
DATA1 DD 12341234H
DATA2 DD 56785678H  
RESULT DD 2 DUP(?)

.CODE
MOV AX, @DATA
MOV DS, AX 
  
MOV AX, WORD PTR DATA1
MUL WORD PTR DATA2      ;mul res = w2 w1
MOV WORD PTR RESULT, AX 
MOV CX, DX              ;cx = w2
    
MOV AX, WORD PTR DATA1+2  
MUL WORD PTR DATA2      ;mul res = w4 w3
ADD CX, AX              ;cx = w2+w3
MOV BX, DX              ;bx = w4

JNC nocarry1
ADD BX, 1H              ;bx = w4 + c23

nocarry1:
MOV AX, WORD PTR DATA1
MUL WORD PTR DATA2+2    ;mul res = w6 w5
ADD CX, AX              ;cx = w2+w3+w5
MOV WORD PTR RESULT+2, CX
MOV CX, DX              ;cx = w6

JNC nocarry2
ADD CX, 1H              ;cx = w6 + c235

nocarry2:
MOV AX, WORD PTR DATA1+2
MUL WORD PTR DATA2+2    ;mul res = w8 w7
ADD CX, AX              ;cx = w6+c235+w7

JNC nocarry3
ADD DX, 1H               ;dx = w8 + c67

nocarry3:
ADD CX, BX               ;cx = w6+c235+w7+w4+c23
MOV WORD PTR RESULT+4, CX

JNC nocarry4
ADD DX, 1H               ;dx = w8 + c67 + c674

nocarry4:
MOV WORD PTR RESULT+6, DX

MOV AH, 4CH
INT 21H