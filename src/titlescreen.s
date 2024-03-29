.segment "TITLESCREEN"

titlescreen

	sei

	jsr titlescreeninit1

	ldx #$00
:	lda #$08									; black
	sta colormem+(1*$0100),x
	sta colormem+(2*$0100),x
	sta colormem+(3*$0100),x
	lda #$00
	sta bitmap1+7*320,x
	inx
	bne :-

	ldx #$00
:	lda titlescreen1d800+0*256,x
	sta colormem+0*256,x
	lda titlescreen1d800+0*256+24,x
	sta colormem+0*256+24,x
	inx
	bne :-
	
	lda titlescreenpointsprfile
	sta file01+0
	lda titlescreenpointsprfile+1
	sta file01+1
	jsr loadpackd

	lda titlescreenbkgfile
	sta file01+0
	lda titlescreenbkgfile+1
	sta file01+1
	jsr loadpackd

	lda titlescreenhowfar
	sta file01+0
	lda titlescreenhowfar+1
	sta file01+1
	jsr loadpackd

	lda titlescreenhiscore
	sta file01+0
	lda titlescreenhiscore+1
	sta file01+1
	jsr loadpackd

	lda #$0f
	sta colormem+(8*40)+2
	sta colormem+(8*40)+3
	sta colormem+(9*40)+2
	sta colormem+(9*40)+3
	lda #$0b
	sta colormem+(14*40)+32
	sta colormem+(15*40)+31
	sta colormem+(15*40)+32
	sta colormem+(16*40)+31
	sta colormem+(16*40)+32
	sta colormem+(17*40)+31
	sta colormem+(17*40)+32
	lda #$09
	sta colormem+(22*40)+6

	lda #$34
	sta $01
	jsr titlescreenplothiscores
	lda #$37
	sta $01

	lda #$00
	sta easetimer
	;sta starindex
	;sta startimer
	jsr setpage1								; start with 'how far can you'

	lda #<irqtitle
	ldx #>irqtitle
	ldy #$00
	jsr setirqvectors

	cli

waitspacefireloop
	jsr waitinput

	tax
	and #inputTypeMask
	cmp #joyInput								; was it joy input?
	beq checkfire								; yes, check if it was fire

	txa											; no, it was keyboard input
	cmp #keySpace								; check if it was space
	beq startwithoutplayback					; yes, end loop

.if recordplayback
	cmp #keyP									; check if it was 'p'
	beq startwithplayback						; yes, end loop
.endif

	jmp waitspacefireloop

checkfire
	txa
	cmp #joyFire								; yes, it was joy input, check if it was fire
	bne waitspacefireloop
	jmp startwithoutplayback

.if recordplayback
startwithplayback
	lda #$01
	sta playingback
	jmp waitspacefireloopend
.endif

startwithoutplayback
.if recordplayback
	lda #$00
	sta playingback
.endif
	; fallthrough

waitspacefireloopend
	rts

; -----------------------------------------------------------------------------------------------

titlescreeninit1

	lda #$37
	sta $01

:	bit $d011
	bpl :-
:	bit $d011
	bmi :-
	
	lda #$6b
	sta $d011
	
	lda #$00
	sta $d015
	sta $d01b									; sprite priority
	sta $7fff
	sta $bfff

	jsr clearscreen

	ldx #$00
	ldy #$00
	jsr tuneinit

	lda titlescreen1bmpfile
	sta file01+0
	lda titlescreen1bmpfile+1
	sta file01+1
	jsr loadpackd

	lda titlescreen10400file
	sta file01+0
	lda titlescreen10400file+1
	sta file01+1
	jsr loadpackd

	lda titlescreen1d800file
	sta file01+0
	lda titlescreen1d800file+1
	sta file01+1
	jsr loadpackd

	lda titlescreenfont
	sta file01+0
	lda titlescreenfont+1
	sta file01+1
	jsr loadpackd

	ldx #$00
:	sta titlescreenhiscorelinesspr+$0000,x
	sta titlescreenhiscorelinesspr+$0100,x
	sta titlescreenhiscorelinesspr+$0200,x
	sta titlescreenhiscorelinesspr+$0300,x
	sta titlescreenhiscorelinesspr+$0400,x
	sta titlescreenhiscorelinesspr+$0500,x
	inx
	bne :-

	rts

; -----------------------------------------------------------------------------------------------

logotop

	lda bankforaddress(tslogospr)
	sta $dd00
 	lda #$3b
	sta $d011

	lda d018forscreencharset(screenspecial,$0000)
	sta $d018

	lda #$ff
	sta $d01c
	sta $d015
	lda #%10000000
	sta $d010

	lda #$02
	sta $d025
	lda #$0b
	sta $d026

	ldx #$00
	ldy #$00
:	lda #$00
	sta $d027,x
	lda #$1d
	sta $d001,y
	iny
	iny
	inx
	cpx #$08
	bne :-

	lda #(88+0*24)&255
	sta $d000+0*2
	lda #(88+1*24)&255
	sta $d000+1*2
	lda #(88+2*24)&255
	sta $d000+2*2
	lda #(88+3*24)&255
	sta $d000+3*2
	lda #(88+4*24)&255
	sta $d000+4*2
	lda #(88+5*24)&255
	sta $d000+5*2
	lda #(88+6*24)&255
	sta $d000+6*2
	lda #(88+7*24)&255
	sta $d000+7*2

	ldy #$00
	ldx spriteptrforaddress(tslogospr)
:	txa
	sta screenspecial+$03f8+0,y
	inx
	iny
	cpy #$08
	bne :-

	lda #$56									; #$4c
	jsr cycleperfect

	ldx #$00
:	lda sprraster,x
	sta $d025
	ldy #$05
:	dey
	bne :-
	bit $ea
	inx
	cpx #22
	bne :--

	ldx #$18
	stx $d016
	
	lda d018forscreencharset(screen1, bitmap1)	; start of screen below sprite logo, set right regs for bitmap etc.
	sta $d018

	lda bankforaddress(bitmap1)
	sta $dd00

	lda #$00
	sta $d020
	sta $d021

	rts

irqtitle

	pha

	jsr logotop

	inc tsanimframedelay
	lda tsanimframedelay
	cmp #$06
	bne :+

	lda #$00
	sta tsanimframedelay
	inc tsanimframe
	inc tsanimframe
	lda tsanimframe
	cmp #$06
	bne :+
	lda #$00
	sta tsanimframe

:
	jsr setspriteanims
	jsr setspritexoffs

	ldx #0*pointlinespositionsblocksize
	jsr setpointlinespositions

															; prepare first line of sprites
titlescreensequence:
	lda #$00												; 1 = how far can you go, 2 = scores, 0 = hiscores
	beq tspage0
	cmp #$01
	beq tspage1

tspage2
	ldy #((0*6+0)*pointlinesdatablocksize)					; *0 = scores
	jmp tspagecheckend

tspage1
	ldy #((1*6+0)*pointlinesdatablocksize)					; *1 = how far
	jmp tspagecheckend

tspage0
	ldy #((2*6+0)*pointlinesdatablocksize)					; *2 = hiscores
	;jmp tspagecheckend

tspagecheckend
	jsr setpointlinesptrcolors

	lda #<irqtitle2
	ldx #>irqtitle2
	ldy #$68
	jmp endirq

irqtitle2

	pha

	lda #$50
	jsr cycleperfect

	lda d018forscreencharset(screen1,$7000)
	sta $d018
	lda #$1b
	sta $d011
	lda #$08
	sta $d022
	lda #$0a
	sta $d023
	lda #$09
	sta $d021

	jsr waitnextpointline

												; prepare second and rest of sprite lines

	ldx #1*pointlinespositionsblocksize			; careful! x and y get automatically increased by setpointlinespositions and setpointlinesptrcolors

	lda titlescreensequence+1
	beq tspage0_1
	cmp #$01
	beq tspage1_1
	;cmp #$02
	;beq tspage2_1

tspage2_1
	ldy #((0*6+1)*pointlinesdatablocksize)		; *0 = scores
	jmp tspageend_1

tspage1_1
	ldy #((1*6+1)*pointlinesdatablocksize)		; *1 = how far
	jmp tspageend_1

tspage0_1
	ldy #((2*6+1)*pointlinesdatablocksize)		; *2 = hiscores
	;jmp tspageend_1

tspageend_1

	jsr setpointlinespositions
	jsr setpointlinesptrcolors
	jsr waitnextpointline

	jsr setpointlinespositions
	jsr setpointlinesptrcolors
	lda #$06
	sta $d021
	lda #$04
	sta $d022
	lda #$0e
	sta $d023
	jsr waitnextpointline

	jsr setpointlinespositions
	jsr setpointlinesptrcolors
	jsr waitnextpointline

	jsr setpointlinespositions
	jsr setpointlinesptrcolors
	jsr waitnextpointline

	jsr setpointlinespositions
	jsr setpointlinesptrcolors
	lda #$0b
	sta $d021
	lda #$0c
	sta $d022
	lda #$0f
	sta $d023
	jsr waitnextpointline

	lda #$00
	sta $d020
	sta $d021

	jsr titlescreenlowerbordersprites

	ldx spriteptrforaddress(tspressfirespr)
	stx screenspecial+$03f8+1
	inx
	stx screenspecial+$03f8+2
	inx
	stx screenspecial+$03f8+3
	inx
	stx screenspecial+$03f8+4
	inx
	stx screenspecial+$03f8+5
	inx
	stx screenspecial+$03f8+6

	lda #<irqtitle3
	ldx #>irqtitle3
	ldy #$fa
	jmp endirq

titlescreenlowerbordersprites

	ldx #$00
	lda #$fc									; prepare lower border sprites
:	sta $d001+0*2,x
	inx
	inx
	cpx #$10
	bne :-

	ldx spriteptrforaddress(fuelandscoresprites+0*64)
	stx screenspecial+$03f8+0
	ldx spriteptrforaddress(fuelandscoresprites+7*64)
	stx screenspecial+$03f8+7

	lda #$33
	sta $d000
	
	lda #$72+0*24
	sta $d002
	lda #$72+1*24
	sta $d004
	lda #$72+2*24
	sta $d006
	lda #$72+3*24
	sta $d008
	lda #$72+4*24
	sta $d00a
	lda #$72+5*24
	sta $d00c
	
	lda #$27
	sta $d00e

	lda #%10000000
	sta $d010

	lda #$00
	sta $d025
	sta $d026
	sta $d027+0
	sta $d027+1
	sta $d027+2
	sta $d027+3
	sta $d027+4
	sta $d027+5
	sta $d027+6
	sta $d027+7
	rts

titlescreenlowerbordersprites2

	lda #$12									; open border : unset RSEL bit (and #%00110111) + turn on ECM to move ghostbyte to $f9ff
	sta $d011

	lda #$42									; #$4c
	jsr cycleperfect

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bit $ea

	ldx #$34									; open border : unset RSEL bit (and #%00110111) + turn on ECM to move ghostbyte to $f9ff
	ldy #$18									; no multicolour or bitmap, otherwise ghostbyte move won't work
	stx $d011
	sty $d016

	lda d018forscreencharset(screenspecial,$0000)
	sta $d018
	lda bankforaddress(screenspecial)
	sta $dd00

	lda #$0c
	sta $d025
	lda #$01
	sta $d026

	lda #$08
:	cmp $d012
	bne :-

	ldx spriteptrforaddress(fuelandscoresprites+1*64)
	stx screenbordersprites+$03f8+1
	inx
	stx screenbordersprites+$03f8+2

	ldx spriteptrforaddress(fuelandscoresprites+5*64)
	stx screenbordersprites+$03f8+5
	inx
	stx screenbordersprites+$03f8+6

	lda #%11100000
	sta $d010

	lda #$20+0*24
	sta $d000
	lda #$20+1*24
	sta $d002
	lda #$20+2*24
	sta $d004

	lda #$07+0*24+16
	sta $d00a
	lda #$07+1*24+16
	sta $d00c
	lda #$07+2*24+16
	sta $d00e

	jsr tuneplay

	lda #$ff									; put sprites back up so the upper border doesn't draw them again
	sta $d001+0*2
	sta $d001+1*2
	sta $d001+2*2
	sta $d001+3*2
	sta $d001+4*2
	sta $d001+5*2
	sta $d001+6*2
	sta $d001+7*2
	rts

irqtitle3
	pha

	jsr titlescreenlowerbordersprites2

	jsr twinklestars

	inc easetimer
	lda easetimer
	bne :+
	jsr increasepage
:
	lda #<irqtitle
	ldx #>irqtitle
	ldy #$14
	jmp endirq

sprraster
.byte $00,$00,$00,$00,$00,$00,$00,$06,$0e,$03,$06,$06,$04,$06,$04,$04,$0e,$0e,$03,$03,$0d,$01

setpointlinespositions

	lda pointlinespositions,x
	sta $d001+0*2
	sta $d001+1*2
	sta $d001+2*2
	sta $d001+3*2
	sta $d001+4*2
	sta $d001+5*2
	sta $d001+6*2
	sta $d001+7*2
	inx

	clc
	adc #20
	sta waitnextpointline+1

	lda pointlinespositions,x
	sta $d010
	inx

	lda pointlinespositions,x
	sta $d000+0*2
	inx
	lda pointlinespositions,x
	sta $d000+1*2
	inx
	lda pointlinespositions,x
	sta $d000+2*2
	inx
	lda pointlinespositions,x
	sta $d000+3*2
	inx
	lda pointlinespositions,x
	sta $d000+4*2
	inx
	lda pointlinespositions,x
	sta $d000+5*2
	inx
	lda pointlinespositions,x
	sta $d000+6*2
	inx
	lda pointlinespositions,x
	sta $d000+7*2
	inx

	rts

setpointlinesptrcolors

	lda pointlinesdata1,y
	sta screenui+$03f8+0
	iny
	lda pointlinesdata1,y
	sta screenui+$03f8+1
	iny
	lda pointlinesdata1,y
	sta screenui+$03f8+2
	iny
	lda pointlinesdata1,y
	sta screenui+$03f8+3
	iny
	lda pointlinesdata1,y
	sta screenui+$03f8+4
	iny
	lda pointlinesdata1,y
	sta screenui+$03f8+5
	iny
	lda pointlinesdata1,y
	sta screenui+$03f8+6
	iny
	lda pointlinesdata1,y
	sta screenui+$03f8+7
	iny

	lda pointlinesdata1,y
	sta $d025
	iny
	lda pointlinesdata1,y
	sta $d026
	iny
	lda pointlinesdata1,y
	sta $d027+0
	iny
	lda pointlinesdata1,y
	sta $d027+1
	iny
	lda pointlinesdata1,y
	sta $d027+2
	sta $d027+3
	sta $d027+4
	sta $d027+5
	sta $d027+6
	sta $d027+7
	iny

	rts

waitnextpointline

	lda #$00
:	cmp $d012
	bne :-

	rts

setspriteanims

	ldx tsanimframe

	clc
	txa
	adc pointlineanims+0
	sta pointlinesdata1+(0*pointlinesdatablocksize)+1
	adc #$01
	sta pointlinesdata1+(0*pointlinesdatablocksize)+0

	txa
	adc pointlineanims+1
	sta pointlinesdata1+(1*pointlinesdatablocksize)+1
	adc #$01
	sta pointlinesdata1+(1*pointlinesdatablocksize)+0

	txa
	adc pointlineanims+2
	sta pointlinesdata1+(2*pointlinesdatablocksize)+1
	adc #$01
	sta pointlinesdata1+(2*pointlinesdatablocksize)+0

	txa
	adc pointlineanims+3
	sta pointlinesdata1+(3*pointlinesdatablocksize)+1
	adc #$01
	sta pointlinesdata1+(3*pointlinesdatablocksize)+0

	txa
	adc pointlineanims+4
	sta pointlinesdata1+(4*pointlinesdatablocksize)+1
	adc #$01
	sta pointlinesdata1+(4*pointlinesdatablocksize)+0

	txa
	adc pointlineanims+5
	sta pointlinesdata1+(5*pointlinesdatablocksize)+1
	adc #$01
	sta pointlinesdata1+(5*pointlinesdatablocksize)+0

	rts

setspritexoffs

	ldx #$00										; sprite row 0-5

	ldy easetimer
:	lda easetablo,y
	sta spriterowxstartlo,x
	lda easetabhi,y
	sta spriterowxstarthi,x
	dey
	dey
	dey
	inx
	cpx #$06
	bne :-

	ldx #$00

spriterowloop

	lda tsro1lo,x
	sta tso0+1
	lda tsro1hi,x
	sta tso0+2

	clc
	lda tsplposlo,x
	adc #$01
	sta tso11+1
	sta tso13+1
	adc #$01
	sta tso12+1
	lda tsplposhi,x
	sta tso11+2
	sta tso12+2
	sta tso13+2

	ldy #$00										; sprite 0-7

	lda #$00
tso11
	sta pointlinespositions+1

	clc
:	lda spriterowxstartlo,x
tso0
	adc spriterowoffs0,y
tso12
	sta pointlinespositions+2,y
	lda spriterowxstarthi,x
	adc #$00
	and #$01
	lsr
tso13
	ror pointlinespositions+1
	iny
	cpy #$08
	bne :-

	inx
	cpx #$06
	bne spriterowloop

	rts

increasepage
	; copy x offsets for this page
	lda titlescreensequence+1
	cmp #$00
	beq setpage1
	cmp #$01
	beq setpage2
	; if 2 fall through, so we're back at 0

setpage0								; hiscores
	lda #$00
	sta titlescreensequence+1
	ldx #$00
:	lda spriterowoffs3,x
	sta spriterowoffs0,x
	inx
	cpx #6*8
	bne :-
	jmp setpageend

setpage1								; how far can you
	lda #$01
	sta titlescreensequence+1
	ldx #$00
:	lda spriterowoffs2,x
	sta spriterowoffs0,x
	inx
	cpx #6*8
	bne :-
	jmp setpageend

setpage2								; scores
	lda #$02
	sta titlescreensequence+1
	ldx #$00
:	lda spriterowoffs1,x
	sta spriterowoffs0,x
	inx
	cpx #6*8
	bne :-

setpageend
	rts

; -----------------------------------------------------------------------------------------------

.segment "TWINKLESTARS"

twinklestars
	inc startimer
	lda startimer
	cmp #$40
	bne :+

	ldx #$00
	jsr plottitlestar
	ldx #$01
	jsr plottitlestar
	ldx #$02
	jsr plottitlestar

	clc
	lda starindex
	adc #$30
	sta starindex

:	rts

plottitlestar

	clc
	lda staroffsetlo,x
	sta ptss1+1
	sta ptss2+1
	adc #$30
	sta ptss3+1
	sta ptss4+1
	lda staroffsethi,x
	sta ptss1+2
	sta ptss2+2
	adc #$00
	sta ptss3+2
	sta ptss4+2

:	lda #$00
	sta startimer
	ldx starindex
ptss1
	lda screen1+8*40,x
	cmp #$19
	bne :+
	lda #$01
ptss2
	sta screen1+8*40,x
:
ptss3
	lda screen1+8*40+$0030,x
	cmp #$01
	bne :+
	lda #$19
ptss4
	sta screen1+8*40+$0030,x

:	rts

starindex
	.byte $00

startimer
	.byte $00

staroffsetlo
	.byte <(screen1+8*40), <(screen1+12*40+15), <(screen1+16*40+30)

staroffsethi
	.byte >(screen1+8*40), >(screen1+12*40+15), >(screen1+16*40+30)

; -----------------------------------------------------------------------------------------------
