.segment "PLOTBITMAPSCORES"

plotbitmapscores
	sei
	lda #$35
	sta $01

	; plot score
	ldy score+0
	lda #<scoredigit0
	ldx #>scoredigit0
	jsr plotdigitcompact
	ldy score+1
	lda #<scoredigit1
	ldx #>scoredigit1
	jsr plotdigitcompact
	ldy score+2
	lda #<scoredigit2
	ldx #>scoredigit2
	jsr plotdigitcompact
	ldy score+3
	lda #<scoredigit3
	ldx #>scoredigit3
	jsr plotdigitcompact
	ldy score+4
	lda #<scoredigit4
	ldx #>scoredigit4
	jsr plotdigitcompact
	ldy score+5
	lda #<scoredigit5
	ldx #>scoredigit5
	jsr plotdigitcompact

	; plot hiscore
	ldy hiscore+0
	lda #<hiscoredigit0
	ldx #>hiscoredigit0
	jsr plotdigitcompact
	ldy hiscore+1
	lda #<hiscoredigit1
	ldx #>hiscoredigit1
	jsr plotdigitcompact
	ldy hiscore+2
	lda #<hiscoredigit2
	ldx #>hiscoredigit2
	jsr plotdigitcompact
	ldy hiscore+3
	lda #<hiscoredigit3
	ldx #>hiscoredigit3
	jsr plotdigitcompact
	ldy hiscore+4
	lda #<hiscoredigit4
	ldx #>hiscoredigit4
	jsr plotdigitcompact
	ldy hiscore+5
	lda #<hiscoredigit5
	ldx #>hiscoredigit5
	jsr plotdigitcompact
	lda #$37
	sta $01
	cli
	rts

plotlivesleft
	sei
	lda #$35
	sta $01
	ldy lives
	lda #<livesdigit0
	ldx #>livesdigit0
	jsr plotdigitcompact
	lda #$37
	sta $01
	cli
	rts

plottimesgamefinished
	sei
	lda #$35
	sta $01
	ldy timesgamefinished
	lda #<flagsdigit0
	ldx #>flagsdigit0
	jsr plotdigitcompact
	lda #$37
	sta $01
	cli
	rts

plotdigitcompact
	sta zp0
	stx zp1
	ldx times8lowtable,y

	ldy #$00
:	lda fontdigits,x
	sta (zp0),y
	inx
	iny
	iny
	iny
	cpy #18
	bne :-
	rts

.segment "PLOT"

plotfuelplotscoreupdatefuel

	lda $01
	pha
	lda #$35
	sta $01
	
.macro tick column
	sec
	lda fuel									; load fuel
	sbc #(4*column)								; deduct column
	bcs :+
	lda #$00
:	tax
	lda fuelticks,x
	.repeat 4, I
		sta fuelandscoresprites + $0086 + ((column+1).mod 3) + (((column+1) / 3) * 64) + (I+1)*3
	.endrepeat
.endmacro

.repeat 14, I
	tick I
.endrepeat

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
	jsr sfx_initextralifesoundvoice1
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
	;cmp #$00
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
