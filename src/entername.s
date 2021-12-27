.segment "ENTERNAMESCREEN"

.struct saveparams
    filename    .word ; existing file to overwrite
    from        .word
    length      .word
    loadaddress .word ; usually same as from
    buffer      .word ; $0720 bytes for swapped loader drive code
.endstruct

entername

	sei

	lda #$34
	sta $01

	jsr inserthighscore

	lda #$37
	sta $01

	lda hiscoreindex
	cmp #$05
	bmi showentername

	cli
	rts

showentername

	ldx hiscoresfile+0;							; .asciiz "hs"
	ldy hiscoresfile+1;
	stx params+saveparams::filename+0;
	sty params+saveparams::filename+1;

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
	sta screen3+8*40,x
	sta screen3+9*40,x
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

	ldx #$00									; colour high score yellow - can be removed if running out of space
	lda #$07+8
:	sta $d800+11*40+20,x
	inx
	cpx #$0b
	bne :-

	ldx #$00									; plot pleaseenteryourname
:	lda pleaseenteryourname,x
	sta screen3+13*40+9,x
	inx
	cpx #$16
	bne :-
	
	ldx #$00									; draw 6 underscores for name
	lda #$2d
:	sta screen3+15*40+17,x
	inx
	cpx #$06
	bne :-

;	lda #$01									; plot a as first char?
;	sta screen3+15*40+17
;	lda #$03+8									; colour cyan to indicate we're editing... make it pulse?
;	sta $d800+15*40+17

	ldy #$00
	ldx #$00
:	txa
	clc
	adc #$01
	sta screen3+17*40+12,y
	adc #$09
	sta screen3+19*40+12,y
	adc #$09
	sta screen3+21*40+12,y
	adc #$09
	sta screen3+23*40+12,y
	iny
	iny
	inx
	cpx #$09
	bne :-

	lda #$2c									; plot del and end
	sta screen3+23*40+24
	lda #$05
	sta screen3+23*40+26
	lda #$0e
	sta screen3+23*40+27
	lda #$04
	sta screen3+23*40+28

	lda #$00
	sta namecolumn
	sta enrow
	sta encolumn

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
	bne :+
	jmp enfire
:	cmp #joyRight
	bne :+
	jmp enright
:	cmp #joyLeft
	bne :+
	jmp enleft
:	cmp #joyUp
	bne :+
	jmp enup
:	cmp #joyDown
	bne :+
	jmp endown

:	jmp waitfireloop

enfire
	lda enrow
	cmp #$03
	bne normalinput
	lda encolumn
	cmp #$06
	beq delchar
	cmp #$07
	bpl inputdone
	jmp normalinput

inputdone
	ldx #$00								; save highscore name. score has already been saved
:	lda screen3+15*40+17,x
ihs4
	sta hiscores,x
	inx
	cpx #$06
	bne :-

	rts

delchar
	lda namecolumn
	cmp #$00
	beq endinput

	dec namecolumn
	lda #$2d
	ldx namecolumn
	sta screen3+15*40+17,x
	jmp endinput

normalinput
	lda namecolumn
	cmp #$06
	beq endinput

	ldx enrow
	lda times9table,x
	clc
	adc encolumn
	adc #$01
	ldx namecolumn
	sta screen3+15*40+17,x
	inc namecolumn

endinput	
	jmp waitfireloop

enright
	lda encolumn
	cmp #$08
	beq :+
	inc encolumn
:	jmp waitfireloop

enleft
	lda encolumn
	beq :+
	dec encolumn
:	jmp waitfireloop

enup
	lda enrow
	beq :+
	dec enrow
:	jmp waitfireloop

endown
	lda enrow
	cmp #$03
	beq :+
	inc enrow
:	jmp waitfireloop

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

	lda d018forscreencharset(screen3,fontchars)
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

	lda #$03
	sta $d015
	lda #$07
	sta $d025
	lda #$00
	sta $d010

	lda encolumn						; column * 16
	asl
	asl
	asl
	asl
	clc
	adc #$76
	sta $d000
	sta $d002
	lda enrow
	asl
	asl
	asl
	asl
	clc
	adc #$b4
	sta $d001
	sta $d003

	lda #(fontchars+$0380)/64
	sta screen3+$03f8
	lda #(fontchars+$03c0)/64
	sta screen3+$03f9

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

encolumn
	.byte $00	; 0-a

enrow
	.byte $00	; 0-2

times9table
	.byte 0*9, 1*9, 2*9, 3*9

namecolumn
	.byte $00

hiscoreindex
	.byte $00

hiscoreindextimes12
	.byte $00

params							; saveparams
	.word 0
	.word hiscores
	.word $003c
	.word hiscores
	.word $7000
