.segment "LOADERINSTALL"
.incbin "./exe/install-c64.prg", $02
.segment "LOADER"
.incbin "./exe/loader-c64.prg", $02

.include "loadersymbols-c64.inc"

.feature pc_assignment
.feature labels_without_colons

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
:	stx $d020
	stx $d021
	cli

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

	ldx #<file01
	ldy #>file01
	jsr loadraw
	bcs error

	sei
	lda #$00
	sta $d020
	sta $d021
	jmp $080d

error
	lda #$02
:	sta $d020
	jmp :-

; -----------------------------------------------------------------------------------------------
; - START OF IRQ CODE
; -----------------------------------------------------------------------------------------------

.segment "IRQ"

irq1
	pha

	;lda #$40							; #$4c
	;jsr cycleperfect
	
 	lda #$1b
	sta $d011

	inc $d020

	lda #<irq2
	ldx #>irq2
	ldy #$f8
	jmp endirq
	
; -----------------------------------------------------------------------------------------------

irq2
	pha

	ldx #$00
	lda #$1f
	ldy #$14
	sta $d011,x
	sty $d011

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
