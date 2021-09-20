.segment "BULLETCOLLISION"

testbullet0bkgcollision

	sec
	lda bull0+sprdata::xlow
	sbc #$10
	sta calcxlow
	lda bull0+sprdata::xhigh
	sbc #$00
	sta calcxhigh
	sec
	lda bull0+sprdata::ylow
	sbc #$2c
	sta calcylow

	jsr calcspritepostoscreenpos

	lda calchit
	cmp #specialtiletransparent
	beq :+

	jmp handlebullet0bkgcollision

:	rts

testbullet0sprcollision

	lda bull0+sprdata::xlow
	sta calcxlow
	lda bull0+sprdata::xhigh
	sta calcxhigh
	lda bull0+sprdata::ylow
	sta calcylow

	clc
	lda bull0+sprdata::xlow
	adc #$08
	sta calcxlowmax
	lda bull0+sprdata::xhigh
	adc #$00
	sta calcxhighmax
	clc
	lda bull0+sprdata::ylow
	adc #$04
	sta calcylowmax

	jsr calcspritepostospritepos
	
	lda calcsprhit
	beq :++										; 0 = no hit

	cmp #$02
	bne :+
	
	jmp bullet0bkgsmallexplosion				; 1 = small hit
	
:	jmp bullet0bkgbigexplosion					; 2 = big hit

:	rts

; -----------------------------------------------------------------------------------------------

handlebullet0bkgcollision

	cmp #$ff
	beq bullet0bkgsmallexplosion

	sec
	lda bull0+sprdata::ylow
	sbc calcspryoffset
	sta bull0+sprdata::ylow
	
	jsr scheduleremovehitobject

bullet0bkgbigexplosion

.if ingame_sfx
	jsr sfx_initbulletexplosionsoundvoice2
.endif

	lda calchit
	and #%11111100
	cmp #bkgcollision::mysterynoncave
	beq bullet0bkgmystery
	cmp #bkgcollision::mysterycave
	beq bullet0bkgmystery

	lda #explosiontypes::big						; set big explosion anim
	sta bull0+sprdata::isexploding
	lda #$ff
	sta bull0+sprdata::xvel
	lda #$00
	sta bull0+sprdata::yvel
	sta bull0counter
	rts

bullet0bkgmystery
	lda mysterytimer								; store 1,2,3 in higher 4 bits
	asl
	asl
	asl
	asl
	ora #explosiontypes::mystery					; set mystery explosion anim
	sta bull0+sprdata::isexploding
	lda #$ff
	sta bull0+sprdata::xvel
	lda #$00
	sta bull0+sprdata::yvel
	sta bull0counter
	rts

bullet0bkgsmallexplosion

	lda #explosiontypes::small						; set small explosion anim
	sta bull0+sprdata::isexploding
	lda #$ff
	sta bull0+sprdata::xvel
	lda #$00
	sta bull0+sprdata::yvel
	sta bull0counter
	rts

; -----------------------------------------------------------------------------------------------

testbullet1bkgcollision

	sec
	lda bull1+sprdata::xlow
	sbc #$10
	sta calcxlow
	lda bull1+sprdata::xhigh
	sbc #$00
	sta calcxhigh
	sec
	lda bull1+sprdata::ylow
	sbc #$2c
	sta calcylow

	jsr calcspritepostoscreenpos

	lda calchit
	cmp #specialtiletransparent
	beq :+

	jmp handlebullet1bkgcollision

:	rts

testbullet1sprcollision

	lda bull1+sprdata::xlow
	sta calcxlow
	lda bull1+sprdata::xhigh
	sta calcxhigh
	lda bull1+sprdata::ylow
	sta calcylow

	clc
	lda bull1+sprdata::xlow
	adc #$08
	sta calcxlowmax
	lda bull1+sprdata::xhigh
	adc #$00
	sta calcxhighmax
	clc
	lda bull1+sprdata::ylow
	adc #$04
	sta calcylowmax

	jsr calcspritepostospritepos
	
	lda calcsprhit
	beq :++										; 0 = no hit

	cmp #$02
	bne :+
	
	jmp bullet1bkgsmallexplosion				; 1 = small hit
	
:	jmp bullet1bkgbigexplosion					; 2 = big hit

:	rts

; -----------------------------------------------------------------------------------------------

handlebullet1bkgcollision

	cmp #specialtilesolid
	beq bullet1bkgsmallexplosion

	sec
	lda bull1+sprdata::ylow
	sbc calcspryoffset
	sta bull1+sprdata::ylow
	
	jsr scheduleremovehitobject

bullet1bkgbigexplosion

	lda calchit
	and #%11111100
	cmp #bkgcollision::mysterynoncave
	beq bullet1bkgmystery
	cmp #bkgcollision::mysterycave
	beq bullet1bkgmystery

	lda #explosiontypes::big					; set big explosion anim
	sta bull1+sprdata::isexploding
	lda #$ff
	sta bull1+sprdata::xvel
	lda #$00
	sta bull1+sprdata::yvel
	sta bull1counter
	rts

bullet1bkgmystery
	lda mysterytimer							; store 1,2,3 in higher 4 bits
	asl
	asl
	asl
	asl
	ora #explosiontypes::mystery				; set mystery explosion anim
	sta bull1+sprdata::isexploding
	lda #$ff
	sta bull1+sprdata::xvel
	lda #$00
	sta bull1+sprdata::yvel
	sta bull1counter
	rts

bullet1bkgsmallexplosion

	lda #explosiontypes::small					; set small explosion anim
	sta bull1+sprdata::isexploding
	lda #$ff
	sta bull1+sprdata::xvel
	lda #$00
	sta bull1+sprdata::yvel
	sta bull1counter
	rts

; -----------------------------------------------------------------------------------------------
