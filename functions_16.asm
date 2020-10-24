%ifndef FUNCTIONS_16_ASM
%define FUNCTIONS_16_ASM

; Various sub-routines that will be useful to the boot loader code	

; Output Carriage-Return/Line-Feed (CRLF) sequence to screen using BIOS

Console_Write_CRLF:
	mov 	ah, 0Eh						; Output CR
    mov 	al, 0Dh
    int 	10h
    mov 	al, 0Ah						; Output LF
    int 	10h
    ret

; Write to the console using BIOS.
; 
; Input: SI points to a null-terminated string

Console_Write_16:
	mov 	ah, 0Eh						; BIOS call to output value in AL to screen

Console_Write_16_Repeat:
    mov		al, [si]
	inc     si
    test 	al, al						; If the byte is 0, we are done
	je 		Console_Write_16_Done
	int 	10h							; Output character to screen
	jmp 	Console_Write_16_Repeat

Console_Write_16_Done:
    ret

; Write string to the console using BIOS followed by CRLF
; 
; Input: SI points to a null-terminated string

Console_WriteLine_16:
	call 	Console_Write_16
	call 	Console_Write_CRLF
	ret

; Outputs value in bx register as a hex value
Console_Write_Hex:
	push	cx
	push	si
	push	ax
	push	dx

	mov		ax, bx
	mov		cx, 16
	xor		si, si
	jmp		Build_Stack

; Outputs value in bx register as an int value
Console_Write_Int:
	push	cx
	push	si
	push	ax
	push	dx

	mov		ax, bx
	mov		cx, 10
	xor		si, si
	jmp		Build_Stack

Build_Stack:
	xor		dx, dx
	div		cx
	push	dx
	inc		si
	test	ax, ax
	jnz		Build_Stack

Write_Stack:
	pop		dx
	mov		ax,	dx
	cmp		ax, 9
	jg		Out_Hex
	jmp		Out_Int

Out_Hex:
	add		ax, '7'
	mov		ah, 0Eh
	int		10h
	jmp		Write_Finished

Out_Int:
	add		ax, '0'
	mov		ah, 0Eh
	int		10h
	jmp		Write_Finished

Write_Finished:
	dec		si
	test	si, si
	jnz		Write_Stack
	call	Console_Write_CRLF

	pop	dx
	pop	ax
	pop	si
	pop	cx
	ret

; Example
; push	2
; push	4
; call	Math_Mul
; value stored in ax
Math_Mul:
	push	bp
	mov		bp, sp
	push	dx
	push	cx

	xor		dx, dx
	mov		ax, [bp + 4]
	mov		cx, [bp + 6]
	mul		cx

	pop		dx
	pop		cx
	mov		sp, bp
	pop		bp
	ret		4

; push value onto stack, if negative will be flipped and returned in ax
Math_Abs:
	push	bp
	mov		bp, sp

	mov		ax, [bp + 4]
	cmp		ax, 0
	jg		.End
.Neg:
	neg		ax

.End:
	mov		sp, bp
	pop		bp
	ret		2

Math_Test:
	mov		ax, 20
	mov		bx, 15
	sub		ax, bx
	sub		ax, bx
	sub		ax, bx

	cmp		ax, bx
	jg		.AxGreater
	jmp		.BxGreater

.AxGreater:
	mov		si, axgreater
	jmp		.End

.BxGreater:
	mov		si, bxgreater

.End
	call	Console_WriteLine_16
	ret

axgreater	db 'ax is greater than bx', 0
bxgreater	db 'bx is greater than ax', 0


%endif