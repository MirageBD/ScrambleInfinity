.segment "ENTERNAMESCREEN"

enterhiscore

	; check for highscore here
	rts

	sei
	
	lda #$37
	sta $01

	lda #$00
	sta $d015
	sta $d418

	lda #$7f
	sta $d011
	
	jsr clearscreen
	
	lda #$09
	sta $d021

	lda #$32+9*8+2
	sta $d012

	lda #<irqentername
	ldx #>irqentername
	ldy #$00
	jsr setirqvectors

	cli

	lda #$1b
	sta $d011

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

	lda #$42									; #$4c
	jsr cycleperfect

	lda #$02
	sta $d020

	lda #$e0
:	cmp $d012
	bne :-

	lda #$00
	sta $d020

	lda #<irqentername
	ldx #>irqentername
	ldy #$32+9*8+2

	jmp endirq

; -----------------------------------------------------------------------------------------------