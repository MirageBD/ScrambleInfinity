.SEGMENT "RECORDPLAYBACK"

.if recordplayback

; when dorecord or doplayback are called register X should contain the joystick register value ($dc00)

recordmemend                                     = $2200

; -----------------------------------------------------------------------------------------------

clearrecordmem

	lda #<recordmem
	sta crm+1
	lda #>recordmem
	sta crm+2

crmloop
    ldx #$00
    lda #$00
crm
    sta recordmem,x
    inx
    bne crm

    inc crm+2
    lda crm+2
    cmp #>recordmemend                         ; clear till recordmemend
    bne crmloop

    rts

; -----------------------------------------------------------------------------------------------

initrecordplayback

    lda #$00
	sta recordplaybacktimerlo
	
    lda #$7f
	sta prevjoystate
	
    lda #<recordmem
	sta writerecordedvalue+1
	sta readrecordedvalue+1
	
    lda #>recordmem
	sta writerecordedvalue+2
	sta readrecordedvalue+2
    
    lda playingback
	bne :+
	
    jsr clearrecordmem

:   rts

; -----------------------------------------------------------------------------------------------

writerecordedvalue

    sta recordmem
    inc writerecordedvalue+1
    bne :+
    inc writerecordedvalue+2
:   rts

; -----------------------------------------------------------------------------------------------

dorecord

    lda writerecordedvalue+2                    ; don't record if we've past the end of the recording memory
    cmp #>recordmemend
    beq dorecordend
 
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

    ldx prevjoystate                            ; always fetch the last joystick state

    inc recordplaybacktimerlo

    jsr readrecordedvalue                       ; read recorded timer lo
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