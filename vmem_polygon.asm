; vmem_polygon.asm
; Contains a mcaro and function to draw a polygon
; Requires an array of x and y positions constituting the points to be plotted
; Will then draw lines connecting the points, and adds an enclosing line to close off the polygon

%ifndef VMEM_POLYGON_ASM
%define VMEM_POLYGON_ASM

%include "functions_16.asm"
%include "graphics.asm"
%include "math.asm"
%include "vmem_line.asm"

; points array, no of points, colour
%macro draw_polygon 3
    lea		ax, [%1]
	push 	ax
	push	%2
	push 	%3
    call    Draw_Polygon
%endmacro

%assign colour 4
%assign total_points 6
%assign points_array 8

%assign offset 2
%assign last_access 4

Draw_Polygon:
    push    bp
    mov     bp, sp
    sub     sp, 8
    push    es
.SetupEs:
    push    0A000h
    pop     es
.SetupLastPair:
    mov     ax, [bp + total_points]
    sal     ax, 2 ; *= 4
    sub     ax, 2
    mov     [bp - last_access], ax ; last pair = (totalpoints * 4) - 2
.InitOffset:
    mov     ax, 6
    mov     [bp - offset], ax
    jmp     .Draw
.Draw:
    ; Look at values accessed done wrong, need to add some register value to bp to access instead
    mov     si, [bp + points_array]
    mov     ax, [bp - offset]
    add     si, ax
    mov     bx, [si]
    push    bx ; pair 2 y
    sub     si, 2
    mov     bx, [si]
    push    bx ; pair 2 x
    sub     si, 2
    mov     bx, [si]
    push    bx ; pair 1 y
    sub     si, 2
    mov     bx, [si]
    push    bx ; pair 1 x
    mov     bx, [bp + colour]
    push    bx
    call    Draw_Line
.IncrementOffset:
    mov     ax, [bp - offset]
    add     ax, 4
    mov     [bp - offset], ax
.Check:
    mov     ax, [bp + points_array]
    add     si, 6
    sub     si, ax
    mov     bx, [bp - last_access]
    cmp     si, bx
    je      .AddEnclosingLine
    jmp     .Draw
.AddEnclosingLine:
    mov     si, [bp + points_array]
    mov     ax, [bp - last_access]
    add     si, ax
    mov     bx, [si]
    push    bx ; pair 2 y
    sub     si, 2
    mov     bx, [si]
    push    bx ; pair 2 x

    mov     si, [bp + points_array]
    add     si, 2
    mov     bx, [si]
    push    bx ; pair 1 y
    sub     si, 2
    mov     bx, [si]
    push    bx ; pair 1 x
    mov     bx, [bp + colour]
    push    bx
    call    Draw_Line


.Cleanup:
    mov     si, [bp - last_access]
    pop     es
    mov     sp, bp
    pop     bp
    ret     6

%endif