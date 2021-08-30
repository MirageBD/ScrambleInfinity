.segment "STDINPUT"

; -----------------------------------------------------------------------------------------------

.define inputTypeMask			%10000000

.define keyboardInput			%00000000

; -----------------------------------------------------------------------------------------------

waitinput

tryreadkeyboard
	jsr readkey									; wait until a key is pressed
	cpy #$ff
	beq tryreadjoystick
    jmp keypressed
tryreadjoystick
	jsr readjoy
	beq tryreadkeyboard
    jmp joypressed

; -----------------------------------------------------------------------------------------------
