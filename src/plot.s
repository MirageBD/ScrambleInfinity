plotfuelplotscoreupdatefuel

	lda $01
	pha
	lda #$35
	sta $01
	
.macro tick arg1, arg2
	sec
	lda fuel									; load fuel
	sbc #(arg2)									; deduct arg2
	bcs :+
	lda #$00
:	tax
	lda fuelticks,x
	;sta arg1+0*3
	sta arg1+1*3
	sta arg1+2*3
	sta arg1+3*3
	sta arg1+4*3
	;sta arg1+5*3
.endmacro

	;tick scoreandfuelsprites+$0086+(0*64), 0+(0*3*4)		; 3 * 4 expanded pixels in a sprite horizontally
	tick scoreandfuelsprites+$0087+(0*64), 0+(0*3*4)
	tick scoreandfuelsprites+$0088+(0*64), 4+(0*3*4)

	tick scoreandfuelsprites+$0086+(1*64), 8+(0*3*4)
	tick scoreandfuelsprites+$0087+(1*64), 0+(1*3*4)
	tick scoreandfuelsprites+$0088+(1*64), 4+(1*3*4)

	tick scoreandfuelsprites+$0086+(2*64), 8+(1*3*4)
	tick scoreandfuelsprites+$0087+(2*64), 0+(2*3*4)
	tick scoreandfuelsprites+$0088+(2*64), 4+(2*3*4)

	tick scoreandfuelsprites+$0086+(3*64), 8+(2*3*4)
	tick scoreandfuelsprites+$0087+(3*64), 0+(3*3*4)
	tick scoreandfuelsprites+$0088+(3*64), 4+(3*3*4)

	tick scoreandfuelsprites+$0086+(4*64), 8+(3*3*4)
	tick scoreandfuelsprites+$0087+(4*64), 0+(4*3*4)
	tick scoreandfuelsprites+$0088+(4*64), 4+(4*3*4)

; plotscore

updatedigit0
	lda score+0
	cmp prevscore+0
	beq updatedigit1
	plotdigit score+0, scoredigit0

updatedigit1
	lda score+1
	cmp prevscore+1
	beq updatedigit2
	plotdigit score+1, scoredigit1

updatedigit2
	lda score+2
	cmp prevscore+2
	beq updatedigit3
	plotdigit score+2, scoredigit2
	lda lives
	cmp #$09
	beq :+
	inc lives									; award extra life at every 10000 points
:	plotdigit lives, livesdigit0

updatedigit3
	lda score+3
	cmp prevscore+3
	beq updatedigit4
	plotdigit score+3, scoredigit3

updatedigit4
	lda score+4
	cmp prevscore+4
	beq updatedigit5
	plotdigit score+4, scoredigit4

updatedigit5
	lda score+5
	cmp prevscore+5
	beq updateprevscore
	plotdigit score+5, scoredigit5

updateprevscore
	lda score+0
	sta prevscore+0
	lda score+1
	sta prevscore+1
	lda score+2
	sta prevscore+2
	lda score+3
	sta prevscore+3
	lda score+4
	sta prevscore+4
	lda score+5
	sta prevscore+5
	
updatefuel

	inc fueltimer
	lda fueltimer
	cmp fueldecreaseticks							
	bne :+

	lda #$00
	sta fueltimer

.if fueldecreases
	lda scrollspeed
	cmp #$00
	beq :+

	dec fuel
.endif
:	lda fuel
	cmp #$ff
	bne :+

	lda #$00
	sta fuel

:	pla
	sta $01
	
	rts

; -----------------------------------------------------------------------------------------------

updatescore

	ldx #$05
usloop
	clc
	lda score,x
	cmp #$0a
	bcc :+
	sec
	sbc #$0a
	sta score,x
	clc
	lda score-1,x
	adc #$01
	sta score-1,x
:	dex
	bne usloop

	rts
    