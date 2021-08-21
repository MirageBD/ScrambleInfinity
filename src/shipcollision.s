.segment "SHIPCOLLISION"

testshipbkgcollision

	sec
	lda ship0+sprdata::xlow
shipbkgcollisionprecision
	sbc testshipbkgcollisionoffset				; shipbkg collision precision - #$02 is good for end zones?
	sta calcxlow
	lda ship0+sprdata::xhigh
	sbc #$00
	sta calcxhigh
	sec
	lda ship0+sprdata::ylow
	sbc #$2a
	sta calcylow

	jsr calcshippostoscreenpos

	lda calchit
	cmp #$20
	bne shiphitbkg

	jmp testshipbkgcollisionend

	;sec
	;lda ship0+sprdata::xlow
	;sbc #$18									; shipbkg collision precision - #$02 is good for end zones?
	;sta calcxlow
	;lda ship0+sprdata::xhigh
	;sbc #$00
	;sta calcxhigh
	;sec
	;lda ship0+sprdata::ylow
	;sbc #$2a
	;sta calcylow

	;jsr calcshippostoscreenpos

	;lda calchit
	;cmp #$20
	;beq tsbe

shiphitbkg
	lda #$00
	sta scrollspeed
	sta s0counter
	sta ship0+sprdata::xvel
	lda #playerstates::exploding
	sta playerstate
	lda #explosiontypes::big
	sta ship0+sprdata::isexploding
	; rts
	; fall through

testshipbkgcollisionend
	rts

testshipbkgcollisionoffset
.byte $02

; -----------------------------------------------------------------------------------------------

testshipsprcollision

	clc
	lda ship0+sprdata::xlow
	adc #$02
	sta calcxlow
	lda ship0+sprdata::xhigh
	adc #$00
	sta calcxhigh
	clc
	lda ship0+sprdata::ylow
	adc #$04
	sta calcylow

	clc
	lda ship0+sprdata::xlow
	adc #$14
	sta calcxlowmax
	lda ship0+sprdata::xhigh
	adc #$00
	sta calcxhighmax
	clc
	lda ship0+sprdata::ylow
	adc #$0b
	sta calcylowmax

	jsr calcshippostospritepos
	
	lda calcsprhit
	beq testshipsprcollisionend

	lda #$00
	sta scrollspeed
	sta s0counter
	sta ship0+sprdata::xvel
	lda #playerstates::exploding
	sta playerstate
	lda #explosiontypes::big
	sta ship0+sprdata::isexploding
	; rts
	; fall through

testshipsprcollisionend
	rts

; -----------------------------------------------------------------------------------------------

