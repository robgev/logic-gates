.model  SMALL

.stack  100H			; start the stack at SS:100H

.data
       NL1          DB      0AH,0DH,'ENTER NO:','$'
       NEWAPPX         DW      ?
       BITS01  db  00000000B

.code
 MAIN:
 mov ax,@DATA	; setup the DS register value
 mov ds,ax

 N     equ     177H
 ;newtons algorithm=> newAppx=(oldAppx+(N/oldAppx))/2
 ;assume oldAppx=1 to start
mov bx,1	;bx=oldAppx=1

loop_start:
mov dx, 0 ;reset the remainder
mov ax, N ;ax=number whose square root needs to be found
div bx	;ax will be quotient of (N/oldAppx = ax/bx)

;quotient is in ax now
add ax,bx	;ax = (N/oldAppx) + oldAppx
shr ax,1	;divide by 2

mov NEWAPPX, ax ;keep the new approximation in a var
xchg ax,bx	;ax(newAppx) now becomes bx(oldAppx)
sub NEWAPPX, ax	;newAppx-oldAppx --> checking to see whats the difference between these approximations
jns positive_diff ;if the difference is positive
neg NEWAPPX ;else negate and go to the same positive_diff

positive_diff:
cmp NEWAPPX,0	;if approximation difference is not as small as we  want
ja loop_start ;loop again
mov BITS01, bl ;store the square root result in BITS01

;   ******************************************************
;   * I think we could do well even without the subroutines     *
;   * I wrote all the subroutines, even AND, OR and XOR           *
;   * Although they are all already available in the lang        *
;   * My program works layer by layer, it does all the             *
;   * Operations that come first, backs up results serially     *
;   * In bh and then starts to work with the resulting byte      *
;   * It continues applying the same iterative logic until        *
;   * All three layers are finished                                              *
;   ******************************************************


simulation_start:
mov al, BITS01 ;start the simulation
mov bh, 00000000B ;empty backup register
call NOR ;do the first operation
call BACKUPRESULT
shr al, 2 ;remove bits 0 and 1, they are already used
mov bl, al ;bl is kinda argument for BACKUPRESULT whose default val is what's in ah
and bl, 00000001B ;keep only the upper bit (2nd bit in 8bit input)
call BACKUPRESULT ;as there is no op with 2nd bit on the first step we just push it
and al, 11111110B ;remove the second bit's value
mov bl, al ;as we need double 3rd bit and we have it in pos 1 in 8 bit al
shr bl, 1 ;we put it in pos 0 in bl
and bl, 00000001B ;keep only that bit
or al, bl ;add it to al;
call NAND
call BACKUPRESULT
shr al, 2 ;remove bits 3 and 3 :) move to 4 and 5
call CUSTOM_XOR
call BACKUPRESULT
shr al, 2 ; remove bits 4 and 5
call NAND
call BACKUPRESULT ;first iteration complete
;now we have reduced gate scheme backed up in bh
; we will take it, put in ah and iterate again
mov al, bh ;we have 5 useful bits, 01, 2, 33, 45, 67
mov bh, 00000000B ;empty backup register
call CUSTOM_XOR ; 45 part XOR 67 part
and al, 11111110B ;remove 67 bit, we don't need it anymore
or al, ah ;put the result instead
call CUSTOM_NOT ;now we also inverted the result
call BACKUPRESULT
shr al, 1; remove 67 part, we need 45 part as we have one more connection from it
mov bl, al
and bl, 00000001B ;we need 45 part for the next step so we just back it up
call BACKUPRESULT
shr al, 1 ;remove it
mov bl, al
and bl, 00000001B ;we need 33 part for the next step so we just back it up
call BACKUPRESULT
shr al, 1 ;remove it
call NAND ;we call nand on 01 and 2
call  BACKUPRESULT ;2nd iteration over, not much remains
mov al, bh ;now we have 4 useful bits 47 45 33 02
call CUSTOM_OR
shr al, 2 ; remove 02 and 33
shl al, 1 ; open a place for the previous result
or al, ah ; add it as the first bit
call NAND ;03 and 45 NAND
shr al, 2
shl al, 1
or al, ah
call NAND ;the last step, now we have the result in ah
jmp OUTPUT

BACKUPRESULT:
  shl bh, 1 ;shift left backup
  or bh, bl ;add the new result

NAND:
    mov bl,al           ; copy of input bits into BL
    mov cl,al           ; and another in CL
    and bl, 00000001B   ; mask off all bits except input bit 0
    and cl, 00000010B   ; mask off all bits except input bit 1
    shr cl,1            ; move bit 1 value into bit 0 of CL register
                        ; now we have the binary value of each bit in BL and CL, in bit 0 location
    and bl,cl           ; AND these two registers, result in BL
    not bl              ; invert bits for the not part of nand
    and bl, 00000001B   ; clear all upper bits positions leaving bit 0 either a zero or one

    mov ah, bl          ; copy answer into return value register
    ret                 ; uncomment for subroutine

NOR:
      ; substitute AND with OR
    mov bl,al
    mov cl,al
    and bl, 00000001B
    and cl, 00000010B
    shr cl,1

    or bl,cl
    not bl
    and bl, 00000001B

    mov ah, bl
    ret

CUSTOM_XOR:
      ; substitute AND with XOR
    mov bl,al
    mov cl,al
    and bl, 00000001B
    and cl, 00000010B
    shr cl,1

    xor bl,cl
    and bl, 00000001B

    mov ah, bl
    ret

  CUSTOM_OR:
      ; substitute AND with OR
      mov bl,al
      mov cl,al
      and bl, 00000001B
      and cl, 00000010B
      shr cl,1

      or bl,cl
      and bl, 00000001B

      mov ah, bl
      ret

  CUSTOM_NOT:
      ; remove second register, NOT has one "argument"
      mov bl,al
      and bl, 00000001B
      not bl
      and bl, 00000001B

      mov ah, bl
      ret


OUTPUT:
    mov dl, ah          ; copy result into DL for DOS ASCII printout
    add dl, 30H         ; comment out for subroutine
    mov AH,2            ; print result
    int 21H             ; to console via DOS call

EXIT:
  mov AH,4CH		; setup to terminate program and
  int 21H		; return to the DOC prompt
END MAIN
