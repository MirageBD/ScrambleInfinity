.segment "BOMBCOLLISION"

testbomb0bkgcollision

	sec
	lda bomb0+sprdata::xlow
	sbc #$1a
	sta calcxlow
	lda bomb0+sprdata::xhigh
	sbc #$00
	sta calcxhigh
	sec
	lda bomb0+sprdata::ylow
	sbc #42
	sta calcylow

	lda bomb0+sprdata::ylow						; check if the bomb has gone too low - nasty, but have to do this
	cmp #$df
	bpl :+
	jmp bombinsidescreenok0
	
:	cmp #$00
	bmi :+
	jmp bombinsidescreenok0
	
:	lda #$df									; clamp bomb position
	sta bomb0+sprdata::ylow
	lda #$ff									; and simulate collision with background
	sta calchit
	jmp handlebomb0bkgcollision
	
bombinsidescreenok0

	jsr calcspritepostoscreenpos

	lda calchit
	cmp #$20
	beq :+

	jmp handlebomb0bkgcollision

:	rts

testbomb0sprcollision

	lda bomb0+sprdata::xlow
	sta calcxlow
	lda bomb0+sprdata::xhigh
	sta calcxhigh
	lda bomb0+sprdata::ylow
	sta calcylow

	clc
	lda bomb0+sprdata::xlow
	adc #$08
	sta calcxlowmax
	lda bomb0+sprdata::xhigh
	adc #$00
	sta calcxhighmax
	clc
	lda bomb0+sprdata::ylow
	adc #$08
	sta calcylowmax

	jsr calcspritepostospritepos
	
	lda calcsprhit
	beq :+

	jmp bomb0explode

:	rts

; -----------------------------------------------------------------------------------------------

handlebomb0bkgcollision

	cmp #$ff
	bne :+

	sec
	lda bomb0+sprdata::ylow
	sbc #$08
	sta bomb0+sprdata::ylow
	jmp bomb0explode

:	sec
	lda bomb0+sprdata::ylow
	sbc calcspryoffset
	sta bomb0+sprdata::ylow

	jsr scheduleremovehitobject

bomb0explode

	lda calchit
	and #%11111100
	cmp #bkgcollision::mysterynoncave
	beq bomb0explodemystery
	cmp #bkgcollision::mysterycave
	beq bomb0explodemystery

	lda #explosiontypes::big					; set big explosion anim
	sta bomb0+sprdata::isexploding
	lda #$00
	sta bomb0+sprdata::xvel
	sta bomb0+sprdata::yvel
	sta bomb0counter
	rts

bomb0explodemystery
	lda mysterytimer							; store 1,2,3 in higher 4 bits
	asl
	asl
	asl
	asl
	ora #explosiontypes::mystery				; set mystery explosion anim
	sta bomb0+sprdata::isexploding
	lda #$00
	sta bomb0+sprdata::xvel
	sta bomb0+sprdata::yvel
	sta bomb0counter
	rts

; -----------------------------------------------------------------------------------------------

testbomb1bkgcollision

	sec
	lda bomb1+sprdata::xlow
	sbc #$1a
	sta calcxlow
	lda bomb1+sprdata::xhigh
	sbc #$00
	sta calcxhigh
	sec
	lda bomb1+sprdata::ylow
	sbc #42
	sta calcylow

	lda bomb1+sprdata::ylow						; check if the bomb has gone too low - nasty, but have to do this
	cmp #$df
	bpl :+
	jmp bombinsidescreenok1
	
:	cmp #$00
	bmi :+
	jmp bombinsidescreenok1
	
:	lda #$df									; clamp bomb position
	sta bomb1+sprdata::ylow
	lda #$ff									; and simulate collision with background
	sta calchit
	jmp handlebomb1bkgcollision
	
bombinsidescreenok1

	jsr calcspritepostoscreenpos

	lda calchit
	cmp #$20
	beq :+

	jmp handlebomb1bkgcollision

:	rts
	
testbomb1sprcollision

	lda bomb1+sprdata::xlow
	sta calcxlow
	lda bomb1+sprdata::xhigh
	sta calcxhigh
	lda bomb1+sprdata::ylow
	sta calcylow

	clc
	lda bomb1+sprdata::xlow
	adc #$08
	sta calcxlowmax
	lda bomb1+sprdata::xhigh
	adc #$00
	sta calcxhighmax
	clc
	lda bomb1+sprdata::ylow
	adc #$08
	sta calcylowmax

	jsr calcspritepostospritepos
	
	lda calcsprhit
	beq :+

	jmp bomb1explode

:	rts

; -----------------------------------------------------------------------------------------------

handlebomb1bkgcollision

	cmp #$ff
	bne :+

	sec
	lda bomb1+sprdata::ylow
	sbc #$08
	sta bomb1+sprdata::ylow
	jmp bomb1explode

:	sec
	lda bomb1+sprdata::ylow
	sbc calcspryoffset
	sta bomb1+sprdata::ylow
	
	jsr scheduleremovehitobject

bomb1explode

	lda calchit
	and #%11111100
	cmp #bkgcollision::mysterynoncave
	beq bomb1explodemystery
	cmp #bkgcollision::mysterycave
	beq bomb1explodemystery

	lda #explosiontypes::big					; set big explosion anim
	sta bomb1+sprdata::isexploding
	lda #$00
	sta bomb1+sprdata::xvel
	sta bomb1+sprdata::yvel
	sta bomb1counter
	rts

bomb1explodemystery
	lda mysterytimer							; store 1,2,3 in higher 4 bits
	asl
	asl
	asl
	asl
	ora #explosiontypes::mystery				; set mystery explosion anim
	sta bomb1+sprdata::isexploding
	lda #$00
	sta bomb1+sprdata::xvel
	sta bomb1+sprdata::yvel
	sta bomb1counter
	rts

; -----------------------------------------------------------------------------------------------
