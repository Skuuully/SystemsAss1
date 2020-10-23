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
