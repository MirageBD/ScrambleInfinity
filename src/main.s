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
.include "tables.s"
.include "helpers.s"
.include "ingame.s"

; ------------------------------------------------------------------------------------------------------------------------

.segment "ENTRY"

	sei

	lda #$34
	sta $01

	copymemblocks sprites1, sprites2, $0d00
	copymemblocks tslogosprorg, tslogospr, $0200

	lda #$37
	sta $01

	lda #gameflow::titlescreen
	sta gameflowstate+1

	dec $d019

	cli

	jmp handlegameflow

; -----------------------------------------------------------------------------------------------

.segment "GAMEFLOW"

handlegameflow

	;tsx
	;stx $d020									; stack pointer should always be $f6 at this point

gameflowstate
	lda #gameflow::waiting						; selfmodifying
	beq handlegameflow

	; -----------------------------------------

	comparegameflow #gameflow::loadsubzone
	jsr loadsubzone
	nextgameflow #gameflow::waiting

	; -----------------------------------------

	comparegameflow #gameflow::titlescreen
	jsr screensafe
	jsr titlescreen
	nextgameflow #gameflow::startingame

	; -----------------------------------------

	comparegameflow #gameflow::startingame
	jsr screensafe
	jsr startingame
	jsr setsafemode
	jsr setzone0
	jsr ingameatcurrentzone
	nextgameflow #gameflow::continueingame

	; -----------------------------------------

	comparegameflow #gameflow::continueingame
	jsr screensafe
	jsr setuplevel
	nextgameflow #gameflow::waiting

	; -----------------------------------------

	comparegameflow #gameflow::livesleftscreen
	jsr screensafe
	jsr livesleftscreen
	jsr setsafemode
	jsr ingameatcurrentzone
	nextgameflow #gameflow::continueingame
	
	; -----------------------------------------

	comparegameflow #gameflow::congratulations
	jsr screensafe
	jsr congratulations
	jsr setsafemode
	jsr setzone0
	jsr ingameatcurrentzone
	nextgameflow #gameflow::continueingame

	; -----------------------------------------

:	jmp handlegameflow

; -----------------------------------------------------------------------------------------------

setsafemode

	sei
	lda #$35
	sta $01
	lda #$7b
	sta $d011
	lda #$00
	sta $d020
	sta $d021
	rts

; -----------------------------------------------------------------------------------------------

ingameatcurrentzone

	jsr setingamebkgcolours
	jsr initiatebitmapscores
	jsr resetfirestate
	rts

; -----------------------------------------------------------------------------------------------

screensafe

	lda #$00
	sta $d418
	sta $d015
	rts

; -----------------------------------------------------------------------------------------------

setirqvectors

	sta $fffe
	sta $0314
	stx $ffff
	stx $0315
	sty $d012

	lda $dc0d
	lda $dd0d
	dec $d019

	rts

; -----------------------------------------------------------------------------------------------
