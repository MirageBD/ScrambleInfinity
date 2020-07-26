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
.segment "LOGOSPR"
.incbin "./bin/logospr.bin"
.segment "WINGSPR"
.incbin "./bin/wingspr.bin"

.feature pc_assignment
.feature labels_without_colons

.define d018forscreencharset(scr,cst)	#(((scr&$3fff)/$0400) << 4) | (((cst&$3fff)/$0800) << 1)
.define bankforaddress(addr)			#(3-(addr>>14))
.define spriteptrforaddress(addr)		#((addr&$3fff)>>6)

titlecol = $c000
titlecold800 = (titlecol + 40*25)
titlespr = $c800
logospr = $ca00
wingspr = $cc00
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

	lda #$0c
	sta $d020
	sta $d021

	lda #$01
	sta $d01a

	lda #$00
	sta $d012

	lda #<irqlogosprites
	ldx #>irqlogosprites
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
	lda #$00
	sta $d020
	sta $d021
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

irqlogosprites
	pha

	lda #$40							; #$4c
	jsr cycleperfect

	lda #$00
	sta $dd00
 	lda #$5b
	sta $d011

	lda #$ff
	sta $d015
	sta $d01c
	lda #%10000000
	sta $d010

	lda #$02
	sta $d025
	lda #$0b
	sta $d026
	lda #$00
	sta $d027+0
	sta $d027+1
	sta $d027+2
	sta $d027+3
	sta $d027+4
	sta $d027+5
	sta $d027+6
	sta $d027+7

	lda #$1d
	sta $d001+0*2
	sta $d001+1*2
	sta $d001+2*2
	sta $d001+3*2
	sta $d001+4*2
	sta $d001+5*2
	sta $d001+6*2
	sta $d001+7*2

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

	ldx spriteptrforaddress(logospr)
	stx titlecol+$03f8+0
	inx
	stx titlecol+$03f8+1
	inx
	stx titlecol+$03f8+2
	inx
	stx titlecol+$03f8+3
	inx
	stx titlecol+$03f8+4
	inx
	stx titlecol+$03f8+5
	inx
	stx titlecol+$03f8+6
	inx
	stx titlecol+$03f8+7

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

	nop
	nop

	ldx #$18
	ldy #$3b
	stx $d016
	sty $d011

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

	lda #$0c
	sta $d020

	; set left wing sprite
	lda #%00000000
	sta $d010
	lda #$9a
	sta $d001+7*2
	lda #$00
	sta $d000+7*2
	ldx spriteptrforaddress(wingspr)
	stx titlecol+$03f8+7
	lda #$0b
	sta $d025
	lda #$0f
	sta $d026
	lda #$00
	sta $d027+7

	lda #<irqleftwing
	ldx #>irqleftwing
	ldy #$99
	jmp endirq
	
; -----------------------------------------------------------------------------------------------

irqleftwing

	pha

	lda #$41							; #$4c
	jsr cycleperfect

	ldx #$17
	ldy #$18
	stx $d016
	sty $d016

.macro opensideborderbadline
	bit $ea
	ldx #$17
	ldy #$18
	stx $d016
	sty $d016
.endmacro

.macro opensideborder
	jsr waitopenborder
	ldx #$17
	ldy #$18
	stx $d016
	sty $d016
.endmacro

	opensideborderbadline
	opensideborder
	opensideborder
	opensideborder
	opensideborder
	opensideborder
	opensideborder
	opensideborder
	opensideborderbadline
	opensideborder
	opensideborder
	opensideborder
	opensideborder
	opensideborder
	opensideborder
	opensideborder
	opensideborderbadline
	opensideborder

	; set right wing sprite
	lda #%10000000
	sta $d010
	lda #$dc
	sta $d001+7*2
	lda #$58
	sta $d000+7*2
	ldx spriteptrforaddress(wingspr+64)
	stx titlecol+$03f8+7
	lda #$0b
	sta $d025
	lda #$0f
	sta $d026
	lda #$00
	sta $d027+7

	lda #<irqrightwing
	ldx #>irqrightwing
	ldy #$db
	jmp endirq

; -----------------------------------------------------------------------------------------------

irqrightwing

	pha

	lda #$46							; #$4c
	jsr cycleperfect

	ldx #$17
	ldy #$18
	stx $d016
	sty $d016

	opensideborder
	opensideborder
	opensideborder
	opensideborder
	opensideborder
	opensideborderbadline
	opensideborder
	opensideborder
	opensideborder
	opensideborder

	lda #$0c
	sta $d021

	lda #<irqopenborder
	ldx #>irqopenborder
	ldy #$f8
	jmp endirq

; -----------------------------------------------------------------------------------------------

irqopenborder
	pha

	nop
	nop

	ldy #$3f
	sty $d011

	lda #$32				; open border : unset RSEL bit (and #%00110111) + turn on ECM to move ghostbyte to $f9ff
	sta $d011

	lda #<irqlowerborder
	ldx #>irqlowerborder
	ldy #$fa
	jmp endirq

; -----------------------------------------------------------------------------------------------

irqlowerborder
	pha

	nop
	nop
	nop
	nop
	nop
	nop

	lda #$54				; open border : unset RSEL bit (and #%00110111) + turn on ECM to move ghostbyte to $f9ff
	sta $d011

	lda #$08				; no multicolour or bitmap, otherwise ghostbyte move won't work
	sta $d016

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

	lda #$00
	sta $d01c

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

	lda #<irqlogosprites
	ldx #>irqlogosprites
	ldy #$18
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

.segment "SPRRASTER"

sprraster
.byte $00,$00,$00,$00,$00,$00,$00,$06,$0e,$03,$06,$06,$04,$06,$04,$04,$0e,$0e,$03,$03,$0d,$01

waitopenborder
	ldx #$06
:	dex
	bne :-
	bit $ea
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
