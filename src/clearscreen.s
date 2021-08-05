.segment "CLEARSCREEN"

clearscreen

	lda #$18
	sta $d016
	lda d018forscreencharset(screenui,fontui)
	sta $d018
	
	ldx #$00
:	lda #$00
	sta screenui+(0*$0100),x
	sta screenui+(1*$0100),x
	sta screenui+(2*$0100),x
	sta screenui+(3*$0100),x
	lda #$08
	sta colormem+(0*$0100),x
	sta colormem+(1*$0100),x
	sta colormem+(2*$0100),x
	sta colormem+(3*$0100),x
	inx
	bne :-

	lda #$00
	sta $d020
	sta $d021
	lda #$02
	sta $d022
	lda #$0a
	sta $d023

	lda bankforaddress(screenui)
	sta $dd00
	
	rts

; -----------------------------------------------------------------------------------------------

waitkey

checkfire
	lda $dc00
	and #%00010000								; fire
	bne checkspace
waitreleasefire
	lda $dc00
	and #%00010000
	beq waitreleasefire
	jmp checkfiredone

checkspace
	lda #%01111111
	sta $dc00
	lda $dc01
	and #%00010000								; space
	bne checkfire
waitreleasespace
	lda #%01111111
	sta $dc00
	lda $dc01
	and #%00010000
	beq waitreleasespace

checkfiredone

	rts

; -----------------------------------------------------------------------------------------------

irqlimbo
	pha

	lda #$00
	sta $d015

	lda #<irqlimbo
	ldx #>irqlimbo
	ldy #$00
	jmp endirq
    