.segment "SCROLLER"

plottiles

	;ldy #$03

plotloop
	clc
gett1
	lda loadeddata1+0*2
	sta currenttile+0
	sta currenttiletimes8+0
	;adc #$00
	sta plotc1+1
gett2
	lda loadeddata1+0*2+1
	sta currenttile+1
	sta currenttiletimes8+1
	adc #>maptilecolors
	sta plotc1+2
	
												; get low and high byte of tile number and convert it to:
												; - 0-31 = missile, fuel, special, boss (4x4x2)
												; -   32 = empty
												; -  255 (specialtilesolid)= solid

	lda currenttile+1							; > 256 = always solid tile
	bne solidtile
	
	lda currenttile+0
	bmi solidtile								; < 0 = solid tile
	cmp #firstsolidtile
	bpl solidtile								; > 67 = solid tile
	
	lda currenttile+0
	cmp #firsttransparenttile
	bpl transtile								; > firsttransparenttile (32) && < firstsolidtile (72) = transparent tile

missilefuelspecialtile
	lda currenttile+0
	and #%00011111
	sta currenttile+0
	jmp skipspecialtiles
	
transtile
	lda #specialtiletransparent
	sta currenttile+0
	jmp skipspecialtiles

solidtile
	lda #specialtilesolid
	sta currenttile+0
	;jmp skipspecialtiles
	; fall through

skipspecialtiles
	asl currenttiletimes8+0
	rol currenttiletimes8+1
	asl currenttiletimes8+0
	rol currenttiletimes8+1
	asl currenttiletimes8+0
	rol currenttiletimes8+1
	
	clc
	lda currenttiletimes8+0
	;adc #$00
	sta ploth1+1
	lda currenttiletimes8+1
	adc #>maptiles
	sta ploth1+2

	ldx #$07
ploth1
	lda $e000,x
ploth2
	sta bitmap2+1*320,x
ploth3
	sta bitmap1+0*320,x
	dex
	bpl ploth1

plotc1
	lda maptilecolors+1
plotc2
	sta screen2+1*40
plotc3
	sta screen1+0*40

	lda currenttile+0
plott1
	sta screenspecial

	clc
	add16bit gett1, 2
	add16bit gett2, 2
	add16bit ploth2, 320
	add16bit ploth3, 320
	add16bit plotc2, 40
	add16bit plotc3, 40
	add16bit plott1, 40
	inc row
	
	rts

plottilesdone
	lda row
	cmp #$18
	beq inccol
	
	rts

;-------------------------------------

inccol

	lda #$00
	sta row

	inc column
	lda column
	cmp #$28
	bne inccol2

	jmp incpag

inccol2
	lda gett2+1									; plot special missile tiles
	sta plott2+1
	lda gett2+2
	sta plott2+2

	lda plott1+1
	sta plott3+1
	lda plott1+2
	sta plott3+2
	
plott2	lda loadeddata1
plott3	sta screenspecial+$03c0

	clc
	add16bit gett1, 2
	add16bit gett2, 2							; end plot special missile tiles

	sec
	sub16bit ploth2, 24*320-8
	sub16bit ploth3, 24*320-8
	sub16bit plotc2, 24*40-1
	sub16bit plotc3, 24*40-1
	sub16bit plott1, 24*40-1

	rts

;-------------------------------------

incpag

	lda #$00
	sta column
	
	jsr increasesubzone
	jsr configuresubzoneload

	lda #gameflow::loadsubzone					; flag that the main loop should start the subzone load
	sta gameflowstate+1

	inc flip
	lda flip
	cmp #$02
	beq incpag2
	
	jmp incpag3

incpag2
	lda #$00
	sta flip
	lda bankforaddress(bitmap2)
	sta page+1
	store16bit gett1, loadeddata1+0*2
	store16bit gett2, loadeddata1+1+0*2
	store16bit ploth2, bitmap2+1*320
	store16bit ploth3, bitmap1+0*320
	store16bit plotc2, screen2+1*40
	store16bit plotc3, screen1+0*40
	store16bit plott1, screenspecial+0*40
	rts
	
incpag3
	lda bankforaddress(bitmap1)
	sta page+1
	store16bit gett1, loadeddata2+0*2
	store16bit gett2, loadeddata2+1+0*2
	store16bit ploth2, bitmap1+1*320
	store16bit ploth3, bitmap2+0*320
	store16bit plotc2, screen1+1*40
	store16bit plotc3, screen2+0*40
	store16bit plott1, screenspecial+0*40
	rts

; -----------------------------------------------------------------------------------------------

scrollspeed
.byte $01
diedframes
.byte $00
diedframeclearframes
.byte $00

scrollscreen

	sec
	lda screenposlow							; screenposhigh, screenposlow start at bitmapwidth-1, end at 0
	sbc scrollspeed
	sta screenposlow
	lda screenposhigh
	sbc #$00
	sta screenposhigh
	cmp #$ff
	bne :+
	
	ldx #>(bitmapwidth-1)
	ldy #<(bitmapwidth-1)
	stx screenposhigh
	sty screenposlow
	
:	rts

; -----------------------------------------------------------------------------------------------

calcvsp

	sec											; first calculate the inverse numbers
	lda #<(bitmapwidth-1)
	sbc screenposlow
	sta invscreenposlow
	lda #>(bitmapwidth-1)
	sbc screenposhigh
	sta invscreenposhigh

	clc
	lda invscreenposlow
	and #$07
	eor #$07
	sta drawstarsoffsetlo+1
	adc #$10
	sta scrlow+1

	clc
	lda invscreenposhigh						; divide the 16 bit number by 8
	ror											; shift bit into carry
	lda invscreenposlow
	ror											; shift carry back in
	lsr
	lsr
	
	sta vspoffset+1
	
	rts

; -----------------------------------------------------------------------------------------------

correctvspsprites

	lda #$36

	clc
cvsppos
	ldx #$ff
	cpx #$33
	bcs not1
	adc #$07									; #$07 for 2 sprites
	cpx #$32
	bcs not1
	adc #$07

not1
	sta vspcor+1
	
	rts

; -----------------------------------------------------------------------------------------------
