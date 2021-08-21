.define fueldecreases					1					; HACKS
.define pointsforbeingalive				1
.define shipbkgcollision				1
.define shipsprcollision				1
.define livesdecrease					1
.define firebullets						1
.define firebombs						1
.define startzone						#$00				; #$00 - #$04 (STARTING BEFORE BOSS WON'T WORK)
.define diedfade						1
.define debugrastertime					1

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
