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

.segment "WAITKEY"

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

