; Second stage of the boot loader

BITS 16

ORG 9000h
	jmp 	Second_Stage

%include "functions_16.asm"

;	Start of the second stage of the boot loader
	
Second_Stage:
    mov 	si, second_stage_msg	; Output our greeting message
    call 	Console_WriteLine_16
	
	mov		bx, 0FFFFh
	call	Console_Write_Int

	mov		bx, 0FFFFh
	call	Console_Write_Hex

	; Put your test code here

	; This never-ending loop ends the code.  It replaces the hlt instruction
	; used in earlier examples since that causes some odd behaviour in 
	; graphical programs.
endloop:
	jmp		endloop

second_stage_msg	db 'Second stage loaded', 0

	times 3584-($-$$) db 0	