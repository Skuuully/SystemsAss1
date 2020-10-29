%ifndef	BOOT2_ASM
%define	BOOT2_ASM

; Second stage of the boot loader

BITS 16

ORG 9000h
	jmp 	Second_Stage

;%include "bios_bresenham.asm"
%include "functions_16.asm"
%include "graphics.asm"
%include "vmem_circle.asm"
%include "vmem_line.asm"
%include "vmem_polygon.asm"
%include "vmem_rect.asm"

;	Start of the second stage of the boot loader
	
Second_Stage:
    mov 	si, second_stage_msg	; Output our greeting message
    call 	Console_WriteLine_16

	call	Set_Video_Mode
	draw_rect 5, 0, 0, 159, 50
	draw_rect 6, 161, 0, 159, 50
	draw_line 10, 0, 0, 320, 200
	draw_line 11, 320, 0, 0, 200
	draw_circle 15, 40, 160, 100 ; colour, radius, xcenter, ycenter
	draw_circle 2, 35, 160, 100 ; colour, radius, xcenter, ycenter
	draw_circle 15, 30, 160, 100 ; colour, radius, xcenter, ycenter
	draw_circle 2, 25, 160, 100 ; colour, radius, xcenter, ycenter
	draw_circle 15, 20, 160, 100 ; colour, radius, xcenter, ycenter
	draw_circle 2, 15, 160, 100 ; colour, radius, xcenter, ycenter
	draw_circle 15, 10, 160, 100 ; colour, radius, xcenter, ycenter
	draw_circle 2, 5, 160, 100 ; colour, radius, xcenter, ycenter
	draw_circle 15, 1, 160, 100 ; colour, radius, xcenter, ycenter
	draw_circle 15, 0, 160, 100 ; colour, radius, xcenter, ycenter
	draw_polygon triangle_array, 3, 14
	draw_polygon hexagon_array, 6, 9

	; This never-ending loop ends the code.  It replaces the hlt instruction
	; used in earlier examples since that causes some odd behaviour in 
	; graphical programs.
endloop:
	jmp		endloop

second_stage_msg	db 'Second stage loaded', 0
line_drawn_msg		db 'Line finished drawing', 0
triangle_array	dw 240, 80, 240, 110, 280, 110
hexagon_array	dw 40, 80, 30, 100, 40, 120, 60, 120, 70, 100, 60, 80

	times 3584-($-$$) db 0	

%endif