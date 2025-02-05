; vmem_line.asm
; Cntains function and macro to draw a line to video memory
; Uses bresenhams line algorithm to determine a best fit, only uses int operations.

%ifndef VMEM_LINE_ASM
%define VMEM_LINE_ASM

%include "math.asm"

bad_param_message  db 'bad parameter given, x value range 0 - 320, y value range 0 - 200', 0

; colour, x0, y0, x1, y1
%macro draw_line 5
    push    %5
    push    %4
    push    %3
    push    %2
    push    %1
    call    Draw_Line
%endmacro

; Passed params
%assign     y1  12
%assign     x1  10
%assign     y0  8
%assign     x0  6
%assign     colour  4
; Locals
%assign     deltaX 2
%assign     deltaY 4
%assign     sx  6
%assign     sy  8
%assign     err 10
%assign     e2  12

; Draws a line between two points in the colour specified
; Example:
; push 100 ; y1
; push 100 ; x1
; push 0 ; y0
; push 0 ; x0
; push 12 ; colour between 0-15
Draw_Line:
    push    bp
    mov     bp, sp
    sub     sp, 12
    push    es
    pushgen
.SetupEs:
    push    0A000h
    pop     es
.CheckParams:
    mov     bx, [bp + x0]
    cmp     bx, 0
    jl      .BadParams
    cmp     bx, 320
    jg      .BadParams

    mov     bx, [bp + x1]
    cmp     bx, 0
    jl      .BadParams
    cmp     bx, 320
    jg      .BadParams

    mov     bx, [bp + y0]
    cmp     bx, 0
    jl      .BadParams
    cmp     bx, 200
    jg      .BadParams
    
    mov     bx, [bp + y1]
    cmp     bx, 0
    jl      .BadParams
    cmp     bx, 200
    jg      .BadParams

    ; Parameters are ok
    jmp     .SetupDeltaX
.BadParams:
    mov     si, bad_param_message
    call    Console_WriteLine_16
    jmp     .Cleanup
.SetupDeltaX:
    mov     ax, [bp + x0]
    mov     bx, [bp + x1]
    sub     bx, ax
    math_abs    bx
    mov     [bp - deltaX], ax
.SetupDeltaY:
    mov     ax, [bp + y0]
    mov     bx, [bp + y1]
    sub     bx, ax
    math_abs    bx
    mov     [bp - deltaY], ax
.SetupErr:
    mov     ax, [bp - deltaX]
    mov     bx, [bp - deltaY]
    sub     ax, bx
    mov     [bp - err], ax
.SetupSx:
    mov     ax, -1
    mov     [bp - sx], ax
    mov     bx, [bp + x0]
    mov     cx, [bp + x1]
    cmp     bx, cx
    jl      .FlipSx
    jmp     .SetupSy
.FlipSx:
    mov     ax, 1
    mov     [bp - sx], ax
.SetupSy:
    mov     ax, -1
    mov     [bp - sy], ax
    mov     bx, [bp + y0]
    mov     cx, [bp + y1]
    cmp     bx, cx
    jl      .FlipSy
    jmp     .Loop
.FlipSy:
    mov     ax, 1
    mov     [bp - sy], ax
.Loop:
.SetupOffset:
    mov     bx, [bp + y0]
    math_mul    bx, 320
    mov     bx, ax
    mov     ax, [bp + x0]
    add     bx, ax
.DrawPixel:
    mov     ax, [bp + colour]
    mov     [es:bx], al
.LoopCheck:
    mov     ax, [bp + x1]
    mov     dx, [bp + x0]
    cmp     dx, ax
    jne     .LoopStageTwo
.LoopCheckTwo:
    mov     bx, [bp + y1]
    mov     cx, [bp + y0]
    cmp     cx, bx
    je      .Cleanup
.LoopStageTwo:
.UpdateE2:
    mov     ax, [bp - err]
    sal     ax, 1 ; ax *= 2
    mov     [bp - e2], ax
.CheckE2GreaterNegDeltaY:
    mov     bx, [bp - deltaY]
    neg     bx
    mov     ax, [bp - e2]
    cmp     ax, bx
    jg      .UpdateX0
    jmp     .CheckE2LessDeltaX
.UpdateX0:
    mov     bx, [bp - deltaY]
    mov     cx, [bp - err]
    sub     cx, bx
    mov     [bp - err], cx
    mov     ax, [bp + x0]
    mov     bx, [bp - sx]
    add     ax, bx
    mov     [bp + x0], ax
.CheckE2LessDeltaX:
    mov     ax, [bp - e2]
    mov     bx, [bp - deltaX]
    cmp     ax, bx
    jl      .UpdateY0
    jmp     .Loop
.UpdateY0:
    mov     bx, [bp - deltaX]
    mov     cx, [bp - err]
    add     cx, bx
    mov     [bp - err], cx
    mov     dx, [bp + y0]
    mov     ax, [bp - sy]
    add     dx, ax
    mov     [bp + y0], dx
    jmp     .Loop

.Cleanup:
    popgen
    pop     es
    mov     sp, bp
    pop     bp
    ret     10

%endif