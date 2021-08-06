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

.include "macros.s"
.include "globals.s"
.include "core.s"
.include "irq.s"
.include "gameplay.s"
.include "scroller.s"
.include "subzones.s"
.include "plot.s"
.include "collision.s"
.include "zones.s"
.include "titlescreen.s"
.include "livesleftscreen.s"
.include "congratulationsscreen.s"
.include "clearscreen.s"
.include "tables.s"
.include "cycleperfect.s"

; MAIN ------------------------------------------------------------------------------------------

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

; -----------------------------------------------------------------------------------------------

.segment "NORMALGAMEPLAY"

normalgameplay

	jsr inithandlecollisions
	
handlezonecode3
	jsr plotdummymultsprites

	ldy sortorder
	lda sortsprc,y
	sta $d02d
	ldy sortorder+1
	lda sortsprc,y
	sta $d02e

handlezonecode4
	jsr plotrestmissilemultsprites

shiphitdebug

	rts

; -----------------------------------------------------------------------------------------------

normalgameplay2

	jsr scrollscreen
	jsr joyrout									; 03
	jsr calcvsp
	jsr animship								; 04
	jsr animbullet0								; 05
	jsr animbullet1								; 06
	jsr animbomb0								; 07
	
	lda #$04
:	cmp $d012
	bpl :-
	
	lda #%11110000
	sta $d010
	
	lda #$20+0*24
	sta $d000
	lda #$20+1*24
	sta $d002
	lda #$20+2*24
	sta $d004
	lda #$20+3*24
	sta $d006

	lda #$07+0*24
	sta $d00a
	lda #$07+1*24
	sta $d00c
	lda #$07+2*24
	sta $d00e
	
	lda scrollspeed								; we died, scrollspeed is 0
	beq wedied

	lda $01
	pha
	lda #$34
	sta $01
	
	jsr plottiles
	
	pla
	sta $01
	
	jmp stillalive

wedied

	inc diedframes								; goes up to #$40

	lda diedframes								; has enough time past to continue game?
	cmp #$80
	bne wediedclearframe

.if livesdecrease
	dec lives
.endif
	lda lives
	bne :+

	lda #states::titlescreen
	sta state+1
	jmp wediedend
	
:	lda #states::livesleftscreen
	sta state+1
	jmp wediedend

wediedclearframe

.if diedfade
	cmp #$18
	bmi wediedend

	lda diedframeclearframes
	cmp #24
	bne :+
	jmp wediedend

:
	lsr invscreenposhigh						; divide xpos by 8 to get current vsp column
	ror invscreenposlow
	lsr invscreenposhigh
	ror invscreenposlow
	lsr invscreenposhigh
	ror invscreenposlow							; current column

	clc
	ldx diedframeclearframes
	lda times40lowtable,x
	adc invscreenposlow
	sta diedclearlinelow
	lda times40hightable,x
	adc #$00
	sta diedclearlinehigh

	clc
	lda #<screen1
	adc diedclearlinelow
	sta sf1+1
	lda #>screen1
	adc diedclearlinehigh
	sta sf1+2

	clc
	lda #<screen2
	adc diedclearlinelow
	sta sf2+1
	lda #>screen2
	adc diedclearlinehigh
	sta sf2+2

	clc
	lda #<$d800
	adc diedclearlinelow
	sta sf3+1
	lda #>$d800
	adc diedclearlinehigh
	sta sf3+2

clearline
	lda #$00
	ldx #$00
:
sf1	sta screen1,x
sf2	sta screen2,x
sf3	sta $d800,x
	inx
	cpx #$28
	bne :-

	inc diedframeclearframes

.endif

wediedend

	lda #$20
:	cmp $d012
	bne :-

stillalive	
	;lda #$00
	;sta $d020
	; we are below the bottom border sprites - set up the top border sprites now
	
	.repeat 6,i
	lda #$16									; was 16
	sta $d001+i*2
	lda spriteptrforaddress(livesandzonesprites+i*64)
	sta screenbordersprites+$03f8+i
	.endrepeat
	
	lda #$09
	sta $d027+0
	sta $d027+1
	lda #$06
	sta $d027+2
	sta $d027+3
	sta $d027+4
	sta $d027+5

	lda #$20+0*24								; UI ship
	sta $d000
	lda #$20+1*24								; x
	sta $d002

	lda #$00+0*24								; empty
	sta $d004
	lda #$00+1*24								; empty
	sta $d006

	lda #$1c+0*24								; UI flag
	sta $d008
	lda #$1c+1*24								; x
	sta $d00a

	lda #%00111100
	sta $d010
	
	lda spriteptrforaddress(emptysprite)		; empty sprites for missiles in top border
	sta screenbordersprites+$03f8+6
	sta screenbordersprites+$03f8+7

	lda #$0c
	sta $d025
	lda #$01
	sta $d026
	
	jsr tuneplay								; 01
	jsr animbomb1								; 08
	jsr removescheduledobject					; 02

	jsr sortmultsprites							; 0b
	
handlezonecode2
	jsr plotfirstmissilemultsprites				; 0c

	lda #$1d									; was 1d
:	cmp $d012
	bcs :-

	lda #$48									; #$4c
	jsr cycleperfect

	lda #$00									; top of zone blocks
	sta $d010

	.repeat 6,i									; sprite colours for zone blocks
	lda zonecolours+i
	sta $d027+i
	lda #$74+i*24
	sta $d000+i*2
	.endrepeat

	jsr updatespritepositions1					; 0a

	lda #$2a									; was 2a
:	cmp $d012
	bcs :-
		
	jsr updatespritepositions2
	jsr correctvspsprites

	lda #$00
	sta $d025	
	lda #$09
	sta $d026
	
	lda #$02
	sta $d02d
	lda #$0f
	sta $d02c
	sta $d02e

	lda #$ff
	sta $d01b									; sprite priority

scrlow
	lda #$18
	sta $d016

	rts

; -----------------------------------------------------------------------------------------------

.segment "ENDIRQ"

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
