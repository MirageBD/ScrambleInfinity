.segment "TITLESCREEN"

titlescreen

	sei
	
	lda #$37
	sta $01

	lda #$7b
	sta $d011

	jsr clearscreen

	ldx #$00
	ldy #$00
	jsr tuneinit

	ldx #$00
	stx $d01b									; sprite priority
	stx $7fff
	stx $bfff
	stx $d012
	inx
	stx $d01a

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

	ldx #$00
:	lda #$08									; black
	sta colormem+(1*$0100),x
	sta colormem+(2*$0100),x
	sta colormem+(3*$0100),x
	lda #$00
	sta bitmap1+7*320,x
	inx
	bne :-

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

	ldx #$00
:	lda titlescreen1d800+0*256,x
	sta colormem+0*256,x
	lda titlescreen1d800+0*256+24,x
	sta colormem+0*256+24,x
	inx
	bne :-

	lda #$00
	sta easetimer
	jsr setpage1								; start with 'how far can you'

	lda #<irqtitle
	ldx #>irqtitle
	sta $fffe
	sta $0314
	stx $ffff
	stx $0315

	lda $dc0d
	lda $dd0d
	dec $d019
	cli
	
	jsr waitkey

	jmp ingamefresh

; -----------------------------------------------------------------------------------------------

irqtitle

	pha

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

hatseflatsikweetgeennamenmeer:
	lda #$01
	beq :+
	ldy #((1*6+0)*pointlinesdatablocksize)
	jmp :++
:	ldy #((0*6+0)*pointlinesdatablocksize)
:	jsr setpointlinesptrcolors

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

	ldx #1*pointlinespositionsblocksize			; careful! x and y get automatically increased by setpointlinespositions and setpointlinesptrcolors

	lda hatseflatsikweetgeennamenmeer+1
	beq :+
	ldy #((1*6+1)*pointlinesdatablocksize)
	jmp :++
:	ldy #((0*6+1)*pointlinesdatablocksize)

:	jsr setpointlinespositions
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

	ldx #$00
	lda #$f8									; prepare lower border sprites
:	sta $d001+0*2,x
	inx
	inx
	cpx #$10
	bne :-

	ldx spriteptrforaddress(tspressfirespr)
	stx screenui2+$03f8+0
	inx
	stx screenui2+$03f8+1
	inx
	stx screenui2+$03f8+2
	inx
	stx screenui2+$03f8+3
	inx
	stx screenui2+$03f8+4
	inx
	stx screenui2+$03f8+5

	lda #(112+0*24)&255
	sta $d000+0*2
	lda #(112+1*24)&255
	sta $d000+1*2
	lda #(112+2*24)&255
	sta $d000+2*2
	lda #(112+3*24)&255
	sta $d000+3*2
	lda #(112+4*24)&255
	sta $d000+4*2
	lda #(112+5*24)&255
	sta $d000+5*2
	lda #$00
	sta $d000+6*2
	sta $d000+7*2

	lda #$00000000
	sta $d010

	lda #$0b
	sta $d025
	sta $d026
	ldx #$00
:	sta $d027,x
	inx
	cpx #$08
	bne :-

	lda #<irqtitle3
	ldx #>irqtitle3
	ldy #$f8
	jmp endirq

irqtitle3
	pha

	lda #$12									; open border : unset RSEL bit (and #%00110111) + turn on ECM to move ghostbyte to $f9ff
	sta $d011

	lda #$52									; #$4c
	jsr cycleperfect

	lda #$0b
	sta $d020
	sta $d021

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

	lda d018forscreencharset(screenui2,$0000)
	sta $d018
	lda bankforaddress(screenui2)
	sta $dd00

	lda #$01
	sta $d025
	lda #$00
	sta $d026
	lda #$0c
	sta $d027+0
	sta $d027+1
	sta $d027+2
	sta $d027+3
	sta $d027+4
	sta $d027+5
	sta $d027+6
	sta $d027+7

	clc
	lda $d001+0*2
	adc #21
	sta $d001+0*2
	sta $d001+1*2
	sta $d001+2*2
	sta $d001+3*2
	sta $d001+4*2
	sta $d001+5*2
	sta $d001+6*2
	sta $d001+7*2

	lda #$0b
:	cmp $d012
	bne :-

	lda #$48									; #$4c
	jsr cycleperfect

	ldx spriteptrforaddress(tspressfirespr+6*64)
	stx screenui2+$03f8+0
	inx
	stx screenui2+$03f8+1
	inx
	stx screenui2+$03f8+2
	inx
	stx screenui2+$03f8+3
	inx
	stx screenui2+$03f8+4
	inx
	stx screenui2+$03f8+5

	lda #$ff									; put sprites back up so the upper border doesn't draw them again
	sta $d001+0*2
	sta $d001+1*2
	sta $d001+2*2
	sta $d001+3*2
	sta $d001+4*2
	sta $d001+5*2
	sta $d001+6*2
	sta $d001+7*2

	jsr tuneplay

	inc easetimer
	lda easetimer
	bne :+
	jsr flippage
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
	iny
	lda pointlinesdata1,y
	sta $d027+3
	iny
	lda pointlinesdata1,y
	sta $d027+4
	iny
	lda pointlinesdata1,y
	sta $d027+5
	iny
	lda pointlinesdata1,y
	sta $d027+6
	iny
	lda pointlinesdata1,y
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

flippage
	; copy x offsets for this page
	lda hatseflatsikweetgeennamenmeer+1
	beq setpage1
setpage0
	lda #$00
	sta hatseflatsikweetgeennamenmeer+1
	ldx #$00
:	lda spriterowoffs1,x
	sta spriterowoffs0,x
	inx
	cpx #6*8
	bne :-
	jmp setpageend
setpage1
	lda #$01
	sta hatseflatsikweetgeennamenmeer+1
	ldx #$00
:	lda spriterowoffs2,x
	sta spriterowoffs0,x
	inx
	cpx #6*8
	bne :-

setpageend
	rts