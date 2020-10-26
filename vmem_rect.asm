%ifndef VMEM_SQUARE_ASM
%define VMEM_SQUARE_ASM

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
    push    ax
    push    320
    call    Math_Mul
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
    mov     sp, bp
    pop     bp
    ret     10

%endif