%ifndef	BOOT2_ASM
%define	BOOT2_ASM

; Second stage of the boot loader

BITS 16

ORG 9000h
	jmp 	Second_Stage

;%include "bios_bresenham.asm"
%include "functions_16.asm"
%include "graphics.asm"
%include "vmem_bresenham.asm"

;	Start of the second stage of the boot loader
	
Second_Stage:
    mov 	si, second_stage_msg	; Output our greeting message
    call 	Console_WriteLine_16

	; call	Math_Test
	call	Set_Video_Mode
	push	0; y1
	push	300 ; x1
	push	0 ; y0
	push	20 ; x0
	push	15 ; col
	call	Draw_Line
	push	0 ; y1
	push	20 ; x1
	push	200 ; y0
	push	20 ; x0
	push	14 ; col
	call	Draw_Line
	push	5 ; y1
	push	5 ; x1
	push	0 ; y0
	push	5 ; x0
	push	13 ; col
	call	Draw_Line
	push	0 ; y1
	push	0 ; x1
	push	50 ; y0
	push	50 ; x0
	push	12 ; col
	call	Draw_Line
	push	0 ; y1
	push	0 ; x1
	push	10 ; y0
	push	1 ; x0
	push	11 ; col
	call	Draw_Line
	push	50 ; y1
	push	0 ; x1
	push	200 ; y0
	push	0 ; x0
	push	10 ; col
	call	Draw_Line
	; mov		si, line_drawn_msg
	; call	Console_WriteLine_16


	; This never-ending loop ends the code.  It replaces the hlt instruction
	; used in earlier examples since that causes some odd behaviour in 
	; graphical programs.
endloop:
	jmp		endloop

second_stage_msg	db 'Second stage loaded', 0
line_drawn_msg		db 'Line finished drawing', 0

	times 3584-($-$$) db 0	

%endif