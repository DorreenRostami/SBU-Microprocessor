ORG 100H

.DATA
    PROMPT_1 DB 'Enter a Decimal number (0 to 131071) : $'
    ILLEGAL DB 0DH,0AH,'Illegal character. Try again : $'
    LINEFEED DB 13, 10, "$"
    MIN DW 1H
    MAXCOUNT DW 1H
    PRIMECOUNT DW 0H

.CODE
MAIN PROC
    MOV AX, @DATA                
    MOV DS, AX
    
    LEA DX, PROMPT_1             ; load and display the string PROMPT_1
    MOV AH, 9
    INT 21H
    
    CALL DECIMAL_INPUT            
    
    MOV MAXCOUNT, BX
    
    CALL PRINT_PRIME
    
    
    MOV AH, 4CH                  ; return control to DOS
    INT 21H
MAIN ENDP

DECIMAL_INPUT PROC
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
        
        CMP AL, 39H               ; compare AL with 9
        JG @ERROR                 ; jump to label @ERROR if AL>9
        
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
DECIMAL_INPUT ENDP 

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

PRINT_PRIME PROC
    @NEXTNUM:
    INC MIN
    
    MOV AX, MIN         ; set AX (numerator) = MIN
    MOV CL, 2
    DIV CL              ; AL = MIN / 2, AX = remainder
    AND AX, 00FFH       ; AX = MIN / 2 
    MOV BX, AX          ; BX = MIN / 2
    XOR CX, CX          ; clear CX
    
    @CONT:
    CMP BX, 2
    JB @NUMISPRIME      ; this is prime if BX < 2
    
    MOV AX, MIN
    XOR DX, DX          ; clear DX
    DIV BX              ; AX / BX
    
    DEC BX              ; BX--
    
    CMP DX, 0           ; check for remainder  
    
    JNE @CONT           ; continue if we have remainder (DX != 0)
    JMP @NEXTNUM        ; start checking next number if remainder=0
    
    
    @NUMISPRIME:
    MOV BX, MIN
    CALL DECIMAL_OUTPUT 
    INC PRIMECOUNT
    MOV BX, MAXCOUNT
    CMP PRIMECOUNT, BX
    JB @NEXTNUM         ; if PRIMECOUNT<MAXCOUNT continue looking for primes
    
    RET
PRINT_PRIME ENDP

END MAIN