.segment "STDINPUT"

; -----------------------------------------------------------------------------------------------

.define inputTypeMask			%10000000

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

/*
.macro waitforspaceorfire

waitspacefireloop
	jsr waitinput

	tax
	and #inputTypeMask
	cmp #joyInput								; was it joy input?
	beq :+

	txa
	cmp #keySpace								; no, it was keyboard input, check if it was space
	bne waitspacefireloop
	jmp waitspacefireloopend

:	txa
	cmp #joyFire								; yes, it was joy input, check if it was fire
	bne waitspacefireloop

waitspacefireloopend

.endmacro
*/

; -----------------------------------------------------------------------------------------------
