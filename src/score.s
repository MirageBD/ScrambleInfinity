.segment "UPDATESCOREANDFUEL"

updategroundscore

	lda calchit
	and #%11111100

	cmp #bkgcollision::fuelnoncave
	bne :+
	addpoints #1, 5
	addpoints #5, 6								; add 150 points
	jsr increasefuel
	jmp updatescore
:	cmp #bkgcollision::fuelcave
	bne :+
	addpoints #1, 5
	addpoints #5, 6								; add 150 points
	jsr increasefuel
	jmp updatescore
:	cmp #bkgcollision::standingmissilenoncave
	bne :+
	addpoints #5, 6								; groundmissile = add 50 points (5 at 6th position)
	jmp updatescore
:	cmp #bkgcollision::standingmissilecave
	bne :+
	addpoints #5, 6								; groundmissile cave = add 80 points
	jmp updatescore
:	cmp #bkgcollision::mysterynoncave
	bne :+
	clc											; mystery = add 100/200/300 points (1/2/3 at 5th position)
	lda score+5
	adc mysterytimer
	sta score+5
	jmp updatescore
:	cmp #bkgcollision::mysterycave
	bne :+
	clc											; mystery = add 100/200/300 points (1/2/3 at 5th position)
	lda score+5
	adc mysterytimer
	sta score+5
	jmp updatescore
:	cmp #bkgcollision::bosscave
	bne :+
	lda #$01
	sta gamefinished
	addpoints #8, 5								; boss = add 800 points (8 at 5th position)
	jmp updatescore
	
:	rts

; -----------------------------------------------------------------------------------------------

updateflyingscore								; hit a flying sprite (missile, ufo)

	lda sortsprtype,x
	cmp #sprcollision::flyingmissile
	bne :+
	addpoints #4, 6								; airmissile = add 80 points (only add 40, because missiles are 2 sprites overlayed)
	jmp updatescore
:	cmp #sprcollision::flyingufo
	bne :+
	addpoints #1, 5								; ufo = add 100 points
	jmp updatescore

:	rts

; -----------------------------------------------------------------------------------------------

increasefuel

	clc
	lda fuel
fueladdptr
	adc fueladd									; add fuel
	sta fuel
	cmp fuelfull
	bcc :+
	lda fuelfull
	sta fuel

:	rts

; -----------------------------------------------------------------------------------------------

updatescore

	lda score+0
	beq :+

	lda #$09									; if the 'carry' bit is not 0 then we've past 999999
	sta score+1
	sta score+2
	sta score+3
	sta score+4
	sta score+5
	sta score+6
	jmp usloopend

:	ldx #$06									; loop over all digits, lowest first
usloop
	clc
	lda score,x
	cmp #$0a									; higher than 10?
	bcc :+
	sec
	sbc #$0a									; yes, deduct 10
	sta score,x
	clc
	lda score-1,x
	adc #$01									; and add 1 to the next digit
	sta score-1,x
:	dex
	bne usloop

usloopend
	rts
    
; -----------------------------------------------------------------------------------------------

testhiscorebeaten

	lda hiscore+0
	cmp score+0
	bcc sethiscorebeaten
	bne endcompare

	lda hiscore+1
	cmp score+1
	bcc sethiscorebeaten
	bne endcompare

	lda hiscore+2
	cmp score+2
	bcc sethiscorebeaten
	bne endcompare

	lda hiscore+3
	cmp score+3
	bcc sethiscorebeaten
	bne endcompare

	lda hiscore+4
	cmp score+4
	bcc sethiscorebeaten
	bne endcompare

	lda hiscore+5
	cmp score+5
	bcc sethiscorebeaten
	bne endcompare

endcompare										; hiscore > score -> stop comparing
	rts

sethiscorebeaten:								; hiscore < score -> stop and set as beaten

	lda #$01
	sta hiscorebeaten

	lda spriteptrforaddress(fuelandscoresprites+0*64) 				; +0*64 = show score as hiscore, +5*64 = show real hiscore sprites
	sta scoreishiscoresprptr+1
	rts

; -----------------------------------------------------------------------------------------------

copyscoretohiscore

	ldx #$00
:	lda score,x
	sta hiscore,x
	inx
	cpx #$07
	bne :-

	rts

; -----------------------------------------------------------------------------------------------
