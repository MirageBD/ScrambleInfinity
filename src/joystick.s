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
	ldx $dc00                                       ; #$7f when nothing is pressed

.if record
    jsr increaserecordplaybacktimer

    cpx prevjoystate                                ; if the joystick state hasn't changed then don't do anything
    beq :+

    stx prevjoystate
    lda recordplaybacktimerhi
    jsr recordstate
    lda recordplaybacktimerlo
    jsr recordstate
    txa
    jsr recordstate
:
.elseif playback
    jsr increaserecordplaybacktimer
    jsr doplayback                              ; doplayback compares the time. if it's the same then X will be the recorded joystick value
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

increaserecordplaybacktimer

    inc recordplaybacktimerlo
    bne :+
    inc recordplaybacktimerhi
:
    rts

; -----------------------------------------------------------------------------------------------

recordstate

recordstateptr
    sta recordmem
    inc recordstateptr+1
    bne :+
    inc recordstateptr+2

: rts

; ----------------------------------------------------------------------------------------------- PLAYBACK

readrecordedvalue

playbackstateptr
    lda recordmem
    rts

; -----------------------------------------------------------------------------------------------

increaseplaybackstate

    inc playbackstateptr+1
    bne :+
    inc playbackstateptr+2

: rts

; -----------------------------------------------------------------------------------------------

doplayback
    ldx prevjoystate

    lda recordplaybacktimerhiequal              ; was the hi timer equal?
    beq doplaybacktimerhiequal                  ; no, so check again if it's equal

    jmp doplaybacktimerloequal                  ; yes, so check if timer lo is the same

doplaybacktimerhiequal
    jsr readrecordedvalue                       ; read recorded timer hi value
    cmp recordplaybacktimerhi                   ; is it equal to the current timer hi?
    bne doplaybackend                           ; nope, bail out

    jsr increaseplaybackstate                   ; yes, timer hi is equal. increase ptr to the recorded low value
    lda #$01
    sta recordplaybacktimerhiequal              ; signal that timer hi was equal

doplaybacktimerloequal
    jsr readrecordedvalue                       ; read recorded timer lo

    cmp recordplaybacktimerlo                   ; is it the same as the current timer lo?
    bne doplaybackend                           ; nope, bail out

    jsr increaseplaybackstate                   ; yes, timer hi and lo are equal. increase ptr to the recorded joystick value
    jsr readrecordedvalue                       ; read recorded joystick value and put it in X
    tax
    stx prevjoystate
    lda #$00                                    ; signal that we have to compare timer hi again
    sta recordplaybacktimerhiequal
    jsr increaseplaybackstate                   ; and increase ptr so we're reading a timer hi value the next time

doplaybackend
    rts

; -----------------------------------------------------------------------------------------------

recordplaybacktimerhiequal
.byte 00

.endif

; -----------------------------------------------------------------------------------------------
