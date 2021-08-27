.segment "COMETS"

launchcomet

	clc
	lda subzone
	cmp #$23
	bpl :+
	rts

:	cmp #$32
	bmi :+
	rts
	
:	inc comettimer
	lda comettimer
	cmp #$10
	beq :+
	rts
	
:	lda #$00
	sta comettimer

	lda #$50
	sta sortsprxlow,y
	lda #$01
	sta sortsprxhigh,y
	lda cometnum
	and #$1f
	tax
	lda cometposy,x								; between #$38 and #$b4?
	sta sortsprylow,y

	lda spriteptrforaddress(sprites2+cometanimstart*64)		; comet start
	sta sortsprp,y
	lda #$07
	sta sortsprc,y
	lda #$10
	sta sortsprwidth,y
	lda #$8
	sta sortsprheight,y
	lda #sprcollision::flyingcomet
	sta sortsprtype,y

	inc cometnum

	jsr addmulsprite

	rts
	
; -----------------------------------------------------------------------------------------------
	
animcomets

	lda bomb1counter2
	beq :+
	
	rts

:	ldx #$00
hcaloop
	inc sortsprp,x
	lda sortsprp,x
	cmp spriteptrforaddress(sprites2+(cometanimstart+cometanimframes)*64)	; comet end
	bcc :+
	lda spriteptrforaddress(sprites2+cometanimstart*64)						; comet start
	sta sortsprp,x
:	inx
	cpx #MAXMULTPLEXSPR
	bne hcaloop

	rts
	
; -----------------------------------------------------------------------------------------------

handlecometmovement

	ldx #MAXMULTPLEXSPR
hcmloop
	lda sortsprylow-1,x
	cmp #$ff
	beq :+										; don't move sprites if they are not on screen
	inc sortsprlifetime-1,x
	lda sortsprlifetime-1,x
	and #%00111111
	tay
	sec											; decrease x position
	lda sortsprxlow-1,x
	sbc #$06
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
	bne hcmloop

	rts
	
; -----------------------------------------------------------------------------------------------
