.segment "SUBZONES"

incsubzone

	inc subzone									; increase screen/subzone
	ldx subzone
	lda subzones,x
	cmp #$ff									; is it 255?
	bne :++
	
:	inc subzone									; yes, keep increasing until it's not 255 any more
	ldx subzone
	lda subzones,x
	cmp #$ff
	beq :-
	;inc zone									; increase zone
	inc subzone									; increase subzone one more time to jump over the 'you're dead, start on this empty screen'-subzone
	jmp :++
	
:	cmp #$31									; is it the boss screen?
	bne :+
	dec subzone
	
:	ldx subzone									; load next subzone
	lda subzones,x
	sta file	

	jsr calculatezonefromsubzone

	rts

calculatezonefromsubzone
	lda subzone									; get subzone (NOT subzones,x) and div by 16 to get zone
	cmp #$10
	bmi :+
	sec											; only subtract 3 when we're in zone 1 or higher
	sbc #$02
:	lsr
	lsr
	lsr
	lsr
	sta zone
	rts

findstartofzone

	lda zone
	asl
	asl
	asl
	asl
	sta subzone

:	ldx subzone
	lda subzones,x
	sta file
	
	rts
	
; -----------------------------------------------------------------------------------------------

subzones
.byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.byte $0a,$0b,$0c,$0d,$0e,$0f,$10,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.byte $12,$13,$14,$15,$16,$17,$18,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.byte $1a,$1b,$1c,$1d,$1e,$1f,$20,$21,$22,$23,$24,$ff,$ff,$ff,$ff,$ff
.byte $26,$27,$28,$29,$2a,$2b,$2c,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.byte $2e,$2f,$30,$31,$32,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

zonetab
.byte $01,$0d,$15,$1d,$29,$31

loadsubzone
	lda file

	ldx #$00
:	lda zonetab,x
	cmp file
	beq :+
	inx
	cpx #$06
	bne :-
	jmp :++

:	lda zonecodeptrslow,x
	sta handlezonecode+1
	lda zonecodeptrshigh,x
	sta handlezonecode+2

	lda zonecode2ptrslow,x
	sta handlezonecode2+1
	lda zonecode2ptrshigh,x
	sta handlezonecode2+2

	lda zonecode3ptrslow,x
	sta handlezonecode3+1
	lda zonecode3ptrshigh,x
	sta handlezonecode3+2

	lda zonecode4ptrslow,x
	sta handlezonecode4+1
	lda zonecode4ptrshigh,x
	sta handlezonecode4+2

	jsr initmultsprites

:	ldx zone									; SET ONE ZONE BLOCK WHEN LOADING NEW DATA!!!
	lda zonecolour1
	sta zonecolours,x

	lda file
	and #%00001111
	tax
	lda filenameconvtab,x
	sta file01+1
	
	lda file
	lsr
	lsr
	lsr
	lsr
	tax
	lda filenameconvtab,x
	sta file01

	lda #states::loadingsubzone
	sta state+1

	rts
    