.define fueldecreases					1					; HACKS
.define pointsforbeingalive				1
.define shipbkgcollision				1
.define shipsprcollision				1
.define livesdecrease					1
.define firebullets						1
.define firebombs						1
.define startzone						#$00				; #$00 - #$04 (STARTING BEFORE BOSS WON'T WORK)
.define diedfade						0
.define debugrastertime					0

.define record                          1                   ; 0 or 1
.define playback                        0                   ; 0 or 2

.define bulletspeedx					8					; was 6
.define bombstartspeedx					5
.define bombstartspeedy					1
.define bombthrowspeed                  3					; number of frames the bomb goes forward a lot faster. has to be smaller than bombanimframes

.macro debugrasterstart color
    .if debugrastertime
        lda color
        sta $d020
    .endif
.endmacro

.macro debugrasterend
    .if debugrastertime
        lda #$00
        sta $d020
    .endif
.endmacro
