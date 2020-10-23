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

	mov		cx, 16
	mov		ah, 0Eh

; Outputs value in bx register as an int value
Console_Write_Int:
	push	cx
	push	si
	push	ax
	push	dx

	mov		cx, 10
	mov		ah, 0Eh
	xor		si, si

Build_Stack:
	xor		dx, dx
	div		cx
	push	ax
	inc		si
	test	dx, dx
	jnz		Build_Stack

Write_Stack:
	pop		ax
	cmp		ax, 9
	jg		.Out_Hex
	jmp		.Out_Int

.Out_Hex:
	add		ax, '7'
	int		10h

.Out_Int:
	add		ax, '0'
	int		10h

.Write_Finished:
	dec		si
	test	si, si
	jnz		Write_Stack
	call	Console_Write_CRLF

	pop	dx
	pop	ax
	pop	si
	pop	cx
	ret
