.segment "COPYMEM"

copymem
	ldx #$00
copymemfrom
	lda $1000,x
copymemto
	sta $2000,x
	dex
	bne copymemfrom
	inc copymemfrom+2
	inc copymemto+2
	lda copymemfrom+2
copymemsize
	cmp #>($1000+$0d00)
	bne copymemfrom
	rts

; -----------------------------------------------------------------------------------------------

.segment "LOADERHELPERS"

loadpackd

	ldx #<file01
	ldy #>file01
	jsr loadcompd

	rts

loadloadinstall

	ldx #<loadinstallfile
	ldy #>loadinstallfile
	jsr loadraw

	rts

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
