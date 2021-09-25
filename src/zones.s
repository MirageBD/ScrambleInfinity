.segment "ZONES"

handlezone1										; missiles	
	jsr launchmissile
	jsr animmissiles
	jmp handlemissilemovement

handlezone2										; ufos
	jsr launchufo
	jsr animufos
	jsr handleufomovement
	rts

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
	beq handlenomorezones
	;jmp handlezone5rest
	
handlezone5rest
	jsr animmissiles
	jmp handlemissilemovement

handlenomorezones
	lda timesgamefinished
	cmp #$09
	beq :+
	inc timesgamefinished

:
	jsr setfueladdfromtimesgamefinished

	lda #gameflow::congratulations
	sta gameflowstate+1

	rts

; -----------------------------------------------------------------------------------------------

setfueladdfromtimesgamefinished

	sec
	lda fueladdstart
	sbc timesgamefinished
	cmp #$04
	bpl :+
	lda #$04
:	sta fueladdptr+1

	rts

; -----------------------------------------------------------------------------------------------
