; vmem_rect.asm
; Cotnains function and macro to draw a rectangle to the screen.
; Uses a single loop and relies on video memory being one long block of continuos memory to access.
; Works by calculating a start point from x and y given.
; Calculates the final pixel to plot to use as acheck to quit the loop
; Uses stosb to output a row, loops rows until positioned after the pixel

%ifndef VMEM_SQUARE_ASM
%define VMEM_SQUARE_ASM

%include "functions_16.asm"
%include "graphics.asm"
%include "math.asm"

; colour, x0, y0, width, height
%macro draw_rect 5
    push    %5
    push    %4
    push    %3
    push    %2
    push    %1
    call    Draw_Rect
%endmacro

rect_bad_parameter db 'Bad parameters given to draw rectangle', 0

%assign colour 4
%assign x0 6
%assign y0 8
%assign width 10
%assign height 12

%assign start_pixel 2
%assign end_pixel 4

; push 	10 ; height
; push 	50 ; width
; push 	5 ; y0
; push 	5 ; x0
; push 	2 ; colour
; call	Draw_Rect
Draw_Rect:
    push    bp
    mov     bp, sp
    sub     sp, 10
    push    es
    pushgen
.SetupEs:
    push    0A000h
    pop     es

.CheckParameters:
    mov     ax, [bp + x0]
    cmp     ax, 0
    jl      .BadParameter
    cmp     ax, 320
    jg      .BadParameter
    mov     bx, [bp + width]
    add     ax, bx
    cmp     ax, 320
    jg      .BadParameter

    mov     ax, [bp + y0]
    cmp     ax, 0
    jl      .BadParameter
    cmp     ax, 200
    jg      .BadParameter
    mov     bx, [bp + height]
    add     ax, bx
    cmp     ax, 200
    jg      .BadParameter

    jmp     .SetupStartPixel
.BadParameter:
    call    Set_Text_Mode
    console_writeline_16 rect_bad_parameter
    jmp     .Cleanup
.SetupStartPixel:
	mov		ax, [bp + y0]
	math_mul ax, 320
	mov		bx, [bp + x0]
	add 	ax, bx  ; ax now contains starting point
	mov		[bp - start_pixel], ax
.SetupEndPixel:
	mov		cx, [bp + width]
	add		ax, cx
	mov		cx, ax
	mov		bx, [bp + height]
	math_mul bx, 320
	add		cx, ax
	mov		[bp - end_pixel], cx
.InitDi:
	mov		ax, [bp - start_pixel]
	mov		di, ax
.Draw:
	mov		cx, [bp + width]
	mov		ax, [bp + colour]
    rep     stosb
.UpdateDi:
	mov		cx, [bp + width]
	sub		di, cx
    mov     ax, 320
	add		di, ax
.CheckFinished:
	mov		cx, [bp - end_pixel]
	cmp		di, cx
	jl		.Draw
.Cleanup:
    popgen
    pop     es
    mov     sp, bp
    pop     bp
    ret     10

%endif