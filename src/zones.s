handlezonecode
	jsr handlezone1								; self modified jsr
	jmp hcend

:	lda bullet0tested
	bne :+
	lda #$01
	sta bullet0tested
	inc collisionshandled
	lda shootingbullet0
	beq :+
	lda bull0+sprdata::isexploding
	cmp #explosiontypes::none
	bne :+
	jsr testbullet0bkgcollision
	jsr testbullet0sprcollision
	jmp hcend
	
:	lda bullet1tested
	bne :+
	lda #$01
	sta bullet1tested
	inc collisionshandled
	lda shootingbullet1
	beq :+
	lda bull1+sprdata::isexploding
	cmp #explosiontypes::none
	bne :+
	jsr testbullet1bkgcollision
	jsr testbullet1sprcollision
	jmp hcend

:	lda bomb0tested
	bne :+
	lda #$01
	sta bomb0tested
	inc collisionshandled
	lda shootingbomb0
	beq :+
	lda bomb0+sprdata::isexploding
	cmp #explosiontypes::none
	bne :+
	jsr testbomb0bkgcollision
	jsr testbomb0sprcollision
	jmp hcend

:	lda bomb1tested
	bne :+
	lda #$01
	sta bomb1tested
	inc collisionshandled
	lda shootingbomb1
	beq :+
	lda bomb1+sprdata::isexploding
	cmp #explosiontypes::none
	bne :+
	jsr testbomb1bkgcollision
	jsr testbomb1sprcollision

:	lda shiptested
	bne :+
	lda #$01
	sta shiptested
	inc collisionshandled
	lda hascontrol
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
:
hcend
	
	rts

; -----------------------------------------------------------------------------------------------

handlezone1										; missiles	
	jsr launchmissile
	jsr animmissiles
	jmp handlemissilemovement

handlezone2										; ufos
	jsr launchufo
	jsr animufos
	jmp handleufomovement

handlezone3										; comets
	jsr launchcomet
	jsr animcomets
	jmp handlecometmovement

handlezone4										; missiles
	jsr launchmissile
	jsr animmissiles
	jmp handlemissilemovement

handlezone5										; avoid fuel
	lda gamefinished
	cmp #$01
	bpl :++										; if 1 or higher!

	clc
	lda subzone
	cmp #$43
	bpl :+
	lda #$00
	sta ingamebkgcolor+1
	jmp handlezone5rest

:	inc bkgpulsetimer
	lda bkgpulsetimer
	lsr
	and #$0f
	tax
	lda bkgpulsecolors,x
	sta ingamebkgcolor+1
	jmp handlezone5rest
	
:	lda #$00
	sta ingamebkgcolor+1
	inc gamefinished
	lda gamefinished
	cmp #$30
	beq handlegamefinished
	jmp handlezone5rest
	
handlegamefinished
	lda flags
	cmp #$09
	beq :+
	inc flags
:	lda #states::congratulations
	sta state+1
	rts

handlezone5rest
	jsr animmissiles
	jmp handlemissilemovement
