.segment "MISSILES"

launchmissile

	lda randomseed
	beq doeor
	asl
	beq noeor									; if the input was $80, skip the EOR
	bcc noeor
doeor
	eor #$1f
noeor
	sta randomseed
	and #%00011001								; #%00001111 = pretty good random seed, make sure this is uneven otherwise we get half missiles
	sta misofst+1

	;lda #$25									; testing - launch as soon as possible
	;sta misofst+1

	lda #$00
	sta flipflop

	clc
	lda column
	adc #$01
misofst
	adc #$00
	cmp #$28
	bcc :+

	sec
	sbc #$28

	ldx #$01
	stx flipflop

:	tax
	lda screenspecial+$03c0,x
	beq :+
	jmp missilefound

:	rts

missilefound

	sta calcylow
	sta calcylowvsped
	stx calcxlow
	lda clearbmptile
	sta calcbkghit
	
	lda flipflop
	bne :+
	
	dec calcylowvsped
	
:	clc
	ldx calcylow
	lda times8lowtable,x
	adc #$2f-21-3
	sta startmissileypos

	ldx #MAXMULTPLEXSPR
:	lda sortsprylow-1,x
	cmp #$ff
	beq :+
	cmp startmissileypos
	bcs :++
:	dex
	bne :--
	
	jmp oktoremove
	
:	rts

oktoremove

	jsr scheduleremovehitobject

	clc
	ldx calcxlow
	lda times8lowtable,x
	adc screenposlow
	sta calcxlow
	lda times8hightable,x
	adc screenposhigh
	sta calcxhigh
	
	lda flipflop
	bne :+
	
	sec
	lda calcxlow
	sbc #$40
	sta calcxlow
	lda calcxhigh
	sbc #$01
	sta calcxhigh

:	clc
	lda calcxlow
	adc #$1a
	sta calcxlow
	lda calcxhigh
	adc #$00
	sta calcxhigh

	clc
	ldx calcylow
	lda times8lowtable,x
	adc #$35
	sta calcylow

	ldy curmulsprite

	lda calcxlow
	sta sortsprxlow,y
	lda calcxhigh
	sta sortsprxhigh,y
	lda calcylow
	sta sortsprylow,y

	lda spriteptrforaddress(sprites2+(missileanimstart+1)*64)	; missile start + 1 for highlight
	sta sortsprp,y
	lda #$02
	sta sortsprc,y
	lda #$0c
	sta sortsprwidth,y
	lda #$10
	sta sortsprheight,y
	lda #sprcollision::flyingmissile
	sta sortsprtype,y

	jsr addmulsprite

	ldy curmulsprite

	lda calcxlow
	sta sortsprxlow,y
	lda calcxhigh
	sta sortsprxhigh,y
	lda calcylow
	sta sortsprylow,y

	lda spriteptrforaddress(sprites2+missileanimstart*64)	; missile highlight start
	sta sortsprp,y
	lda #$07												; missile highlight colour
	sta sortsprc,y
	lda #$0c
	sta sortsprwidth,y
	lda #$10
	sta sortsprheight,y
	lda #sprcollision::flyingmissile
	sta sortsprtype,y
	
	jsr addmulsprite

	rts

; -----------------------------------------------------------------------------------------------

handlemissilemovement

	ldx #MAXMULTPLEXSPR
hmmloop
	lda sortsprylow-1,x
	cmp #$ff
	beq :++										; don't move sprites if they are not on screen
	dec sortsprylow-1,x							; decrease y position
	lda sortsprylow-1,x							; test if out of screen
	cmp #$20
	bcs :+
	lda #$ff
	sta sortsprylow-1,x
:	sec											; decrease x position with scrollspeed
	lda sortsprxlow-1,x
	sbc scrollspeed
	sta sortsprxlow-1,x
	lda sortsprxhigh-1,x
	sbc #$00
	sta sortsprxhigh-1,x
	bne :+
	lda sortsprxlow-1,x							; test if out of screen
	cmp #$10
	bcs :+
	lda #$ff
	sta sortsprylow-1,x
:	dex
	bne hmmloop

	rts

; -----------------------------------------------------------------------------------------------
