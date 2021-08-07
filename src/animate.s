.segment "ANIMATEBULLET0"

animbullet0

	inc bull0counter2
	lda bull0counter2
	cmp #$03
	beq :+
	
	rts
	
:	lda #$00
	sta bull0counter2

	lda bull0+sprdata::isexploding
	and #%00001111
	cmp #explosiontypes::big
	beq bull0biganim
	cmp #explosiontypes::small
	beq bull0smallanim
	cmp #explosiontypes::mystery
	beq bull0mysteryanim

bull0normalanim
	lda spriteptrforaddress(sprites2+bulletanimstart*64)
	sta bull0+sprdata::pointer
	lda #$01
	sta bull0+sprdata::colour
	rts

bull0smallanim
	ldx bull0counter
	lda bulletsmallexplosionanim,x
	sta bull0+sprdata::pointer
	
	lda bulletsmallexplosioncolours,x
	sta bull0+sprdata::colour
	
	inc bull0counter
	lda bull0counter
	cmp #bulletsmallexplosionanimframes
	beq bull0explosiondone

	rts
	
bull0biganim
	ldx bull0counter
	lda bulletbigexplosionanim,x
	sta bull0+sprdata::pointer
	
	lda bulletbigexplosioncolours,x
	sta bull0+sprdata::colour
	
	inc bull0counter
	lda bull0counter
	cmp #bulletbigexplosionanimframes
	beq bull0explosiondone

	rts
	
bull0explosiondone
	lda #$ff
	sta bull0+sprdata::ylow
	lda #$00
	sta bull0+sprdata::xlow
	sta bull0+sprdata::xhigh
	sta bull0+sprdata::xvel
	sta bull0+sprdata::yvel
	sta bull0+sprdata::isexploding
	lda #$00
	sta shootingbullet0
	
	lda #$01									; shoot immediately after bullet is gone
	sta bulletcooloff
	
	rts

bull0mysteryanim
	ldx bull0counter
	cpx #$03
	bmi :+
	lda bull0+sprdata::isexploding
	lsr
	lsr
	lsr
	lsr
	tay
	lda mystery100200300spriteptrs,y
	jmp :++
:	lda mysteryanim,x
:	sta bull0+sprdata::pointer
	
	lda mysterycolours,x
	sta bull0+sprdata::colour
	
	inc bull0counter
	lda bull0counter
	cmp #mysteryanimframes
	beq bull0explosiondone

	rts

; -----------------------------------------------------------------------------------------------

.segment "ANIMATEBULLET1"

animbullet1

	inc bull1counter2
	lda bull1counter2
	cmp #$03
	beq :+
	
	rts
	
:	lda #$00
	sta bull1counter2

	lda bull1+sprdata::isexploding
	and #%00001111
	cmp #explosiontypes::big
	beq bull1biganim
	cmp #explosiontypes::small
	beq bull1smallanim
	cmp #explosiontypes::mystery
	beq bull1mysteryanim

bull1normalanim
	lda spriteptrforaddress(sprites2+bulletanimstart*64)
	sta bull1+sprdata::pointer
	lda #$01
	sta bull1+sprdata::colour
	rts

bull1smallanim

	ldx bull1counter
	lda bulletsmallexplosionanim,x
	sta bull1+sprdata::pointer
	
	lda bulletsmallexplosioncolours,x
	sta bull1+sprdata::colour
	
	inc bull1counter
	lda bull1counter
	cmp #bulletsmallexplosionanimframes
	beq bull1explosiondone

	rts
	
bull1biganim

	ldx bull1counter
	lda bulletbigexplosionanim,x
	sta bull1+sprdata::pointer
	
	lda bulletbigexplosioncolours,x
	sta bull1+sprdata::colour
	
	inc bull1counter
	lda bull1counter
	cmp #bulletbigexplosionanimframes
	beq bull1explosiondone

	rts
	
bull1explosiondone
	lda #$ff
	sta bull1+sprdata::ylow
	lda #$00
	sta bull1+sprdata::xlow
	sta bull1+sprdata::xhigh
	sta bull1+sprdata::xvel
	sta bull1+sprdata::yvel
	sta bull1+sprdata::isexploding
	sta shootingbullet1
	
	lda #$01									; shoot immediately after bullet is gone
	sta bulletcooloff

	rts

bull1mysteryanim
	ldx bull1counter
	cpx #$03
	bmi :+
	lda bull1+sprdata::isexploding
	lsr
	lsr
	lsr
	lsr
	tay
	lda mystery100200300spriteptrs,y
	jmp :++
:	lda mysteryanim,x
:	sta bull1+sprdata::pointer
	
	lda mysterycolours,x
	sta bull1+sprdata::colour
	
	inc bull1counter
	lda bull1counter
	cmp #mysteryanimframes
	beq bull1explosiondone

	rts

; -----------------------------------------------------------------------------------------------

.segment "ANIMATEBOMB0"

animbomb0

	inc bomb0counter2
	lda bomb0counter2
	cmp #$04
	beq :+
	
	rts
	
:	lda #$00
	sta bomb0counter2

	lda bomb0+sprdata::isexploding
	and #%00001111
	cmp #explosiontypes::big
	beq bomb0explosionanim
	cmp #explosiontypes::mystery
	beq bomb0mysteryanim

bomb0normalanim

	ldx bomb0counter
	lda bombanim,x
	sta bomb0+sprdata::pointer

	lda bombcolours,x
	sta bomb0+sprdata::colour

	inc bomb0counter
	lda bomb0counter
	cmp #bombanimframes
	bne :+

	lda #bombanimloopframe
	sta bomb0counter

:	rts

bomb0explosionanim
	ldx bomb0counter
	lda bombexplosionanim,x
	sta bomb0+sprdata::pointer
	
	lda bombexplosioncolours,x
	sta bomb0+sprdata::colour
	
	inc bomb0counter
	lda bomb0counter
	cmp #bombexplosionanimframes
	beq bomb0explosiondone

	rts
	
bomb0explosiondone
	lda #$ff
	sta bomb0+sprdata::ylow
	lda #$00
	sta bomb0+sprdata::xlow
	sta bomb0+sprdata::xhigh
	sta bomb0+sprdata::xvel
	sta bomb0+sprdata::yvel
	sta bomb0+sprdata::isexploding
	sta shootingbomb0
	
	lda #$01
	sta bombcooloff
	
	rts

bomb0mysteryanim
	ldx bomb0counter
	cpx #$03
	bmi :+
	lda bomb0+sprdata::isexploding
	lsr
	lsr
	lsr
	lsr
	tay
	lda mystery100200300spriteptrs,y
	jmp :++
:	lda mysteryanim,x
:	sta bomb0+sprdata::pointer
	
	lda mysterycolours,x
	sta bomb0+sprdata::colour
	
	inc bomb0counter
	lda bomb0counter
	cmp #mysteryanimframes
	beq bomb0explosiondone

	rts

; -----------------------------------------------------------------------------------------------

.segment "ANIMATEBOMB1"

animbomb1

	inc bomb1counter2
	lda bomb1counter2
	cmp #$04
	beq :+
	
	rts
	
:	lda #$00
	sta bomb1counter2

	lda bomb1+sprdata::isexploding
	and #%00001111
	cmp #explosiontypes::big
	beq bomb1explosionanim
	cmp #explosiontypes::mystery
	beq bomb1mysteryanim

bomb1normalanim

	ldx bomb1counter
	lda bombanim,x
	sta bomb1+sprdata::pointer

	lda bombcolours,x
	sta bomb1+sprdata::colour

	inc bomb1counter
	lda bomb1counter
	cmp #bombanimframes
	bne :+

	lda #bombanimloopframe
	sta bomb1counter

:	rts

bomb1explosionanim
	ldx bomb1counter
	lda bombexplosionanim,x
	sta bomb1+sprdata::pointer
	
	lda bombexplosioncolours,x
	sta bomb1+sprdata::colour
	
	inc bomb1counter
	lda bomb1counter
	cmp #bombexplosionanimframes
	beq bomb1explosiondone

	rts
	
bomb1explosiondone
	lda #$ff
	sta bomb1+sprdata::ylow
	lda #$00
	sta bomb1+sprdata::xlow
	sta bomb1+sprdata::xhigh
	sta bomb1+sprdata::xvel
	sta bomb1+sprdata::yvel
	sta bomb1+sprdata::isexploding
	sta shootingbomb1
	
	lda #$01
	sta bombcooloff

	rts

bomb1mysteryanim
	ldx bomb1counter
	cpx #$03
	bmi :+
	lda bomb1+sprdata::isexploding
	lsr
	lsr
	lsr
	lsr
	tay
	lda mystery100200300spriteptrs,y
	jmp :++
:	lda mysteryanim,x
:	sta bomb1+sprdata::pointer
	
	lda mysterycolours,x
	sta bomb1+sprdata::colour
	
	inc bomb1counter
	lda bomb1counter
	cmp #mysteryanimframes
	beq bomb1explosiondone

	rts

; -----------------------------------------------------------------------------------------------

.segment "ANIMATEMISSILES"

animmissiles

	lda bomb1counter2
	beq :+
	
	rts

:	ldx #$00
hmaloop
	inc sortsprp,x
	inc sortsprp,x
	lda sortsprp,x
	cmp spriteptrforaddress(sprites2+(missileanimstart+missileanimframes)*64)	; missile end
	bcc :+
	sec
	lda sortsprp,x
	sbc #missileanimframes							; missile anim frames
	sta sortsprp,x
:	inx
	cpx #MAXMULTPLEXSPR
	bne hmaloop

	rts

; -----------------------------------------------------------------------------------------------

.segment "ANIMATESHIP"

animship

	inc s0counter2
	lda s0counter2
	cmp #$08
	beq :+
	
	rts
	
:	lda #$00
	sta s0counter2
	lda ship0+sprdata::isexploding
	cmp #explosiontypes::none
	beq ship0normalanim
	ldx s0counter
	lda bombexplosionanim,x
	sta ship0+sprdata::pointer
	lda bombexplosioncolours,x
	sta ship0+sprdata::colour
	inc s0counter
	lda s0counter
	cmp #$08
	beq ship0explosiondone

	rts
	
ship0explosiondone
	lda #$ff
	sta ship0+sprdata::ylow
	lda #$00
	sta ship0+sprdata::xlow
	sta ship0+sprdata::xhigh
	sta ship0+sprdata::xvel
	sta ship0+sprdata::yvel
	sta ship0+sprdata::isexploding

	rts

ship0normalanim
	inc s0counter
	lda s0counter
	and #shipanimframes
	tax
	lda s0anim,x
	sta ship0+sprdata::pointer
	lda #$01
	sta ship0+sprdata::colour

	rts
    
; -----------------------------------------------------------------------------------------------
