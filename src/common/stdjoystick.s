.segment "STDJOYSTICK"

; -----------------------------------------------------------------------------------------------

.define joyUp					%10000001
.define joyDown					%10000010
.define joyLeft					%10000100
.define joyRight				%10001000
.define joyFire					%10010000

.define joyMask					%00011111

.define joyInput				%10000000

joystate
	.byte $ff

; -----------------------------------------------------------------------------------------------

readjoy

	lda $dc00
	and #joyMask
	eor #joyMask
	sta joystate

	rts

; -----------------------------------------------------------------------------------------------

joypressed

:	lda $dc00									; wait until the joystick stops doing anything
	and #joyMask
	cmp #joyMask
	bne :-

	lda joystate
	ora #joyInput								; Accumulator now contains joystick bits and the highest bit set to signal that the joystick did something, not the keyboard

	rts

; -----------------------------------------------------------------------------------------------
