%ifndef VMEM_SQUARE_ASM
%define VMEM_SQUARE_ASM

%include "math.asm"

%macro draw_rect 5
    push    %5
    push    %4
    push    %3
    push    %2
    push    %1
    call    Draw_Rect_One_Loop
%endmacro

%assign colour 4
%assign x0 6
%assign y0 8
%assign width 10
%assign height 12

%assign curr_x 2
%assign curr_y 4
%assign x_end 6
%assign y_end 8

; Example call
; push 20 ; height
; push 20 ; width
; push 10 ; y0
; push 10 ; x0
; push 12 ; colour
; call Draw_Rect
Draw_Rect:
    push    bp
    mov     bp, sp
    sub     sp, 8
    pushgen
.InitStarts:
    mov     ax, [bp + x0]
    mov     [bp - curr_x], ax
    mov     bx, [bp + width]
    add     bx, ax
    mov     [bp - x_end], bx

    mov     ax, [bp + y0]
    mov     [bp - curr_y], ax
    mov     bx, [bp + height]
    add     bx, ax
    mov     [bp - y_end], bx

    push    0A000h
    pop     es
.LoopHeight:
.LoopWidth:
	mov     dx, [bp - curr_x]
	add     bx, dx
    inc     dx
    mov     [bp - curr_x], dx
.CalcPixelPos:
    mov     ax, [bp - curr_y]
    math_mul    ax, 320
    mov     bx, [bp - curr_x]
    add     ax, bx
    mov     bx, ax ; Pixel pos
.PlotPixel:
    mov     ax, [bp + colour]
    mov     [es:bx], al
.EndWidth:
    mov     ax, [bp - curr_x]
    inc     ax
    mov     bx, [bp - x_end]
    cmp     ax, bx
    jne     .LoopWidth
    mov     ax, [bp + x0]
    mov     [bp - curr_x], ax
.EndHeight:
    mov     ax, [bp - curr_y]
    inc     ax
    mov     [bp - curr_y], ax
    mov     bx, [bp - y_end]
    cmp     ax, bx
    jne     .LoopHeight
.Cleanup:
    popgen
    mov     sp, bp
    pop     bp
    ret     10

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
; call	Draw_Rect_One_Loop
Draw_Rect_One_Loop:
    push    bp
    mov     bp, sp
    sub     sp, 10
    pushgen
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
.SetupEs:
    push    0A000h
    pop     es
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
    mov     sp, bp
    pop     bp
    ret     10

%endif