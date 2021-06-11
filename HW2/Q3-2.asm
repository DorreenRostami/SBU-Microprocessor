ORG 100H

.DATA
    PROMPT_1 DB 13,10,'Enter a decimal number (string of 4 characters) : $' 
    PROMPT_2 DB 13,10,'Enter a decimal number (0 to 131071) : $' 
    ILLEGAL DB 13,10,'Illegal character. Try again : $'
    PROMPT_3 DB 13,10,'Remainder is : $'
    STRING DB 5 ;MAX NUMBER OF CHARACTERS ALLOWED (4).
       DB ? ;NUMBER OF CHARACTERS ENTERED BY USER.
       DB 5 DUP (?) ;CHARACTERS ENTERED BY USER.
    LEN DW ?
    NUM1 DW ?    
    NUM2 DW ?
.CODE 
MAIN PROC
    MOV AX, @DATA                
    MOV DS, AX 
    
    LEA DX, PROMPT_1    
    MOV AH, 9
    INT 21H
    
    MOV  AH, 0AH
    MOV  DX, OFFSET STRING
    INT  21H
    
    CALL STRING2NUM 
    MOV NUM1, CX 
    
    LEA DX, PROMPT_2    
    MOV AH, 9
    INT 21H
    
    CALL DECIMAL_INPUT 
    MOV NUM2, BX
    
    LEA DX, PROMPT_3    
    MOV AH, 9
    INT 21H
    
    MOV AX, NUM1
    XOR DX, DX
    DIV NUM2
    
    MOV BX, DX
    CALL DECIMAL_OUTPUT
    
    MOV AH, 4CH                 ; return control to DOS
    INT 21H
MAIN ENDP
    
STRING2NUM PROC 
    ; this procedure will convert decimal string to number   
    ; input : none
    ; output : store number in CX
    
    MOV SI, OFFSET STRING + 1   ; SI points to number of chars entered by the user
    MOV BX, [SI]
    AND BX, 000FH
    MOV LEN, BX     
    
    INC SI                      ; SI points to most significant digit
    XOR BX, BX
    XOR CX, CX

    @NEXT:                          
    MOV BL, [SI]          
    SUB BL, 30H                 ;convert ascii to digit
    MOV BH, 0                   ;clear BH, now BX=BL.
    MOV AX, 10
    MUL CX                      ;DX&AX=AX*CX
    MOV CX, AX
    ADD CX, BX                  ;CX = CX + BX    
    
    INC SI 
    DEC LEN               
    JNZ @NEXT                   ;loop if LEN != 0
    
    RET 
STRING2NUM ENDP 

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
        CMP AL, 30H               ; compare AL with 0 
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