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
	
	sta foo3+1
	
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

; -----------------------------------------------------------------------------------------------

calcspritepostospritepos

	lda #$00
	sta calcsprhit

	ldx #$00
cssloop
	lda sortsprylow,x
	cmp #$ff
	beq dontintersect

	cmp calcylowmax
	bcs dontintersect

	clc
	lda sortsprylow,x
	adc sortsprheight,x
	sec
	cmp calcylow
	bcc dontintersect

	sec
	lda sortsprxlow,x
	sbc calcxlowmax
	lda sortsprxhigh,x
	sbc calcxhighmax
	bcs dontintersect

	clc
	lda sortsprxlow,x
	adc sortsprwidth,x
	sta sortsprxlowmax,x
	lda sortsprxhigh,x
	adc #$00
	sta sortsprxhighmax,x

	sec
	lda sortsprxlowmax,x
	sbc calcxlow
	lda sortsprxhighmax,x
	sbc calcxhigh
	bcc dontintersect

	lda sortsprtype,x
	cmp #$03
	bne :+
	lda #$02
	sta calcsprhit
	jmp dontintersect
:	lda #$01
	sta calcsprhit
	lda #$ff
	sta sortsprylow,x
	jsr updateflyingscore

dontintersect	
	inx
	cpx #MAXMULTPLEXSPR
	bne cssloop
	
	rts

; -----------------------------------------------------------------------------------------------	

calcshippostospritepos

	lda #$00
	sta calcsprhit

	ldx #$00
cssloop2
	lda sortsprylow,x
	cmp #$ff
	beq dontintersect2

	cmp calcylowmax
	bcs dontintersect2
	
	clc
	lda sortsprylow,x
	adc sortsprheight,x
	sec
	cmp calcylow
	bcc dontintersect2
	
	sec
	lda sortsprxlow,x
	sbc calcxlowmax
	lda sortsprxhigh,x
	sbc calcxhighmax
	bcs dontintersect2
	
	clc
	lda sortsprxlow,x
	adc sortsprwidth,x
	sta sortsprxlowmax,x
	lda sortsprxhigh,x
	adc #$00
	sta sortsprxhighmax,x

	sec
	lda sortsprxlowmax,x
	sbc calcxlow
	lda sortsprxhighmax,x
	sbc calcxhigh
	bcc dontintersect2

	lda sortsprtype,x
	cmp #$03
	bne :+
	lda #$02
	sta calcsprhit
	jmp dontintersect2
:	lda #$01
	sta calcsprhit

dontintersect2
	inx
	cpx #MAXMULTPLEXSPR
	bne cssloop2
	
	rts

; -----------------------------------------------------------------------------------------------	

calcspritepostoscreenpos

	clc											; add inverse vsp position
	lda calcxlow
	adc invscreenposlow
	sta calcxlow
	lda calcxhigh
	adc invscreenposhigh
	sta calcxhigh

	lsr calcxhigh								; divide xpos by 8 to get column
	ror calcxlow
	lsr calcxhigh
	ror calcxlow
	lsr calcxhigh
	ror calcxlow

	lda #$00
	sta flipflop

	lda calcxlow
	cmp #$28
	bmi :+

	lda #$01
	sta flipflop

	sec
	lda calcxlow
	sbc #$28
	sta calcxlow

:	lsr calcylow								; divide ypos by 8 to get row
	lsr calcylow
	lsr calcylow

	clc
	ldx calcylow
	lda times40lowtable,x
	sta csptsp0+1
	lda times40hightable,x
	sta csptsp0+2

	clc
	lda csptsp0+1
	adc calcxlow
	sta csptsp0+1
	lda csptsp0+2
	adc #>screenspecial
	sta csptsp0+2

csptsp0	lda $c001
	sta calchit
	cmp #$ff
	beq csend

	lda #$00
	sta calcspryoffset

	lda calchit										; find top left position of object hit
	and #%00000001
	beq :+
	dec calcxlow

:	lda calchit
	and #%00000010
	beq :+
	dec calcylow
	lda #$08
	sta calcspryoffset
:	
	lda clearbmptile
	sta calcbkghit

csbkghit

	lda calcylow								; calculate vsp'ed position of hit tile
	sta calcylowvsped
	lda flipflop
	bne :+
	dec calcylowvsped

:	jsr updategroundscore

csend
	rts

; -----------------------------------------------------------------------------------------------	

calcshippostoscreenpos

	clc											; add inverse vsp position
	lda calcxlow
	adc invscreenposlow
	sta calcxlow
	lda calcxhigh
	adc invscreenposhigh
	sta calcxhigh

	lsr calcxhigh								; divide xpos by 8 to get column
	ror calcxlow
	lsr calcxhigh
	ror calcxlow
	lsr calcxhigh
	ror calcxlow

	lda #$00
	sta flipflop

	lda calcxlow
	cmp #$28
	bmi :+

	lda #$01
	sta flipflop

	sec
	lda calcxlow
	sbc #$28
	sta calcxlow

:	lsr calcylow								; divide ypos by 8 to get row
	lsr calcylow
	lsr calcylow

	clc
	ldx calcylow
	lda times40lowtable,x
	sta csptsp1+1
	lda times40hightable,x
	sta csptsp1+2

	clc
	lda csptsp1+1
	adc calcxlow
	sta csptsp1+1
	lda csptsp1+2
	adc #>screenspecial
	sta csptsp1+2

csptsp1
	lda screenspecial+1
	sta calchit

	rts

; -----------------------------------------------------------------------------------------------	

inithandlecollisions

	lda #$00
	sta shiptested
	sta bullet0tested
	sta bullet1tested
	sta bomb0tested
	sta bomb1tested
	sta handlezonetested
	sta collisionshandled

	rts

handlerestcollisions

	lda collisionshandled
	cmp #$07
	bcs :+
	
	jsr handlecollisions
	inc collisionshandled
	jmp handlerestcollisions

:	rts

handlecollisions

	lda handlezonetested
	bne :+
	lda #$01
	sta handlezonetested

handlezonecode
	jsr handlezone1								; self modified jsr
	jmp hcend

:	lda bullet0tested
	bne :+
	lda #$01
	sta bullet0tested
	inc collisionshandled
	lda shootingbullet0
	beq :+
	lda bull0+sprdata::isexploding
	cmp #explosiontypes::none
	bne :+
	jsr testbullet0bkgcollision
	jsr testbullet0sprcollision
	jmp hcend
	
:	lda bullet1tested
	bne :+
	lda #$01
	sta bullet1tested
	inc collisionshandled
	lda shootingbullet1
	beq :+
	lda bull1+sprdata::isexploding
	cmp #explosiontypes::none
	bne :+
	jsr testbullet1bkgcollision
	jsr testbullet1sprcollision
	jmp hcend

:	lda bomb0tested
	bne :+
	lda #$01
	sta bomb0tested
	inc collisionshandled
	lda shootingbomb0
	beq :+
	lda bomb0+sprdata::isexploding
	cmp #explosiontypes::none
	bne :+
	jsr testbomb0bkgcollision
	jsr testbomb0sprcollision
	jmp hcend

:	lda bomb1tested
	bne :+
	lda #$01
	sta bomb1tested
	inc collisionshandled
	lda shootingbomb1
	beq :+
	lda bomb1+sprdata::isexploding
	cmp #explosiontypes::none
	bne :+
	jsr testbomb1bkgcollision
	jsr testbomb1sprcollision

:	lda shiptested
	bne :+
	lda #$01
	sta shiptested
	inc collisionshandled
	lda hascontrol
	bne :+
	lda ship0+sprdata::isexploding
	cmp #explosiontypes::none
	bne :+
.if shipbkgcollision
	jsr testshipbkgcollision
.endif
.if shipsprcollision
	jsr testshipsprcollision
.endif
:
hcend
	
	rts

; -----------------------------------------------------------------------------------------------

handlezone1										; missiles	
	jsr launchmissile
	jsr animmissiles
	jmp handlemissilemovement

handlezone2										; ufos
	jsr launchufo
	jsr animufos
	jmp handleufomovement

handlezone3										; comets
	jsr launchcomet
	jsr animcomets
	jmp handlecometmovement

handlezone4										; missiles
	jsr launchmissile
	jsr animmissiles
	jmp handlemissilemovement

handlezone5										; avoid fuel
	lda gamefinished
	cmp #$01
	bpl :++										; if 1 or higher!

	clc
	lda subzone
	cmp #$43
	bpl :+
	lda #$00
	sta ingamebkgcolor+1
	jmp handlezone5rest

:	inc bkgpulsetimer
	lda bkgpulsetimer
	lsr
	and #$0f
	tax
	lda bkgpulsecolors,x
	sta ingamebkgcolor+1
	jmp handlezone5rest
	
:	lda #$00
	sta ingamebkgcolor+1
	inc gamefinished
	lda gamefinished
	cmp #$30
	beq handlegamefinished
	jmp handlezone5rest
	
handlegamefinished
	lda flags
	cmp #$09
	beq :+
	inc flags
:	lda #states::congratulations
	sta state+1
	rts

handlezone5rest
	jsr animmissiles
	jmp handlemissilemovement
	
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
    