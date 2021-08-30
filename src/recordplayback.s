.SEGMENT "RECORDPLAYBACK"

.if record | playback

; when dorecord or doplayback are called register X should contain the joystick register value ($dc00)

; -----------------------------------------------------------------------------------------------

writerecordedvalue
    sta recordmem
    inc writerecordedvalue+1
    bne :+
    inc writerecordedvalue+2
:   rts

; -----------------------------------------------------------------------------------------------

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