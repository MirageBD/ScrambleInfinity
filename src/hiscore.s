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
	lda plotdata,y
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

plotdata
	.byte $0d, $09, $12, $01, $07, $05
	.byte $20, $21, $20, $20, $20, $20

	.byte $0a, $01, $0d, $0d, $05, $12
	.byte $20, $20, $21, $20, $20, $20

	.byte $04, $01, $0e, $05, $00, $00
	.byte $20, $20, $20, $21, $20, $20

	.byte $0b, $12, $09, $0c, $0c, $00
	.byte $20, $20, $20, $20, $21, $20

	.byte $02, $15, $12, $07, $0c, $01
	.byte $20, $20, $20, $20, $20, $21
