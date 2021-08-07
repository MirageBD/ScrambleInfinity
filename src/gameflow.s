.segment "GAMEFLOW"

handlegameflow

gameflowstate
:	lda #gameflow::waiting						; selfmodifying - see states enum
	beq handlegameflow

	cmp #gameflow::loadingsubzone
	bne :+
	jsr loadingsubzone
	jmp handlegameflow

:	cmp #gameflow::initlevel
	bne :+
	jsr screensafe
	jsr setuplevel
	jmp handlegameflow

:	cmp #gameflow::titlescreen
	bne :+
	jsr screensafe
	jsr titlescreen
	jmp handlegameflow

:	cmp #gameflow::livesleftscreen
	bne :+
	jsr screensafe
	jsr livesleftscreen
	jmp handlegameflow
	
:	cmp #gameflow::congratulations
	bne :+
	jsr screensafe
	jsr congratulations
	jmp handlegameflow

:	jmp handlegameflow

; -----------------------------------------------------------------------------------------------
