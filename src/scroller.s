.segment "SCROLLER"

plottiles

	ldy #$03

plotloop
	clc
gett1
	lda loadeddata1+0*2
	sta currenttile+0
	sta currenttiletimes8+0
	;adc #$00
	sta plotc1+1
gett2
	lda loadeddata1+1+0*2
	sta currenttile+1
	sta currenttiletimes8+1
	adc #>maptilecolors
	sta plotc1+2
	
	lda currenttile+1							; > 256 = always solid tile
	;cmp #$00
	bne solidtile
	
	lda currenttile+0
	;cmp #$00
	bmi solidtile								; < 0 = solid tile
	cmp #firstsolidtile
	bpl solidtile								; > 67 = solid tile
	
	lda currenttile+0
	cmp #firsttransparenttile
	bpl transtile								; > 32 && < 68 = transparent tile

missilefuelspecialtile
	lda currenttile+0
	and #%00011111
	sta currenttile+0
	jmp skipspecialtiles
	
transtile
	lda #$20
	sta currenttile+0
	jmp skipspecialtiles

solidtile
	lda #$ff
	sta currenttile+0
	jmp skipspecialtiles

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
	
	dey
	beq plotdone
	
	jmp plotloop

plotdone
	lda row
	cmp #$18
	bne incrow2
	
	jmp inccol

incrow2
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
	lda gett2+1									; do missile stuff
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
	add16bit gett2, 2							; end of do missile stuff

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
	
	jsr incsubzone
	jsr loadsubzone

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

.include "subzones.s"

; -----------------------------------------------------------------------------------------------

scrollspeed
.byte $01
diedframes
.byte $00
diedframeclearframes
.byte $00

scrollscreen

	sec
	lda screenposlow
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

.include "plot.s"
.include "collision.s"

	jmp handlezonecode

.include "zones.s"

; -----------------------------------------------------------------------------------------------

normalgameplay

	jsr inithandlecollisions
	
handlezonecode3
	jsr plotdummymultsprites

	ldy sortorder
	lda sortsprc,y
	sta $d02d
	ldy sortorder+1
	lda sortsprc,y
	sta $d02e

handlezonecode4
	jsr plotrestmissilemultsprites

shiphitdebug

	rts

; -----------------------------------------------------------------------------------------------

normalgameplay2

	jsr scrollscreen
	jsr joyrout									; 03
	jsr calcvsp
	jsr animship								; 04
	jsr animbullet0								; 05
	jsr animbullet1								; 06
	jsr animbomb0								; 07
	
	lda #$04
:	cmp $d012
	bpl :-
	
	lda #%11110000
	sta $d010
	
	lda #$20+0*24
	sta $d000
	lda #$20+1*24
	sta $d002
	lda #$20+2*24
	sta $d004
	lda #$20+3*24
	sta $d006

	lda #$07+0*24
	sta $d00a
	lda #$07+1*24
	sta $d00c
	lda #$07+2*24
	sta $d00e
	
	lda scrollspeed								; we died, scrollspeed is 0
	beq wedied

	lda $01
	pha
	lda #$34
	sta $01
	
	jsr plottiles
	
	pla
	sta $01
	
	jmp stillalive

wedied

	inc diedframes								; goes up to #$40

	lda diedframes								; has enough time past to continue game?
	cmp #$80
	bne wediedclearframe

.if livesdecrease
	dec lives
.endif
	lda lives
	bne :+

	lda #states::titlescreen
	sta state+1
	jmp wediedend
	
:	lda #states::livesleftscreen
	sta state+1
	jmp wediedend

wediedclearframe

.if diedfade
	cmp #$18
	bmi wediedend

	lda diedframeclearframes
	cmp #24
	bne :+
	jmp wediedend

:
	lsr invscreenposhigh						; divide xpos by 8 to get current vsp column
	ror invscreenposlow
	lsr invscreenposhigh
	ror invscreenposlow
	lsr invscreenposhigh
	ror invscreenposlow							; current column

	clc
	ldx diedframeclearframes
	lda times40lowtable,x
	adc invscreenposlow
	sta diedclearlinelow
	lda times40hightable,x
	adc #$00
	sta diedclearlinehigh

	clc
	lda #<screen1
	adc diedclearlinelow
	sta sf1+1
	lda #>screen1
	adc diedclearlinehigh
	sta sf1+2

	clc
	lda #<screen2
	adc diedclearlinelow
	sta sf2+1
	lda #>screen2
	adc diedclearlinehigh
	sta sf2+2

	clc
	lda #<$d800
	adc diedclearlinelow
	sta sf3+1
	lda #>$d800
	adc diedclearlinehigh
	sta sf3+2

clearline
	lda #$00
	ldx #$00
:
sf1	sta screen1,x
sf2	sta screen2,x
sf3	sta $d800,x
	inx
	cpx #$28
	bne :-

	inc diedframeclearframes

.endif

wediedend

	lda #$20
:	cmp $d012
	bne :-

stillalive	
	;lda #$00
	;sta $d020
	; we are below the bottom border sprites - set up the top border sprites now
	
	.repeat 6,i
	lda #$16									; was 16
	sta $d001+i*2
	lda spriteptrforaddress(livesandzonesprites+i*64)
	sta screenbordersprites+$03f8+i
	.endrepeat
	
	lda #$09
	sta $d027+0
	sta $d027+1
	lda #$06
	sta $d027+2
	sta $d027+3
	sta $d027+4
	sta $d027+5

	lda #$20+0*24								; UI ship
	sta $d000
	lda #$20+1*24								; x
	sta $d002

	lda #$00+0*24								; empty
	sta $d004
	lda #$00+1*24								; empty
	sta $d006

	lda #$1c+0*24								; UI flag
	sta $d008
	lda #$1c+1*24								; x
	sta $d00a

	lda #%00111100
	sta $d010
	
	lda spriteptrforaddress(emptysprite)		; empty sprites for missiles in top border
	sta screenbordersprites+$03f8+6
	sta screenbordersprites+$03f8+7

	lda #$0c
	sta $d025
	lda #$01
	sta $d026
	
	jsr tuneplay								; 01
	jsr animbomb1								; 08
	jsr removescheduledobject					; 02

	jsr sortmultsprites							; 0b
	
handlezonecode2
	jsr plotfirstmissilemultsprites				; 0c

	lda #$1d									; was 1d
:	cmp $d012
	bcs :-

	lda #$48									; #$4c
	jsr cycleperfect

	lda #$00									; top of zone blocks
	sta $d010

	.repeat 6,i									; sprite colours for zone blocks
	lda zonecolours+i
	sta $d027+i
	lda #$74+i*24
	sta $d000+i*2
	.endrepeat

	jsr updatespritepositions1					; 0a

	lda #$2a									; was 2a
:	cmp $d012
	bcs :-
		
	jsr updatespritepositions2
	jsr correctvspsprites

	lda #$00
	sta $d025	
	lda #$09
	sta $d026
	
	lda #$02
	sta $d02d
	lda #$0f
	sta $d02c
	sta $d02e

	lda #$ff
	sta $d01b									; sprite priority

scrlow
	lda #$18
	sta $d016

	rts
    