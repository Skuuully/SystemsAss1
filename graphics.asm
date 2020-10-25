%ifndef GRAPHICS_ASM
%define GRAPHICS_ASM

Set_Video_Mode:
    push    ax
    mov     ah, 0
    mov     al, 13h
    int     10h
    pop     ax
    ret

%endif