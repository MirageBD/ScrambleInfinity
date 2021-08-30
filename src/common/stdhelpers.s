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



