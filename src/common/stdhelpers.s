.segment "COPYMEM"

copymem
	ldx #$00
copymemfrom
	lda $1000,x
copymemto
	sta $2000,x
	dex
	bne copymemfrom
	inc copymemfrom+2
	inc copymemto+2
	lda copymemfrom+2
copymemsize
	cmp #>($1000+$0d00)
	bne copymemfrom
	
	rts

; -----------------------------------------------------------------------------------------------

.segment "LOADERHELPERS"

loadpackd

	ldx #<file01
	ldy #>file01
	jsr loadcompd

	rts

loadloadinstall

	ldx #<loadinstallfile
	ldy #>loadinstallfile
	jsr loadraw

	rts

; -----------------------------------------------------------------------------------------------

.segment "WAITINPUT"

.define inputTypeMask			%10000000

.define keyboardInput			%00000000
.define joyInput				%10000000

; -----------------------------------------------------------------------------------------------

waitinput

:	jsr readkey									; wait until a key is pressed
	cpy #$ff
	bne keypressed								; wait until the key is no longer pressed, then rts
	jsr readjoy
	bne joypressed								; wait until the joystick stops doing things, then rts
	jmp :-

; -----------------------------------------------------------------------------------------------

; -----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; DC00        DC01 |   Bit#0                     Bit#1                     Bit#2                     Bit#3                     Bit#4                     Bit#5                     Bit#6                     Bit#7                  |
; -----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Bit#0 - $01,$FE  |   Insert/Delete             Return                    cursor left/right         F7                        F1                        F3                        F5                        cursor up/down         |
; -----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Bit#1 - $02,$FD  |   3                         W                         A                         4                         Z                         S                         E                         left Shift             |
; -----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Bit#2 - $04,$FB  |   5                         R                         D                         6                         C                         F                         T                         X                      |
; -----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Bit#3 - $08,$F7  |   7                         Y                         G                         8                         B                         H                         U                         V                      |
; -----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Bit#4 - $10,$EF  |   9                         I                         J                         0                         M                         K                         O                         N                      |
; -----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Bit#5 - $20,$DF  |   + (plus)                  P                         L                         – (minus)                 . (period)                : (colon)                 @ (at)                    , (comma)              |
; -----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Bit#6 - $40,$BF  |   £ (pound)                 * (asterisk)              ; (semicolon)             Clear/Home                right Shift (Shift Lock)  = (equal)                 ↑ (up arrow)              / (slash)              |
; -----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Bit#7 - $80,$7F  |   1                         ← (left arrow)            Control                   2                         Space                     Commodore                 Q                         Run/Stop               |
; -----------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

.define keyInsertDelete			%00000000
.define keyReturn				%00000001
.define keyCursorLeftRight		%00000010
.define keyF7					%00000011
.define keyF1					%00000100
.define keyF3					%00000101
.define keyF5					%00000110
.define keyCursorUpDown			%00000111

.define key3					%00001000
.define keyW					%00001001
.define keyA					%00001010
.define key4					%00001011
.define keyZ					%00001100
.define keyS					%00001101
.define keyE					%00001110
.define keyShiftLeft			%00001111

.define key5					%00010000
.define keyR					%00010001
.define keyD					%00010010
.define key6					%00010011
.define keyC					%00010100
.define keyF					%00010101
.define keyT					%00010110
.define keyX					%00010111

.define key7					%00011000
.define keyY					%00011001
.define keyG					%00011010
.define key8					%00011011
.define keyB					%00011100
.define keyH					%00011101
.define keyU					%00011110
.define keyV					%00011111

.define key9					%00100000
.define keyI					%00100001
.define keyJ					%00100010
.define key0					%00100011
.define keyM					%00100100
.define keyK					%00100101
.define keyO					%00100110
.define keyN					%00100111

.define keyPlus					%00101000
.define keyP					%00101001
.define keyL					%00101010
.define keyMinus				%00101011
.define keyPeriod				%00101100
.define keyColon				%00101101
.define keyAt					%00101110
.define keyComma				%00101111

.define keyPound				%00110000
.define keyAsterisk				%00110001
.define keySemiColon			%00110010
.define keyClearHome			%00110011
.define keyShiftRightShiftLock	%00110100
.define keyEqual				%00110101
.define keyArrowUp				%00110110
.define keySlash				%00110111

.define key1					%00111000
.define keyArrowLeft			%00111001
.define keyControl				%00111010
.define key2					%00111011
.define keySpace				%00111100
.define keyCommodore			%00111101
.define keyQ					%00111110
.define keyRunStop				%00111111

; -----------------------------------------------------------------------------------------------

bitshifted
.byte %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000

matrixrow
	.byte $ff
matrixcolumn
	.byte $ff

; -----------------------------------------------------------------------------------------------

readkey

	ldx #$00									; go through all the rows

:	lda #%11111111
	eor bitshifted,x							; set bit 0-7 to 0
	sta $dc00
	tay

	lda $dc01
	cmp #$ff
	bne :+

	inx
	cpx #$08
	bne :-

	ldy #%11111111

:	sty matrixrow
	sta matrixcolumn

	rts

; -----------------------------------------------------------------------------------------------

keypressed

	sty $dc00									; wait until the key is no longer pressed in the same matrix column
:	lda $dc01
	cmp matrixcolumn
	beq :-

	lda matrixrow
	jsr calculatebitoffset
	stx matrixrow

	lda matrixcolumn
	jsr calculatebitoffset
	stx matrixcolumn

	lda matrixrow
	asl
	asl
	asl
	ora matrixcolumn							; Accumulator now contains a key that I have lots of defines for

	rts

; -----------------------------------------------------------------------------------------------

calculatebitoffset

	eor #%11111111
	clc
	ldx #$00
:	lsr
	bcs :+
	inx
	jmp :-

:	rts

; -----------------------------------------------------------------------------------------------

.define joyUp					%10000001
.define joyDown					%10000010
.define joyLeft					%10000100
.define joyRight				%10001000
.define joyFire					%10010000

.define joyMask					%00011111

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
