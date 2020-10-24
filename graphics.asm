%ifndef GRAPHICS_ASM
%define GRAPHICS_ASM

Set_Video_Mode:
    push    ax
    mov     ah, 0
    mov     al, 13h
    int     10h
    pop     ax
    ret

colourmessage   db 'colour: ', 0
x0message   db 'x0: ', 0
x1message   db 'x1: ', 0
y0message   db 'y0: ', 0
y1message   db 'y1: ', 0
loopingmessage  db 'looping now', 0

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
; push 0 ; y1
; push 12 ; colour between 0-15
Draw_Line:
    push    bp
    mov     bp, sp
    sub     sp, 12
; .DebugParams:
;     mov     si, colourmessage
;     call    Console_Write_16
;     mov     bx, [bp + colour]
;     call    Console_Write_Int

;     mov     si, x0message
;     call    Console_Write_16
;     mov     bx, [bp + x0]
;     call    Console_Write_Int

;     mov     si, y0message
;     call    Console_Write_16
;     mov     bx, [bp + y0]
;     call    Console_Write_Int

;     mov     si, x1message
;     call    Console_Write_16
;     mov     bx, [bp + x1]
;     call    Console_Write_Int

;     mov     si, y1message
;     call    Console_Write_16
;     mov     bx, [bp + y1]
;     call    Console_Write_Int
;     jmp     .Cleanup
.SetupDeltaX:
    mov     ax, [bp + x0]
    mov     bx, [bp + x1]
    sub     bx, ax
    push    bx
    call    Math_Abs
    mov     [bp - deltaX], ax
.SetupDeltaY:
    mov     ax, [bp + y0]
    mov     bx, [bp + y1]
    sub     bx, ax
    push    bx
    call    Math_Abs
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
    mov     cx, [bp + x0]
    mov     dx, [bp + y0]
    mov     ax, [bp + colour]
.PlotPixel:
    mov     ah, 0Ch
    xor     bh, bh
    int     10h
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
    mov     sp, bp
    pop     bp
    ret     10

%endif