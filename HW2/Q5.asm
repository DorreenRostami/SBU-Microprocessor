ORG 100H

.DATA
    PROMPT_1 DB 'Enter n in decimal form (0<=n<=8) : $'
    ILLEGAL DB 0DH,0AH,'Illegal character. Try again : $'
    LINEFEED DB 13, 10, "$"

.CODE
MAIN PROC
    MOV AX, @DATA                
    MOV DS, AX
    
    LEA DX, PROMPT_1             ; load and display the string PROMPT_1
    MOV AH, 9
    INT 21H
    
    CALL DECIMAL_INPUT_N 
    MOV AX, 1
    
    CALL CALC_FACT
    MOV BX, AX 
    
    CALL DECIMAL_OUTPUT
    
    MOV AH, 4CH                  ; return control to DOS
    INT 21H
MAIN ENDP

CALC_FACT PROC
    ; this procedure will calculat factorial of a number    
    ; input : BX
    ; output : store number in AX
    
    MUL BX          ; set AX = AX*BX 
    
    CMP BX, 1H
    JBE @END_FACT   ; end if BX<=1
    
    DEC BX
    
    CALL CALC_FACT
    
    @END_FACT:
    CMP BX, 0
    JA @RETURN
    MOV AX, 1
    
    @RETURN:
    RET   
CALC_FACT ENDP    

DECIMAL_INPUT_N PROC
    ; this procedure will read a number in decimal form    
    ; input : none
    ; output : store number in BX
    
    JMP @READ                    
    
    @ERROR:                       
    LEA DX, ILLEGAL               ; load and display the string ILLEGAL
    MOV AH, 9                        
    INT 21H
    
    @READ:                      
    XOR BX, BX                    
    XOR CX, CX                   
    
    MOV AH, 1                    
    INT 21H                       
    CMP AL, 0DH                   ; compare AL with CR
    JE @END                       ; jump to label @END if AL=CR
    
    @INPUT:                       
        CMP AL, 30H               ; compare AL with 0 (48=30H)
        JL @ERROR                 ; jump to label @ERROR if AL<0
        
        CMP AL, 38H               ; compare AL with 8
        JG @ERROR                 ; jump to label @ERROR if AL>8
        
        AND AX, 000FH             ; convert ascii to decimal code
        
        PUSH AX                   
        
        MOV AX, 10                
        MUL BX                    ; set AX=AX*BX
        MOV BX, AX                ; set BX=AX
        
        POP AX                   
        
        ADD BX, AX                ; set BX=AX+BX
        
        MOV AH, 1                 
        INT 21H                   
        CMP AL, 0DH               ; compare AL with CR
        JNE @INPUT                ; jump to label if AL!=CR
                                   
    @END:                         
    
    RET                          
DECIMAL_INPUT_N ENDP 

DECIMAL_OUTPUT PROC
    ; this procedure will display a decimal number
    ; input : BX
    ; output : none 
    
    
    MOV AH, 09
    MOV DX, OFFSET LINEFEED        ; print new line + CR
    INT 21H
    XOR DX, DX
    
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