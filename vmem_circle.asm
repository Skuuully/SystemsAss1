%ifndef VMEM_CIRCLE_ASM
%define VMEM_CIRCLE_ASM

%include "functions_16.asm"
%include "math.asm"

; colour, radius, ycenter, xcenter
%macro draw_circle 4
    push    %4
    push    %3
    push    %2
    push    %1
    call    Draw_Circle
%endmacro

%macro plot_pixel 3
    push    %1
    push    %2

    mov     ax, %3
    math_mul ax, 320
    pop     bx
    add     ax, bx
    mov     bx, ax ; pixel to plot
    pop     ax
    mov     [es:bx], al
%endmacro

%assign colour 4
%assign radius 6
%assign xcenter 8
%assign ycenter 10

%assign decision 2
%assign curr_x 4
%assign curr_y 6
Draw_Circle:
    push    bp
    mov     bp, sp
    sub     sp, 6
    push    es
    push    0A000h
    pop     es
    pushgen
.InitDecision: ; d = 3 - 2r
    mov     bx, 3
    mov     ax, [bp + radius]
    sal     ax, 1 ;=*2
    sub     bx, ax
    mov     [bp - decision], bx
.InitXY:
    xor     ax, ax
    mov     [bp - curr_x], ax
    mov     cx, [bp + radius]
    mov     [bp - curr_y], cx
.LoopCheck:
    mov     bx, [bp - curr_x]
    mov     cx, [bp - curr_y]
    cmp     bx, cx
    jg     .Cleanup
.PlotPoints: ; x = curr_x, p = xcenter
    mov     ax, [bp + xcenter]
    mov     bx, [bp + ycenter]
    mov     cx, [bp - curr_x]
    mov     dx, [bp - curr_y]
    add     cx, ax
    add     dx, bx
    mov     bx, [bp + colour]
    plot_pixel  bx, cx, dx

    mov     ax, [bp + xcenter]
    mov     bx, [bp + ycenter]
    mov     cx, [bp - curr_x]
    mov     dx, [bp - curr_y]
    add     dx, ax
    add     cx, bx
    mov     bx, [bp + colour]
    plot_pixel bx, dx, cx

    mov     ax, [bp + xcenter]
    mov     bx, [bp + ycenter]
    mov     cx, [bp - curr_x]
    mov     dx, [bp - curr_y]
    sub     ax, dx
    add     cx, bx
    mov     bx, [bp + colour]
    plot_pixel bx, ax, cx

    mov     ax, [bp + xcenter]
    mov     bx, [bp + ycenter]
    mov     cx, [bp - curr_x]
    mov     dx, [bp - curr_y]
    sub     ax, cx
    add     dx, bx
    mov     bx, [bp + colour]
    plot_pixel bx, ax, dx

    mov     ax, [bp + xcenter]
    mov     bx, [bp + ycenter]
    mov     cx, [bp - curr_x]
    mov     dx, [bp - curr_y]
    sub     ax, cx
    sub     bx, dx
    mov     cx, [bp + colour]
    plot_pixel cx, ax, bx

    mov     ax, [bp + xcenter]
    mov     bx, [bp + ycenter]
    mov     cx, [bp - curr_x]
    mov     dx, [bp - curr_y]
    sub     ax, dx
    sub     bx, cx
    mov     cx, [bp + colour]
    plot_pixel cx, ax, bx

    mov     ax, [bp + xcenter]
    mov     bx, [bp + ycenter]
    mov     cx, [bp - curr_x]
    mov     dx, [bp - curr_y]
    add     dx, ax
    sub     bx, cx
    mov     ax, [bp + colour]
    plot_pixel ax, dx, bx

    mov     ax, [bp + xcenter]
    mov     bx, [bp + ycenter]
    mov     cx, [bp - curr_x]
    mov     dx, [bp - curr_y]
    add     cx, ax
    neg     dx
    add     dx, bx
    mov     bx, [bp + colour]
    plot_pixel bx, cx, dx
.UpdateDecision:
    mov     ax, [bp - decision]
    cmp     ax, 0
    jge     .DecisionGreater
    mov     bx, [bp - curr_x]
    sal     bx, 2 ; *=4
    add     bx, 6
    add     ax, bx
    mov     [bp - decision], ax ; d = d + 4x + 6
    jmp     .IncrementX
.DecisionGreater:
    mov     ax, [bp - curr_x]
    mov     bx, [bp - curr_y]
    sub     ax, bx
    sal     ax, 2 ; *=4
    add     ax, 10
    mov     bx, [bp - decision]
    add     ax, bx
    mov     [bp - decision], ax ; d = d + 4(x-y) + 10
.DecrementY:
    mov     ax, [bp - curr_y]
    dec     ax
    mov     [bp - curr_y], ax
.IncrementX:
    mov     ax, [bp - curr_x]
    inc     ax
    mov     [bp - curr_x], ax
    jmp     .LoopCheck
.Cleanup:
    popgen
    pop     es
    mov     sp, bp
    pop     bp
    ret     8

%endif