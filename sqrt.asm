.model  SMALL

.stack  100H			; start the stack at SS:100H

.DATA
       NL1          DB      0AH,0DH,'ENTER NO:','$'
       NEWAPPX         DW      ?

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
cmp bx,19 ;if it is small enough, do this
je TEST1
jne EXIT

TEST1:
  mov AH,09H		; setup to notify user
  lea dx,NL1		; that the value entered
  int 21H		; is not a prime by a DOS console out of NL2 ASCII string and

EXIT:
  mov AH,4CH		; setup to terminate program and
  int 21H		; return to the DOC prompt
END MAIN
