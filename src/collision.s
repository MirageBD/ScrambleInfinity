.segment "COLLISION"

calcspritepostospritepos

	lda #$00
	sta calcsprhit

	ldx #$00
cssloop
	lda sortsprylow,x
	cmp #$ff
	beq dontintersect

	cmp calcylowmax
	bcs dontintersect

	clc
	lda sortsprylow,x
	adc sortsprheight,x
	sec
	cmp calcylow
	bcc dontintersect

	sec
	lda sortsprxlow,x
	sbc calcxlowmax
	lda sortsprxhigh,x
	sbc calcxhighmax
	bcs dontintersect

	clc
	lda sortsprxlow,x
	adc sortsprwidth,x
	sta sortsprxlowmax,x
	lda sortsprxhigh,x
	adc #$00
	sta sortsprxhighmax,x

	sec
	lda sortsprxlowmax,x
	sbc calcxlow
	lda sortsprxhighmax,x
	sbc calcxhigh
	bcc dontintersect

	lda sortsprtype,x
	cmp #$03
	bne :+
	lda #$02
	sta calcsprhit
	jmp dontintersect
:	lda #$01
	sta calcsprhit
	lda #$ff
	sta sortsprylow,x
	jsr updateflyingscore

dontintersect	
	inx
	cpx #MAXMULTPLEXSPR
	bne cssloop
	
	rts

; -----------------------------------------------------------------------------------------------	

calcshippostospritepos

	lda #$00
	sta calcsprhit

	ldx #$00
cssloop2
	lda sortsprylow,x
	cmp #$ff
	beq dontintersect2

	cmp calcylowmax
	bcs dontintersect2
	
	clc
	lda sortsprylow,x
	adc sortsprheight,x
	sec
	cmp calcylow
	bcc dontintersect2
	
	sec
	lda sortsprxlow,x
	sbc calcxlowmax
	lda sortsprxhigh,x
	sbc calcxhighmax
	bcs dontintersect2
	
	clc
	lda sortsprxlow,x
	adc sortsprwidth,x
	sta sortsprxlowmax,x
	lda sortsprxhigh,x
	adc #$00
	sta sortsprxhighmax,x

	sec
	lda sortsprxlowmax,x
	sbc calcxlow
	lda sortsprxhighmax,x
	sbc calcxhigh
	bcc dontintersect2

	lda sortsprtype,x
	cmp #$03
	bne :+
	lda #$02
	sta calcsprhit
	jmp dontintersect2
:	lda #$01
	sta calcsprhit

dontintersect2
	inx
	cpx #MAXMULTPLEXSPR
	bne cssloop2
	
	rts

; -----------------------------------------------------------------------------------------------	

calcspritepostoscreenpos

	clc											; add inverse vsp position
	lda calcxlow
	adc invscreenposlow
	sta calcxlow
	lda calcxhigh
	adc invscreenposhigh
	sta calcxhigh

	lsr calcxhigh								; divide xpos by 8 to get column
	ror calcxlow
	lsr calcxhigh
	ror calcxlow
	lsr calcxhigh
	ror calcxlow

	lda #$00
	sta flipflop

	lda calcxlow
	cmp #$28
	bmi :+

	lda #$01
	sta flipflop

	sec
	lda calcxlow
	sbc #$28
	sta calcxlow

:	lsr calcylow								; divide ypos by 8 to get row
	lsr calcylow
	lsr calcylow

	clc
	ldx calcylow
	lda times40lowtable,x
	sta csptsp0+1
	lda times40hightable,x
	sta csptsp0+2

	clc
	lda csptsp0+1
	adc calcxlow
	sta csptsp0+1
	lda csptsp0+2
	adc #>screenspecial
	sta csptsp0+2

csptsp0	lda screenspecial+1
	sta calchit
	cmp #specialtilesolid
	beq csend

	lda #$00
	sta calcspryoffset

	lda calchit									; find top left position of object hit
	; sta $d020
	and #%00000001
	beq :+										; is it even?
	dec calcxlow								; no, decrease 1 to make it even

:	lda calchit
	and #%00000010
	beq :+
	dec calcylow
	lda #$08
	sta calcspryoffset
:	
	lda clearbmptile
	sta calcbkghit

csbkghit

	lda calcylow								; calculate vsp'ed position of hit tile
	sta calcylowvsped
	lda flipflop
	bne :+
	dec calcylowvsped

:	jsr updategroundscore

csend

	rts

; -----------------------------------------------------------------------------------------------	

calcshippostoscreenpos

	clc											; add inverse vsp position
	lda calcxlow
	adc invscreenposlow
	sta calcxlow
	lda calcxhigh
	adc invscreenposhigh
	sta calcxhigh

	lsr calcxhigh								; divide xpos by 8 to get column
	ror calcxlow
	lsr calcxhigh
	ror calcxlow
	lsr calcxhigh
	ror calcxlow

	lda #$00
	sta flipflop

	lda calcxlow
	cmp #$28
	bmi :+

	lda #$01
	sta flipflop

	sec
	lda calcxlow
	sbc #$28
	sta calcxlow

:	lsr calcylow								; divide ypos by 8 to get row
	lsr calcylow
	lsr calcylow

	clc
	ldx calcylow
	lda times40lowtable,x
	sta csptsp1+1
	lda times40hightable,x
	sta csptsp1+2

	clc
	lda csptsp1+1
	adc calcxlow
	sta csptsp1+1
	lda csptsp1+2
	adc #>screenspecial
	sta csptsp1+2

csptsp1
	lda screenspecial+1
	sta calchit

	rts

; -----------------------------------------------------------------------------------------------	

.segment "INITHANDLECOLLISIONS"

inithandlecollisions

	lda #$00
	sta taskshandled

	lda flip									; store off the value of 'flip' at the top of the frame,
	sta flipstored								; so the correct value is used when calculating tiles to clear.

	rts

; -----------------------------------------------------------------------------------------------	

.segment "HANDLERESTCOLLISIONS"

handletask

	debugrasterstart taskshandled

	ldx taskshandled
	cpx #$06
	bmi :+
	debugrasterend
	;inc taskshandled
	rts

:	cpx #$00									; test if the game finished for any of the collision tasks, not the zone task
	beq :+

	lda gamefinished							; only handle collisions if the game hasn't finished yet
	cmp #$01
	bmi :+
	;inc taskshandled
	debugrasterend
	rts

:	lda taskcodeptrslow,x
	sta handlecollisionptr+1
	lda taskcodeptrshigh,x
	sta handlecollisionptr+2
	inc taskshandled

handlecollisionptr
	jsr $0000
	debugrasterend
	rts

handlezoneptr1
	jsr handlezone1								; self modified jsr
	rts

taskcodeptrslow
.byte <handlezoneptr1
.byte <testbullet0collisions
.byte <testbullet1collisions
.byte <testbomb0collisions
.byte <testbomb1collisions
.byte <testshipcollisions
taskcodeptrshigh
.byte >handlezoneptr1
.byte >testbullet0collisions
.byte >testbullet1collisions
.byte >testbomb0collisions
.byte >testbomb1collisions
.byte >testshipcollisions

testbullet0collisions
	debugrasterstart #$01
	lda shootingbullet0
	beq :+
	lda bull0+sprdata::isexploding
	cmp #explosiontypes::none
	bne :+
	jsr testbullet0bkgcollision
	jsr testbullet0sprcollision
:	debugrasterend
	rts
	
testbullet1collisions
	debugrasterstart #$02
	lda shootingbullet1
	beq :+
	lda bull1+sprdata::isexploding
	cmp #explosiontypes::none
	bne :+
	jsr testbullet1bkgcollision
	jsr testbullet1sprcollision
:	debugrasterend
	rts

testbomb0collisions
	debugrasterstart #$03
	lda shootingbomb0
	beq :+
	lda bomb0+sprdata::isexploding
	cmp #explosiontypes::none
	bne :+
	jsr testbomb0bkgcollision
	jsr testbomb0sprcollision
:	debugrasterend
	rts

testbomb1collisions
	debugrasterstart #$04
	lda shootingbomb1
	beq :+
	lda bomb1+sprdata::isexploding
	cmp #explosiontypes::none
	bne :+
	jsr testbomb1bkgcollision
	jsr testbomb1sprcollision
:	debugrasterend
	rts

testshipcollisions
	debugrasterstart #$05
	lda playerstate
	bne :+
	lda ship0+sprdata::isexploding
	cmp #explosiontypes::none
	bne :+
.if shipbkgcollision
	jsr testshipbkgcollision
.endif
.if shipsprcollision
	jsr testshipsprcollision
.endif

:	debugrasterend
	rts

; -----------------------------------------------------------------------------------------------	
