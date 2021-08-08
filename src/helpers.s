; -----------------------------------------------------------------------------------------------

.segment "SETINGAMEBKGCOLOURS"

setingamebkgcolours

	ldx #$00
:	lda #$0c
	sta colormem+(0*$0100),x
	sta colormem+(1*$0100),x
	sta colormem+(2*$0100),x
	sta colormem+(3*$0100),x
	dex
	bne :-

	lda #$00
	sta ingamebkgcolor+1

	rts

; -----------------------------------------------------------------------------------------------

.segment "RESETFIRESTATE"

resetfirestate									; this makes sure there are no leftover bullets on the screen after death

	jsr bull0explosiondone
	jsr bull1explosiondone
	jsr bomb0explosiondone
	jsr bomb1explosiondone

	rts

; -----------------------------------------------------------------------------------------------

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
