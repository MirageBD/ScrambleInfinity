.segment "INGAME"

ingame1

	jsr inithandlecollisions
	
handlezoneptr3
	jsr plotdummymultsprites

	ldy sortorder
	lda sortsprc,y
	sta $d02d
	ldy sortorder+1
	lda sortsprc,y
	sta $d02e

	debugrasterstart #$06
handlezoneptr4
	jsr plotrestmissilemultsprites
	debugrasterend

	debugrasterstart #$07
	lda $01
	pha
	lda #$34
	sta $01
	jsr plottiles
	pla
	sta $01
	debugrasterend

	rts

; -----------------------------------------------------------------------------------------------

ingame2

	debugrasterstart #$0b
	jsr scrollscreen

.if enabledebugkeys
	lda #keyQ
	jsr checkdebugkey
	bne :+
	jmp quickdie
:
.endif

	jsr handlejoystick							; 03
	jsr calcvsp
	jsr animship								; 04
	jsr animbullet0								; 05
	jsr animbullet1								; 06
	debugrasterend
	
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

	lda #$07+0*24+16
	sta $d00a
	lda #$07+1*24+16
	sta $d00c
	lda #$07+2*24+16
	sta $d00e
	
scoreishiscoresprptr
	ldx spriteptrforaddress(fuelandscoresprites+5*64) 				; +0*64 = show score as hiscore, +5*64 = show real hiscore sprites
	stx screenbordersprites+$03f8+5
	inx
	stx screenbordersprites+$03f8+6

	debugrasterstart #$0a
	jsr animbomb0								; 07
	debugrasterstart #$04
	jsr testhiscorebeaten
	debugrasterstart #$02

	lda scrollspeed								; we died, scrollspeed is 0
	beq wedied

	lda $01
	pha
	lda #$34
	sta $01
	breakpoint breakhere
	jsr plottiles
	jsr plottiles
	jsr plotdone
	jsr checkflip
	pla
	sta $01
	debugrasterend
	
	jsr drawstars

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

quickdie
	lda #gameflow::titlescreen
	sta gameflowstate+1
	jmp wediedend
	
:	lda #gameflow::livesleftscreen
	sta gameflowstate+1
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
	
	debugrasterstart #$07
	jsr tuneplay								; 01
	jsr animbomb1								; 08
	jsr removescheduledobject					; 02	; if no object is scheduled for removal then the score is plotted and fuel updated
	jsr sortmultsprites							; 0b

handlezoneptr2
	jsr plotfirstmissilemultsprites				; 0c
	debugrasterend

	lda #$1d									; was 1d
:	cmp $d012
	bcs :-

	debugrasterstart #$04

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
	debugrasterend

	lda #$2a									; was 2a
:	cmp $d012
	bcs :-
		
	debugrasterstart #$05
	jsr updatespritepositions2
	jsr correctvspsprites
	debugrasterend

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

; -----------------------------------------------------------------------------------------------
