ORG 100H

.DATA
    ARR DW 10, 7, 10H, 11, 11H
    LEN DW 5
    SUM DW 0
.CODE 

MAIN PROC
    MOV AX,@DATA
    MOV DS,AX
    
    LEA DI, ARR 
    
    @LOOP:
    MOV AL, [DI]
    MOV AH, [DI+1]
    MOV CX, 02H 
    DIV CX
    
    ADD DI, 2
    DEC LEN
    
    CMP DX, 0
    JE @LOOP
    
    MOV AL, [DI - 2]
    MOV AH, [DI - 1]
    ADD SUM, AX
    
    CMP LEN, 0
    JNE @LOOP
    
    MOV BX, SUM
    CALL DECIMAL_OUTPUT
    
    MOV AH, 4CH                 ; return control to DOS
    INT 21H 
MAIN ENDP

DECIMAL_OUTPUT PROC
    ; this procedure will display a decimal number
    ; input : BX
    ; output : none 
    
    MOV AX, BX                     
    XOR CX, CX                     
    MOV BX, 10                     
    
    @REPEAT:                      
        XOR DX, DX                 
        DIV BX                     ; divide AX by BX
        PUSH DX                    ; push DX (rem) onto the STACK
        INC CX                     
        OR AX, AX                  
    JNE @REPEAT                    ; jump to label @REPEAT if ZF=0 (AX=0)
    
    MOV AH, 2                      
    
    @DISPLAY:                      
        POP DX                     
        OR DL, 30H                 ; convert decimal to ascii code
        INT 21H                    
    LOOP @DISPLAY                  ; jump to label @DISPLAY if CX!=0
    
    RET                         
DECIMAL_OUTPUT ENDP