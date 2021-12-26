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
	lda #$01
:	sta screen3+$0000,x
	sta screen3+$0100,x
	sta screen3+$0200,x
	sta screen3+$0300,x
	inx
	bne :-



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
	lda #$0c
	sta $d022
	lda #$0c
	sta $d023
	lda #$00
	sta $d021
	lda #$03
	sta $dd00

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