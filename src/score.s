.segment "UPDATESCOREANDFUEL"

updategroundscore

	lda calchit
	and #%11111100

	cmp #bkgcollision::fuelnoncave
	bne :+
	addpoints #1, 4
	addpoints #5, 5								; add 150 points
	jsr increasefuel
	jmp updatescore
:	cmp #bkgcollision::fuelcave
	bne :+
	addpoints #1, 4
	addpoints #5, 5								; add 150 points
	jsr increasefuel
	jmp updatescore
:	cmp #bkgcollision::standingmissilenoncave
	bne :+
	addpoints #5, 5								; groundmissile = add 50 points (5 at 5th position)
	jmp updatescore
:	cmp #bkgcollision::standingmissilecave
	bne :+
	addpoints #8, 5								; groundmissile cave = add 80 points
	jmp updatescore
:	cmp #bkgcollision::mysterynoncave
	bne :+
	clc											; mystery = add 100/200/300 points (1/2/3 at 4th position)
	lda score+4
	adc mysterytimer
	sta score+4
	jmp updatescore
:	cmp #bkgcollision::mysterycave
	bne :+
	clc											; mystery = add 100/200/300 points (1/2/3 at 4th position)
	lda score+4
	adc mysterytimer
	sta score+4
	jmp updatescore
:	cmp #bkgcollision::bosscave
	bne :+
	lda #$01
	sta gamefinished
	addpoints #8, 4								; boss = add 800 points (8 at 4th position)
	jmp updatescore
	
:	rts

; -----------------------------------------------------------------------------------------------

updateflyingscore								; hit a flying sprite (missile, ufo)

	lda sortsprtype,x
	cmp #sprcollision::flyingmissile
	bne :+
	addpoints #4, 5								; airmissile = add 80 points (only add 40, because missiles are 2 sprites overlayed)
	jmp updatescore
:	cmp #sprcollision::flyingufo
	bne :+
	addpoints #1, 4								; ufo = add 100 points
	jmp updatescore

:	rts

; -----------------------------------------------------------------------------------------------

increasefuel

	clc
	lda fuel
	adc fueladd									; add 8 fuel
	sta fuel
	cmp fuelfull
	bcc :+
	lda fuelfull
	sta fuel

:	rts

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
	cpx #$06
	bne :-

	rts

; -----------------------------------------------------------------------------------------------
