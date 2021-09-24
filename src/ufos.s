.segment "UFOS"

launchufo

	clc
	lda subzone
	cmp #$13
	bpl :+
	rts

:	cmp #$18
	bmi :+
	rts

:	inc ufotimer
	lda ufotimer
	cmp ufospawntime
	beq :+
	
	rts
	
:	lda #$00
	sta ufotimer

	ldy curmulsprite

	lda #$50
	sta sortsprxlow,y
	lda #$01
	sta sortsprxhigh,y
	lda ufosiny
	sta sortsprylow,y

	lda spriteptrforaddress(sprites2+cometanimstart*64)		; comet start
	sta sortsprp,y
	lda #$0e
	sta sortsprc,y
	lda #$10
	sta sortsprwidth,y
	lda #$08
	sta sortsprheight,y
	lda #sprcollision::flyingufo
	sta sortsprtype,y

	ldx ufonum
	txa
	and #$04
	tax
	lda timesufotable,x
	sta sortsprlifetime,y

	inc ufonum

	jsr addmulsprite

	rts

; -----------------------------------------------------------------------------------------------

animufos

	lda bomb1counter2
	beq :+
	
	rts

:	ldx #$00
hualoop
	inc sortsprp,x
	lda sortsprp,x
	cmp spriteptrforaddress(sprites2+(ufoanimstart+ufoanimframes)*64)	; ufo end
	bcc :+
	lda spriteptrforaddress(sprites2+ufoanimstart*64)		; ufo start - 8E80, 8ec0, 8f00
	sta sortsprp,x
:	inx
	cpx #MAXMULTPLEXSPR
	bne hualoop

	rts

; -----------------------------------------------------------------------------------------------

handleufomovement

	ldx #MAXMULTPLEXSPR
humloop
	lda sortsprylow-1,x
	cmp #$ff
	beq :+										; don't move sprites if they are not on screen
	inc sortsprlifetime-1,x
	lda sortsprlifetime-1,x
	and #%00111111
	tay
	lda ufosiny,y
	sta sortsprylow-1,x
	sec											; decrease x position
	lda sortsprxlow-1,x
	;sbc scrollspeed
	sbc ufosinx,y
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
	bne humloop

	rts

; -----------------------------------------------------------------------------------------------

