; ------------------------------------------------------------------------------------------------------------------------

; TODO:

; points for being alive doesn't get called when player is out of fuel and going down?
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

.include "binaries.s"

.include "macros.s"
.include "globals.s"
.include "core.s"
.include "irq.s"
.include "gameplay.s"
.include "shipcollision.s"
.include "bulletcollision.s"
.include "bombcollision.s"
.include "scheduler.s"
.include "animate.s"
.include "spritepositions.s"
.include "score.s"
.include "comets.s"
.include "ufos.s"
.include "missiles.s"
.include "multiplex.s"
.include "scroller.s"
.include "subzones.s"
.include "plot.s"
.include "collision.s"
.include "zones.s"
.include "titlescreen.s"
.include "livesleft.s"
.include "congratulations.s"
.include "clearscreen.s"
.include "tables.s"
.include "helpers.s"
.include "ingame.s"

; ------------------------------------------------------------------------------------------------------------------------

.segment "MAIN"

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

	lda #gameflow::titlescreen
	sta gameflowstate+1

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

	jmp handlegameflow

; -----------------------------------------------------------------------------------------------

.segment "GAMEFLOW"

handlegameflow

gameflowstate
:	lda #gameflow::waiting						; selfmodifying
	beq handlegameflow

	cmp #gameflow::loadingsubzone
	bne :+
	jsr loadingsubzone
	jmp handlegameflow

:	cmp #gameflow::initlevel
	bne :+
	jsr screensafe
	jsr setuplevel
	jmp handlegameflow

:	cmp #gameflow::titlescreen
	bne :+
	jsr screensafe
	jsr titlescreen
	jmp handlegameflow

:	cmp #gameflow::livesleftscreen
	bne :+
	jsr screensafe
	jsr livesleftscreen
	jmp handlegameflow
	
:	cmp #gameflow::congratulations
	bne :+
	jsr screensafe
	jsr congratulations
	jmp handlegameflow

:	jmp handlegameflow

; -----------------------------------------------------------------------------------------------
