.segment "SCHEDULEREMOVEHITOBJECT"

scheduleremovehitobject
	
	inc schedulequeue
	ldx schedulequeue
	
	lda calcylow
	sta scheduledcalcylow,x
	
	lda calcylowvsped
	sta scheduledcalcylowvsped,x
	
	lda calcxlow
	sta scheduledcalcxlow,x
	
	lda calcbkghit
	sta scheduledcalcbkghit,x
	
	rts

; -----------------------------------------------------------------------------------------------

removescheduledobject

	lda schedulequeue
	cmp #$ff									; -1 = nothing in queue
	bne :+

	jsr plotfuelplotscoreupdatefuel

	rts

:	lda scheduledcalcylow						; get first scheduled position to remove
	sta calcylow
	
	lda scheduledcalcylowvsped
	sta calcylowvsped
	
	lda scheduledcalcxlow
	sta calcxlow
	
	lda scheduledcalcbkghit
	sta calcbkghit
	
	ldx #$00									; move queue
:	lda scheduledcalcylow+1,x
	sta scheduledcalcylow+0,x
	lda scheduledcalcylowvsped+1,x
	sta scheduledcalcylowvsped+0,x
	lda scheduledcalcxlow+1,x
	sta scheduledcalcxlow+0,x
	lda scheduledcalcbkghit+1,x
	sta scheduledcalcbkghit+0,x
	inx
	cpx schedulequeue
	bmi :-

	dec schedulequeue							; decrease queue

removeobject

	clc											; setup clear bitmap 1 tiles
	ldx calcylowvsped
	lda times320lowtable,x
	adc #<bitmap1-1
	sta hbo0+1
	lda times320hightable,x
	adc #>bitmap1-1
	sta hbo0+2
	
	clc
	ldx calcxlow
	lda times8lowtable,x
	adc hbo0+1
	sta hbo0+1
	lda times8hightable,x
	adc hbo0+2
	sta hbo0+2

	clc											; setup clear bitmap 2 tiles
	ldx calcylowvsped
	lda times320lowtable,x
	adc #<bitmap2-1
	sta hbo1+1
	lda times320hightable,x
	adc #>bitmap2-1
	sta hbo1+2
	
	clc
	ldx calcxlow
	lda times8lowtable,x
	adc hbo1+1
	sta hbo1+1
	lda times8hightable,x
	adc hbo1+2
	sta hbo1+2

	ldx calcylow								; setup clear specialtiles/tilemem tiles
	lda times40lowtable,x
	adc #<screenspecial-1
	sta hbo8+1
	lda times40hightable,x
	adc #>screenspecial-1
	sta hbo8+2

	clc
	lda calcxlow
	adc hbo8+1
	sta hbo8+1
	lda #$00
	adc hbo8+2
	sta hbo8+2

	lda #>clearmisilepositiondata				; setup clear misile position data
	sta hbo10+2
	lda #<clearmisilepositiondata
	sta hbo10+1

	clc
	lda calcxlow
	adc hbo10+1
	sta hbo10+1
	lda #$00
	adc hbo10+2
	sta hbo10+2

	lda flip									; compensate for bank switch
	bne flipped
	
	jmp notflipped
	
flipped	clc
	lda hbo0+1
	adc #$40
	sta hbo0+1
	lda hbo0+2
	adc #$01
	sta hbo0+2
	
	jmp cleartiles
	
notflipped	
	clc
	lda hbo1+1
	adc #$40
	sta hbo1+1
	lda hbo1+2
	adc #$01
	sta hbo1+2

cleartiles
	clc
	lda hbo0+1
	adc #$40
	sta hbo2+1
	lda hbo0+2
	adc #$01
	sta hbo2+2
	
	clc
	lda hbo1+1
	adc #$40
	sta hbo3+1
	lda hbo1+2
	adc #$01
	sta hbo3+2

	clc
	lda hbo8+1
	adc #$28
	sta hbo9+1
	lda hbo8+2
	adc #$00
	sta hbo9+2

	ldx #$10
	lda calcbkghit
hbo0
	sta bitmap1-1,x
hbo1
	sta bitmap2-1,x
hbo2
	sta bitmap1+bitmapwidth-1,x
hbo3
	sta bitmap2+bitmapwidth-1,x
	dex
	bne hbo0

	ldx #$02
	lda #$20
hbo8
	sta screenspecial,x
hbo9
	sta screenspecial+40,x
	dex
	bne hbo8

	lda #$00
hbo10
	sta clearmisilepositiondata

	rts

; -----------------------------------------------------------------------------------------------

