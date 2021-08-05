; ------------------------------------------------------------------------------------------------------------------------

; TODO:

; add proper disk fail handling.
; highscore + obfuscate (irq loader now loadable after reverting to kernal).
; stars at startup-screen (or maybe something more fancy).
; new music (give option to play without music?) 2channel prefered.
; add sound-fx for fire/bomb/explode.
; more obfuscate against hackers? On drive? Probably not worth it.
; fix bug where ground targets sometimes get cleaned only half when hit.

; ------------------------------------------------------------------------------------------------------------------------

; char indices should be ordered like this for the $d800 colours to be $0c
; 0123456789abcdef
; 1222221222223222		; black, blue = 1, midgray = 3, others = 2

; timanthes file needs 1 layer set to bitmap multicolor and tilemap ticked. DON'T use the 'characters multicolor' mode!
; on save leave all checkboxes as is, but untick 'Add loadaddress' and tick 'Add tiledata info'

; box-box-intersection-test
; if(Axmin < Bxmax && Bxmin < Axmax && Aymin < Bymax && Bymin < Aymax) intersect = true

; ------------------------------------------------------------------------------------------------------------------------

; From Andreas, for cart:
; i let $fffe/ffff point to irqHandler and I let $0314/15 point to kernel: then timing is equal
;
;      pha               ; 3
;      txa               ; 2
;      pha               ; 3
;      tya               ; 2
;      pha               ; 3
;      tsx               ; 2
;      lda $0104,x       ; 4
;      and #$10          ; 2
;      beq :+            ; 3
;      nop               ;
;   :                 ;
;      jmp ($0314)       ; 5     jmp (ind)         ; that's a comment... i point 0314/15 to there, the comment is to remind me of that pointer
;                        ;
;   * = ($0314)       ;
;      kernel:
;      dec $d019
;      pla
;      tay
;      pla
;      tax
;      pla
;      rti
;             
; that code “simulates” what the kernel does
; so with kernel swapped out everything is executed by your own code, swapped in the kernel does its’ thing and jumps to “kernel:”

; ------------------------------------------------------------------------------------------------------------------------

.feature pc_assignment
.feature labels_without_colons

.include "loadersymbols-c64.inc"

.segment "MUSIC"
.incbin "./bin/jammer.bin"

.segment "DIGITSPRITEFONT"						; referenced by code. digits to plot into sprites
.incbin "./bin/font.bin"

.segment "FUELSPRITES"							; referenced by code. score and highscore are plotted in here
.incbin "./bin/fuel.bin"

.segment "ZONESPRITES"							; referenced by code. lives and flags are plotted in here
.incbin "./bin/b54321.bin"

.segment "SPRITES1"								; copied to other bank when going in-game, used as sprites
.incbin "./bin/s0.bin"							; ""
.incbin "./bin/b0.bin"							; ""
.incbin "./bin/bmb0.bin"						; ""
.incbin "./bin/expl0.bin"						; ""
.incbin "./bin/expl1.bin"						; ""
.incbin "./bin/expl2.bin"						; ""
.incbin "./bin/miss.bin"						; ""
.incbin "./bin/ufo.bin"							; ""
.incbin "./bin/comet.bin"						; ""
.incbin "./bin/mysteryspr.bin"					; ""

.segment "MAPTILES"
.incbin "./exe/mt.out"

.segment "MAPTILECOLORS"
.incbin "./exe/mtc.out"

.segment "TSLOGOSPR"
.incbin "./bin/tslogospr.bin"

.segment "TSPRESSFIRESPR"
.incbin "./bin/tspressfirespr.bin"

.segment "CONGRATS"
.incbin "./bin/ingamemetamap.bin"

.segment "UIFONT"
.incbin "./bin/ingamemeta.bin"

.segment "SCREEN1"
	.res 1024
.segment "BITMAP1"
	.res 8192
.segment "SCREENSPECIAL"
	.res 1024
.segment "SPRITES2"
	.res 64
.segment "EMPTYSPRITE"
	.res 64

; ------------------------------------------------------------------------------------------------------------------------

.include "globals.s"
.include "macros.s"

; MAIN ------------------------------------------------------------------------------------------

.segment "CORE"

	sei

	lda #$34
	sta $01

	copymemblocks sprites1, sprites2, $0d00
	copymemblocks tslogosprorg, tslogospr, $0200

	lda #$37
	sta $01

	lda #$01
	sta $d01a

	lda #$18
	sta $d012

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

	jmp titlescreen

.include "core.s"

; -----------------------------------------------------------------------------------------------

.segment "IRQ"
.include "irq.s"

.segment "GAMEPLAY"
.include "gameplay.s"

.segment "GAMEPLAY2"
.include "gameplay2.s"

.segment "SCROLLER"
.include "scroller.s"

.segment "TITLESCREEN"
.include "titlescreen.s"

.segment "TITLESCREENTABLES"
.include "titlescreentables.s"

.segment "LIVESLEFTSCREEN"
.include "livesleftscreen.s"

.segment "CONGRATULATIONSSCREEN"
.include "congratulationsscreen.s"

.segment "CLEARSCREEN"
.include "clearscreen.s"

.segment "TABLES"
.include "tables.s"

.segment "CYCLEPERFECT"
.include "cycleperfect.s"

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

; ingamestart and ingameend are used by: ingame, ingamefromlivesleftscreen and ingamefromcongratulations

ingamestart

	sei
	lda #$35
	sta $01
	lda #$7b
	sta $d011
	lda #$00
	sta $d020
	sta $d021
	rts

ingameend
	lda #$01
	sta $d01a
	lda #<irq3
	ldx #>irq3
	ldy #$f8
	sta $fffe
	sta $0314
	stx $ffff
	stx $0315
	sty $d012
	dec $d019
	cli
	jmp statecheck

; -----------------------------------------------------------------------------------------------

.segment "EASETABLES"
.include "easetables.s"

; -----------------------------------------------------------------------------------------------
