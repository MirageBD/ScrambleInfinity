.segment "HISCORE"

titlescreenplothiscores

	; last zero sprite
	ldy #$20
	lda #<(titlescreenhiscorelinesspr+(0*64)+(11+0)*3+0)
	ldx #>(titlescreenhiscorelinesspr+(0*64)+(11+0)*3+0)
	jsr plotcharcompact

	lda #$00
	sta charindex

	ldy charindex
:	jsr plotcharimp
	inc charindex
	ldy charindex
	cpy #(5*12)
	bne :-

	rts

plotcharimp
	lda hiscores,y
	sta chartemp
	lda plottolo,y
	ldx plottohi,y
	ldy chartemp
	jmp plotcharcompact

chartemp
	.byte $00

charindex
	.byte $00

plottolo
	.byte <(titlescreenhiscorelinesspr+(1*64)+(11*3)+0)
	.byte <(titlescreenhiscorelinesspr+(1*64)+(11*3)+1)
	.byte <(titlescreenhiscorelinesspr+(1*64)+(11*3)+2)
	.byte <(titlescreenhiscorelinesspr+(2*64)+(11*3)+0)
	.byte <(titlescreenhiscorelinesspr+(2*64)+(11*3)+1)
	.byte <(titlescreenhiscorelinesspr+(2*64)+(11*3)+2)
	.byte <(titlescreenhiscorelinesspr+(3*64)+(11*3)+0)
	.byte <(titlescreenhiscorelinesspr+(3*64)+(11*3)+1)
	.byte <(titlescreenhiscorelinesspr+(3*64)+(11*3)+2)
	.byte <(titlescreenhiscorelinesspr+(4*64)+(11*3)+0)
	.byte <(titlescreenhiscorelinesspr+(4*64)+(11*3)+1)
	.byte <(titlescreenhiscorelinesspr+(4*64)+(11*3)+2)

	.byte <(titlescreenhiscorelinesspr+(5*64)+(11*3)+0)
	.byte <(titlescreenhiscorelinesspr+(5*64)+(11*3)+1)
	.byte <(titlescreenhiscorelinesspr+(5*64)+(11*3)+2)
	.byte <(titlescreenhiscorelinesspr+(6*64)+(11*3)+0)
	.byte <(titlescreenhiscorelinesspr+(6*64)+(11*3)+1)
	.byte <(titlescreenhiscorelinesspr+(6*64)+(11*3)+2)
	.byte <(titlescreenhiscorelinesspr+(7*64)+(11*3)+0)
	.byte <(titlescreenhiscorelinesspr+(7*64)+(11*3)+1)
	.byte <(titlescreenhiscorelinesspr+(7*64)+(11*3)+2)
	.byte <(titlescreenhiscorelinesspr+(8*64)+(11*3)+0)
	.byte <(titlescreenhiscorelinesspr+(8*64)+(11*3)+1)
	.byte <(titlescreenhiscorelinesspr+(8*64)+(11*3)+2)

	.byte <(titlescreenhiscorelinesspr+(9*64)+(11*3)+0)
	.byte <(titlescreenhiscorelinesspr+(9*64)+(11*3)+1)
	.byte <(titlescreenhiscorelinesspr+(9*64)+(11*3)+2)
	.byte <(titlescreenhiscorelinesspr+(10*64)+(11*3)+0)
	.byte <(titlescreenhiscorelinesspr+(10*64)+(11*3)+1)
	.byte <(titlescreenhiscorelinesspr+(10*64)+(11*3)+2)
	.byte <(titlescreenhiscorelinesspr+(11*64)+(11*3)+0)
	.byte <(titlescreenhiscorelinesspr+(11*64)+(11*3)+1)
	.byte <(titlescreenhiscorelinesspr+(11*64)+(11*3)+2)
	.byte <(titlescreenhiscorelinesspr+(12*64)+(11*3)+0)
	.byte <(titlescreenhiscorelinesspr+(12*64)+(11*3)+1)
	.byte <(titlescreenhiscorelinesspr+(12*64)+(11*3)+2)

	.byte <(titlescreenhiscorelinesspr+(13*64)+(11*3)+0)
	.byte <(titlescreenhiscorelinesspr+(13*64)+(11*3)+1)
	.byte <(titlescreenhiscorelinesspr+(13*64)+(11*3)+2)
	.byte <(titlescreenhiscorelinesspr+(14*64)+(11*3)+0)
	.byte <(titlescreenhiscorelinesspr+(14*64)+(11*3)+1)
	.byte <(titlescreenhiscorelinesspr+(14*64)+(11*3)+2)
	.byte <(titlescreenhiscorelinesspr+(15*64)+(11*3)+0)
	.byte <(titlescreenhiscorelinesspr+(15*64)+(11*3)+1)
	.byte <(titlescreenhiscorelinesspr+(15*64)+(11*3)+2)
	.byte <(titlescreenhiscorelinesspr+(16*64)+(11*3)+0)
	.byte <(titlescreenhiscorelinesspr+(16*64)+(11*3)+1)
	.byte <(titlescreenhiscorelinesspr+(16*64)+(11*3)+2)

	.byte <(titlescreenhiscorelinesspr+(17*64)+(11*3)+0)
	.byte <(titlescreenhiscorelinesspr+(17*64)+(11*3)+1)
	.byte <(titlescreenhiscorelinesspr+(17*64)+(11*3)+2)
	.byte <(titlescreenhiscorelinesspr+(18*64)+(11*3)+0)
	.byte <(titlescreenhiscorelinesspr+(18*64)+(11*3)+1)
	.byte <(titlescreenhiscorelinesspr+(18*64)+(11*3)+2)
	.byte <(titlescreenhiscorelinesspr+(19*64)+(11*3)+0)
	.byte <(titlescreenhiscorelinesspr+(19*64)+(11*3)+1)
	.byte <(titlescreenhiscorelinesspr+(19*64)+(11*3)+2)
	.byte <(titlescreenhiscorelinesspr+(20*64)+(11*3)+0)
	.byte <(titlescreenhiscorelinesspr+(20*64)+(11*3)+1)
	.byte <(titlescreenhiscorelinesspr+(20*64)+(11*3)+2)

plottohi
	.byte >(titlescreenhiscorelinesspr+(1*64)+(11*3)+0)
	.byte >(titlescreenhiscorelinesspr+(1*64)+(11*3)+1)
	.byte >(titlescreenhiscorelinesspr+(1*64)+(11*3)+2)
	.byte >(titlescreenhiscorelinesspr+(2*64)+(11*3)+0)
	.byte >(titlescreenhiscorelinesspr+(2*64)+(11*3)+1)
	.byte >(titlescreenhiscorelinesspr+(2*64)+(11*3)+2)
	.byte >(titlescreenhiscorelinesspr+(3*64)+(11*3)+0)
	.byte >(titlescreenhiscorelinesspr+(3*64)+(11*3)+1)
	.byte >(titlescreenhiscorelinesspr+(3*64)+(11*3)+2)
	.byte >(titlescreenhiscorelinesspr+(4*64)+(11*3)+0)
	.byte >(titlescreenhiscorelinesspr+(4*64)+(11*3)+1)
	.byte >(titlescreenhiscorelinesspr+(4*64)+(11*3)+2)

	.byte >(titlescreenhiscorelinesspr+(5*64)+(11*3)+0)
	.byte >(titlescreenhiscorelinesspr+(5*64)+(11*3)+1)
	.byte >(titlescreenhiscorelinesspr+(5*64)+(11*3)+2)
	.byte >(titlescreenhiscorelinesspr+(6*64)+(11*3)+0)
	.byte >(titlescreenhiscorelinesspr+(6*64)+(11*3)+1)
	.byte >(titlescreenhiscorelinesspr+(6*64)+(11*3)+2)
	.byte >(titlescreenhiscorelinesspr+(7*64)+(11*3)+0)
	.byte >(titlescreenhiscorelinesspr+(7*64)+(11*3)+1)
	.byte >(titlescreenhiscorelinesspr+(7*64)+(11*3)+2)
	.byte >(titlescreenhiscorelinesspr+(8*64)+(11*3)+0)
	.byte >(titlescreenhiscorelinesspr+(8*64)+(11*3)+1)
	.byte >(titlescreenhiscorelinesspr+(8*64)+(11*3)+2)

	.byte >(titlescreenhiscorelinesspr+(9*64)+(11*3)+0)
	.byte >(titlescreenhiscorelinesspr+(9*64)+(11*3)+1)
	.byte >(titlescreenhiscorelinesspr+(9*64)+(11*3)+2)
	.byte >(titlescreenhiscorelinesspr+(10*64)+(11*3)+0)
	.byte >(titlescreenhiscorelinesspr+(10*64)+(11*3)+1)
	.byte >(titlescreenhiscorelinesspr+(10*64)+(11*3)+2)
	.byte >(titlescreenhiscorelinesspr+(11*64)+(11*3)+0)
	.byte >(titlescreenhiscorelinesspr+(11*64)+(11*3)+1)
	.byte >(titlescreenhiscorelinesspr+(11*64)+(11*3)+2)
	.byte >(titlescreenhiscorelinesspr+(12*64)+(11*3)+0)
	.byte >(titlescreenhiscorelinesspr+(12*64)+(11*3)+1)
	.byte >(titlescreenhiscorelinesspr+(12*64)+(11*3)+2)

	.byte >(titlescreenhiscorelinesspr+(13*64)+(11*3)+0)
	.byte >(titlescreenhiscorelinesspr+(13*64)+(11*3)+1)
	.byte >(titlescreenhiscorelinesspr+(13*64)+(11*3)+2)
	.byte >(titlescreenhiscorelinesspr+(14*64)+(11*3)+0)
	.byte >(titlescreenhiscorelinesspr+(14*64)+(11*3)+1)
	.byte >(titlescreenhiscorelinesspr+(14*64)+(11*3)+2)
	.byte >(titlescreenhiscorelinesspr+(15*64)+(11*3)+0)
	.byte >(titlescreenhiscorelinesspr+(15*64)+(11*3)+1)
	.byte >(titlescreenhiscorelinesspr+(15*64)+(11*3)+2)
	.byte >(titlescreenhiscorelinesspr+(16*64)+(11*3)+0)
	.byte >(titlescreenhiscorelinesspr+(16*64)+(11*3)+1)
	.byte >(titlescreenhiscorelinesspr+(16*64)+(11*3)+2)

	.byte >(titlescreenhiscorelinesspr+(17*64)+(11*3)+0)
	.byte >(titlescreenhiscorelinesspr+(17*64)+(11*3)+1)
	.byte >(titlescreenhiscorelinesspr+(17*64)+(11*3)+2)
	.byte >(titlescreenhiscorelinesspr+(18*64)+(11*3)+0)
	.byte >(titlescreenhiscorelinesspr+(18*64)+(11*3)+1)
	.byte >(titlescreenhiscorelinesspr+(18*64)+(11*3)+2)
	.byte >(titlescreenhiscorelinesspr+(19*64)+(11*3)+0)
	.byte >(titlescreenhiscorelinesspr+(19*64)+(11*3)+1)
	.byte >(titlescreenhiscorelinesspr+(19*64)+(11*3)+2)
	.byte >(titlescreenhiscorelinesspr+(20*64)+(11*3)+0)
	.byte >(titlescreenhiscorelinesspr+(20*64)+(11*3)+1)
	.byte >(titlescreenhiscorelinesspr+(20*64)+(11*3)+2)

.byte $de, $ad, $be, $ef

inserthighscore

	; nnnnnn1 ssssss1
	; nnnnnn2 ssssss2
	; nnnnnn3 ssssss3
	; nnnnnn4 ssssss4
	; nnnnnn5 ssssss5

	lda #$06									; assume no highscore was reached
	sta hiscoreindex

	ldx #$00

:	ldy times12table,x

	lda hiscores+6+0,y
	jsr charasnumber
	cmp score+1
	bcc sethiscoreindex
	bne endhiscoreindexcompare

	lda hiscores+6+1,y
	jsr charasnumber
	cmp score+2
	bcc sethiscoreindex
	bne endhiscoreindexcompare

	lda hiscores+6+2,y
	jsr charasnumber
	cmp score+3
	bcc sethiscoreindex
	bne endhiscoreindexcompare

	lda hiscores+6+3,y
	jsr charasnumber
	cmp score+4
	bcc sethiscoreindex
	bne endhiscoreindexcompare

	lda hiscores+6+4,y
	jsr charasnumber
	cmp score+5
	bcc sethiscoreindex
	bne endhiscoreindexcompare

	lda hiscores+6+5,y
	jsr charasnumber
	cmp score+6
	bcc sethiscoreindex
	bne endhiscoreindexcompare

endhiscoreindexcompare

	inx
	cpx #$06
	bne :-

	rts

sethiscoreindex:

	stx hiscoreindex
	lda times12table,x
	sta hiscoreindextimes12

	clc														; move other scores down
	lda #<hiscores
	adc hiscoreindextimes12
	sta ihs1+1
	sta ihs4+1
	adc #12
	sta ihs2+1
	lda #>hiscores
	sta ihs1+2
	sta ihs2+2
	sta ihs3+2
	sta ihs4+2

	clc
	lda ihs1+1
	adc #$06
	sta ihs3+1

	ldx #5*12
ihs1	
	lda hiscores,x
ihs2
	sta hiscores+12,x
	dex
	cpx #$ff
	bne ihs1

	ldx #$00
:	lda score+1,x
	jsr numberaschar
ihs3
	sta hiscores,x
	inx
	cpx #$06
	bne :-

	rts

times12table
	.byte 0*12, 1*12, 2*12, 3*12, 4*12, 5*12

charasnumber

	sec
	sbc #$20
	rts

numberaschar
	clc
	adc #$20
	rts

; ends $a430