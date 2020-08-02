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
	lda #$0c
	sta $d020
	sta $d021

	lda #$1b
	sta $d011

	lda #$14
	sta $d018
	lda #$08
	sta $d016
	
	lda #$03
	sta $dd00

	lda #$00
	sta $d015

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

	lda #$0c
	sta $d020
	sta $d021

	lda #$1b
	sta $d011

	lda #$01
	ldx #$00
:	sta $d800+0*256,x
	sta $d800+1*256,x
	sta $d800+2*256,x
	sta $d800+3*256,x
	inx
	bne :-

	; entering scramble system
	ldx #$00
:	lda enteringtext,x
	sta $0400+9*40+8,x
	inx
	cpx #24
	bne :-

	; draw loading bar
	lda #$70
	sta $0400+11*40
	lda #$6e
	sta $0400+11*40+39

	lda #$5d
	sta $0400+12*40
	sta $0400+12*40+39

	lda #$6d
	sta $0400+13*40
	lda #$7d
	sta $0400+13*40+39

	ldx #$00
	lda #$40
:	sta $0400+11*40+1,x
	sta $0400+13*40+1,x
	inx
	cpx #38
	bne :-

	lda #$01
	sta $d01a

	lda #$00
	sta $d012

	lda #<irq0
	ldx #>irq0
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

	; fill loading bar
	lda #$a0
	ldx #$00
:	sta $0400+12*40+1,x
	inx
	cpx #38
	bne :-

	lda #$1b
	sta $d011
	jmp $080d

error
	lda #$02
:	sta $d020
	jmp :-

loading
.byte $00

enteringtext
.byte $05,$0e,$14,$05,$12,$09,$0e,$07
.byte $20,$13,$03,$12,$01,$0d,$02,$0c
.byte $05,$20,$13,$19,$13,$14,$05,$0d

; -----------------------------------------------------------------------------------------------
; - START OF IRQ CODE
; -----------------------------------------------------------------------------------------------

.segment "IRQ"

irq0
	pha

 	lda #$1b
	sta $d011

	lda #$40							; #$4c
	jsr cycleperfect

	lda loading
	cmp #$01
	bne :+

	jsr drawloadbar

:
	lda #<irq1
	ldx #>irq1
	ldy #50 + 8*8 - 2
	jmp endirq
	
; -----------------------------------------------------------------------------------------------

irq1

	pha

	lda #$40							; #$4c
	jsr cycleperfect

	nop
	nop
	nop

	;lda #$00
	;sta $d020
	;sta $d021

	lda #<irq2
	ldx #>irq2
	ldy #50 + 14*8 + 7
	jmp endirq

; -----------------------------------------------------------------------------------------------

irq2

	pha

	lda #$40							; #$4c
	jsr cycleperfect

	nop
	nop
	nop

	;lda #$0c
	;sta $d020
	;sta $d021

	lda #<irq3
	ldx #>irq3
	ldy #$ff
	jmp endirq

; -----------------------------------------------------------------------------------------------

irq3

	pha

	ldy #$1f
	sty $d011

	lda #<irq0
	ldx #>irq0
	ldy #$00
	jmp endirq

; -----------------------------------------------------------------------------------------------
; - END OF IRQ CODE
; -----------------------------------------------------------------------------------------------

file01
.asciiz "LS"

; -----------------------------------------------------------------------------------------------

drawloadbar
	lda endaddrhi				; don't do anything if too low endaddrhi/endeddrlo loadaddrhi/loadaddrlo
	cmp #$00
	bne :+
	rts

:	lda endaddrhi
	lsr
	sta endtmp

	lda #$a0
	ldx #$00
:	sta $0400+12*40+1,x
	inx
	cpx endtmp
	bne :-

	rts
	
	.byte $00

endtmp
.byte $00

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
