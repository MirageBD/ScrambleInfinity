.segment "INGAMEJOYSTICK"

handlejoystick

	lda playerstate
	beq yescontrol								; playerstate == 0 = incontrol

	cmp #$ff									; if exploding then no control
	beq :+

	dec playerstate								; if playerstate == flyingintomission then decrease playerstate and increase ship position
	inc ship0+sprdata::xlow
	lda #$58
	sta ship0+sprdata::ylow

:	rts

yescontrol

	lda fuel
	bne readjoy
	
	inc nofuelcounter
	lda nofuelcounter
	cmp #$02
	bne readjoy
	lda #$00
	sta nofuelcounter
	inc ship0+sprdata::ylow

readjoy
	ldx $dc00                                   ; #$7f when nothing is pressed

.if record
    jsr dorecord
.elseif playback
    jsr doplayback
.endif

	lda fuel
	beq down1									; fuel is 0 - not allowed to go up. only down, left, right, fire
	txa
	and #%00000001								; up
	bne down1
	dec ship0+sprdata::ylow
	jmp left1
down1
	txa
	and #%00000010								; down
	bne left1
	inc ship0+sprdata::ylow
left1
	txa
	and #%00000100								; left
	bne right1
	dec ship0+sprdata::xlow
	jmp fire1
right1
	txa
	and #%00001000								; right
	bne fire1
	inc ship0+sprdata::xlow
fire1
	txa
	and #%00010000								; fire
	beq :+
	jmp no1

:	jmp tryfirebullet

; ----------------------------------------------------------------------------------------------- RECORDING

.if record | playback

writerecordedvalue
    sta recordmem
    inc writerecordedvalue+1
    bne :+
    inc writerecordedvalue+2
:   rts

; ----------------------------------------------------------------------------------------------- PLAYBACK

dorecord
    inc recordplaybacktimerlo
    beq :+                                      ; always write state when timer is 0

    cpx prevjoystate                            ; if the joystick state hasn't changed then don't do anything
    beq dorecordend

:   lda recordplaybacktimerlo
    jsr writerecordedvalue
    txa
    sta prevjoystate
    jsr writerecordedvalue

dorecordend
    rts

; -----------------------------------------------------------------------------------------------

readrecordedvalue
    lda recordmem
    rts

increaseplaybackstate
    inc readrecordedvalue+1
    bne :+
    inc readrecordedvalue+2
:   rts

; -----------------------------------------------------------------------------------------------

doplayback
    inc recordplaybacktimerlo

    ldx prevjoystate                            ; always fetch the last joystick state

    jsr readrecordedvalue                       ; read recorded timer lo
    beq :+                                      ; if it's 0 then always fetch joystick state

    cmp recordplaybacktimerlo                   ; is it the same as the current timer lo?
    bne doplaybackend                           ; nope, bail out

:   jsr increaseplaybackstate
    jsr readrecordedvalue
    tax
    stx prevjoystate
    jsr increaseplaybackstate

doplaybackend
    rts

; -----------------------------------------------------------------------------------------------

.endif