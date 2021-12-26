.segment "ENTERNAMESCREEN"

entername

	; check for highscore here
	;rts

	sei
	
	jsr titlescreeninit1

	ldx #$00
:	lda #$09									; white
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
	
	ldx #$00
	lda #$00
:	sta screen3+$0000,x
	sta screen3+$0100,x
	sta screen3+$0200,x
	sta screen3+$0300,x
	inx
	bne :-

	ldx #$00									; fill congratulations bit with solid black char
:	lda #$08
	sta $d800+8*40,x
	sta $d800+9*40,x
	lda #$2f
	sta screen3++8*40,x
	sta screen3++9*40,x
	inx
	cpx #$28
	bne :-

	clc											; plot congratulations
	ldx #$00
:	txa
	adc #$30
	sta screen3+8*40+6,x
	adc #$20
	sta screen3+9*40+6,x
	inx
	cpx #27
	bne :-

	ldx #$00									; plot yougotahiscore
:	lda yougotahiscore,x
	sta screen3+11*40+10,x
	inx
	cpx #$15
	bne :-

	ldx #$00									; plot pleaseenteryourname
:	lda pleaseenteryourname,x
	sta screen3+13*40+9,x
	inx
	cpx #$16
	bne :-
	
	ldx #$00
	lda #$01
:	sta screen3+15*40+17,x
	inx
	cpx #$06
	bne :-

	lda #$2b
	sta screen3+16*40+17

	ldy #$00
	ldx #$00
:	txa
	clc
	adc #$01
	sta screen3+18*40+10,y
	adc #$0b
	sta screen3+20*40+10,y
	adc #$0b
	sta screen3+22*40+10,y
	iny
	iny
	inx
	cpx #$0b
	bne :-

	lda #$2a
	sta screen3+22*40+26
	lda #$05
	sta screen3+22*40+28
	lda #$0e
	sta screen3+22*40+29
	lda #$04
	sta screen3+22*40+30

	lda #<irqentername
	ldx #>irqentername
	ldy #$00
	jsr setirqvectors

	cli

waitfireloop
	jsr waitinput

	tax
	and #inputTypeMask
	cmp #joyInput								; was it joy input?
	beq ehscheckfire							; yes, check if it was fire

	jmp waitfireloop

ehscheckfire
	txa
	cmp #joyFire								; yes, it was joy input, check if it was fire
	bne waitfireloop

	rts

; -----------------------------------------------------------------------------------------------

.segment "IRQENTERNAME"

irqentername

	pha

	jsr logotop

	lda #<irqentername2
	ldx #>irqentername2
	ldy #$68
	jmp endirq

irqentername2
	pha

	lda #$50
	jsr cycleperfect

	lda d018forscreencharset(screen3,$3800)
	sta $d018
	lda #$1b
	sta $d011
	lda #$0a
	sta $d022
	lda #$07
	sta $d023
	lda #$00
	sta $d021
	lda #$03
	sta $dd00

	lda #$74
:	cmp $d012
	bne :-

	lda #$09
	sta $d021

	lda #$81
:	cmp $d012
	bne :-

	lda #$00
	sta $d021
	lda #$0c
	sta $d022

	lda #<irqentername3
	ldx #>irqentername3
	ldy #$fa
	jmp endirq

irqentername3
	pha

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
	bit $ea

	ldx #$34									; open border : unset RSEL bit (and #%00110111) + turn on ECM to move ghostbyte to $f9ff
	ldy #$18									; no multicolour or bitmap, otherwise ghostbyte move won't work
	stx $d011
	sty $d016

	lda #$02
	sta $dd00

	jsr tuneplay

	lda #<irqentername
	ldx #>irqentername
	ldy #$14
	jmp endirq

; -----------------------------------------------------------------------------------------------

yougotahiscore
	.byte $19,$0f,$15, $00, $07,$0f,$14, $00, $01, $00, $08,$09,$07,$08, $00, $13,$03,$0f,$12,$05,$1d

pleaseenteryourname
	.byte $10,$0c,$05,$01,$13,$05, $00, $05,$0e,$14,$05,$12, $00, $19,$0f,$15,$12, $00, $0e,$01,$0d,$05