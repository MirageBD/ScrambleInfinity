.segment "LOADERINSTALL"
.incbin "./exe/install-c64.prg", $02
.segment "LOADER"
.incbin "./exe/loader-c64.prg", $02

.include "loadersymbols-c64.inc"

.segment "TITLE"
.incbin "./bin/title.bin"
.segment "TITLECOL"
.incbin "./bin/titlecol.bin"
.segment "TITLESPR"
.incbin "./bin/titlespr.bin"

.feature pc_assignment
.feature labels_without_colons

.define d018forscreencharset(scr,cst)	#(((scr&$3fff)/$0400) << 4) | (((cst&$3fff)/$0800) << 1)
.define bankforaddress(addr)			#(3-(addr>>14))
.define spriteptrforaddress(addr)		#((addr&$3fff)>>6)

titlecol = $c000
titlecold800 = (titlecol + 40*25)
titlespr = $c800
title = $e000

; -----------------------------------------------------------------------------------------------

.segment "MAIN"

	sei
	
	jsr $e544
	lda #$00
	sta $d020
	sta $d021

	jsr install							; init drive code
	
	ldx #$00
	bcc :++
	cmp #$04							; #STATUS::DEVICE_INCOMPATIBLE
	beq :+
	ldx #$04
:	cmp #$05							; #STATUS::TOO_MANY_DEVICES
	beq :+
	ldx #$00
:	cli

	sei

	lda #$00							; Disable all interferences
	sta $d015							; for a stable timer
	lda #$35
	sta $01
	lda #$7f
	sta $dc0d
	bit $dc0d

	ldx #$01							; Wait for raster line 0 twice
:	bit $d011							; to make sure there are no sprites
	bpl :-
:	bit $d011
	bmi :-
	dex
	bpl :--

	ldx $d012							; Achieve an initial stable raster point
	inx									; using halve invariance method
:	cpx $d012
	bne :-
	ldy #$0a
:	dey
	bne :-
	inx
	cpx $d012
	nop
	beq :+
	nop
	bit $24
:	ldy #$09
:	dey
	bne :-
	nop
	nop
	inx
	cpx $d012
	nop
	beq :+
	bit $24
:	ldy #$0a
:	dey
	bne :-
	inx
	cpx $d012
	bne :+
:	.repeat 5
	nop
	.endrepeat							; Raster is stable here
	
	;.repeat 46							; add offset to timer (95 cycles)
	;nop
	;.endrepeat
	;bit $ea

	.repeat 13							; add offset to timer (95 cycles)
		pha
		pla
	.endrep
	nop
	nop

	lda #$3e							; Start a continious timer
	sta $dc04							; with 63 ticks each loop
	sty $dc05
	lda #%00010001
	sta $dc0e

	lda #$37
	sta $01

	lda d018forscreencharset(titlecol,title)
	sta $d018

	lda #$18
	sta $d016

	lda bankforaddress(title)
	sta $dd00

	lda #$3b
	sta $d011

	ldx #$00
:	lda titlecold800+0*$0100,x
	sta $d800+0*$0100,x
	lda titlecold800+1*$0100,x
	sta $d800+1*$0100,x
	lda titlecold800+2*$0100,x
	sta $d800+2*$0100,x
	lda titlecold800+3*$0100,x
	sta $d800+3*$0100,x
	inx
	bne :-

	lda #$01
	sta $d01a

	lda #$31
	sta $d012

	lda #<irq1
	ldx #>irq1
	sta $fffe
	sta $0314
	stx $ffff
	stx $0315

	lda $dc0d
	lda $dd0d
	dec $d019

	cli

; -----------------------------------------------------------------------------------------------

	lda #$01
	sta loading

	ldx #<file01
	ldy #>file01
	jsr loadraw
	bcs error

	lda #$00
	sta loading

:	lda $dc00
	and #%00010000								; fire
	beq startgame
	jmp :-

startgame
	lda #$7b
	sta $d011
	jmp $080d

error
	lda #$02
:	sta $d020
	jmp :-

loading
.byte $00

; -----------------------------------------------------------------------------------------------
; - START OF IRQ CODE
; -----------------------------------------------------------------------------------------------

.segment "IRQ"

irq1
	pha

	lda #$40							; #$4c
	jsr cycleperfect
	
 	lda #$3b
	sta $d011

	lda #$0c
	sta $d021

	lda loading
	cmp #$01
	beq :+
	lda #$00
	sta $d020
	jmp :++

incd020
:	lda #$00
	sta $d020
	inc incd020+1

:
	; big wait to simulate some irq action going on
	lda #$3a
:	cmp $d012
	bne :-

	lda #$00
	sta $d020

	lda #<irq2
	ldx #>irq2
	ldy #$f8
	jmp endirq
	
; -----------------------------------------------------------------------------------------------

irq2
	pha

	ldx #$00
	lda #$3f
	ldy #$34
	sta $d011,x
	sty $d011

	lda #<irq3
	ldx #>irq3
	ldy #$fa
	jmp endirq

; -----------------------------------------------------------------------------------------------

irq3
	pha

	nop
	nop
	nop
	nop
	nop
	nop

	lda #$00
	sta $d021

	lda #%00001111
	sta $d015
	lda #%00001110
	sta $d010

	lda #$01
	sta $d027
	sta $d028
	sta $d029
	sta $d02a

	lda #$ff
	sta $d001+0*2
	sta $d001+1*2
	sta $d001+2*2
	sta $d001+3*2

	lda loading
	cmp #$01
	beq :+
	ldx spriteptrforaddress(titlespr+4*64)
	jmp :++
:	ldx spriteptrforaddress(titlespr)
:	stx titlecol+$03f8+0
	inx
	stx titlecol+$03f8+1
	inx
	stx titlecol+$03f8+2
	inx
	stx titlecol+$03f8+3

	lda #(248+0*24)&255
	sta $d000+0*2
	lda #(248+1*24)&255
	sta $d000+1*2
	lda #(248+2*24)&255
	sta $d000+2*2
	lda #(248+3*24)&255
	sta $d000+3*2

	lda #<irq1
	ldx #>irq1
	ldy #$31
	jmp endirq

; -----------------------------------------------------------------------------------------------
; - END OF IRQ CODE
; -----------------------------------------------------------------------------------------------

file01
.asciiz "FF"

; -----------------------------------------------------------------------------------------------

.segment "CYCLEPERFECT"

cycleperfect

	sec
	sbc $dc04
	sta bplcode2+1
bplcode2
	bpl :+
:	.repeat 48
	lda #$a9
	.endrepeat
	lda #$a5
	nop
		
	rts

; -----------------------------------------------------------------------------------------------	

endirq	
	sta $fffe
	sta $0314
	stx $ffff
	stx $0315
	sty $d012
	dec $d019

	lda #%00000010
	and $01
	beq :+
	pla
	jmp $ea81
:
	pla
	rti

; -----------------------------------------------------------------------------------------------	
