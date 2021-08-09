.macro cycleperfectmacro
	sec
	sbc $dc04
	sta bplcode2+1
bplcode2
	bpl :+
:	.repeat 48
	lda #$a9
	.endrepeat
	lda #$a5
	nop
		
	rts
.endmacro
    
; -----------------------------------------------------------------------------------------------

.macro nextgameflow I
	lda I
	sta gameflowstate+1
	jmp handlegameflow
.endmacro

.macro comparegameflow I
:	cmp I
	bne :+
.endmacro

; -----------------------------------------------------------------------------------------------

.macro add16bit arg1, arg2						; clear carry before using this
	lda arg1+1
	adc #<(arg2)
	sta arg1+1
	lda arg1+2
	adc #>(arg2)
	sta arg1+2
.endmacro

.macro sub16bit arg1, arg2						; set carry before using this
	lda arg1+1
	sbc #<(arg2)
	sta arg1+1
	lda arg1+2
	sbc #>(arg2)
	sta arg1+2
.endmacro

.macro store16bit arg1, arg2
	lda #<(arg2)
	sta arg1+1
	lda #>(arg2)
	sta arg1+2
.endmacro

; -----------------------------------------------------------------------------------------------

.macro addpoints arg1, arg2
	clc
	lda score+arg2
	adc arg1
	sta score+arg2
.endmacro

; -----------------------------------------------------------------------------------------------

.macro plotdigit arg1, arg2
	ldx arg1
	ldy times8lowtable,x
	lda fontdigits+0,y
	sta arg2+0*3
	lda fontdigits+1,y
	sta arg2+1*3
	lda fontdigits+2,y
	sta arg2+2*3
	lda fontdigits+3,y
	sta arg2+3*3
	lda fontdigits+4,y
	sta arg2+4*3
	lda fontdigits+5,y
	sta arg2+5*3
.endmacro

; -----------------------------------------------------------------------------------------------

.macro copymemblocks from, to, size
	clc
	lda #>from
	sta copymemfrom+2
	adc #>size
	sta copymemsize+1
	lda #>to
	sta copymemto+2
	jsr copymem
.endmacro

; -----------------------------------------------------------------------------------------------
