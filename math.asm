%ifndef MATH_ASM
%define MATH_ASM

; Performs multiplication math, result stored in ax
%macro math_mul 2
	push 	%1
	push	%2
	call	Math_Mul
%endmacro

; Performs modulo math, in form arg1 % arg2, value stored in ax 
%macro math_modulo 2
	push	%1
	push	%2
	call	Math_Modulo
%endmacro

; Example
; push	2
; push	4
; call	Math_Mul
; value stored in ax
Math_Mul:
	push	bp
	mov		bp, sp
	push	dx
	push	cx

	xor		dx, dx
	mov		ax, [bp + 4]
	mov		cx, [bp + 6]
	mul		cx

	pop		cx
	pop		dx
	mov		sp, bp
	pop		bp
	ret		4

; push value onto stack, if negative will be flipped and returned in ax
Math_Abs:
	push	bp
	mov		bp, sp

	mov		ax, [bp + 4]
	cmp		ax, 0
	jg		.End
.Neg:
	neg		ax

.End:
	mov		sp, bp
	pop		bp
	ret		2

; Value returned in ax
; Example 5 % 4:
; push 5
; push 4
; call Math_Modulo
Math_Modulo:
	push	bp
	mov		bp, sp
	push	dx
	push	cx

.Body:
	xor		dx, dx
	mov		ax, [bp + 6]
	mov		cx, [bp + 4]
	div		cx
	mov		ax, dx


.Cleanup:
	pop		cx
	pop		dx
	mov		sp, bp
	pop		bp
	ret		4

%endif