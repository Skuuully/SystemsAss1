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

%assign total_pixels 2
%assign offset 4 
%assign start_pixel 6
%assign x_end 8
%assign pixels_plotted 10

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

    jmp     .SetupTotalPixels
.BadParameter:
    call    Set_Text_Mode
    console_writeline_16 rect_bad_parameter
    jmp     .Cleanup
.SetupTotalPixels:
    mov     ax, [bp + width]
    mov     bx, [bp + height]
    push    ax
    push    bx
    call    Math_Mul
    mov     [bp - total_pixels], ax
.SetupStart:
    mov     ax, [bp + y0]
    math_mul    ax, 320
    mov     bx, [bp + x0]
    add     ax, bx
    mov     [bp - start_pixel], ax
.SetupOffset:
    mov     ax, 321
    mov     bx, [bp + width]
    sub     ax, bx
    mov     [bp - offset], ax
.SetupXEnd:
    mov     ax, [bp + x0]
    mov     bx, [bp + width]
    add     ax, bx
    mov     [bp - x_end], ax
.Start:
    mov     bx, [bp - start_pixel]
    xor     cx, cx
    mov     [bp - pixels_plotted], cx
.Plot:
    mov     ax, [bp + colour]
    mov     [es:bx], al
    mov     dx, [bp - pixels_plotted]
    inc     dx
    mov     [bp - pixels_plotted], dx
    mov     ax, [bp - total_pixels]
    cmp     dx, ax
    je      .Cleanup
.PutIncreaseToCx:
    push    dx
    mov     dx, [bp + width]
    push    dx
    call    Math_Modulo
    cmp     ax, 0
    je      .IncreaseCxOffset
    jmp     .IncrementCx
.IncreaseCxOffset:
    mov     dx, [bp - offset]
    mov     cx, dx
    jmp     .UpdateBx
.IncrementCx:
    mov     cx, 1
.UpdateBx:
    add     bx, cx
    jmp     .Plot
.Cleanup:
    popgen
    pop     es
    mov     sp, bp
    pop     bp
    ret     10

%endif