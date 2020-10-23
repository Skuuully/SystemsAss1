
Set_Video_Mode:
    push    ax

    mov     ah, 0
    mov     al, 13h
    int     10h

    pop     ax
    ret

; @param al, x0 - The first coordinate x
; @param ah, y0 - The first coordinate y
; @param bl, x1 - The second coordinate x
; @param bh, y1 - The second coordinate y
Draw_Line:
    push    ax
    push    bx

    mov     cx, 1
    mov     dx, 1

    cmp     al, bl
    jl      .XLess
    
    cmp     ah, bh
    jl      .YLess

.XLess:
    mov     cx, -1
    jmp     .Continue_Setup

.YLess:
    mov     dx, -1
    jmp     .Continue_Setup

;dx := abs(x1-x0)
;dy := abs(y1-y0)
;err := dx-dy
.Continue_Setup:
    sub     bl, al
    sub     bh, ah
    sub     bl, bh
    mov     si, bx
    pop     bx
    pop     ax

.Loop:
    push    cx
    push    dx
    mov     cx, ax
    mov     dx, bx
    call    Plot_Pixel
    pop     cx
    pop     dx
    cmp     al, bl
    je      .LoopCheckTwo

;e2 := 2*err
;if e2 > -dy
;   err := err -dy 
;   x0 := x0 + sx
;if e2 < dx
;   err := err + dx
;   y0 := y0 + sy
.LoopStageTwo:
    mov     cx, si
    mul     cx, 2
    mul     bx, -1
    cmp     cx, bx 
    jmp     .Loop

.LoopCheckTwo:
    cmp     ah, bh
    jne     .LoopStageTwo

.Cleanup:
    ret


Plot_Pixel:
    push    ax
    push    bx

    call    Set_Video_Mode
    mov     ah, 0Ch
    mov     al, 01h ; pixel col
    xor     bh, bh ; video page number
    int     10h

    pop    bx
    pop    ax
    ret
