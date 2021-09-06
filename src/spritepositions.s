.segment "SPRITEPOSITIONS"

updatespritepositions1

	lda #$00
	sta highbit+1

	lda bull0+sprdata::xvel
	;cmp #$00
	bpl :+

	jmp negativebullet0speed

:	clc
	lda bull0+sprdata::xlow
	adc bull0+sprdata::xvel						; bullet 0 speed
	sta bull0+sprdata::xlow
	lda bull0+sprdata::xhigh
	adc #$00
	and #%00000001
	sta bull0+sprdata::xhigh
	asl
	ora highbit+1
	sta highbit+1

	lda bull0+sprdata::xhigh					; test bullet 0 xhigh
	beq handlebullet1speed
	lda bull0+sprdata::xlow
	cmp #$48
	bcc handlebullet1speed

	lda #$00
	sta shootingbullet0
	lda #$ff
	sta bull0+sprdata::ylow
	jmp handlebullet1speed

negativebullet0speed

	sec
	lda bull0+sprdata::xlow
	sbc scrollspeed
	sta bull0+sprdata::xlow
	lda bull0+sprdata::xhigh
	sbc #$00
	and #%00000001
	sta bull0+sprdata::xhigh
	asl
	ora highbit+1
	sta highbit+1

handlebullet1speed

	lda bull1+sprdata::xvel
	;cmp #$00
	bpl :+

	jmp negativebullet1speed

:	clc
	lda bull1+sprdata::xlow
	adc bull1+sprdata::xvel						; bullet 1 speed
	sta bull1+sprdata::xlow
	lda bull1+sprdata::xhigh
	adc #$00
	and #%00000001
	sta bull1+sprdata::xhigh
	asl
	asl
	ora highbit+1
	sta highbit+1

	lda bull1+sprdata::xhigh					; test bullet 1 xhigh
	beq handlebomb0speed
	lda bull1+sprdata::xlow
	cmp #$48
	bcc handlebomb0speed
	
	lda #$00
	sta shootingbullet1
	lda #$ff
	sta bull1+sprdata::ylow
	jmp handlebomb0speed

negativebullet1speed

	sec
	lda bull1+sprdata::xlow
	sbc scrollspeed
	sta bull1+sprdata::xlow
	lda bull1+sprdata::xhigh
	sbc #$00
	and #%00000001
	sta bull1+sprdata::xhigh
	asl
	asl
	ora highbit+1
	sta highbit+1

handlebomb0speed

	clc
	lda bomb0+sprdata::ylow
	adc bomb0+sprdata::yvel						; bomb 0 y speed
	sta bomb0+sprdata::ylow
	lda bomb0+sprdata::xlow
	adc bomb0+sprdata::xvel						; bomb 0 x speed
	sta bomb0+sprdata::xlow

	sec
	lda bomb0+sprdata::xlow
	sbc scrollspeed
	sta bomb0+sprdata::xlow

	clc
	lda bomb1+sprdata::ylow
	adc bomb1+sprdata::yvel						; bomb 1 y speed
	sta bomb1+sprdata::ylow
	lda bomb1+sprdata::xlow
	adc bomb1+sprdata::xvel						; bomb 1 x speed
	sta bomb1+sprdata::xlow

	sec
	lda bomb1+sprdata::xlow
	sbc scrollspeed
	sta bomb1+sprdata::xlow

	lda bomb0+sprdata::xlow
	cmp #$04
	bcs :+
	lda #$00
	sta shootingbomb0
	sta bomb0+sprdata::isexploding
	sta bomb0+sprdata::xvel
	sta bomb0+sprdata::yvel
	lda #$ff
	sta bomb0+sprdata::ylow
	
:	lda bomb1+sprdata::xlow
	cmp #$04
	bcs :+
	lda #$00
	sta shootingbomb1
	sta bomb1+sprdata::isexploding
	sta bomb1+sprdata::xvel
	sta bomb1+sprdata::yvel
	lda #$ff
	sta bomb1+sprdata::ylow
	
:	lda ship0+sprdata::pointer
	sta screen1+$03f8+0
	sta screen2+$03f8+0
	lda bull0+sprdata::pointer
	sta screen1+$03f8+1
	sta screen2+$03f8+1
	lda bull1+sprdata::pointer
	sta screen1+$03f8+2
	sta screen2+$03f8+2
	lda bomb0+sprdata::pointer
	sta screen1+$03f8+3
	sta screen2+$03f8+3
	lda bomb1+sprdata::pointer
	sta screen1+$03f8+4
	sta screen2+$03f8+4

restrictbombpositions

	lda shootingbomb0
	beq bombinsidescreenok0

	lda bomb0+sprdata::ylow						; check if the bomb has gone too low - nasty, but have to do this
	cmp #$df
	bpl :+
	jmp bombinsidescreenok0
	
:	cmp #$00
	bmi :+
	jmp bombinsidescreenok0
	
:	lda #$df									; clamp bomb position
	sta bomb0+sprdata::ylow
	lda #specialtilesolid						; and simulate collision with background
	sta calchit
	jmp handlebomb0bkgcollision	

bombinsidescreenok0
	lda shootingbomb1
	beq bombinsidescreenok1

	lda bomb1+sprdata::ylow						; check if the bomb has gone too low - nasty, but have to do this
	cmp #$df
	bpl :+
	jmp bombinsidescreenok1
	
:	cmp #$00
	bmi :+
	jmp bombinsidescreenok1
	
:	lda #$df									; clamp bomb position
	sta bomb1+sprdata::ylow
	lda #specialtilesolid						; and simulate collision with background
	sta calchit
	jmp handlebomb1bkgcollision
	
bombinsidescreenok1
	rts
	
	; ----------------------

updatespritepositions2

	lda $d010
highbit
	ora #$00
	sta $d010

	lda ship0+sprdata::ylow
	sta $d001
	lda ship0+sprdata::xlow
	sta $d000

	lda bull0+sprdata::ylow
	sta $d003
	lda bull0+sprdata::xlow
	sta $d002

	lda bull1+sprdata::ylow
	sta $d005
	lda bull1+sprdata::xlow
	sta $d004

	lda bomb0+sprdata::ylow
	sta $d007
	lda bomb0+sprdata::xlow
	sta $d006

	lda bomb1+sprdata::ylow
	sta $d009
	lda bomb1+sprdata::xlow
	sta $d008

	lda ship0+sprdata::colour
	sta $d027
	lda bull0+sprdata::colour
	sta $d028
	lda bull1+sprdata::colour
	sta $d029
	lda bomb0+sprdata::colour
	sta $d02a
	lda bomb1+sprdata::colour
	sta $d02b

	rts

; -----------------------------------------------------------------------------------------------
