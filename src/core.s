.segment "INITIATEBITMAPSCORES"

initiatebitmapscores
	sei
	lda #$35
	sta $01

	; plot score
	ldy score+0
	lda #<scoredigit0
	ldx #>scoredigit0
	jsr plotdigitcompact
	ldy score+1
	lda #<scoredigit1
	ldx #>scoredigit1
	jsr plotdigitcompact
	ldy score+2
	lda #<scoredigit2
	ldx #>scoredigit2
	jsr plotdigitcompact
	ldy score+3
	lda #<scoredigit3
	ldx #>scoredigit3
	jsr plotdigitcompact
	ldy score+4
	lda #<scoredigit4
	ldx #>scoredigit4
	jsr plotdigitcompact
	ldy score+5
	lda #<scoredigit5
	ldx #>scoredigit5
	jsr plotdigitcompact

	; plot hiscore
	ldy hiscore+0
	lda #<hiscoredigit0
	ldx #>hiscoredigit0
	jsr plotdigitcompact
	ldy hiscore+1
	lda #<hiscoredigit1
	ldx #>hiscoredigit1
	jsr plotdigitcompact
	ldy hiscore+2
	lda #<hiscoredigit2
	ldx #>hiscoredigit2
	jsr plotdigitcompact
	ldy hiscore+3
	lda #<hiscoredigit3
	ldx #>hiscoredigit3
	jsr plotdigitcompact
	ldy hiscore+4
	lda #<hiscoredigit4
	ldx #>hiscoredigit4
	jsr plotdigitcompact
	ldy hiscore+5
	lda #<hiscoredigit5
	ldx #>hiscoredigit5
	jsr plotdigitcompact

	; plot lives left
	ldy lives
	lda #<livesdigit0
	ldx #>livesdigit0
	jsr plotdigitcompact

	; plot times game finished (flags)
	ldy timesgamefinished
	lda #<flagsdigit0
	ldx #>flagsdigit0
	jsr plotdigitcompact
	
	lda #$37
	sta $01
	cli
	rts

plotdigitcompact
	sta zp0
	stx zp1
	ldx times8lowtable,y

	ldy #$00
:	lda fontdigits,x
	sta (zp0),y
	inx
	iny
	iny
	iny
	cpy #18
	bne :-
	rts

.segment "STARTINGAME"

startingame

	sei

	lda #$7b
	sta $d011

	lda #$00
	sta $d015
	sta $d020
	sta $d021
	sta $d418

	lda #$34
	sta $01
	copymemblocks sprites2, sprites1, $0d00
	lda #$37
	sta $01

	lda #<irqlimbo								; set limbo irq so it doesn't mess with $d011/$d018/$dd00 causing all kinds of glitches
	ldx #>irqlimbo
	ldy #$00
	sta $fffe
	sta $0314
	stx $ffff
	stx $0315
	sty $d012

	lda $dc0d
	lda $dd0d
	dec $d019

	cli

	ldx #$00									; set score to zero
	lda #$00
:	sta score,x
	sta prevscore,x
	sta hiscore,x
	inx
	cpx #$06
	bne :-

	lda startlives
	sta lives
	lda #$00
	sta timesgamefinished

	rts

; -----------------------------------------------------------------------------------------------

.segment "LOADSUBZONE"

loadsubzone
	jsr loadpackd

	bcc :+
	jmp error

:	rts

error
	sta $0800
	inc $d021
	jmp error
	

; -----------------------------------------------------------------------------------------------

.segment "SETZONE0"

setzone0
	
	;lda #$00
	sta ship0+sprdata::xhigh
	sta ship0+sprdata::xlow
		
	lda #$ff
	sta $7fff
	sta $bfff
	
	lda startzone								; #$00, #$01, #$02, #$03, #$04, #$05
	sta zone
	asl
	asl
	asl
	asl
	ora #$01									; #$01, #$11, #$21, #$31, #$41, #$51
	sta subzone
	
	rts

setupfilename	
	
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
	tay
	lda filenameconvtab,y
	sta file01+0
	
	rts

.segment "SETUPLEVEL"

setuplevel

	sei

	lda #$37
	sta $01

	ldx #$00
	ldy #$00
	jsr tuneinit

	lda #$74
	sta $d011

	lda #$17
	sta $d016
	
	lda d018forscreencharset(screen2,bitmap2)
	sta $d018
	
	ldy bankforaddress(bitmap2)
	sty $dd00

	ldx #$10
	stx screen1+$03f8+0
	stx screen2+$03f8+0
	inx
	stx screen1+$03f8+1
	stx screen2+$03f8+1

	jsr findstartofzone
		
	jsr setupfilename							; stores 0 in x, 0 in y
	jsr loadpackd

	;bcc :+
	;jmp error

;:
	inc file									; file = 1
	jsr setupfilename
	jsr loadpackd

	;bcc :+
	;jmp error

;:
	jsr incpag2									; set up pointers for initial tile plot
	inc file									; file = 2
	lda #$00
	sta row
	sta column
	sta flip
	sta ps1+1
	sta ps2+1

	lda #$34
	sta $01

ps1	lda #$00									; plot initial screens
	cmp #$01
	bne :+
ps2	lda #$00
	cmp #$40
	bne :+
	jmp plotinitialscreendone
:	jsr plottiles
	inc ps2+1
	lda ps2+1
	cmp #$00
	bne ps1
	inc ps1+1
	jmp ps1

plotinitialscreendone

	inc file
	inc subzone
	lda file
	cmp #$02
	beq :+
	jmp setupleveldone

:	ldx #$00									; clear temporary tiles from screen - only need to do this for first subzone?
	lda clearbmptile
:	sta bitmap1,x
	sta bitmap1+64,x
	inx
	bne :-
	
	ldx #$00
:	lda #$66
	sta screen1,x
	lda #$20
	sta screenspecial,x
	inx
	cpx #$28
	bne :-

	lda #$20									; empty tiles used for index ordering
	.repeat 34, i
	sta loadeddata2+i*50+0
	.endrepeat

setupleveldone
	lda #$37
	sta $01

	jsr setupfilename							; we've loaded and set up 2 subzones, now pre-emptively load subzone 3
	jsr loadpackd

	jsr calculatezonefromsubzone				; and calculate the zone from the subzone (can subtract 3 now)
	
	;bcc :+
	;jmp error

;:
	lda #playerstates::flyingintomission
	sta playerstate

	jsr initmultsprites

	lda fuelfull
	sta fuel

	lda #$00
	sta ufonum
	sta cometnum
	sta timeseconds
	lda #$01
	sta timeseconds
	
	lda #$01
	sta scrollspeed
	lda #$00
	sta diedframes
	sta diedframeclearframes

	ldx #>(bitmapwidth-1)
	ldy #<(bitmapwidth-1)
	stx screenposhigh
	sty screenposlow

	ldx #$00
	lda #$ff
:	sta sortsprylow,x
	inx
	cpx #MAXMULTPLEXSPR
	bne :-

	; ---------------------------------------------------------

	lda zonecolour1								; SET ZONE COLOURS!!! THIS GETS CALLED ONLY WHEN WE ENTER THE GAME OR HAVE DIED
	ldx #$ff
:	sta zonecolours+1,x
	inx
	cpx zone									; zone = $00,$01,$02,$03,$04,$05
	bne :-

	lda zonecolour0
:	sta zonecolours+1,x
	inx
	cpx #$06
	bne :-

	; ---------------------------------------------------------

	lda #$01
	sta bulletcooloff
	sta bombcooloff
	
	lda #$00
	sta gamefinished
	
	ldy #$74
	sty $d011

	lda #<irqingamef8
	ldx #>irqingamef8
	ldy #$f8
	jsr setirqvectors

	cli

	rts
	
; -----------------------------------------------------------------------------------------------
