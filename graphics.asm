
Set_Video_Mode:
    push    ax

    mov     ah, 0
    mov     al, 13h
    int     10h

    pop     ax
    ret

; colour = [bp + 2]
; 1st coordinate x [bp + 4]
; 1st coordinate y [bp + 6]
; 2nd coordinate x [bp + 8]
; 2nd coordinate y [bp + 10]
; dx = bp - 2
; dy = bp - 4
; sx = bp - 6
; sy = bp - 8
; err = bp - 10
; e2 = bp - 12 
Draw_Line:
    push    bp
    mov     bp, sp
    sub     sp, 12

    push    ax
    push    bx

    mov     ax, 1
    mov     bx, 1
    mov     [bp - 6], ax
    mov     [bp - 8], bx

.CheckX:
    mov     ax, [bp + 4]
    mov     bx, [bp + 8]

    cmp     ax, bx
    jl      .XLess
    jmp     .CheckY

.CheckY:
    mov     ax, [bp + 6]
    mov     bx, [bp + 10]
    
    cmp     ax, bx
    jl      .YLess
    jmp     .Continue_Setup

.XLess:
    mov     ax, -1
    mov     [bp - 6], ax
    jmp     .CheckY

.YLess:
    mov     ax, -1
    mov     [bp - 8], ax
    jmp     .Continue_Setup

.Continue_Setup:
.SetupDx:
    mov     ax, [bp + 4]
    mov     bx, [bp + 8]
    sub     bx, ax
    push    bx
    call    Math_Abs
    mov     [bp - 2], ax
.SetupDy:
    mov     ax, [bp + 6]
    mov     bx, [bp + 10]
    sub     bx, ax
    push    bx
    call    Math_Abs
    mov     [bp - 4], ax
.SetupErr:
    mov     bx, [bp - 2]
    sub     bx, ax
    mov     [bp - 10], bx
.Loop:
    mov     cx, [bp + 4]
    mov     dx, [bp + 6]
    mov     ax, [bp + 2]
    call    Plot_Pixel
    mov     ax, [bp + 8]
    mov     bx, [bp + 10]
    cmp     cx, ax
    je      .LoopCheckTwo

.LoopStageTwo:
.SetupE2:
    mov     ax, [bp - 10]
    shl     ax, 1
    mov     [bp - 12], ax
    mov     bx, [bp - 4]
.CheckE2GreaterNegDy:
    neg     bx
    cmp     ax, bx
    jg      .SetupX0
.SetupX0:
    mov     cx, [bp - 10]
    add     cx, bx
    mov     ax, [bp + 4]
    mov     bx, [bp - 6]
    add     ax, bx
    mov     [bp + 4], bx
.CheckE2LessDx:
    mov     ax, [bp - 12]
    mov     bx, [bp - 2]
    cmp     ax, bx
    jl      .SetupY0
    jmp     .LoopStageTwo

.SetupY0:
    mov     cx, [bp - 10]
    add     cx, bx
    mov     dx, [bp + 6]
    mov     ax, [bp - 8]
    add     dx, ax
    mov     [bp + 6], dx
    jmp     .LoopStageTwo

.LoopCheckTwo:
    cmp     dx, bx
    jne     .LoopStageTwo

.Cleanup:
    mov     sp, bp
    pop     bp
    ret


Plot_Pixel:
    push    ax
    push    bx

    call    Set_Video_Mode
    mov     ah, 0Ch
    ;mov     al, 01h ; pixel col
    xor     bh, bh ; video page number
    int     10h

    pop    bx
    pop    ax
    ret
