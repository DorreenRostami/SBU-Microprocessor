#make_exe#

.model small 
.stack 64

.DATA
    linefeed db 13, 10, "$" 
    
    border_start_col dw 99 
    border_start_row dw 0
    ; each block is 10 pixels
    border_end_col dw 180 ; 8 cols
    border_end_row dw 111 ; 11 rows 
    
    border2_start_col dw 5 
    border2_start_row dw 5
    border2_end_col dw 60 
    border2_end_row dw 60 
    
    board_color  dw 0,0,0,0,0,0,0,0 ;0-7 
                 dw 0,0,0,0,0,0,0,0 ;8-15
                 dw 0,0,0,0,0,0,0,0 ;16-23
                 dw 0,0,0,0,0,0,0,0 ;24-31
                 dw 0,0,0,0,0,0,0,0 ;32-39
                 dw 0,0,0,0,0,0,0,0 ;40-47
                 dw 0,0,0,0,0,0,0,0 ;48-55
                 dw 0,0,0,0,0,0,0,0 ;56-63
                 dw 0,0,0,0,0,0,0,0 ;64-71
                 dw 0,0,0,0,0,0,0,0 ;72-79
                 dw 0,0,0,0,0,0,0,0 ;80-87              
    board_col    dw 100,110,120,130,140,150,160,170 ;top left col pixel               
    board_row    dw 1,11,21,31,41,51,61,71, 81, 91, 101 ;top left row pixel 
    full_row     dw 0,0,0,0,0,0,0,0,0,0,0 ;1 if row is full
    start_row_down dw 0 ;row to start moving down from
    start_block_down dw 0
    skip_rows dw 0 
    
    start_col dw 100
    start_row dw 1
    end_col dw 109
    end_row dw 10
    
    color_arr dw 0,0,0
    color_arr_ptr dw 0
    curr_color dw ?
    curr_block dw 0
    curr_rotation dw 0 
    curr_f_block dw 80
    
    score dw 0
    score_col db 2 ;pixel of column to start printing score from 

.CODE
MAIN PROC FAR
    mov ax, @DATA                
    mov ds, ax
    
    call rand_color
    call delay
    call clear_screen 
    call set_graphic_mode
    call draw_border
    call print_next_string
    call rand_color
    call delay
    call print_score_string    
    
newshape:
    call show_score
    call new_shape
    call show_next_two
    call handle_curr_shape
    jmp newshape             
    
endgame:    
    mov ah, 4Ch ; return control to DOS
    int 21h
MAIN ENDP

clear_screen proc
    mov al, 06h ; scroll down
    mov bh, 00h
    mov cx, 0000h
    mov dx, 184Fh
    int 10h             
    ret                    
endp clear_screen     

set_graphic_mode proc
    mov ax, 0013h   ; AH=00h is BIOS.SetVideoMode, AL=13h is 320x200 mode
    int 10h 
    ret
endp set_graphic_mode 

show_score proc
    mov ax, score
    out 199, ax
    
    mov ax, score                     
    xor cx, cx                     
    mov bx, 10                     
@REPEAT:                      
    xor dx, dx                 
    div bx                         
    push dx                       
    inc cx                     
    or ax, ax                  
    jne @REPEAT   ;jump if ZF=0 (AX=0)                          
@DISPLAY:                      
    pop dx                     
    or dl, 30h    ;convert decimal to ascii code
    push dx
    mov  dl, score_col  ;Column
    mov  dh, 9          ;Row
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h
    inc score_col
    mov  bl, 0Fh  ;Color is white
    mov  bh, 0    ;Display page
    pop ax        ;al will have ascii code (line 102)
    mov  ah, 0Eh  ;Teletype
    int  10h                     
    loop @DISPLAY ;jump if CX!=0
    
    mov score_col,2    
    ret                         
show_score endp

print_score_string proc
    mov  dl, 2    ;Column
    mov  dh, 8    ;Row
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h
    mov  bl, 0Fh  ;Color is white
    mov  bh, 0    ;Display page
    mov  ah, 0Eh  ;Teletype
    mov  al, 's'
    int  10h
    
    mov  dl, 3    ;Column
    mov  ah, 02h  ;SetCursorPosition
    int  10h
    mov  ah, 0Eh  ;Teletype
    mov  al, 'c'
    int  10h
    
    mov  dl, 4    ;Column
    mov  ah, 02h  ;SetCursorPosition
    int  10h    
    mov  ah, 0Eh  ;Teletype
    mov  al, 'o'
    int  10h
    
    mov  dl, 5    ;Column
    mov  ah, 02h  ;SetCursorPosition
    int  10h    
    mov  ah, 0Eh  ;Teletype
    mov  al, 'r'
    int  10h
    
    mov  dl, 6    ;Column
    mov  ah, 02h  ;SetCursorPosition
    int  10h    
    mov  ah, 0Eh  ;Teletype
    mov  al, 'e'
    int  10h
    
    ret
print_score_string endp 

print_next_string proc
    mov  dl, 2    ;Column
    mov  dh, 1    ;Row
    mov  bh, 0    ;Display page
    mov  ah, 02h  ;SetCursorPosition
    int  10h
    mov  bl, 0Fh  ;Color is white
    mov  bh, 0    ;Display page
    mov  ah, 0Eh  ;Teletype
    mov  al, 'n'
    int  10h
    
    mov  dl, 3    ;Column
    mov  ah, 02h  ;SetCursorPosition
    int  10h
    mov  ah, 0Eh  ;Teletype
    mov  al, 'e'
    int  10h
    
    mov  dl, 4    ;Column
    mov  ah, 02h  ;SetCursorPosition
    int  10h    
    mov  ah, 0Eh  ;Teletype
    mov  al, 'x'
    int  10h
    
    mov  dl, 5    ;Column
    mov  ah, 02h  ;SetCursorPosition
    int  10h    
    mov  ah, 0Eh  ;Teletype
    mov  al, 't'
    int  10h
    
    ret
print_next_string endp

draw_border proc 
    mov ah, 0Ch 
    mov al, 0Fh ;white
    mov dx, border_start_row
    mov cx, border_start_col 
top_row:    
    int 10h
    inc cx
    cmp cx, border_end_col
    jnz top_row
right_col:
    int 10h
    inc dx
    cmp dx, border_end_row
    jnz right_col
bottom_row:
    int 10h
    dec cx
    cmp cx, border_start_col
    jnz bottom_row
left_col:
    int 10h
    dec dx
    cmp dx, border_start_row
    jnz left_col
    
    mov dx, border2_start_row
    mov cx, border2_start_col 
top_row2:    
    int 10h
    inc cx
    cmp cx, border2_end_col
    jnz top_row2
right_col2:
    int 10h
    inc dx
    cmp dx, border2_end_row
    jnz right_col2
bottom_row2:
    int 10h
    dec cx
    cmp cx, border2_start_col
    jnz bottom_row2
left_col2:
    int 10h
    dec dx
    cmp dx, border2_start_row
    jnz left_col2
        
    ret
endp draw_border

draw_square proc 
    ;input block number in bx
    mov ah, 0Ch   
    lea di, board_color
    add di, bx
    add di, bx 
    mov al, [di]
    push ax
    
    mov ax, bx
    mov bx, 8
    xor dx, dx
    div bx      ;dx=col num, ax=row num 
    add dx, dx
    add ax, ax
      
    lea di, board_row
    add di, ax
    mov cx, [di]
    mov start_row, cx
    add cx, 9
    mov end_row, cx 
    
    lea di, board_col
    add di, dx
    mov cx, [di]
    mov start_col, cx
    add cx, 9
    mov end_col, cx
    
    pop ax
    mov dx, start_row
loop1:
    mov cx, start_col
loop2:
    int 10h
    inc cx
    cmp cx, end_col
    jnz loop2
    inc dx
    cmp dx, end_row
    jnz loop1
    
    ret    
endp draw_square

rand_color proc
    ;insert random number in color_arr    
    xor ax,ax       ; clear ax
    int 1Ah         ; Int 1ah/ah=0 get timer ticks since midnight in CX:DX
    mov ax,dx       
    xor dx,dx       
    mov bx,5        
    div bx          ; divide dx:ax by bx
    inc dx          ; dx = modulo from division                     
                    ; 1<=dx<=5 (blue,green,cyan,red,magenta)
         
    lea di, color_arr
    add di, color_arr_ptr
    add di, color_arr_ptr
    mov [di], dx
        
    inc color_arr_ptr
    mov ax, color_arr_ptr
    xor dx, dx
    mov bx, 3
    div bx
    mov color_arr_ptr, dx
    
    ret                    
endp rand_color  

new_shape proc
    call rand_color  
    lea di, color_arr
    add di, color_arr_ptr
    add di, color_arr_ptr
    mov dx, [di]     
    mov curr_color, dx
    mov curr_rotation, 0
    xor ax, ax 
    xor bx, bx
shape1: 
    ;shape1 will always be at top left corner unless game is over    
    cmp dx, 1 
    jnz shape2  
    jmp end_new_shape
shape2:
    cmp dx, 2 
    jnz shape3    
check2:
    cmp ax, 6
    ja endgame
    push ax
    call can_place_here
    pop ax
    cmp bx, 1
    jz end_new_shape
addax2:
    add ax,1
    jmp check2    
shape3:
    cmp dx, 3 
    jnz shape4   
check3:
    cmp ax, 6
    ja endgame
    push ax
    call can_place_here
    pop ax
    cmp bx, 1
    jz end_new_shape
addax3:
    add ax,1
    jmp check3     
shape4:
    cmp dx, 4 
    jnz shape5  
check4:
    cmp ax, 6
    ja endgame 
    push ax
    call can_place_here
    pop ax
    cmp bx, 1
    jz end_new_shape
addax4:
    add ax,1
    jmp check4                  
shape5:
check5:
    cmp ax, 5
    ja endgame
    lea di, board_color
    mov bx, ax          ;won't call can_place_here
    add bx, bx          ;bc only 1 block needs to be checked
    add bx, 18
    cmp [di+bx], 0      ;2(ax+9)=2ax+18
    jz end_new_shape
addax5:
    add ax,1
    jmp check5        
end_new_shape:
    mov curr_block, ax 
    mov dx, curr_color
    call draw_shape  
    ret
endp new_shape

draw_shape proc
    ;curr_color should be set to current shape color
    ;before calling this proc!!!
    ;dx = 0 if shape should be blacked out
    ;o.w dx = curr_color
    lea si, board_color
    add si, curr_block
    add si, curr_block
draw_shape1:     
    cmp curr_color, 1 
    jnz draw_shape2
    cmp curr_rotation, 0
    jnz draw_shape1_rot1    
    mov [si], dx
    mov [si+2], dx
    mov [si+4], dx 
    mov [si+6], dx
    mov bx, curr_block
    call draw_square
    mov bx, curr_block
    add bx, 1
    call draw_square
    mov bx, curr_block
    add bx, 2
    call draw_square
    mov bx, curr_block
    add bx, 3
    call draw_square 
    jmp end_draw_shape
draw_shape1_rot1: 
    cmp curr_rotation, 1
    jnz draw_shape1_rot2    
    mov [si], dx
    mov [si+16], dx
    mov [si+32], dx 
    mov [si+48], dx
    mov bx, curr_block
    call draw_square
    mov bx, curr_block
    add bx, 8
    call draw_square
    mov bx, curr_block
    add bx, 16
    call draw_square
    mov bx, curr_block
    add bx, 24
    call draw_square 
    jmp end_draw_shape
draw_shape1_rot2: 
    cmp curr_rotation, 2
    jnz draw_shape1_rot3    
    mov [si], dx
    mov [si-2], dx
    mov [si-4], dx 
    mov [si-6], dx
    mov bx, curr_block
    call draw_square
    mov bx, curr_block
    sub bx, 1
    call draw_square
    mov bx, curr_block
    sub bx, 2
    call draw_square
    mov bx, curr_block
    sub bx, 3
    call draw_square 
    jmp end_draw_shape
draw_shape1_rot3:       
    mov [si], dx
    mov [si-16], dx
    mov [si-32], dx 
    mov [si-48], dx
    mov bx, curr_block
    call draw_square
    mov bx, curr_block
    sub bx, 8
    call draw_square
    mov bx, curr_block
    sub bx, 16
    call draw_square
    mov bx, curr_block
    sub bx, 24
    call draw_square 
    jmp end_draw_shape

draw_shape2:
    cmp curr_color, 2 
    jnz draw_shape3    
    cmp curr_rotation, 0
    jnz draw_shape2_rot1 
    mov [si], dx
    mov [si+2], dx
    mov [si+16], dx 
    mov [si+18], dx
    mov bx, curr_block          
    call draw_square
    mov bx, curr_block
    add bx, 1         
    call draw_square
    mov bx, curr_block
    add bx, 8           
    call draw_square
    mov bx, curr_block
    add bx, 9           
    call draw_square 
    jmp end_draw_shape
draw_shape2_rot1:
    cmp curr_rotation, 1
    jnz draw_shape2_rot2 
    mov [si], dx
    mov [si-2], dx
    mov [si+16], dx 
    mov [si+14], dx
    mov bx, curr_block          
    call draw_square
    mov bx, curr_block
    sub bx, 1         
    call draw_square
    mov bx, curr_block
    add bx, 8           
    call draw_square
    mov bx, curr_block
    add bx, 7           
    call draw_square 
    jmp end_draw_shape
draw_shape2_rot2:
    cmp curr_rotation, 2
    jnz draw_shape2_rot3 
    mov [si], dx
    mov [si-2], dx
    mov [si-16], dx 
    mov [si-18], dx
    mov bx, curr_block          
    call draw_square
    mov bx, curr_block
    sub bx, 1         
    call draw_square
    mov bx, curr_block
    sub bx, 8           
    call draw_square
    mov bx, curr_block
    sub bx, 9           
    call draw_square 
    jmp end_draw_shape
draw_shape2_rot3:      
    mov [si], dx
    mov [si+2], dx
    mov [si-16], dx 
    mov [si-14], dx
    mov bx, curr_block          
    call draw_square
    mov bx, curr_block
    add bx, 1         
    call draw_square
    mov bx, curr_block
    sub bx, 8           
    call draw_square
    mov bx, curr_block
    sub bx, 7           
    call draw_square 
    jmp end_draw_shape            
    
draw_shape3:
    cmp curr_color, 3 
    jnz draw_shape4   
    cmp curr_rotation, 0
    jnz draw_shape3_rot1 
    mov [si], dx
    mov [si+16], dx
    mov [si+32], dx 
    mov [si+34], dx
    mov bx, curr_block           
    call draw_square
    mov bx, curr_block
    add bx, 8           
    call draw_square
    mov bx, curr_block
    add bx, 16
    call draw_square
    mov bx, curr_block
    add bx, 17
    call draw_square 
    jmp end_draw_shape  
draw_shape3_rot1:
    cmp curr_rotation, 1
    jnz draw_shape3_rot2 
    mov [si], dx
    mov [si-2], dx
    mov [si-4], dx 
    mov [si+12], dx
    mov bx, curr_block           
    call draw_square
    mov bx, curr_block
    sub bx, 1           
    call draw_square
    mov bx, curr_block
    sub bx, 2
    call draw_square
    mov bx, curr_block
    add bx, 6
    call draw_square 
    jmp end_draw_shape
draw_shape3_rot2:
    cmp curr_rotation, 2
    jnz draw_shape3_rot3 
    mov [si], dx
    mov [si-16], dx
    mov [si-32], dx 
    mov [si-34], dx
    mov bx, curr_block           
    call draw_square
    mov bx, curr_block
    sub bx, 8           
    call draw_square
    mov bx, curr_block
    sub bx, 16
    call draw_square
    mov bx, curr_block
    sub bx, 17
    call draw_square 
    jmp end_draw_shape
draw_shape3_rot3:     
    mov [si], dx
    mov [si+2], dx
    mov [si+4], dx 
    mov [si-12], dx
    mov bx, curr_block           
    call draw_square
    mov bx, curr_block
    add bx, 1           
    call draw_square
    mov bx, curr_block
    add bx, 2
    call draw_square
    mov bx, curr_block
    sub bx, 6
    call draw_square 
    jmp end_draw_shape            

draw_shape4:
    cmp curr_color, 4 
    jnz draw_shape5  
    cmp curr_rotation, 0
    jnz draw_shape4_rot1
    mov [si], dx
    mov [si+16], dx
    mov [si+18], dx 
    mov [si+34], dx
    mov bx, curr_block
    call draw_square
    mov bx, curr_block
    add bx, 8
    call draw_square
    mov bx, curr_block
    add bx, 9
    call draw_square
    mov bx, curr_block
    add bx, 17
    call draw_square 
    jmp end_draw_shape
draw_shape4_rot1:
    cmp curr_rotation, 1
    jnz draw_shape4_rot2
    mov [si], dx
    mov [si-2], dx
    mov [si+14], dx 
    mov [si+12], dx
    mov bx, curr_block
    call draw_square
    mov bx, curr_block
    sub bx, 1
    call draw_square
    mov bx, curr_block
    add bx, 7
    call draw_square
    mov bx, curr_block
    add bx, 6
    call draw_square 
    jmp end_draw_shape
draw_shape4_rot2:    
    cmp curr_rotation, 2
    jnz draw_shape4_rot3
    mov [si], dx
    mov [si-16], dx
    mov [si-18], dx 
    mov [si-34], dx
    mov bx, curr_block
    call draw_square
    mov bx, curr_block
    sub bx, 8
    call draw_square
    mov bx, curr_block
    sub bx, 9
    call draw_square
    mov bx, curr_block
    sub bx, 17
    call draw_square 
    jmp end_draw_shape
draw_shape4_rot3:
    mov [si], dx
    mov [si+2], dx
    mov [si-14], dx 
    mov [si-12], dx
    mov bx, curr_block
    call draw_square
    mov bx, curr_block
    add bx, 1
    call draw_square
    mov bx, curr_block
    sub bx, 7
    call draw_square
    mov bx, curr_block
    sub bx, 6
    call draw_square 
    jmp end_draw_shape                   
     
draw_shape5:
    cmp curr_rotation, 0
    jnz draw_shape5_rot1
    mov [si], dx
    mov [si+2], dx
    mov [si+4], dx 
    mov [si+18], dx
    mov bx, curr_block
    call draw_square
    mov bx, curr_block
    add bx, 1
    call draw_square
    mov bx, curr_block
    add bx, 2
    call draw_square
    mov bx, curr_block
    add bx, 9
    call draw_square
    jmp end_draw_shape
draw_shape5_rot1:
    cmp curr_rotation, 1
    jnz draw_shape5_rot2
    mov [si], dx
    mov [si+16], dx
    mov [si+14], dx 
    mov [si+32], dx
    mov bx, curr_block
    call draw_square
    mov bx, curr_block
    add bx, 8
    call draw_square
    mov bx, curr_block
    add bx, 7
    call draw_square
    mov bx, curr_block
    add bx, 16
    call draw_square 
    jmp end_draw_shape
draw_shape5_rot2:
    cmp curr_rotation, 2
    jnz draw_shape5_rot3
    mov [si], dx
    mov [si-2], dx
    mov [si-4], dx 
    mov [si-18], dx
    mov bx, curr_block
    call draw_square
    mov bx, curr_block
    sub bx, 1
    call draw_square
    mov bx, curr_block
    sub bx, 2
    call draw_square
    mov bx, curr_block
    sub bx, 9
    call draw_square
    jmp end_draw_shape
draw_shape5_rot3:
    mov [si], dx
    mov [si-16], dx
    mov [si-14], dx 
    mov [si-32], dx
    mov bx, curr_block
    call draw_square
    mov bx, curr_block
    sub bx, 8
    call draw_square
    mov bx, curr_block
    sub bx, 7
    call draw_square
    mov bx, curr_block
    sub bx, 16
    call draw_square
    
end_draw_shape:
    ret
endp draw_shape 

can_place_here proc
    ;input starting block in ax 
    ;output true(1) or false(0) in bx           
    lea di, board_color
    add di, ax
    add di, ax
    cmp [di], 0 ;2(ax)
    jnz cantplace
    mov bx, 8
    xor dx, dx
    div bx      ;dx = col  number, ax = row number
    mov cx, ax  ;cx = row number
    mov bx, curr_color  
can_place_shape1:     
    cmp bx, 1 
    jnz can_place_shape2
    cmp curr_rotation, 0
    jnz can_place_shape1_rot1
    cmp dx, 4      ;compare columns
    ja cantplace
    add di, 2      ;2(ax+1)
    cmp [di], 0 
    jnz cantplace     
    add di, 2      ;2(ax+2)
    cmp [di], 0 
    jnz cantplace
    add di, 2      ;2(ax+3)
    cmp [di], 0 
    jnz cantplace
    jmp canplace    
can_place_shape1_rot1:
    cmp curr_rotation, 1
    jnz can_place_shape1_rot2 
    cmp cx, 7      ;compare rows
    ja cantplace
    add di, 16     ;2(ax+8)
    cmp [di], 0 
    jnz cantplace     
    add di, 16     ;2(ax+16)
    cmp [di], 0 
    jnz cantplace
    add di, 16     ;2(ax+24)
    cmp [di], 0 
    jnz cantplace
    jmp canplace    
can_place_shape1_rot2:
    cmp curr_rotation, 2
    jnz can_place_shape1_rot3
    cmp dx, 3      ;compare columns
    jb cantplace 
    sub di, 2      ;2(ax-1)
    cmp [di], 0 
    jnz cantplace     
    sub di, 2      ;2(ax-2)
    cmp [di], 0 
    jnz cantplace
    sub di, 2      ;2(ax-3)
    cmp [di], 0 
    jnz cantplace
    jmp canplace    
can_place_shape1_rot3:
    cmp cx, 3      ;compare rows
    jb cantplace        
    sub di, 16     ;2(ax-8)
    cmp [di], 0 
    jnz cantplace     
    sub di, 16     ;2(ax-16)
    cmp [di], 0 
    jnz cantplace
    sub di, 16     ;2(ax-24)
    cmp [di], 0 
    jnz cantplace
    jmp canplace    

can_place_shape2:
    cmp bx, 2 
    jnz can_place_shape3     
    cmp curr_rotation, 0
    jnz can_place_shape2_rot1
    cmp dx, 6      ;cmp cols
    ja cantplace
    cmp cx, 9      ;cmp rows
    ja cantplace
    add di, 2      ;2(ax+1)
    cmp [di], 0 
    jnz cantplace     
    add di, 14     ;2(ax+8)
    cmp [di], 0 
    jnz cantplace
    add di, 2      ;2(ax+9)
    cmp [di], 0 
    jnz cantplace
    jmp canplace
can_place_shape2_rot1:
    cmp curr_rotation, 1
    jnz can_place_shape2_rot2 
    cmp dx, 1      ;cmp cols
    jb cantplace
    cmp cx, 9      ;cmp rows
    ja cantplace
    sub di, 2      ;2(ax-1)
    cmp [di], 0 
    jnz cantplace     
    add di, 16     ;2(ax+7)
    cmp [di], 0 
    jnz cantplace
    add di, 2      ;2(ax+8)
    cmp [di], 0 
    jnz cantplace
    jmp canplace
can_place_shape2_rot2:
    cmp curr_rotation, 2
    jnz can_place_shape2_rot3
    cmp dx, 1      ;cmp cols
    jb cantplace
    cmp cx, 1      ;cmp rows
    jb cantplace
    sub di, 2      ;2(ax-1)
    cmp [di], 0 
    jnz cantplace     
    sub di, 14     ;2(ax-8)
    cmp [di], 0 
    jnz cantplace
    sub di, 2      ;2(ax-9)
    cmp [di], 0 
    jnz cantplace
    jmp canplace
can_place_shape2_rot3:
    cmp dx, 6      ;cmp cols
    ja cantplace
    cmp cx, 1      ;cmp rows
    jb cantplace
    add di, 2      ;2(ax+1)
    cmp [di], 0 
    jnz cantplace     
    sub di, 16     ;2(ax-7)
    cmp [di], 0 
    jnz cantplace
    sub di, 2      ;2(ax-8)
    cmp [di], 0 
    jnz cantplace
    jmp canplace
    
can_place_shape3:
    cmp bx, 3 
    jnz can_place_shape4   
    cmp curr_rotation, 0
    jnz can_place_shape3_rot1
    cmp dx, 6      ;cmp cols
    ja cantplace
    cmp cx, 8      ;cmp rows
    ja cantplace
    add di, 16     ;2(ax+8)
    cmp [di], 0 
    jnz cantplace     
    add di, 16     ;2(ax+16)
    cmp [di], 0 
    jnz cantplace
    add di, 2      ;2(ax+17)
    cmp [di], 0 
    jnz cantplace
    jmp canplace 
can_place_shape3_rot1:
    cmp curr_rotation, 1
    jnz can_place_shape3_rot2
    cmp dx, 2      ;cmp cols
    jb cantplace
    cmp cx, 9      ;cmp rows
    ja cantplace
    sub di, 2      ;2(ax-1)
    cmp [di], 0 
    jnz cantplace     
    sub di, 2      ;2(ax-2)
    cmp [di], 0 
    jnz cantplace
    add di, 16     ;2(ax+6)
    cmp [di], 0 
    jnz cantplace
    jmp canplace
can_place_shape3_rot2:
    cmp curr_rotation, 2
    jnz can_place_shape3_rot3
    cmp dx, 1      ;cmp cols
    jb cantplace
    cmp cx, 2      ;cmp rows
    jb cantplace
    sub di, 16     ;2(ax-8)
    cmp [di], 0 
    jnz cantplace     
    sub di, 16     ;2(ax-16)
    cmp [di], 0 
    jnz cantplace
    sub di, 2      ;2(ax-17)
    cmp [di], 0 
    jnz cantplace
    jmp canplace
can_place_shape3_rot3:
    cmp dx, 5      ;cmp cols
    ja cantplace
    cmp cx, 1      ;cmp rows
    jb cantplace
    add di, 2      ;2(ax+1)
    cmp [di], 0 
    jnz cantplace     
    add di, 2      ;2(ax+2)
    cmp [di], 0 
    jnz cantplace
    sub di, 16     ;2(ax-6)
    cmp [di], 0 
    jnz cantplace
    jmp canplace     

can_place_shape4:
    cmp bx, 4 
    jnz can_place_shape5
    cmp curr_rotation, 0
    jnz can_place_shape4_rot1
    cmp dx, 6      ;cmp cols
    ja cantplace
    cmp cx, 8      ;cmp rows
    ja cantplace  
    add di, 16     ;2(ax+8)
    cmp [di], 0 
    jnz cantplace     
    add di, 2      ;2(ax+9)
    cmp [di], 0 
    jnz cantplace
    add di, 16     ;2(ax+17)
    cmp [di], 0 
    jnz cantplace
    jmp canplace    
can_place_shape4_rot1:
    cmp curr_rotation, 1
    jnz can_place_shape4_rot2
    cmp dx, 2      ;cmp cols
    jb cantplace
    cmp cx, 9      ;cmp rows
    ja cantplace
    sub di, 2      
    cmp [di], 0 
    jnz cantplace     
    add di, 16      
    cmp [di], 0 
    jnz cantplace
    sub di, 2     
    cmp [di], 0 
    jnz cantplace
    jmp canplace
can_place_shape4_rot2:
    cmp curr_rotation, 2
    jnz can_place_shape4_rot3
    cmp dx, 1      ;cmp cols
    jb cantplace
    cmp cx, 2      ;cmp rows
    jb cantplace
    sub di, 16     
    cmp [di], 0 
    jnz cantplace     
    sub di, 2     
    cmp [di], 0 
    jnz cantplace
    sub di, 16      
    cmp [di], 0 
    jnz cantplace
    jmp canplace
can_place_shape4_rot3:
    cmp dx, 5      ;cmp cols
    ja cantplace
    cmp cx, 1      ;cmp rows
    jb cantplace
    add di, 2      
    cmp [di], 0 
    jnz cantplace     
    sub di, 16      
    cmp [di], 0 
    jnz cantplace
    add di, 2     
    cmp [di], 0 
    jnz cantplace
    jmp canplace           
     
can_place_shape5:
    cmp curr_rotation, 0
    jnz can_place_shape5_rot1
    cmp dx, 5      ;cmp cols
    ja cantplace
    cmp cx, 9      ;cmp rows
    ja cantplace  
    add di, 2      ;2(ax+1)
    cmp [di], 0 
    jnz cantplace     
    add di, 2      ;2(ax+2)
    cmp [di], 0 
    jnz cantplace
    add di, 14     ;2(ax+9)
    cmp [di], 0 
    jnz cantplace
    jmp canplace
can_place_shape5_rot1:
    cmp curr_rotation, 1
    jnz can_place_shape5_rot2
    cmp dx, 1      ;cmp cols
    jb cantplace
    cmp cx, 8      ;cmp rows
    ja cantplace
    add di, 16      
    cmp [di], 0 
    jnz cantplace     
    add di, 16      
    cmp [di], 0 
    jnz cantplace
    sub di, 18     
    cmp [di], 0 
    jnz cantplace
    jmp canplace
can_place_shape5_rot2:
    cmp curr_rotation, 2
    jnz can_place_shape5_rot3
    cmp dx, 2      ;cmp cols
    jb cantplace
    cmp cx, 1      ;cmp rows
    jb cantplace
    sub di, 2     
    cmp [di], 0 
    jnz cantplace     
    sub di, 2     
    cmp [di], 0 
    jnz cantplace
    sub di, 14      
    cmp [di], 0 
    jnz cantplace
    jmp canplace
can_place_shape5_rot3:
    cmp dx, 6      ;cmp cols
    ja cantplace
    cmp cx, 2      ;cmp rows
    jb cantplace
    sub di, 16      
    cmp [di], 0 
    jnz cantplace     
    sub di, 16      
    cmp [di], 0 
    jnz cantplace
    add di, 18     
    cmp [di], 0 
    jnz cantplace
    jmp canplace       

canplace:
    mov bx, 1
    jmp endcheck
cantplace:
    mov bx, 0           
endcheck: 
    ret
endp can_place_here  

handle_curr_shape proc
    jmp checkplacedown
keystart:     
    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx 
    
    mov ah, 00h
    int 16h
keya:    
    cmp al, 61h ;61h='a'
    jnz keyd 
    call move_curr_shape_left
    jmp checkplacedown
keyd:
    cmp al, 64h ;64h='d'
    jnz keyw
    call move_curr_shape_right
    jmp checkplacedown
keyw:
    cmp al, 77h ;77h='w'
    jnz keys
    call rotate_curr_shape  
    
checkplacedown:
    mov ax, curr_block
    add ax, 8
placedownloop:
    xor bx, bx     
    push ax
    call blackout_check
    pop ax
    cmp bx, 0
    jz donecheckplacedown
    add ax,8
    jmp placedownloop
donecheckplacedown:
    sub ax, 8
    mov curr_f_block, ax 
    mov bx, curr_color
    call draw_shape_outline
    jmp keystart
    
keys:
    cmp al, 73h ;73h='s'
    jnz keyq
    call move_curr_shape_down
    jmp keystart   
keyq:
    cmp al, 71h ;71h='q'
    jz endgame
keyf:        
    cmp al, 66h ;66h='f'
    jnz keystart
    call draw_shape ;to black out curr shape
    mov ax, curr_f_block 
    xor bx, bx
    call draw_shape_outline ;to black out shape outline
    mov dx, curr_f_block
    mov curr_block, dx
    mov dx, curr_color
    call draw_shape
    call check_rows
    add score, cx    
    ret
endp handle_curr_shape

normalize_rotation proc
    push ax 
    push dx
    push bx
    mov ax, curr_rotation
    xor dx, dx
    mov bx, 4
    div bx
    mov curr_rotation, dx
    pop bx
    pop dx
    pop ax
    ret
endp inc_rotation    

blackout_check proc
    ;checks if curr shape can be moved to dest block
    ;by blacking out curr shape blocks and calling 
    ;can_place_here on dest block as starting block
    ;and then re-coloring curr shape blocks
    ;--dest block is input as ax
    ;--bx=1 if shape is rotating
    ;--output true(1) or false(0) in bx
    lea si, board_color
    add si, curr_block
    add si, curr_block
    mov [si], 0
blackout_shape1:
    cmp curr_color, 1
    jnz blackout_shape2
    cmp curr_rotation, 0
    jnz blackout_shape1_rot1
    mov [si+2], 0
    mov [si+4], 0
    mov [si+6], 0
    push curr_rotation
    add curr_rotation, bx
    call normalize_rotation     
    push si
    call can_place_here
    pop si
    pop curr_rotation
    mov [si], 1
    mov [si+2], 1
    mov [si+4], 1
    mov [si+6], 1
    jmp blackout_done
blackout_shape1_rot1:
    cmp curr_rotation, 1
    jnz blackout_shape1_rot2 
    mov [si+16], 0
    mov [si+32], 0
    mov [si+48], 0 
    push curr_rotation
    add curr_rotation, bx
    call normalize_rotation     
    push si
    call can_place_here
    pop si
    pop curr_rotation
    mov [si], 1
    mov [si+16], 1
    mov [si+32], 1
    mov [si+48], 1
    jmp blackout_done
blackout_shape1_rot2:    
    cmp curr_rotation, 2
    jnz blackout_shape1_rot3
    mov [si-2], 0
    mov [si-4], 0
    mov [si-6], 0
    push curr_rotation
    add curr_rotation, bx
    call normalize_rotation     
    push si
    call can_place_here
    pop si
    pop curr_rotation
    mov [si], 1
    mov [si-2], 1
    mov [si-4], 1
    mov [si-6], 1
    jmp blackout_done    
blackout_shape1_rot3:
    mov [si-16], 0
    mov [si-32], 0
    mov [si-48], 0 
    push curr_rotation
    add curr_rotation, bx
    call normalize_rotation     
    push si
    call can_place_here
    pop si
    pop curr_rotation
    mov [si], 1
    mov [si-16], 1
    mov [si-32], 1
    mov [si-48], 1
    jmp blackout_done      

blackout_shape2:
    cmp curr_color, 2
    jnz blackout_shape3
    cmp curr_rotation, 0
    jnz blackout_shape2_rot1
    mov [si+16], 0
    mov [si+18], 0
    mov [si+2], 0
    push curr_rotation
    add curr_rotation, bx
    call normalize_rotation     
    push si
    call can_place_here
    pop si
    pop curr_rotation
    mov [si], 2
    mov [si+16], 2
    mov [si+18], 2
    mov [si+2], 2
    jmp blackout_done 
blackout_shape2_rot1:    
    cmp curr_rotation, 1
    jnz blackout_shape2_rot2
    mov [si+16], 0
    mov [si+14], 0
    mov [si-2], 0
    push curr_rotation
    add curr_rotation, bx
    call normalize_rotation     
    push si
    call can_place_here
    pop si
    pop curr_rotation
    mov [si], 2
    mov [si+16], 2
    mov [si+14], 2
    mov [si-2], 2
    jmp blackout_done
blackout_shape2_rot2:    
    cmp curr_rotation, 2
    jnz blackout_shape2_rot3
    mov [si-16], 0
    mov [si-18], 0
    mov [si-2], 0
    push curr_rotation
    add curr_rotation, bx
    call normalize_rotation     
    push si
    call can_place_here
    pop si
    pop curr_rotation
    mov [si], 2
    mov [si-16], 2
    mov [si-18], 2
    mov [si-2], 2
    jmp blackout_done
blackout_shape2_rot3:
    mov [si-16], 0
    mov [si-14], 0
    mov [si+2], 0
    push curr_rotation
    add curr_rotation, bx
    call normalize_rotation     
    push si
    call can_place_here
    pop si
    pop curr_rotation
    mov [si], 2
    mov [si-16], 2
    mov [si-14], 2
    mov [si+2], 2
    jmp blackout_done   
    
blackout_shape3:
    cmp curr_color, 3
    jnz blackout_shape4
    cmp curr_rotation, 0
    jnz blackout_shape3_rot1
    mov [si+16], 0
    mov [si+32], 0
    mov [si+34], 0
    push curr_rotation
    add curr_rotation, bx
    call normalize_rotation     
    push si
    call can_place_here
    pop si
    pop curr_rotation
    mov [si], 3
    mov [si+16], 3
    mov [si+32], 3
    mov [si+34], 3
    jmp blackout_done 
blackout_shape3_rot1:
    cmp curr_rotation, 1
    jnz blackout_shape3_rot2
    mov [si-2], 0
    mov [si-4], 0
    mov [si+12], 0
    push curr_rotation
    add curr_rotation, bx
    call normalize_rotation     
    push si
    call can_place_here
    pop si
    pop curr_rotation
    mov [si], 3
    mov [si-2], 3
    mov [si-4], 3
    mov [si+12], 3
    jmp blackout_done
blackout_shape3_rot2:
    cmp curr_rotation, 2
    jnz blackout_shape3_rot3
    mov [si-16], 0
    mov [si-32], 0
    mov [si-34], 0
    push curr_rotation
    add curr_rotation, bx
    call normalize_rotation     
    push si
    call can_place_here
    pop si
    pop curr_rotation
    mov [si], 3
    mov [si-16], 3
    mov [si-32], 3
    mov [si-34], 3
    jmp blackout_done 
blackout_shape3_rot3:
    mov [si+2], 0
    mov [si+4], 0
    mov [si-12], 0
    push curr_rotation
    add curr_rotation, bx
    call normalize_rotation     
    push si
    call can_place_here
    pop si
    pop curr_rotation
    mov [si], 3
    mov [si+2], 3
    mov [si+4], 3
    mov [si-12], 3
    jmp blackout_done        
    
blackout_shape4:
    cmp curr_color, 4
    jnz blackout_shape5
    cmp curr_rotation, 0
    jnz blackout_shape4_rot1
    mov [si+16], 0
    mov [si+18], 0
    mov [si+34], 0
    push curr_rotation
    add curr_rotation, bx
    call normalize_rotation     
    push si
    call can_place_here
    pop si
    pop curr_rotation
    mov [si], 4
    mov [si+16], 4
    mov [si+18], 4
    mov [si+34], 4
    jmp blackout_done
blackout_shape4_rot1:
    cmp curr_rotation, 1
    jnz blackout_shape4_rot2
    mov [si-2], 0
    mov [si+14], 0
    mov [si+12], 0
    push curr_rotation
    add curr_rotation, bx
    call normalize_rotation     
    push si
    call can_place_here
    pop si
    pop curr_rotation
    mov [si], 4
    mov [si-2], 4
    mov [si+14], 4
    mov [si+12], 4
    jmp blackout_done
blackout_shape4_rot2:
    cmp curr_rotation, 2
    jnz blackout_shape4_rot3
    mov [si-16], 0
    mov [si-18], 0
    mov [si-34], 0
    push curr_rotation
    add curr_rotation, bx
    call normalize_rotation     
    push si
    call can_place_here
    pop si
    pop curr_rotation
    mov [si], 4
    mov [si-16], 4
    mov [si-18], 4
    mov [si-34], 4
    jmp blackout_done 
blackout_shape4_rot3:
    mov [si+2], 0
    mov [si-14], 0
    mov [si-12], 0
    push curr_rotation
    add curr_rotation, bx
    call normalize_rotation     
    push si
    call can_place_here
    pop si
    pop curr_rotation
    mov [si], 4
    mov [si+2], 4
    mov [si-14], 4
    mov [si-12], 4
    jmp blackout_done
    
blackout_shape5:
    cmp curr_rotation, 0
    jnz blackout_shape5_rot1
    mov [si+2], 0
    mov [si+4], 0
    mov [si+18], 0
    push curr_rotation
    add curr_rotation, bx
    call normalize_rotation     
    push si
    call can_place_here
    pop si
    pop curr_rotation
    mov [si], 5
    mov [si+2], 5
    mov [si+4], 5
    mov [si+18], 5
    jmp blackout_done 
blackout_shape5_rot1:
    cmp curr_rotation, 1
    jnz blackout_shape5_rot2
    mov [si+16], 0
    mov [si+14], 0
    mov [si+32], 0
    push curr_rotation
    add curr_rotation, bx
    call normalize_rotation     
    push si
    call can_place_here
    pop si
    pop curr_rotation
    mov [si], 5
    mov [si+16], 5
    mov [si+14], 5
    mov [si+32], 5
    jmp blackout_done
blackout_shape5_rot2:
    cmp curr_rotation, 2
    jnz blackout_shape5_rot3
    mov [si-2], 0
    mov [si-4], 0
    mov [si-18], 0
    push curr_rotation
    add curr_rotation, bx
    call normalize_rotation     
    push si
    call can_place_here
    pop si
    pop curr_rotation
    mov [si], 5
    mov [si-2], 5
    mov [si-4], 5
    mov [si-18], 5
    jmp blackout_done 
blackout_shape5_rot3:
    mov [si-16], 0
    mov [si-14], 0
    mov [si-32], 0
    push curr_rotation
    add curr_rotation, bx
    call normalize_rotation     
    push si
    call can_place_here
    pop si
    pop curr_rotation
    mov [si], 5
    mov [si-16], 5
    mov [si-14], 5
    mov [si-32], 5             
    
blackout_done:
    ret
endp blackout_check

move_curr_shape_left proc
    mov ax, curr_block
    xor dx, dx
    mov bx, 8
    div bx          ;dx = number of column
    cmp dx, 0
    jz left_done    ;cant call can_place_here if 
                    ;curr_block is in left most col  
                    ;bc then ax-1 will go to the row above
    mov ax, curr_block
    dec ax
    xor bx, bx
    call blackout_check
    cmp bx, 0
    jz left_done ;cant move left

    xor dx, dx
    call draw_shape ;to black out shape 
    
    mov ax, curr_f_block 
    xor bx, bx
    call draw_shape_outline ;to black out shape outline
        
    dec curr_block
    mov dx, curr_color
    call draw_shape ;to draw the moved shape      
left_done:    
    ret
endp move_curr_shape_left

move_curr_shape_right proc
    mov ax, curr_block
    xor dx, dx
    mov bx, 8
    div bx          ;dx = number of column
    cmp dx, 7
    jz right_done   ;cant call can_place_here if 
                    ;curr_block is in right most col  
                    ;bc then ax+1 will go to the next row
    mov ax, curr_block
    inc ax 
    xor bx, bx
    call blackout_check
    cmp bx, 0
    jz left_done ;cant move right

    xor dx, dx
    call draw_shape ;to black out shape    
    
    mov ax, curr_f_block 
    xor bx, bx
    call draw_shape_outline ;to black out shape outline
    
    inc curr_block
    mov dx, curr_color
    call draw_shape ;to draw the moved shape            
right_done:    
    ret
endp move_curr_shape_right 

move_curr_shape_down proc
    mov ax, curr_block
    xor dx, dx
    mov bx, 8
    div bx          ;ax = number of row
    cmp ax, 10
    jz down_done    ;cant call can_place_here if 
                    ;curr_block is in bottom row  
                    ;bc then ax+1 will go out of bounds
    mov ax, curr_block
    add ax, 8 
    xor bx, bx
    call blackout_check
    cmp bx, 0
    jz down_done ;cant move down

    xor dx, dx
    call draw_shape ;to black out shape
    add curr_block, 8
    mov dx, curr_color
    call draw_shape ;to draw the moved shape            
down_done:
    ret
endp move_curr_shape_down    

rotate_curr_shape proc
    mov ax, curr_block
    mov bx, 1
    call blackout_check
    cmp bx, 0
    jz rotate_done ;cant rotate

    xor dx, dx
    call draw_shape ;to black out shape    
    
    mov ax, curr_f_block 
    xor bx, bx
    call draw_shape_outline ;to black out shape outline
    
    inc curr_rotation
    call normalize_rotation
    mov dx, curr_color
    call draw_shape ;to draw the moved shape            
rotate_done:    
    ret
endp rotate_curr_shape

check_rows proc
    ;output score to add in cx
    mov ax, 87  ;block number
                ;holds curr block being checked
    lea di, board_color
    add di, ax
    add di, ax
    mov bx, 79  ;holds right most block of the row above
    xor cx, cx  ;hold score to add
loop3:
    cmp [di], 0
    jz aboverow
    sub ax, 1
    cmp bx, ax
    jz fullrow
    sub di, 2
    jmp loop3
aboverow:
    cmp bx, 7   ;right most block of 1st row
    jz endloop3 ;bc it shouldn't have a full block
    lea di, board_color
    add di, bx
    add di, bx
    mov ax, bx
    sub bx, 8
    jmp loop3
fullrow:
    add cx, 20        
    push ax
    push bx
    push dx    
    
    xor dx, dx
    inc ax
    mov bx, 8
    div bx     ;divide ax by 8 => ax = row num
    
    cmp cx, 20
    jnz notfirstfullrow
    mov start_row_down, ax
    sub cx, 10
notfirstfullrow:        
    lea si, full_row
    add si, ax
    add si, ax
    mov [si], 1
    pop dx
    pop bx
    pop ax
    sub bx, 8
    jmp loop3         
endloop3:    
    lea di, board_color
    add di, bx
    add di, bx  ;bx = 7, di = right block of first row
loop5:
    cmp [di], 0
    jnz endgame
    cmp bx, 0
    jz endloop5
    sub di, 2
    dec bx
    jmp loop5
endloop5:
    push cx
    call move_rows_down
    mov start_row_down, 0 
    lea si, full_row
    mov cx, 11
reset:    
    mov [si], 0
    add si, 2
    loop reset
    pop cx              
    ret
endp check_rows 

move_rows_down proc
    cmp start_row_down, 0
    jz endloop4
    
    mov ax, 8
    mul start_row_down  ;answer in dx&ax  
    add ax, 7           ;ax = starting block
    mov start_block_down, ax
    lea di, board_color
    add di, ax
    add di, ax    
    lea si, full_row
    add si, start_row_down 
    add si, start_row_down    
    mov skip_rows, 1
    
    sub si, 2        
    mov bx, 16
label1:
    cmp [si], 0
    jz label2
    add bx, 16
    sub si, 2    
    inc skip_rows
    jmp label1 
label2:    
    mov cx, 8   ;cx=counter for blocks colored in each row
    xor dx, dx  ;dx=0 if the row we are moving blocks down
                ;to was not colored from the beginning.  
loop4:    
    sub di, bx
    mov ax, [di]
    add di, bx 
    cmp [di], 0
    jz emptyblock
    mov dx, 1
emptyblock:    
    mov [di], ax
    
    push di    
    push dx 
    push cx
    push bx
    mov bx, start_block_down
    call draw_square
    pop bx
    pop cx
    pop dx    
    pop di
    
    sub di, 2
    dec start_block_down 
    loop loop4    ;hasnt finished moving a row down if cx!=0     
    cmp dx, 0
    jz endloop4
    
    mov ax, start_block_down 
    inc ax
    add ax, ax
    cmp ax, bx 
    jnz haventreachedtop ;remains true after the 1st ax=bx
    sub bx, 16 
    jmp label2
haventreachedtop:   
    sub si, 2
    cmp [si], 0
    jnz label1
    dec skip_rows
    cmp skip_rows, 0
    jnz label2        
    jmp label1    
endloop4:
    ret
endp move_rows_down 

draw_shape_outline proc
    ;input block number in ax
    ;input color in bx (0 incase of removing outline)
    push bx    
    mov bx, 8
    xor dx, dx
    div bx      ;dx=col num, ax=row num 
    add dx, dx
    add ax, ax
      
    lea di, board_row
    add di, ax
    mov cx, [di]
    mov start_row, cx 
    
    lea di, board_col
    add di, dx
    mov cx, [di]
    mov start_col, cx
    
    pop bx   
    mov dx, start_row    
outline_shape1:
    cmp curr_color, 1
    jnz outline_shape2
    cmp curr_rotation, 0
    jnz outline_shape1_rot1
    mov ax, 38
    call draw_line_ltr
    mov ax, 8
    call draw_line_ttb
    mov ax, 38
    call draw_line_rtl 
    mov ax, 8
    call draw_line_btt  
    jmp outline_done
outline_shape1_rot1:
    cmp curr_rotation, 1
    jnz outline_shape1_rot2
    mov ax, 8
    call draw_line_ltr
    mov ax, 38
    call draw_line_ttb
    mov ax, 8
    call draw_line_rtl
    mov ax, 38
    call draw_line_btt  
    jmp outline_done
outline_shape1_rot2:
    cmp curr_rotation, 2
    jnz outline_shape1_rot3
    mov ax, 9
    call draw_line_ltr
    mov ax, 8
    call draw_line_ttb
    mov ax, 38
    call draw_line_rtl
    mov ax, 8
    call draw_line_btt
    mov ax, 30
    call draw_line_ltr
    jmp outline_done    
outline_shape1_rot3:
    mov ax, 9
    call draw_line_ttb
    mov ax, 8
    call draw_line_ltr
    mov ax, 38
    call draw_line_btt
    mov ax, 8
    call draw_line_rtl
    mov ax, 30
    call draw_line_ttb
    jmp outline_done        

outline_shape2:
    cmp curr_color, 2
    jnz outline_shape3
    cmp curr_rotation, 0
    jnz outline_shape2_rot1 
    jmp draw_outline_shape2 
outline_shape2_rot1:
    cmp curr_rotation, 1
    jnz outline_shape2_rot2
    sub cx, 10
    jmp draw_outline_shape2
outline_shape2_rot2:
    cmp curr_rotation, 2
    jnz outline_shape2_rot3 
    sub cx, 10
    sub dx, 10
    jmp draw_outline_shape2        
outline_shape2_rot3:
    sub dx, 10     
draw_outline_shape2:
    mov ax, 18
    call draw_line_ltr
    mov ax, 18
    call draw_line_ttb
    mov ax, 18
    call draw_line_rtl
    mov ax, 18
    call draw_line_btt
    jmp outline_done
    
outline_shape3:
    cmp curr_color, 3
    jnz outline_shape4
    cmp curr_rotation, 0
    jnz outline_shape3_rot1
    mov ax, 9
    call draw_line_ltr
    mov ax, 19
    call draw_line_ttb
    mov ax, 9
    call draw_line_ltr
    mov ax, 9
    call draw_line_ttb
    mov ax, 18
    call draw_line_rtl
    mov ax, 28
    call draw_line_btt
    jmp outline_done
outline_shape3_rot1:
    cmp curr_rotation, 1
    jnz outline_shape3_rot2
    mov ax, 9
    call draw_line_ltr
    mov ax, 9
    call draw_line_ttb
    mov ax, 20
    call draw_line_rtl
    mov ax, 9
    call draw_line_ttb
    mov ax, 8
    call draw_line_rtl
    mov ax, 18
    call draw_line_btt
    mov ax, 20
    call draw_line_ltr
    jmp outline_done
outline_shape3_rot2:
    cmp curr_rotation, 2
    jnz outline_shape3_rot3
    mov ax, 9
    call draw_line_ttb
    mov ax, 9
    call draw_line_ltr
    mov ax, 28
    call draw_line_btt
    mov ax, 18
    call draw_line_rtl
    mov ax, 8
    call draw_line_ttb
    mov ax, 9
    call draw_line_ltr
    mov ax, 11
    call draw_line_ttb
    jmp outline_done
outline_shape3_rot3:
    mov ax, 9
    call draw_line_ttb
    mov ax, 28
    call draw_line_ltr
    mov ax, 18
    call draw_line_btt
    mov ax, 9
    call draw_line_rtl
    mov ax, 9
    call draw_line_ttb
    mov ax, 19
    call draw_line_rtl
    jmp outline_done        

outline_shape4:
    cmp curr_color, 4
    jnz outline_shape5
    cmp curr_rotation, 0
    jnz outline_shape4_rot1
    mov ax, 9
    call draw_line_ltr
    mov ax, 9
    call draw_line_ttb
    mov ax, 9
    call draw_line_ltr
    mov ax, 18
    call draw_line_ttb
    mov ax, 9
    call draw_line_rtl
    mov ax, 9
    call draw_line_btt
    mov ax, 9
    call draw_line_rtl
    mov ax, 18
    call draw_line_btt
    jmp outline_done
outline_shape4_rot1:
    cmp curr_rotation, 1
    jnz outline_shape4_rot2
    mov ax, 8
    call draw_line_ltr
    mov ax, 8
    call draw_line_ttb
    mov ax, 9
    call draw_line_rtl
    mov ax, 9
    call draw_line_ttb
    mov ax, 19
    call draw_line_rtl
    mov ax, 9
    call draw_line_btt
    mov ax, 9    
    call draw_line_ltr
    mov ax, 8
    call draw_line_btt
    mov ax, 11    
    call draw_line_ltr
    jmp outline_done    
outline_shape4_rot2:
    cmp curr_rotation, 2
    jnz outline_shape4_rot3
    mov ax, 9
    call draw_line_ttb
    mov ax, 9
    call draw_line_ltr
    mov ax, 19
    call draw_line_btt
    mov ax, 9
    call draw_line_rtl
    mov ax, 9
    call draw_line_btt
    mov ax, 9
    call draw_line_rtl
    mov ax, 18    
    call draw_line_ttb
    mov ax, 10    
    call draw_line_ltr
    jmp outline_done    
outline_shape4_rot3:
    mov ax, 8
    call draw_line_ttb
    mov ax, 18
    call draw_line_ltr
    mov ax, 9
    call draw_line_btt
    mov ax, 9
    call draw_line_ltr
    mov ax, 8
    call draw_line_btt
    mov ax, 18
    call draw_line_rtl
    mov ax, 9    
    call draw_line_ttb
    mov ax, 9    
    call draw_line_rtl
    jmp outline_done
    
outline_shape5:
    cmp curr_rotation, 0
    jnz outline_shape5_rot1
    mov ax, 28
    call draw_line_ltr
    mov ax, 8
    call draw_line_ttb
    mov ax, 9
    call draw_line_rtl
    mov ax, 9
    call draw_line_ttb
    mov ax, 10
    call draw_line_rtl
    mov ax, 9
    call draw_line_btt
    mov ax, 9
    call draw_line_rtl
    mov ax, 8
    call draw_line_btt
    jmp outline_done 
outline_shape5_rot1:
    cmp curr_rotation, 1
    jnz outline_shape5_rot2
    mov ax, 9
    call draw_line_ltr
    mov ax, 28
    call draw_line_ttb
    mov ax, 9
    call draw_line_rtl
    mov ax, 9
    call draw_line_btt
    mov ax, 9
    call draw_line_rtl
    mov ax, 10
    call draw_line_btt
    mov ax, 9    
    call draw_line_ltr
    mov ax, 9
    call draw_line_btt
    jmp outline_done       
outline_shape5_rot2:
    cmp curr_rotation, 2
    jnz outline_shape5_rot3
    mov ax, 9
    call draw_line_ltr
    mov ax, 9
    call draw_line_ttb
    mov ax, 28
    call draw_line_rtl     
    mov ax, 9
    call draw_line_btt
    mov ax, 9
    call draw_line_ltr
    mov ax, 9
    call draw_line_btt
    mov ax, 10    
    call draw_line_ltr
    mov ax, 9
    call draw_line_ttb
    jmp outline_done 
outline_shape5_rot3:
    mov ax, 8
    call draw_line_ttb
    mov ax, 9
    call draw_line_ltr
    mov ax, 9
    call draw_line_btt
    mov ax, 9
    call draw_line_ltr
    mov ax, 9
    call draw_line_btt
    mov ax, 9
    call draw_line_rtl
    mov ax, 9    
    call draw_line_btt
    mov ax, 9
    call draw_line_rtl
    mov ax, 20
    call draw_line_ttb
            
outline_done:            
    ret
endp draw_shape_outline

draw_line_ltr proc ;left to right
    ;input start row pixel in dx, col in cx, 
    ;color in bx, pixel count in ax
    mov end_col, cx 
    add end_col, ax
    mov ah, 0Ch    
    mov al, bl
ltr_loop:
    int 10h
    add cx, 1
    cmp cx, end_col
    jb ltr_loop
    ret
endp draw_line_ltr

draw_line_ttb proc ;top to bottom
    mov end_row, dx 
    add end_row, ax
    mov ah, 0Ch    
    mov al, bl    
ttb_loop:
    int 10h
    add dx, 1
    cmp dx, end_row
    jb ttb_loop
    ret
endp draw_line_ttb

draw_line_rtl proc ;right to left
    mov end_col, cx
    sub end_col, ax
    mov ah, 0Ch    
    mov al, bl    
rtl_loop:
    int 10h
    sub cx, 1
    cmp cx, end_col
    ja rtl_loop
    ret
endp draw_line_rtl 

draw_line_btt proc ;bottom to top
    mov end_row, dx
    sub end_row, ax
    mov ah, 0Ch    
    mov al, bl
btt_loop:
    int 10h
    sub dx, 1
    cmp dx, end_row
    ja btt_loop
    ret
endp draw_line_btt 

show_next_two proc
    xor ax, ax
    lea di, color_arr
    add di, color_arr_ptr
    add di, color_arr_ptr
    mov cx, 20 ; col pixel   
    mov dx, 20 ; row pixel
    
prev_label1:
    push ax ;0
    jmp next_draw
    
prev_label2:
    mov cx, 20
    mov dx, 40
    xor ax, ax
    push ax ;0
    add di, 2
    cmp color_arr_ptr, 2
    jnz next_draw
    lea di, color_arr
    jmp next_draw     

next_label1:
    mov cx, 20
    mov dx, 20 
    push [di]
    jmp next_draw
    
next_label2:
    mov cx, 20
    mov dx, 40
    add di, 2
    push [di]
    cmp color_arr_ptr, 1
    jnz next_draw
    pop bx
    lea di, color_arr
    push [di] 
       
next_draw:
    mov bx, [di]
next_shape1:
    cmp bx, 1
    jnz next_shape2
    pop bx ;0 if came from prev labels
    mov ax, 19
    call draw_line_ltr
    mov ax, 4
    call draw_line_ttb
    mov ax, 19
    call draw_line_rtl 
    mov ax, 4
    call draw_line_btt  
    jmp next_done        
next_shape2:
    cmp bx, 2
    jnz next_shape3 
    pop bx ;0 if came from prev labels
    mov ax, 9
    call draw_line_ltr
    mov ax, 9
    call draw_line_ttb
    mov ax, 9
    call draw_line_rtl
    mov ax, 9
    call draw_line_btt
    jmp next_done
next_shape3:
    cmp bx, 3
    jnz next_shape4 
    pop bx ;0 if came from prev labels    
    mov ax, 4
    call draw_line_ltr
    mov ax, 9
    call draw_line_ttb
    mov ax, 4
    call draw_line_ltr
    mov ax, 4
    call draw_line_ttb
    mov ax, 9
    call draw_line_rtl
    mov ax, 14
    call draw_line_btt
    jmp next_done       

next_shape4:
    cmp bx, 4
    jnz next_shape5 
    pop bx ;0 if came from prev labels     
    mov ax, 4
    call draw_line_ltr
    mov ax, 4
    call draw_line_ttb
    mov ax, 4
    call draw_line_ltr
    mov ax, 9
    call draw_line_ttb
    mov ax, 4
    call draw_line_rtl
    mov ax, 4
    call draw_line_btt
    mov ax, 4
    call draw_line_rtl
    mov ax, 9
    call draw_line_btt
    jmp next_done
    
next_shape5: 
    pop bx ;0 if came from prev labels 
    mov ax, 12
    call draw_line_ltr
    mov ax, 4
    call draw_line_ttb
    mov ax, 4
    call draw_line_rtl
    mov ax, 4
    call draw_line_ttb
    mov ax, 4
    call draw_line_rtl
    mov ax, 4
    call draw_line_btt
    mov ax, 4
    call draw_line_rtl
    mov ax, 4
    call draw_line_btt    

next_done:    
    cmp dx, 30
    ja second_next
    cmp bx, 0
    jz prev_label2
    jmp next_label2
second_next:
    cmp bx, 0
    jz next_label1            
    ret
endp show_next_two 

delay proc
    mov cx, 0FFFFh
delayloop:
    loop delayloop
    ret
endp delay           