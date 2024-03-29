
; -----------------------------------------------------------------------------------------------

.segment "ENDIRQ"

endirq	
	sta $fffe
	sta $0314
	stx $ffff
	stx $0315
	sty $d012
	dec $d019

	lda #%00000010
	and $01
	beq :+
	pla
	jmp $ea81
:
	pla
	rti

; -----------------------------------------------------------------------------------------------

.segment "IRQLIMBO"

irqlimbo
	pha

	lda #$00
	sta $d015

	lda #<irqlimbo
	ldx #>irqlimbo
	ldy #$00
	jmp endirq

; -----------------------------------------------------------------------------------------------
