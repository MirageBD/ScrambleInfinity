.feature pc_assignment
.feature labels_without_colons
.feature c_comments

/*

TODO:

fix zone bars filling up wrong initially after dying

make it harder each time you finish a base

instead of having two seperate routines (slow and small, and fast and big) for plotting scores, just use the fast and big one
update timesgamefinished when the boss is killed instead of on the congratulations screen

fix that vertical black line on the left planet on the titlescreen

obfuscate (irq loader now loadable after reverting to kernal).
new music (give option to play without music?) 2channel prefered.
add sound-fx for fire/bomb/explode.
global search for TODO

------------------------------------------------------------------------------------------------------------------------

ALL HITABLE OBJECTS SHOULD BE ALLIGNED BY 2 CHARS!!! Otherwise random memory might get overwritten.

char indices should be ordered like this for the $d800 colours to be $0c
0123456789abcdef
1222221222223222		; black, blue = 1, midgray = 3, others = 2

timanthes file needs 1 layer set to bitmap multicolor and tilemap ticked. DON'T use the 'characters multicolor' mode!
on save leave all checkboxes as is, but untick 'Add loadaddress' and tick 'Add tiledata info'

------------------------------------------------------------------------------------------------------------------------

box-box-intersection-test
if(Axmin < Bxmax && Bxmin < Axmax && Aymin < Bymax && Bymin < Aymax) intersect = true

------------------------------------------------------------------------------------------------------------------------

screenspecial:

the playable area is only 24 chars high, the 25th row contains information about the height of the missile

when the next column is plotted, the tile is read and the following is output to the screenspecial:

- 0-31 for missiles, mystery, fuel and the boss (4 x 4 tiles x 2 for cave = 32) 
- 32 for empty space (air, stars, cave holes, etc.) basically anything below the first solid tile (72 at the moment)
- ff for the rest (solid)

------------------------------------------------------------------------------------------------------------------------

From Andreas, for cart:
i let $fffe/ffff point to irqHandler and I let $0314/15 point to kernel: then timing is equal

      pha               ; 3
      txa               ; 2
      pha               ; 3
      tya               ; 2
      pha               ; 3
      tsx               ; 2
      lda $0104,x       ; 4
      and #$10          ; 2
      beq :+            ; 3
      nop               ;
   :                 ;
      jmp ($0314)       ; 5     jmp (ind)         ; that's a comment... i point 0314/15 to there, the comment is to remind me of that pointer
                        ;
   * = ($0314)       ;
      kernel:
      dec $d019
      pla
      tay
      pla
      tax
      pla
      rti
             
 that code “simulates” what the kernel does
 so with kernel swapped out everything is executed by your own code, swapped in the kernel does its’ thing and jumps to “kernel:”

*/

.include "loadersymbols-c64.inc"

.include "debug.s"

.include "common/stddefines.s"
.include "common/stdmacros.s"
.include "common/stdirq.s"
.include "common/stdhelpers.s"
.include "common/stdkeyboard.s"
.include "common/stdjoystick.s"
.include "common/stdinput.s"

.include "binaries.s"

.include "recordedsession.s"

.include "globals.s"
.include "core.s"
.include "irq.s"
.include "joystickingame.s"
.include "recordplayback.s"
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
.include "parallax.s"
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

	jsr initscore

	lda #<irqlimbo								; set limbo irq we don't end up in the loading screen irq which might not be there any more after unpacking
	ldx #>irqlimbo
	ldy #$00
	sta $fffe
	sta $0314
	stx $ffff
	stx $0315
	sty $d012

	lda $dc0d
	lda $dd0d
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
	lda hiscorebeaten
	beq hiscorenotbeaten
	jsr copyscoretohiscore
hiscorenotbeaten
	jsr plotbitmapscores
	jsr plotlivesleft
	jsr plottimesgamefinished
	jsr titlescreen
	nextgameflow #gameflow::startingame

	; -----------------------------------------

	comparegameflow #gameflow::startingame
	;jsr screensafe
	lda #$00					; don't call screensafe, as that will make sprites flicker on the title screen
	sta $d418

	.if recordplayback
		jsr initrecordplayback
	.endif
	jsr startingame
	jsr setsafemode
	jsr setzone0
	jsr initscore
	jsr plottimesgamefinished
	jsr initlives
	jsr plotlivesleft
	jsr ingameatcurrentzone
	jsr setuplevel
	nextgameflow #gameflow::continueingame

	; -----------------------------------------

	comparegameflow #gameflow::continueingame
	jsr screensafe
	nextgameflow #gameflow::waiting

	; -----------------------------------------

	comparegameflow #gameflow::livesleftscreen
	jsr screensafe
	jsr livesleftscreen
	jsr plotlivesleft
	jsr setsafemode
	jsr ingameatcurrentzone
	jsr setuplevel
	nextgameflow #gameflow::continueingame
	
	; -----------------------------------------

	comparegameflow #gameflow::congratulations
	jsr screensafe
	jsr plottimesgamefinished
	jsr congratulations
	jsr setsafemode
	jsr setzone0
	jsr ingameatcurrentzone
	jsr setuplevel
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

screensafe

	lda #$00
	sta $d418
	sta $d015
	rts

; -----------------------------------------------------------------------------------------------


ingameatcurrentzone

	jsr setingamebkgcolours
	jsr resetfirestate
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
