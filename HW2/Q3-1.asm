ORG 100H

.DATA
    PROMPT_1 DB 'Enter n (1<=n<=16): $'  
    PROMPT_2 DB 'Enter a BCD number : $' 
    PROMPT_3 DB 'Enter a binary number : $'
    ILLEGAL DB 0DH,0AH,'Illegal character. Try again : $'
    LINEFEED DB 13, 10, "$"
    BCD DW ?
    BIN DW ?
    READ DW ?
.CODE 
MAIN PROC
    MOV AX, @DATA                
    MOV DS, AX 
    
    LEA DX, PROMPT_1    
    MOV AH, 9
    INT 21H 
    
    CALL DECIMAL_INPUT_N
    
    MOV AH, 09
    MOV DX, OFFSET LINEFEED       ; new line + CR
    INT 21H
    XOR DX, DX
    
    
    LEA DX, PROMPT_2    
    MOV AH, 9
    INT 21H  
    
    MOV READ, BX
    
    CALL BIN_INPUT
    MOV BCD, BX 
    
    MOV AH, 09
    MOV DX, OFFSET LINEFEED       ; new line + CR
    INT 21H
    XOR DX, DX
    
    LEA DX, PROMPT_3    
    MOV AH, 9
    INT 21H 
    
    MOV READ, 10H
    CALL BIN_INPUT
    MOV BIN, BX
    
    MOV AX, BCD
    XOR DX, DX
    DIV BIN                      ; answer is in DX (rem)
    
    MOV BX, DX
    CALL DECIMAL_OUTPUT
    
    MOV AH, 4CH                  ; return control to DOS
    INT 21H
MAIN ENDP

BIN_INPUT PROC
    ; this procedure will read a number in binary form   
    ; input : READ data
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
        CMP AL, 30H               ; compare AL with 0 
        JL @ERROR                 ; jump to label @ERROR if AL<0
        
        CMP AL, 31H               ; compare AL with 1
        JG @ERROR                 ; jump to label @ERROR if AL>1
        
        AND AX, 000FH             ; convert ascii to decimal code
        
        SHL BX, 1                 ; BX = BX * 2 (shift left)   
        ADD BX, AX                ; set BX=AX+BX
        
        DEC READ
        CMP READ, 0
        JBE @END                ; jump to end if read<=0 (all bits are read)
        
        MOV AH, 1                 
        INT 21H                   
        CMP AL, 0DH               ; compare AL with CR
        JNE @INPUT                ; jump to label if AL!=CR 
                                   
    @END:            
    
    RET                          
BIN_INPUT ENDP

DECIMAL_INPUT_N PROC
    ; this procedure will read a number in decimal form    
    ; input : none
    ; output : store number in BX
    
    JMP @READN                    
    
    @ERRORN:                       
    LEA DX, ILLEGAL               ; load and display the string ILLEGAL
    MOV AH, 9                        
    INT 21H
    
    @READN:                      
    XOR BX, BX                    
    XOR CX, CX                   
    
    MOV AH, 1                    
    INT 21H                       
    CMP AL, 0DH                   ; compare AL with CR
    JE @ENDN                      ; jump to label @END if AL=CR
    
    @INPUTN:                       
        CMP AL, 30H               ; compare AL with 0 
        JL @ERRORN                 ; jump to label @ERROR if AL<0
        
        CMP AL, 39H               ; compare AL with 9
        JG @ERRORN                ; jump to label @ERROR if AL>9
        
        AND AX, 000FH             ; convert ascii to decimal code
        
        PUSH AX                   
        
        MOV AX, 10                
        MUL BX                    ; set AX=AX*BX
        MOV BX, AX                ; set BX=AX
        
        POP AX                   
        
        ADD BX, AX                ; set BX=AX+BX
        CMP BX, 10H               ; compare BX and 16D
        JG @ERRORN
        
        MOV AH, 1                 
        INT 21H                   
        CMP AL, 0DH               ; compare AL with CR
        JNE @INPUTN               ; jump to label if AL!=CR
                                   
    @ENDN:                         
    
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