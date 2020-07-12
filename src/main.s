; ------------------------------------------------------------------------------------------------------------------------

; TODO:

; show mystery points.
; highscore + obfuscate (irq loader now loadable after reverting to kernal).
; stars at startup-screen (or maybe something more fancy).
; new music (give option to play without music?) 2channel prefered.
; add sound-fx for fire/bomb/explode.
; more obfuscate against hackers? On drive? Probably not worth it.
; fancy startup screen.
; fix bug where ground targets sometimes get cleaned only half when hit.
; add proper disk fail handling.

; ------------------------------------------------------------------------------------------------------------------------

; char indices should be ordered like this for the $d800 colours to be $0c
; 0123456789abcdef
; 1222221222223222		; black, blue = 1, midgray = 3, others = 2

; timanthes file needs 1 layer set to bitmap multicolor and tilemap ticked. DON'T use the 'characters multicolor' mode!
; on save leave all checkboxes as is, but untick 'Add loadaddress' and tick 'Add tiledata info'

; box-box-intersection-test
; if(Axmin < Bxmax && Bxmin < Axmax && Aymin < Bymax && Bymin < Aymax) intersect = true

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

.segment "SPRITES1"								; copied to other bank once, used as sprites
.incbin "./bin/s0.bin"							; ""
.incbin "./bin/b0.bin"							; ""
.incbin "./bin/bmb0.bin"						; ""
.incbin "./bin/expl0.bin"						; ""
.incbin "./bin/expl1.bin"						; ""
.incbin "./bin/expl2.bin"						; ""
.incbin "./bin/miss.bin"						; ""
.incbin "./bin/ufo.bin"							; ""
.incbin "./bin/comet.bin"						; ""

.segment "MAPTILES"
.incbin "./exe/mt.out"

.segment "MAPTILECOLORS"
.incbin "./exe/mtc.out"

.segment "UIFONT"								; not referenced, used as font
.incbin "./bin/font2.bin"

.segment "ENEMYICONS"							; not references, used as font
.incbin "./bin/tspts.bin"

.segment "LOADER"
.incbin "./exe/loader-c64.prg", $02

.segment "LOADEDDATA1"
	.res 2048
.segment "LOADEDDATA2"
	.res 2048
.segment "SCREEN1"
	.res 1024
.segment "BITMAP1"
	.res 8192
.segment "SCREEN2"
	.res 1024
.segment "BITMAP2"
	.res 8192
.segment "SCREENSPECIAL"
	.res 1024

; DEBUG DEFINES ----------------------------------------------------------------------------------------------------------

.define fueldecreases		1					; HACKS
.define pointsforbeingalive	1
.define shipbkgcollision	1
.define shipsprcollision	1
.define livesdecrease		1
.define firebullets			1
.define firebombs			1
.define startzone			#$01				; #$01 - #$06

; DEFINES ----------------------------------------------------------------------------------------------------------------

.define bank0				$0000
.define bank1				$4000
.define bank2				$8000
.define bank3				$c000

.define fueladd				#$08				; how much to add when you destroy a fuel tanker
.define fueldecreaseticks	#$20				; frames before fuel decreases by one
.define fuelfull			#$38				; full tank
.define startlives			#$03				; initial lives
.define ufospawntime		#$50				; time before new ufo spawns - can be more, not less
.define bulletcooldown		#$18
.define zonecolour0			#$0b
.define zonecolour1			#$07

.define MAXMULTPLEXSPR		12
.define sortorder			$a0
.define sortcounter			$b2

.define bitmapwidth			320

; ------------------------------------------------------------------------------------------------------------------------

tuneinit					= $1000
tuneplay					= $1003

maptilecolors				= $f800
maptiles					= $d400
font						= $f300

loadeddata1					= $3000
loadeddata2					= $3800

screen1						= $4000
sprites1					= $4400
bitmap1						= $6000
screen2						= $8000
sprites2					= $8400
bitmap2						= $a000
screenspecial				= $c000
screenui					= $c000
clearmisilepositiondata		= screenspecial+$03c0

colormem					= $d800

scoreandfuelsprites			= $f400
livesandzonesprites			= $f600

zp0							= $f9
zp1							= $fa
zp2							= $fb
zp3							= $fc
zp4							= $fd
zp5							= $fe
zptemp						= $ff

livesdigit0					= livesandzonesprites+1*64+ 2*3+2
flagsdigit0 				= livesandzonesprites+5*64+ 2*3+2

scoredigit0 				= scoreandfuelsprites+0*64+14*3+0
scoredigit1 				= scoreandfuelsprites+0*64+14*3+1
scoredigit2 				= scoreandfuelsprites+0*64+14*3+2
scoredigit3 				= scoreandfuelsprites+1*64+14*3+0
scoredigit4 				= scoreandfuelsprites+1*64+14*3+1
scoredigit5 				= scoreandfuelsprites+1*64+14*3+2

; STRUCTS AND ENUMS ------------------------------------------------------------------------------------------------------

.struct sprdata
	xlow					.byte
	xhigh					.byte
	ylow					.byte
	xvel					.byte
	yvel					.byte
	pointer					.byte
	colour					.byte
	isexploding				.byte
.endstruct

.enum states
	waiting					= 0
	initlevel				= 1
	loadingsubzone			= 2
	titlescreen				= 3
	livesleftscreen			= 4
	gameover				= 5
	congratulations			= 6
.endenum

.enum bkgcollision								; 3rd bit for cave?
	standingmissilenoncave	= %00000000
	mysterynoncave			= %00000100
	fuelnoncave				= %00001000
	bossnoncave				= %00001100
	standingmissilecave		= %00010000
	mysterycave				= %00010100
	fuelcave				= %00011000
	bosscave				= %00011100
.endenum

.enum sprcollision
	flyingmissile			= 1
	flyingufo				= 2
	flyingcomet				= 3
.endenum

; MACROS -----------------------------------------------------------------------------------------------------------------

.macro add16bit arg1, arg2						; clear carry before using this
	lda arg1+1
	adc #<(arg2)
	sta arg1+1
	lda arg1+2
	adc #>(arg2)
	sta arg1+2
.endmacro

.macro sub16bit arg1, arg2						; set carry before using this
	lda arg1+1
	sbc #<(arg2)
	sta arg1+1
	lda arg1+2
	sbc #>(arg2)
	sta arg1+2
.endmacro

.macro store16bit arg1, arg2
	lda #<(arg2)
	sta arg1+1
	lda #>(arg2)
	sta arg1+2
.endmacro

.macro addpoints arg1, arg2
	clc
	lda score+arg2
	adc arg1
	sta score+arg2
.endmacro

.macro plotdigit arg1, arg2
	ldx arg1
	ldy times8lowtable,x
	lda font+0,y
	sta arg2+0*3
	lda font+1,y
	sta arg2+1*3
	lda font+2,y
	sta arg2+2*3
	lda font+3,y
	sta arg2+3*3
	lda font+4,y
	sta arg2+4*3
	lda font+5,y
	sta arg2+5*3
.endmacro

; MAIN ------------------------------------------------------------------------------------------

.segment "MAIN"

	sei

	lda #$00									; Disable all interferences
	sta $d015									; for a stable timer
	lda #$35
	sta $01
	lda #$7f
	sta $dc0d
	bit $dc0d

	ldx #$01									; Wait for raster line 0 twice
:	bit $d011									; to make sure there are no sprites
	bpl :-
:	bit $d011
	bmi :-
	dex
	bpl :--

	ldx $d012									; Achieve an initial stable raster point
	inx											; using halve invariance method
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
	.endrepeat									; Raster is stable here

	.repeat 13									; add offset to timer (95 cycles)
		pha
		pla
	.endrep
	nop
	nop

	lda #$3e									; Start a continious timer
	sta $dc04									; with 63 ticks each loop
	sty $dc05
	lda #%00010001
	sta $dc0e

	lda #$37
	sta $01

	lda #$01
	sta $d01a

	lda #$31
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

; -----------------------------------------------------------------------------------------------

	jmp titlescreen

; -----------------------------------------------------------------------------------------------

initiatebitmapscores
	plotdigit score+0, scoredigit0
	plotdigit score+1, scoredigit1
	plotdigit score+2, scoredigit2
	plotdigit score+3, scoredigit3
	plotdigit score+4, scoredigit4
	plotdigit score+5, scoredigit5
	plotdigit lives+0, livesdigit0
	plotdigit flags+0, flagsdigit0
	rts

ingamefresh

	ldx #$00									; set score to zero
	lda #$00
:	sta score,x
	sta prevscore,x
	inx
	cpx #$06
	bne :-

	lda startlives
	sta lives
	lda #$00
	sta flags

	jsr ingamestart								; sets $01
	jsr setupinitiallevel
	jsr setuplevel								; sets $01 to #$37 and returns

	jmp ingamefromui

ingamefromlivesleftscreen
	jsr ingamestart
	jmp ingamefromui
	
ingamefromcongratulations
	jsr ingamestart
	jsr setupinitiallevel
	jsr setuplevel
	jmp ingamefromui

ingamefromui
	jsr setingamebkgcolours
	jsr initiatebitmapscores
	jsr resetfirestate
	jmp ingameend

screensafe
	lda #$00
	sta $d418
	sta $d015
	rts

statecheck
state
:	lda #states::waiting						; selfmodifying - see states enum
	beq :-

	cmp #states::loadingsubzone
	bne :+
	jsr loadingsubzone
	jmp state

:	cmp #states::initlevel
	bne :+
	jsr screensafe
	jsr setuplevel
	jmp state

:	cmp #states::titlescreen
	bne :+
	jsr screensafe
	jsr titlescreen
	jmp state

:	cmp #states::livesleftscreen
	bne :+
	jsr screensafe
	jsr livesleftscreen
	jmp state
	
:	cmp #states::congratulations
	bne :+
	jsr screensafe
	jsr congratulations
	jmp state

:	jmp state
	
loadingsubzone
	lda #states::waiting
	sta state+1

	jsr loadpackd

	bcc :+
	jmp error

:	rts

error
	sta $0800
	inc $d021
	jmp error
	
; -----------------------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------------------

loadpackd

	ldx #<file01
	ldy #>file01
	jsr loadcompd

	rts

loadloadinstall

	ldx #<loadinstallfile
	ldy #>loadinstallfile
	jsr loadraw

	rts

; -----------------------------------------------------------------------------------------------

setingamebkgcolours
	ldx #$00
:	lda #$0c
	sta colormem+(0*$0100),x
	sta colormem+(1*$0100),x
	sta colormem+(2*$0100),x
	sta colormem+(3*$0100),x
	dex
	bne :-
	rts

setupinitiallevel
	
	;lda #$00
	sta ship0+sprdata::xhigh
	sta ship0+sprdata::xlow
	
	lda #>sprites2								; copy sprites to other bank
	sta sprcpy0+2
	lda #>sprites1
	sta sprcpy1+2
sprcpy
	ldx #$00
sprcpy0
	lda sprites2,x
sprcpy1
	sta sprites1,x
	dex
	bne sprcpy0
	inc sprcpy0+2
	inc sprcpy1+2
	lda sprcpy0+2
	cmp #$90
	bne sprcpy
	
	jsr setingamebkgcolours
	
	lda #$ff
	sta $7fff
	sta $bfff
	
	ldx startzone								; #$01, #$02, #$03, #$04, #$05, #$06
	stx zone
	dex
	txa
	asl
	asl
	asl
	asl
	ora #$01									; #$01, #$11, #$21, #$31, #$41, #$51
	sta subzone
	
	rts

setupfilename	
	
	lda file
	and #%00001111
	tax
	lda filenameconvtab,x
	sta file01+1
	
	lda file
	lsr
	lsr
	lsr
	lsr
	tay
	lda filenameconvtab,y
	sta file01+0
	
	rts
	
setuplevel

	sei

	lda #$37
	sta $01

	ldx #$00
	ldy #$00
	jsr tuneinit

	lda #$74
	sta $d011

	lda #$17
	sta $d016
	
	lda #$08
	sta $d018
	
	ldy #$01
	sty $dd00

	ldx #$10
	stx screen1+$03f8+0
	stx screen2+$03f8+0
	inx
	stx screen1+$03f8+1
	stx screen2+$03f8+1

	jsr findstartofzone
		
	jsr setupfilename							; stores 0 in x, 0 in y
	jsr loadpackd

	;bcc :+
	;jmp error

:
	inc file									; file = 1
	jsr setupfilename
	jsr loadpackd

	;bcc :+
	;jmp error

:	jsr incpag2									; set up pointers for initial tile plot
	inc file									; file = 2
	lda #$00
	sta row
	sta column
	sta flip
	sta ps1+1
	sta ps2+1
	
	lda #$34
	sta $01

ps1	lda #$00									; plot initial screens
	cmp #$01
	bne :+
ps2	lda #$00
	cmp #$40
	bne :+
	jmp psdone
:	jsr plottiles
	inc ps2+1
	lda ps2+1
	cmp #$00
	bne ps1
	inc ps1+1
	jmp ps1

psdone

	inc file
	inc subzone
	lda file
	cmp #$02
	bne sldone

	ldx #$00									; clear temporary tiles from screen - only need to do this for first subzone?
	lda #$55
:	sta bitmap1,x
	sta bitmap1+64,x
	inx
	bne :-
	
	ldx #$00
:	lda #$66
	sta screen1,x
	lda #$20
	sta screenspecial,x
	inx
	cpx #$28
	bne :-

	lda #$20									; empty tiles used for index ordering
	.repeat 27, i
	sta loadeddata2+i*50+0
	.endrepeat

sldone
	lda #$37
	sta $01

	lda #states::waiting
	sta state+1

	jsr setupfilename	
	jsr loadpackd

	;bcc :+
	;jmp error

:	lda #$30
	sta hascontrol

	jsr initmultsprites

	lda fuelfull
	sta fuel

	lda #$00
	sta ufonum
	sta cometnum
	sta timeseconds
	lda #$01
	sta timeseconds
	
	lda #$01
	sta scrollspeed

	ldx #>(bitmapwidth-1)
	ldy #<(bitmapwidth-1)
	stx screenposhigh
	sty screenposlow

	ldx #$00
	lda #$ff
:	sta sortsprylow,x
	inx
	cpx #MAXMULTPLEXSPR
	bne :-

	lda zonecolour1
	ldx #$00
:	sta zonecolours,x
	inx
	cpx zone									; zone = $01,$02,$03,$04,$05,$06
	bne :-

	lda zonecolour0
:	sta zonecolours,x
	inx
	cpx #$07
	bne :-

	lda #$01
	sta bulletcooloff
	sta bombcooloff
	
	lda #$00
	sta gamefinished
	
	ldy #$74
	sty $d011

	cli

	rts
	

resetfirestate									; this makes sure there are no leftover bullets on the screen after death
	jsr bull0explosiondone
	jsr bull1explosiondone
	jsr bomb0explosiondone
	jsr bomb1explosiondone
	rts

; -----------------------------------------------------------------------------------------------
; - START OF IRQ CODE
; -----------------------------------------------------------------------------------------------

.segment "IRQ"

irq1
	pha
	sec
vspcor
	lda #$35
	sbc $dc04
	sta bplcode+1
bplcode
	bpl :+
:	.repeat 48
	lda #$a9
	.endrepeat
	lda #$a5									; a5 = lda zp = 3 cycles

	nop

page
	lda #$01
	sta $dd00
	
	lda #$08
	sta $d018

	ldx #$6b

foo3
	bne foo4									; do vsp
foo4
	.repeat 19
	lda #$a9
	.endrepeat
	lda #$a5
	nop

	stx $d011
	lda #$3c									; vsp
	sta $d011
	
	lda #$ff
	sta $d015
	sta $d01c									; sprite multicolour

	lda #$00
	sta $d01b									; sprite priority

	jsr normalgameplay

	lda #$40									; #$4c
	jsr cycleperfect
	
	lda #<irq2
	ldx #>irq2
	ldy #$f2
	jmp endirq
	
; -----------------------------------------------------------------------------------------------
	
irq2											; start of bottom border irq
	pha

	nop
	nop
	nop
	nop
	nop
	
 	lda #$69
 	sta $d011
 
	lda #$fc
	sta $d001
	sta $d003
	sta $d005
	sta $d007
	sta $d009
	sta $d00b
	sta $d00d
	sta $d00f

	lda #$33
	sta $d000
	
	lda #$72+0*24
	sta $d002
	lda #$72+1*24
	sta $d004
	lda #$72+2*24
	sta $d006
	lda #$72+3*24
	sta $d008
	lda #$72+4*24
	sta $d00a
	lda #$72+5*24
	sta $d00c
	
	lda #$27
	sta $d00e

	lda #%10000000
	sta $d010

	ldx #$d0
	stx $c3f8
	inx
	stx $c3f9
	inx
	stx $c3fa
	inx
	stx $c3fb
	inx
	stx $c3fc
	inx
	stx $c3fd
	inx
	stx $c3fe
	inx
	stx $c3ff

	lda #<irq3
	ldx #>irq3
	ldy #$f8
	jmp endirq
	
; -----------------------------------------------------------------------------------------------

irq3
	pha
	
 	ldx #$00
	lda #$7f
	ldy #$74
	sta $d011,x
	sty $d011

	lda #$00
	sta $d018

	lda #$00									; #$02 = $4000-$8000, #$01 = $8000-$c000
	sta $dd00

	lda #$0b
	sta $d025
	lda #$01
	sta $d026
	
	ldy #$07
	lda fuel
	cmp #$10
	bcs :++

	inc fuellowtimer
	lda fuellowtimer
	cmp #$10
	bne :+
	lda #$00
	sta fuellowtimer
:	lda fuellowtimer
	lsr
	lsr
	lsr
	tax
	ldy fuelblink,x
	
:	sty $d027
	sty $d028
	sty $d029
	sty $d02a
	sty $d02b
	sty $d02c
	sty $d02d
	sty $d02e

	jsr normalgameplay2
	
irq3veclo
	lda #<irq1
irq3vechi
	ldx #>irq1
	ldy #$31
	jmp endirq

; -----------------------------------------------------------------------------------------------

irqloadsubzone
	pha

	lda #<irqloadsubzone
	ldx #>irqloadsubzone
	ldy #$31
	jmp endirq

; -----------------------------------------------------------------------------------------------
		
irqtitle

	pha

	lda #$48									; #$4c
	jsr cycleperfect

	lda #$1b
	sta $d011
	
	lda #$00									; no sprites on title screen
	sta $d015
	
	lda #<irqtitle2
	ldx #>irqtitle2
	ldy #$f8
	jmp endirq

irqtitle2
	pha

 	ldx #$00
	lda #$1f
	ldy #$14
	sta $d011,x
	sty $d011
	
	lda #<irqtitle
	ldx #>irqtitle
	ldy #$31
	jmp endirq
	
; -----------------------------------------------------------------------------------------------

irqlivesleft

	pha

	lda #$48									; #$4c
	jsr cycleperfect

	lda #$00									; no sprites on lives left screen
	sta $d015

	lda timerreached
	bne timerreacheddone
	
	inc timerlow
	bne :+
	inc timerhigh
	
:	lda timerhigh
	cmp timerreachedhigh
	bne timerreacheddone
	lda timerlow
	cmp timerreachedlow
	bne timerreacheddone
	lda #$01
	sta timerreached
	
timerreacheddone
	lda #<irqlivesleft
	ldx #>irqlivesleft
	ldy #$31
	jmp endirq

timerlow
.byte $00
timerhigh
.byte $00
timerreachedlow
.byte $00
timerreachedhigh
.byte $00
timerreached
.byte $00

; -----------------------------------------------------------------------------------------------
; - END OF IRQ CODE
; -----------------------------------------------------------------------------------------------

animship

	inc s0counter2
	lda s0counter2
	cmp #$08
	beq :+
	
	rts
	
:	lda #$00
	sta s0counter2

	lda ship0+sprdata::isexploding
	cmp #$00
	beq ship0normalanim

	ldx s0counter
	lda bombexplosionanim,x
	sta ship0+sprdata::pointer
	
	lda bombexplosioncolours,x
	sta ship0+sprdata::colour
	
	inc s0counter
	lda s0counter
	cmp #$08
	beq ship0explosiondone

	rts
	
ship0explosiondone								; we died - decrease lives and see if we need to return to the title screen
	lda #$ff
	sta ship0+sprdata::ylow
	lda #$00
	sta ship0+sprdata::xlow
	sta ship0+sprdata::xhigh
	sta ship0+sprdata::xvel
	sta ship0+sprdata::yvel
	sta ship0+sprdata::isexploding

.if livesdecrease
	dec lives
.endif
	lda lives
	bne :+

	lda #states::titlescreen
	sta state+1
	
	rts
	
:	lda #states::livesleftscreen
	sta state+1

	rts

ship0normalanim
	inc s0counter
	lda s0counter
	and #$03
	tax
	lda s0anim,x
	sta ship0+sprdata::pointer

	lda #$01
	sta ship0+sprdata::colour

	rts

; -----------------------------------------------------------------------------------------------

.segment "GAMEPLAY"

joyrout

	lda hascontrol
	beq yescontrol

	cmp #$ff									; if exploding then no control
	beq :+

	dec hascontrol
	inc ship0+sprdata::xlow
	lda #$58
	sta ship0+sprdata::ylow

:	rts
	
yescontrol

	lda fuel
	bne :+
	
	inc nofuelcounter
	lda nofuelcounter
	cmp #$02
	bne :+
	lda #$00
	sta nofuelcounter
	inc ship0+sprdata::ylow

:	ldx $dc00
	lda fuel
	beq down1									; fuel is 0 - not allowed to go up. only down, left, right, fire
	txa
	and #%00000001								; up
	bne down1
	dec ship0+sprdata::ylow
	jmp left1
down1
	txa
	and #%00000010								; down
	bne left1
	inc ship0+sprdata::ylow
left1
	txa
	and #%00000100								; left
	bne right1
	dec ship0+sprdata::xlow
	jmp fire1
right1
	txa
	and #%00001000								; right
	bne fire1
	inc ship0+sprdata::xlow
fire1
	txa
	and #%00010000								; fire
	beq tryfirebullet
	jmp no1
	
tryfirebullet

.if firebullets
	lda shootingbullet0
	beq firebullet0
	
	lda shootingbullet1
	beq firebullet1
.endif

	jmp tryfirebomb

firebullet0

	lda bulletcooloff
	beq :+
	
	jmp tryfirebomb

:	lda bulletcooldown
	sta bulletcooloff

	lda #$01
	sta shootingbullet0

	lda ship0+sprdata::xlow
	adc #$08
	sta bull0+sprdata::xlow
	lda ship0+sprdata::xhigh
	sta bull0+sprdata::xhigh
	clc
	lda ship0+sprdata::ylow
	adc #$01
	sta bull0+sprdata::ylow
	lda #$06
	sta bull0+sprdata::xvel
	lda #$00
	sta bull0+sprdata::yvel

	;lda #$00
	sta bull0counter
	lda #$02
	sta bull0counter2

	jmp tryfirebomb

firebullet1

	lda bulletcooloff
	beq :+
	
	jmp tryfirebomb

:	lda bulletcooldown
	sta bulletcooloff

	lda #$01
	sta shootingbullet1

	lda ship0+sprdata::xlow
	adc #$08
	sta bull1+sprdata::xlow
	lda ship0+sprdata::xhigh
	sta bull1+sprdata::xhigh
	clc
	lda ship0+sprdata::ylow
	adc #$03
	sta bull1+sprdata::ylow
	lda #$06
	sta bull1+sprdata::xvel
	lda #$00
	sta bull1+sprdata::yvel

	;lda #$00
	sta bull1counter
	lda #$02
	sta bull1counter2


tryfirebomb

.if firebombs
	lda shootingbomb0
	beq firebomb0
	
	lda shootingbomb1
	beq firebomb1
.endif

	jmp no1

firebomb0

	lda bombcooloff
	beq :+
	
	jmp no1

:	lda #$0f
	sta bombcooloff

	ldx #$01
	stx shootingbomb0

	clc
	lda ship0+sprdata::xlow
	adc #$10
	sta bomb0+sprdata::xlow
	lda ship0+sprdata::xhigh
	sta bomb0+sprdata::xhigh
	clc
	lda ship0+sprdata::ylow
	adc #$02
	sta bomb0+sprdata::ylow
	stx bomb0+sprdata::xvel
	stx bomb0+sprdata::yvel

	lda #$00
	sta bomb0counter
	lda #$03
	sta bomb0counter2

	jmp no1

firebomb1

	lda bombcooloff
	beq :+
	
	jmp no1

:	lda #$0f
	sta bombcooloff

	ldx #$01
	stx shootingbomb1

	clc
	lda ship0+sprdata::xlow
	adc #$10
	sta bomb1+sprdata::xlow
	lda ship0+sprdata::xhigh
	sta bomb1+sprdata::xhigh
	clc
	lda ship0+sprdata::ylow
	adc #$02
	sta bomb1+sprdata::ylow
	stx bomb1+sprdata::xvel
	stx bomb1+sprdata::yvel

	lda #$00
	sta bomb1counter
	lda #$03
	sta bomb1counter2
	
	;jsr tryfirebomb

no1

; -----------------------------------------------------------------------------------------------

restrictship

	lda ship0+sprdata::xlow
	cmp #$22
	bcs :+
	lda #$22
	sta ship0+sprdata::xlow
	jmp :++
	
:	cmp #$b0
	bcc :+
	lda #$b0
	sta ship0+sprdata::xlow

:	lda ship0+sprdata::ylow
	cmp #$34
	bcs :+
	lda #$34
	sta ship0+sprdata::ylow
	jmp :++

:	cmp #$e0
	bcc :+
	lda #$e0
	sta ship0+sprdata::ylow

:

; -----------------------------------------------------------------------------------------------

handlecooloff

	lda bulletcooloff
	beq :+
	
	dec bulletcooloff
	
:	lda bombcooloff
	beq :+

	dec bombcooloff

:
	; fall through

; -----------------------------------------------------------------------------------------------

; addpointsbeingalive

.if pointsforbeingalive
	inc timeseconds
	lda timeseconds
	cmp #$50
	bne :+
	
	lda #$00
	sta timeseconds
	addpoints #1, 5								; add 10 points every second
	jsr updatescore
.endif

:	; fall through
	
; -----------------------------------------------------------------------------------------------

; increasemysterytimer

	inc mysterytimer
	lda mysterytimer
	cmp #$04
	bne :+
	lda #$01
	sta mysterytimer

:	rts

; -----------------------------------------------------------------------------------------------


testshipbkgcollision

	sec
	lda ship0+sprdata::xlow
	sbc #$10
	sta calcxlow
	lda ship0+sprdata::xhigh
	sbc #$00
	sta calcxhigh
	sec
	lda ship0+sprdata::ylow
	sbc #$26
	sta calcylow

	jsr calcshippostoscreenpos

	lda calchit
	cmp #$20
	beq tsbe

	lda #$00
	sta scrollspeed
	sta s0counter
	sta ship0+sprdata::xvel
	lda #$ff
	sta hascontrol
	lda #$01
	sta ship0+sprdata::isexploding
	rts

tsbe
	rts

testshipsprcollision

	clc
	lda ship0+sprdata::xlow
	adc #$02
	sta calcxlow
	lda ship0+sprdata::xhigh
	adc #$00
	sta calcxhigh
	clc
	lda ship0+sprdata::ylow
	adc #$04
	sta calcylow

	clc
	lda ship0+sprdata::xlow
	adc #$14
	sta calcxlowmax
	lda ship0+sprdata::xhigh
	adc #$00
	sta calcxhighmax
	clc
	lda ship0+sprdata::ylow
	adc #$0b
	sta calcylowmax

	jsr calcshippostospritepos
	
	lda calcsprhit
	beq tsse

	lda #$00
	sta scrollspeed
	sta s0counter
	sta ship0+sprdata::xvel
	lda #$ff
	sta hascontrol
	lda #$01
	sta ship0+sprdata::isexploding
	rts

tsse
	rts

; -----------------------------------------------------------------------------------------------

testbullet0bkgcollision

	sec
	lda bull0+sprdata::xlow
	sbc #$10
	sta calcxlow
	lda bull0+sprdata::xhigh
	sbc #$00
	sta calcxhigh
	sec
	lda bull0+sprdata::ylow
	sbc #$2c
	sta calcylow

	jsr calcspritepostoscreenpos

	lda calchit
	cmp #$20
	beq :+

	jmp handlebullet0bkgcollision

:	rts

testbullet0sprcollision

	lda bull0+sprdata::xlow
	sta calcxlow
	lda bull0+sprdata::xhigh
	sta calcxhigh
	lda bull0+sprdata::ylow
	sta calcylow

	clc
	lda bull0+sprdata::xlow
	adc #$08
	sta calcxlowmax
	lda bull0+sprdata::xhigh
	adc #$00
	sta calcxhighmax
	clc
	lda bull0+sprdata::ylow
	adc #$04
	sta calcylowmax

	jsr calcspritepostospritepos
	
	lda calcsprhit
	beq :++										; 0 = no hit

	cmp #$02
	bne :+
	
	jmp bullet0bkgsmallexplosion				; 1 = small hit
	
:	jmp bullet0bkgbigexplosion					; 2 = big hit

:	rts

; -----------------------------------------------------------------------------------------------

handlebullet0bkgcollision

	cmp #$ff
	beq bullet0bkgsmallexplosion

	sec
	lda bull0+sprdata::ylow
	sbc calcspryoffset
	sta bull0+sprdata::ylow
	
	jsr scheduleremovehitobject

bullet0bkgbigexplosion

	lda #$01									; set big explosion anim
	sta bull0+sprdata::isexploding
	lda #$ff
	sta bull0+sprdata::xvel
	lda #$00
	sta bull0+sprdata::yvel
	sta bull0counter

	rts

bullet0bkgsmallexplosion

	lda #$02									; set small explosion anim
	sta bull0+sprdata::isexploding
	lda #$ff
	sta bull0+sprdata::xvel
	lda #$00
	sta bull0+sprdata::yvel
	sta bull0counter

	rts

; -----------------------------------------------------------------------------------------------

testbullet1bkgcollision

	sec
	lda bull1+sprdata::xlow
	sbc #$10
	sta calcxlow
	lda bull1+sprdata::xhigh
	sbc #$00
	sta calcxhigh
	sec
	lda bull1+sprdata::ylow
	sbc #$2c
	sta calcylow

	jsr calcspritepostoscreenpos

	lda calchit
	cmp #$20
	beq :+

	jmp handlebullet1bkgcollision

:	rts

testbullet1sprcollision

	lda bull1+sprdata::xlow
	sta calcxlow
	lda bull1+sprdata::xhigh
	sta calcxhigh
	lda bull1+sprdata::ylow
	sta calcylow

	clc
	lda bull1+sprdata::xlow
	adc #$08
	sta calcxlowmax
	lda bull1+sprdata::xhigh
	adc #$00
	sta calcxhighmax
	clc
	lda bull1+sprdata::ylow
	adc #$04
	sta calcylowmax

	jsr calcspritepostospritepos
	
	lda calcsprhit
	beq :++										; 0 = no hit

	cmp #$02
	bne :+
	
	jmp bullet1bkgsmallexplosion				; 1 = small hit
	
:	jmp bullet1bkgbigexplosion					; 2 = big hit

:	rts

; -----------------------------------------------------------------------------------------------

handlebullet1bkgcollision

	cmp #$ff
	beq bullet1bkgsmallexplosion

	sec
	lda bull1+sprdata::ylow
	sbc calcspryoffset
	sta bull1+sprdata::ylow
	
	jsr scheduleremovehitobject

bullet1bkgbigexplosion

	lda #$01									; set big explosion anim
	sta bull1+sprdata::isexploding
	lda #$ff
	sta bull1+sprdata::xvel
	lda #$00
	sta bull1+sprdata::yvel
	sta bull1counter

	rts

bullet1bkgsmallexplosion

	lda #$02									; set small explosion anim
	sta bull1+sprdata::isexploding
	lda #$ff
	sta bull1+sprdata::xvel
	lda #$00
	sta bull1+sprdata::yvel
	sta bull1counter

	rts

; -----------------------------------------------------------------------------------------------

testbomb0bkgcollision

	sec
	lda bomb0+sprdata::xlow
	sbc #$1a
	sta calcxlow
	lda bomb0+sprdata::xhigh
	sbc #$00
	sta calcxhigh
	sec
	lda bomb0+sprdata::ylow
	sbc #42
	sta calcylow

	lda bomb0+sprdata::ylow						; check if the bomb has gone too low - nasty, but have to do this
	cmp #$df
	bpl :+
	jmp bombinsidescreenok0
	
:	cmp #$00
	bmi :+
	jmp bombinsidescreenok0
	
:	lda #$df									; clamp bomb position
	sta bomb0+sprdata::ylow
	lda #$ff									; and simulate collision with background
	sta calchit
	jmp handlebomb0bkgcollision
	
bombinsidescreenok0

	jsr calcspritepostoscreenpos

	lda calchit
	cmp #$20
	beq :+

	jmp handlebomb0bkgcollision

:	rts

testbomb0sprcollision

	lda bomb0+sprdata::xlow
	sta calcxlow
	lda bomb0+sprdata::xhigh
	sta calcxhigh
	lda bomb0+sprdata::ylow
	sta calcylow

	clc
	lda bomb0+sprdata::xlow
	adc #$08
	sta calcxlowmax
	lda bomb0+sprdata::xhigh
	adc #$00
	sta calcxhighmax
	clc
	lda bomb0+sprdata::ylow
	adc #$08
	sta calcylowmax

	jsr calcspritepostospritepos
	
	lda calcsprhit
	beq :+

	jmp bomb0explode

:	rts

; -----------------------------------------------------------------------------------------------

handlebomb0bkgcollision

	cmp #$ff
	bne :+

	sec
	lda bomb0+sprdata::ylow
	sbc #$08
	sta bomb0+sprdata::ylow
	jmp bomb0explode

:	sec
	lda bomb0+sprdata::ylow
	sbc calcspryoffset
	sta bomb0+sprdata::ylow

	jsr scheduleremovehitobject

bomb0explode

	
	lda #$01									; set explosion anim
	sta bomb0+sprdata::isexploding
	lda #$00
	sta bomb0+sprdata::xvel
	sta bomb0+sprdata::yvel
	sta bomb0counter

	rts

; -----------------------------------------------------------------------------------------------

testbomb1bkgcollision

	sec
	lda bomb1+sprdata::xlow
	sbc #$1a
	sta calcxlow
	lda bomb1+sprdata::xhigh
	sbc #$00
	sta calcxhigh
	sec
	lda bomb1+sprdata::ylow
	sbc #42
	sta calcylow

	lda bomb1+sprdata::ylow						; check if the bomb has gone too low - nasty, but have to do this
	cmp #$df
	bpl :+
	jmp bombinsidescreenok1
	
:	cmp #$00
	bmi :+
	jmp bombinsidescreenok1
	
:	lda #$df									; clamp bomb position
	sta bomb1+sprdata::ylow
	lda #$ff									; and simulate collision with background
	sta calchit
	jmp handlebomb1bkgcollision
	
bombinsidescreenok1

	jsr calcspritepostoscreenpos

	lda calchit
	cmp #$20
	beq :+

	jmp handlebomb1bkgcollision

:	rts
	
testbomb1sprcollision

	lda bomb1+sprdata::xlow
	sta calcxlow
	lda bomb1+sprdata::xhigh
	sta calcxhigh
	lda bomb1+sprdata::ylow
	sta calcylow

	clc
	lda bomb1+sprdata::xlow
	adc #$08
	sta calcxlowmax
	lda bomb1+sprdata::xhigh
	adc #$00
	sta calcxhighmax
	clc
	lda bomb1+sprdata::ylow
	adc #$08
	sta calcylowmax

	jsr calcspritepostospritepos
	
	lda calcsprhit
	beq :+

	jmp bomb1explode

:	rts

; -----------------------------------------------------------------------------------------------

handlebomb1bkgcollision

	cmp #$ff
	bne :+

	sec
	lda bomb1+sprdata::ylow
	sbc #$08
	sta bomb1+sprdata::ylow
	jmp bomb1explode

:	sec
	lda bomb1+sprdata::ylow
	sbc calcspryoffset
	sta bomb1+sprdata::ylow
	
	jsr scheduleremovehitobject

bomb1explode

	lda #$01									; set explosion anim
	sta bomb1+sprdata::isexploding
	lda #$00
	sta bomb1+sprdata::xvel
	sta bomb1+sprdata::yvel
	sta bomb1counter

	rts

; -----------------------------------------------------------------------------------------------

scheduleremovehitobject
	
	inc schedulequeue
	ldx schedulequeue
	
	lda calcylow
	sta scheduledcalcylow,x
	
	lda calcylowvsped
	sta scheduledcalcylowvsped,x
	
	lda calcxlow
	sta scheduledcalcxlow,x
	
	lda calcbkghit
	sta scheduledcalcbkghit,x
	
	rts

; -----------------------------------------------------------------------------------------------

removescheduledobject

	lda schedulequeue
	cmp #$ff									; -1 = nothing in queue
	bne :+
	
	jsr plotfuelplotscoreupdatefuel
	
	rts

:	lda scheduledcalcylow						; get first scheduled position to remove
	sta calcylow
	
	lda scheduledcalcylowvsped
	sta calcylowvsped
	
	lda scheduledcalcxlow
	sta calcxlow
	
	lda scheduledcalcbkghit
	sta calcbkghit
	
	ldx #$00									; move queue
:	lda scheduledcalcylow+1,x
	sta scheduledcalcylow+0,x
	lda scheduledcalcylowvsped+1,x
	sta scheduledcalcylowvsped+0,x
	lda scheduledcalcxlow+1,x
	sta scheduledcalcxlow+0,x
	lda scheduledcalcbkghit+1,x
	sta scheduledcalcbkghit+0,x
	inx
	cpx schedulequeue
	bmi :-

	dec schedulequeue							; decrease queue

removeobject

	clc											; setup clear bitmap 1 tiles
	ldx calcylowvsped
	lda times320lowtable,x
	adc #<bitmap1-1
	sta hbo0+1
	lda times320hightable,x
	adc #>bitmap1-1
	sta hbo0+2
	
	clc
	ldx calcxlow
	lda times8lowtable,x
	adc hbo0+1
	sta hbo0+1
	lda times8hightable,x
	adc hbo0+2
	sta hbo0+2

	clc											; setup clear bitmap 2 tiles
	ldx calcylowvsped
	lda times320lowtable,x
	adc #<bitmap2-1
	sta hbo1+1
	lda times320hightable,x
	adc #>bitmap2-1
	sta hbo1+2
	
	clc
	ldx calcxlow
	lda times8lowtable,x
	adc hbo1+1
	sta hbo1+1
	lda times8hightable,x
	adc hbo1+2
	sta hbo1+2

	clc											; setup clear charmem 1 tiles
	ldx calcylowvsped
	lda times40lowtable,x
	adc #<screen1-1
	sta hbo4+1
	lda times40hightable,x
	adc #>screen1-1
	sta hbo4+2

	clc
	lda calcxlow
	adc hbo4+1
	sta hbo4+1
	lda #$00
	adc hbo4+2
	sta hbo4+2

	clc											; setup clear charmem 2 tiles
	ldx calcylowvsped
	lda times40lowtable,x
	adc #<screen2-1
	sta hbo5+1
	lda times40hightable,x
	adc #>screen2-1
	sta hbo5+2

	clc
	lda calcxlow
	adc hbo5+1
	sta hbo5+1
	lda #$00
	adc hbo5+2
	sta hbo5+2

	clc											; setup clear specialtiles/tilemem tiles
	ldx calcylow
	lda times40lowtable,x
	adc #<screenspecial-1
	sta hbo8+1
	lda times40hightable,x
	adc #>screenspecial-1
	sta hbo8+2

	clc
	lda calcxlow
	adc hbo8+1
	sta hbo8+1
	lda #$00
	adc hbo8+2
	sta hbo8+2

	lda #>clearmisilepositiondata				; setup clear misile position data
	sta hbo10+2
	lda #<clearmisilepositiondata
	sta hbo10+1

	clc
	lda calcxlow
	adc hbo10+1
	sta hbo10+1
	lda #$00
	adc hbo10+2
	sta hbo10+2

	lda flip									; compensate for bank switch
	bne flipped
	
	jmp notflipped
	
flipped	clc
	lda hbo0+1
	adc #$40
	sta hbo0+1
	lda hbo0+2
	adc #$01
	sta hbo0+2
	
	clc
	lda hbo4+1
	adc #$28
	sta hbo4+1
	lda hbo4+2
	adc #$00
	sta hbo4+2
	
	jmp cleartiles
	
notflipped	
	clc
	lda hbo1+1
	adc #$40
	sta hbo1+1
	lda hbo1+2
	adc #$01
	sta hbo1+2

	clc
	lda hbo5+1
	adc #$28
	sta hbo5+1
	lda hbo5+2
	adc #$00
	sta hbo5+2

cleartiles
	clc
	lda hbo0+1
	adc #$40
	sta hbo2+1
	lda hbo0+2
	adc #$01
	sta hbo2+2
	
	;clc
	lda hbo1+1
	adc #$40
	sta hbo3+1
	lda hbo1+2
	adc #$01
	sta hbo3+2

	;clc
	lda hbo4+1
	adc #$28
	sta hbo6+1
	lda hbo4+2
	adc #$00
	sta hbo6+2
	
	;clc
	lda hbo5+1
	adc #$28
	sta hbo7+1
	lda hbo5+2
	adc #$00
	sta hbo7+2

	;clc
	lda hbo8+1
	adc #$28
	sta hbo9+1
	lda hbo8+2
	adc #$00
	sta hbo9+2

	ldx #$10
	lda calcbkghit
hbo0
	sta bitmap1-1,x
hbo1
	sta bitmap2-1,x
hbo2
	sta bitmap1+bitmapwidth-1,x
hbo3
	sta bitmap2+bitmapwidth-1,x
	dex
	bne hbo0

	ldx #$02
	lda #$66
hbo4
	sta screen1,x
hbo5
	sta screen2,x
hbo6
	sta screen1+40,x
hbo7
	sta screen2+40,x
	dex
	bne hbo4

	ldx #$02
	lda #$20
hbo8
	sta screenspecial,x
hbo9
	sta screenspecial+40,x
	dex
	bne hbo8

	lda #$00
hbo10
	sta clearmisilepositiondata

	rts

; -----------------------------------------------------------------------------------------------

animbullet0

	inc bull0counter2
	lda bull0counter2
	cmp #$03
	beq :+
	
	rts
	
:	lda #$00
	sta bull0counter2

	lda bull0+sprdata::isexploding
	cmp #$00
	beq bull0normalanim
	cmp #$01
	beq bull0biganim

	ldx bull0counter
	lda bulletsmallexplosionanim,x
	sta bull0+sprdata::pointer
	
	lda bulletsmallexplosioncolours,x
	sta bull0+sprdata::colour
	
	inc bull0counter
	lda bull0counter
	cmp #$05
	beq bull0explosiondone

	rts
	
bull0biganim
	ldx bull0counter
	lda bulletexplosionanim,x
	sta bull0+sprdata::pointer
	
	lda bulletexplosioncolours,x
	sta bull0+sprdata::colour
	
	inc bull0counter
	lda bull0counter
	cmp #$07
	beq bull0explosiondone

	rts
	
bull0explosiondone
	lda #$ff
	sta bull0+sprdata::ylow
	lda #$00
	sta bull0+sprdata::xlow
	sta bull0+sprdata::xhigh
	sta bull0+sprdata::xvel
	sta bull0+sprdata::yvel
	sta bull0+sprdata::isexploding
	lda #$00
	sta shootingbullet0
	
	lda #$01									; shoot immediately after bullet is gone
	sta bulletcooloff
	
	rts

bull0normalanim
	lda #$13
	sta bull0+sprdata::pointer
	lda #$01
	sta bull0+sprdata::colour

	rts

; -----------------------------------------------------------------------------------------------

animbullet1

	inc bull1counter2
	lda bull1counter2
	cmp #$03
	beq :+
	
	rts
	
:	lda #$00
	sta bull1counter2

	lda bull1+sprdata::isexploding
	cmp #$00
	beq bull1normalanim
	cmp #$01
	beq bull1biganim

	ldx bull1counter
	lda bulletsmallexplosionanim,x
	sta bull1+sprdata::pointer
	
	lda bulletsmallexplosioncolours,x
	sta bull1+sprdata::colour
	
	inc bull1counter
	lda bull1counter
	cmp #$05
	beq bull1explosiondone

	rts
	
bull1biganim

	ldx bull1counter
	lda bulletexplosionanim,x
	sta bull1+sprdata::pointer
	
	lda bulletexplosioncolours,x
	sta bull1+sprdata::colour
	
	inc bull1counter
	lda bull1counter
	cmp #$07
	beq bull1explosiondone

	rts
	
bull1explosiondone
	lda #$ff
	sta bull1+sprdata::ylow
	lda #$00
	sta bull1+sprdata::xlow
	sta bull1+sprdata::xhigh
	sta bull1+sprdata::xvel
	sta bull1+sprdata::yvel
	sta bull1+sprdata::isexploding
	lda #$00
	sta shootingbullet1
	
	lda #$01									; shoot immediately after bullet is gone
	sta bulletcooloff

	rts

bull1normalanim
	lda #$13
	sta bull1+sprdata::pointer
	lda #$01
	sta bull1+sprdata::colour

	rts

; -----------------------------------------------------------------------------------------------

animbomb0

	inc bomb0counter2
	lda bomb0counter2
	cmp #$04
	beq :+
	
	rts
	
:	lda #$00
	sta bomb0counter2

	lda bomb0+sprdata::isexploding
	cmp #$00
	beq bomb0normalanim

	ldx bomb0counter
	lda bombexplosionanim,x
	sta bomb0+sprdata::pointer
	
	lda bombexplosioncolours,x
	sta bomb0+sprdata::colour
	
	inc bomb0counter
	lda bomb0counter
	cmp #$0c
	beq bomb0explosiondone

	rts
	
bomb0explosiondone
	lda #$ff
	sta bomb0+sprdata::ylow
	lda #$00
	sta bomb0+sprdata::xlow
	sta bomb0+sprdata::xhigh
	sta bomb0+sprdata::xvel
	sta bomb0+sprdata::yvel
	sta bomb0+sprdata::isexploding
	lda #$00
	sta shootingbomb0
	
	lda #$01
	sta bombcooloff
	
	rts

bomb0normalanim

	ldx bomb0counter
	lda bombanim,x
	sta bomb0+sprdata::pointer

	lda bombcolours,x
	sta bomb0+sprdata::colour

	inc bomb0counter
	lda bomb0counter
	cmp #$07
	bne :+

	lda #$05
	sta bomb0counter

:	rts

; -----------------------------------------------------------------------------------------------

animbomb1

	inc bomb1counter2
	lda bomb1counter2
	cmp #$04
	beq :+
	
	rts
	
:	lda #$00
	sta bomb1counter2

	lda bomb1+sprdata::isexploding
	cmp #$00
	beq bomb1normalanim

	ldx bomb1counter
	lda bombexplosionanim,x
	sta bomb1+sprdata::pointer
	
	lda bombexplosioncolours,x
	sta bomb1+sprdata::colour
	
	inc bomb1counter
	lda bomb1counter
	cmp #$0c
	beq bomb1explosiondone

	rts
	
bomb1explosiondone
	lda #$ff
	sta bomb1+sprdata::ylow
	lda #$00
	sta bomb1+sprdata::xlow
	sta bomb1+sprdata::xhigh
	sta bomb1+sprdata::xvel
	sta bomb1+sprdata::yvel
	sta bomb1+sprdata::isexploding
	lda #$00
	sta shootingbomb1
	
	lda #$01
	sta bombcooloff

	rts

bomb1normalanim

	ldx bomb1counter
	lda bombanim,x
	sta bomb1+sprdata::pointer

	lda bombcolours,x
	sta bomb1+sprdata::colour

	inc bomb1counter
	lda bomb1counter
	cmp #$07
	bne :+

	lda #$05
	sta bomb1counter

:	rts

; -----------------------------------------------------------------------------------------------

animmissiles

	lda bomb1counter2
	beq :+
	
	rts

:	ldx #$00
hmaloop
	inc sortsprp,x
	inc sortsprp,x
	lda sortsprp,x
	cmp #$3a
	bcc :+
	sec
	lda sortsprp,x
	sbc #$0a
	sta sortsprp,x
:	inx
	cpx #MAXMULTPLEXSPR
	bne hmaloop

	rts

; -----------------------------------------------------------------------------------------------

updatespritepositions1

	lda #$00
	sta highbit+1

	lda bull0+sprdata::xvel
	cmp #$00
	bpl :+

	jmp negativebullet0speed

:	clc
	lda bull0+sprdata::xlow
	adc bull0+sprdata::xvel						; bullet 0 speed
	sta bull0+sprdata::xlow
	lda bull0+sprdata::xhigh
	adc #$00
	and #%00000001
	sta bull0+sprdata::xhigh
	asl
	ora highbit+1
	sta highbit+1

	lda bull0+sprdata::xhigh					; test bullet 0 xhigh
	beq handlebullet1speed
	lda bull0+sprdata::xlow
	cmp #$48
	bcc handlebullet1speed

	lda #$00
	sta shootingbullet0
	lda #$ff
	sta bull0+sprdata::ylow
	jmp handlebullet1speed

negativebullet0speed

	sec
	lda bull0+sprdata::xlow
	sbc scrollspeed
	sta bull0+sprdata::xlow
	lda bull0+sprdata::xhigh
	sbc #$00
	and #%00000001
	sta bull0+sprdata::xhigh
	asl
	ora highbit+1
	sta highbit+1

handlebullet1speed

	lda bull1+sprdata::xvel
	cmp #$00
	bpl :+

	jmp negativebullet1speed

:	clc
	lda bull1+sprdata::xlow
	adc bull1+sprdata::xvel						; bullet 1 speed
	sta bull1+sprdata::xlow
	lda bull1+sprdata::xhigh
	adc #$00
	and #%00000001
	sta bull1+sprdata::xhigh
	asl
	asl
	ora highbit+1
	sta highbit+1

	lda bull1+sprdata::xhigh					; test bullet 1 xhigh
	beq handlebomb0speed
	lda bull1+sprdata::xlow
	cmp #$48
	bcc handlebomb0speed
	
	lda #$00
	sta shootingbullet1
	lda #$ff
	sta bull1+sprdata::ylow
	jmp handlebomb0speed

negativebullet1speed

	sec
	lda bull1+sprdata::xlow
	sbc scrollspeed
	sta bull1+sprdata::xlow
	lda bull1+sprdata::xhigh
	sbc #$00
	and #%00000001
	sta bull1+sprdata::xhigh
	asl
	asl
	ora highbit+1
	sta highbit+1

handlebomb0speed

	clc
	lda bomb0+sprdata::ylow
	adc bomb0+sprdata::yvel						; bomb 0 y speed
	sta bomb0+sprdata::ylow
	lda bomb0+sprdata::xlow
	adc bomb0+sprdata::xvel						; bomb 0 x speed
	sta bomb0+sprdata::xlow

	sec
	lda bomb0+sprdata::xlow
	sbc scrollspeed
	sta bomb0+sprdata::xlow

	clc
	lda bomb1+sprdata::ylow
	adc bomb1+sprdata::yvel						; bomb 1 y speed
	sta bomb1+sprdata::ylow
	lda bomb1+sprdata::xlow
	adc bomb1+sprdata::xvel						; bomb 1 x speed
	sta bomb1+sprdata::xlow

	sec
	lda bomb1+sprdata::xlow
	sbc scrollspeed
	sta bomb1+sprdata::xlow

	lda bomb0+sprdata::xlow
	cmp #$04
	bcs :+
	lda #$00
	sta shootingbomb0
	sta bomb0+sprdata::isexploding
	sta bomb0+sprdata::xvel
	sta bomb0+sprdata::yvel
	lda #$ff
	sta bomb0+sprdata::ylow
	
:	lda bomb1+sprdata::xlow
	cmp #$04
	bcs :+
	lda #$00
	sta shootingbomb1
	sta bomb1+sprdata::isexploding
	sta bomb1+sprdata::xvel
	sta bomb1+sprdata::yvel
	lda #$ff
	sta bomb1+sprdata::ylow
	
:	lda ship0+sprdata::pointer
	sta $83f8
	sta $43f8
	lda bull0+sprdata::pointer
	sta $83f9
	sta $43f9
	lda bull1+sprdata::pointer
	sta $83fa
	sta $43fa
	lda bomb0+sprdata::pointer
	sta $83fb
	sta $43fb
	lda bomb1+sprdata::pointer
	sta $83fc
	sta $43fc

	rts
	
	; ----------------------

updatespritepositions2

	lda $d010
highbit
	ora #$00
	sta $d010

	lda ship0+sprdata::ylow
	sta $d001
	lda ship0+sprdata::xlow
	sta $d000

	lda bull0+sprdata::ylow
	sta $d003
	lda bull0+sprdata::xlow
	sta $d002

	lda bull1+sprdata::ylow
	sta $d005
	lda bull1+sprdata::xlow
	sta $d004

	lda bomb0+sprdata::ylow
	sta $d007
	lda bomb0+sprdata::xlow
	sta $d006

	lda bomb1+sprdata::ylow
	sta $d009
	lda bomb1+sprdata::xlow
	sta $d008

	lda ship0+sprdata::colour
	sta $d027
	lda bull0+sprdata::colour
	sta $d028
	lda bull1+sprdata::colour
	sta $d029
	lda bomb0+sprdata::colour
	sta $d02a
	lda bomb1+sprdata::colour
	sta $d02b

	rts

; -----------------------------------------------------------------------------------------------	

updategroundscore

	lda calchit
	and #%11111100

	cmp #bkgcollision::fuelnoncave
	bne :+
	addpoints #1, 4
	addpoints #5, 5								; add 150 points
	jsr increasefuel
	jmp updatescore
:	cmp #bkgcollision::fuelcave
	bne :+
	addpoints #1, 4
	addpoints #5, 5								; add 150 points
	jsr increasefuel
	jmp updatescore
:	cmp #bkgcollision::standingmissilenoncave
	bne :+
	addpoints #5, 5								; groundmissile = add 50 points (5 at 5th position)
	jmp updatescore
:	cmp #bkgcollision::standingmissilecave
	bne :+
	addpoints #8, 5								; groundmissile cave = add 80 points
	jmp updatescore
:	cmp #bkgcollision::mysterynoncave
	bne :+
	clc											; mystery = add 100/200/300 points (1/2/3 at 4th position)
	lda score+4
	adc mysterytimer
	sta score+4
	jmp updatescore
:	cmp #bkgcollision::mysterycave
	bne :+
	clc											; mystery = add 100/200/300 points (1/2/3 at 4th position)
	lda score+4
	adc mysterytimer
	sta score+4
	jmp updatescore
:	cmp #bkgcollision::bosscave
	bne :+
	lda #$01
	sta gamefinished
	addpoints #8, 4								; boss = add 800 points (8 at 4th position)
	jmp updatescore
	
:	rts

; -----------------------------------------------------------------------------------------------	

updateflyingscore								; hit a flying sprite (missile, ufo)

	lda sortsprtype,x
	cmp #sprcollision::flyingmissile
	bne :+
	addpoints #4, 5								; airmissile = add 80 points (only add 40, because missiles are 2 sprites overlayed)
	jmp updatescore
:	cmp #sprcollision::flyingufo
	bne :+
	addpoints #1, 4								; ufo = add 100 points
	jmp updatescore

:	rts

; -----------------------------------------------------------------------------------------------	

increasefuel

	clc
	lda fuel
	adc fueladd									; add 8 fuel
	sta fuel
	cmp fuelfull
	bcc :+
	lda fuelfull
	sta fuel

:	rts

; -----------------------------------------------------------------------------------------------	

.segment "GAMEPLAY2"

launchcomet

	clc
	lda subzone
	cmp #$23
	bpl :+
	rts

:	cmp #$32
	bmi :+
	rts
	
:	inc comettimer
	lda comettimer
	cmp #$10
	beq :+
	rts
	
:	lda #$00
	sta comettimer

	lda #$50
	sta sortsprxlow,y
	lda #$01
	sta sortsprxhigh,y
	ldx cometnum
	txa
	and #$1f
	tax
	lda posycomet,x								; between #$38 and #$b4?
	sta sortsprylow,y

	lda #$3d
	sta sortsprp,y
	lda #$07
	sta sortsprc,y
	lda #$10
	sta sortsprwidth,y
	lda #$8
	sta sortsprheight,y
	lda #sprcollision::flyingcomet
	sta sortsprtype,y

	inc cometnum

	jsr addmulsprite

	rts
	
; -----------------------------------------------------------------------------------------------	
	
animcomets

	lda bomb1counter2
	beq :+
	
	rts

:	ldx #$00
hcaloop
	inc sortsprp,x
	lda sortsprp,x
	cmp #$40
	bcc :+
	lda #$3d									; $8f40 8f80 8fc0
	sta sortsprp,x
:	inx
	cpx #MAXMULTPLEXSPR
	bne hcaloop

	rts
	
; -----------------------------------------------------------------------------------------------	

handlecometmovement


	ldx #MAXMULTPLEXSPR
hcmloop
	lda sortsprylow-1,x
	cmp #$ff
	beq :+										; don't move sprites if they are not on screen
	inc sortsprlifetime-1,x
	lda sortsprlifetime-1,x
	and #%00111111
	tay
	sec											; decrease x position
	lda sortsprxlow-1,x
	sbc #$06
	sta sortsprxlow-1,x
	lda sortsprxhigh-1,x
	sbc #$00
	sta sortsprxhigh-1,x
	bne :+
	lda sortsprxlow-1,x							; test if out of screen
	cmp #$10
	bcs :+
	lda #$ff
	sta sortsprylow-1,x
:	dex
	bne hcmloop


	rts
	
; -----------------------------------------------------------------------------------------------	

launchufo

	clc
	lda subzone
	cmp #$13
	bpl :+
	rts

:	cmp #$18
	bmi :+
	rts

:	inc ufotimer
	lda ufotimer
	cmp ufospawntime
	beq :+
	
	rts
	
:	lda #$00
	sta ufotimer

	ldy curmulsprite

	lda #$50
	sta sortsprxlow,y
	lda #$01
	sta sortsprxhigh,y
	lda sinyufo
	sta sortsprylow,y

	lda #$3d
	sta sortsprp,y
	lda #$03
	sta sortsprc,y
	lda #$10
	sta sortsprwidth,y
	lda #$08
	sta sortsprheight,y
	lda #sprcollision::flyingufo
	sta sortsprtype,y

	ldx ufonum
	txa
	and #$04
	tax
	lda timesufotable,x
	sta sortsprlifetime,y

	inc ufonum

	jsr addmulsprite

	rts

; -----------------------------------------------------------------------------------------------	

animufos

	lda bomb1counter2
	beq :+
	
	rts

:	ldx #$00
hualoop
	inc sortsprp,x
	lda sortsprp,x
	cmp #$3d
	bcc :+
	lda #$3a									; 8E80, 8ec0, 8f00
	sta sortsprp,x
:	inx
	cpx #MAXMULTPLEXSPR
	bne hualoop

	rts

; -----------------------------------------------------------------------------------------------	

handleufomovement

	ldx #MAXMULTPLEXSPR
humloop
	lda sortsprylow-1,x
	cmp #$ff
	beq :+										; don't move sprites if they are not on screen
	inc sortsprlifetime-1,x
	lda sortsprlifetime-1,x
	and #%00111111
	tay
	lda sinyufo,y
	sta sortsprylow-1,x
	sec											; decrease x position
	lda sortsprxlow-1,x
	sbc scrollspeed
	sta sortsprxlow-1,x
	lda sortsprxhigh-1,x
	sbc #$00
	sta sortsprxhigh-1,x
	bne :+
	lda sortsprxlow-1,x							; test if out of screen
	cmp #$10
	bcs :+
	lda #$ff
	sta sortsprylow-1,x
:	dex
	bne humloop

	rts

; -----------------------------------------------------------------------------------------------	

launchmissile

	lda randomseed
	beq doeor
	asl
	beq noeor									; if the input was $80, skip the EOR
	bcc noeor
doeor
	eor #$1f
noeor
	sta randomseed
	and #%00011001								; #%00001111 = pretty good random seed, make sure this is uneven otherwise we get half missiles
	sta misofst+1

	;lda #$25									; testing - launch as soon as possible
	;sta misofst+1

	lda #$00
	sta flipflop

	clc
	lda column
	adc #$01
misofst
	adc #$00
	cmp #$28
	bcc :+

	sec
	sbc #$28

	ldx #$01
	stx flipflop

:	tax
	lda $c3c0,x
	beq :+
	jmp missilefound

:	rts

missilefound

	sta calcylow
	sta calcylowvsped
	stx calcxlow
	lda #$aa
	sta calcbkghit
	
	lda flipflop
	bne :+
	
	dec calcylowvsped
	
:	clc
	ldx calcylow
	lda times8lowtable,x
	adc #$2f-21-3
	sta startmissileypos

	ldx #MAXMULTPLEXSPR
:	lda sortsprylow-1,x
	cmp #$ff
	beq :+
	cmp startmissileypos
	bcs :++
:	dex
	bne :--
	
	jmp oktoremove
	
:	rts

oktoremove

	jsr scheduleremovehitobject

	clc
	ldx calcxlow
	lda times8lowtable,x
	adc screenposlow
	sta calcxlow
	lda times8hightable,x
	adc screenposhigh
	sta calcxhigh
	
	lda flipflop
	bne :+
	
	sec
	lda calcxlow
	sbc #$40
	sta calcxlow
	lda calcxhigh
	sbc #$01
	sta calcxhigh

:	clc
	lda calcxlow
	adc #$1a
	sta calcxlow
	lda calcxhigh
	adc #$00
	sta calcxhigh

	clc
	ldx calcylow
	lda times8lowtable,x
	adc #$35
	sta calcylow

	ldy curmulsprite

	lda calcxlow
	sta sortsprxlow,y
	lda calcxhigh
	sta sortsprxhigh,y
	lda calcylow
	sta sortsprylow,y

	lda #$33
	sta sortsprp,y
	lda #$02
	sta sortsprc,y
	lda #$0c
	sta sortsprwidth,y
	lda #$10
	sta sortsprheight,y
	lda #sprcollision::flyingmissile
	sta sortsprtype,y

	jsr addmulsprite

	ldy curmulsprite

	lda calcxlow
	sta sortsprxlow,y
	lda calcxhigh
	sta sortsprxhigh,y
	lda calcylow
	sta sortsprylow,y

	lda #$32
	sta sortsprp,y
	lda #$07									; missile highlight colour
	sta sortsprc,y
	lda #$0c
	sta sortsprwidth,y
	lda #$10
	sta sortsprheight,y
	lda #sprcollision::flyingmissile
	sta sortsprtype,y
	
	jsr addmulsprite

	rts

; -----------------------------------------------------------------------------------------------	

handlemissilemovement

	ldx #MAXMULTPLEXSPR
hmmloop
	lda sortsprylow-1,x
	cmp #$ff
	beq :++										; don't move sprites if they are not on screen
	dec sortsprylow-1,x							; decrease y position
	lda sortsprylow-1,x							; test if out of screen
	cmp #$20
	bcs :+
	lda #$ff
	sta sortsprylow-1,x
:	sec											; decrease x position with scrollspeed
	lda sortsprxlow-1,x
	sbc scrollspeed
	sta sortsprxlow-1,x
	lda sortsprxhigh-1,x
	sbc #$00
	sta sortsprxhigh-1,x
	bne :+
	lda sortsprxlow-1,x							; test if out of screen
	cmp #$10
	bcs :+
	lda #$ff
	sta sortsprylow-1,x
:	dex
	bne hmmloop

	rts

; -----------------------------------------------------------------------------------------------	

initmultsprites

	ldx #$00
:	txa
	sta sortorder,x
	inx
	cpx #MAXMULTPLEXSPR
	bne :-

	lda #$ff
	sta cvsppos+1
	
	rts

; -----------------------------------------------------------------------------------------------	

addmulsprite

	inc curmulsprite
	lda curmulsprite
	cmp #MAXMULTPLEXSPR
	bne :+
	lda #$00
	sta curmulsprite
:	rts

jumpbackforwardsort
	ldx sortcounter
	lda sortskipslow,x
	sta jumpsortptr+1
	lda sortskipshigh,x
	sta jumpsortptr+2
	
jumpsortptr
	jmp sortskip1

backsort0
	ldy sortorder+1								; compare first pair
	lda sortsprylow,y
	ldy sortorder+0
	cmp sortsprylow,y
	bcc :+										; swap
	jmp jumpbackforwardsort						; don't swap, continue with where we were in the forward sort
:	lda sortorder+1
	sta sortorder+0
	sty sortorder+1
	jmp jumpbackforwardsort						; continue with where we were in the forward sort

backsort1
	ldy sortorder+2								; compare second pair
	lda sortsprylow,y
	ldy sortorder+1
	cmp sortsprylow,y
	bcc :+										; swap
	jmp jumpbackforwardsort						; don't swap, continue with where we were in the forward sort
:	lda sortorder+2
	sta sortorder+1
	sty sortorder+2
	jmp backsort0								; and continue with the first pair

backsort2
	ldy sortorder+3								; compare second pair
	lda sortsprylow,y
	ldy sortorder+2
	cmp sortsprylow,y
	bcc :+										; swap
	jmp jumpbackforwardsort						; don't swap, continue with where we were in the forward sort
:	lda sortorder+3
	sta sortorder+2
	sty sortorder+3
	jmp backsort1								; and continue with the second pair

backsort3
	ldy sortorder+4								; compare second pair
	lda sortsprylow,y
	ldy sortorder+3
	cmp sortsprylow,y
	bcc :+										; swap
	jmp jumpbackforwardsort						; don't swap, continue with where we were in the forward sort
:	lda sortorder+4
	sta sortorder+3
	sty sortorder+4
	jmp backsort2								; and continue with the second pair

backsort4
	ldy sortorder+5								; compare second pair
	lda sortsprylow,y
	ldy sortorder+4
	cmp sortsprylow,y
	bcc :+										; swap
	jmp jumpbackforwardsort						; don't swap, continue with where we were in the forward sort
:	lda sortorder+5
	sta sortorder+4
	sty sortorder+5
	jmp backsort3								; and continue with the second pair

backsort5
	ldy sortorder+6								; compare second pair
	lda sortsprylow,y
	ldy sortorder+5
	cmp sortsprylow,y
	bcc :+										; swap
	jmp jumpbackforwardsort						; don't swap, continue with where we were in the forward sort
:	lda sortorder+6
	sta sortorder+5
	sty sortorder+6
	jmp backsort4								; and continue with the second pair

backsort6
	ldy sortorder+7								; compare second pair
	lda sortsprylow,y
	ldy sortorder+6
	cmp sortsprylow,y
	bcc :+										; swap
	jmp jumpbackforwardsort						; don't swap, continue with where we were in the forward sort
:	lda sortorder+7
	sta sortorder+6
	sty sortorder+7
	jmp backsort5								; and continue with the second pair

backsort7
	ldy sortorder+8								; compare second pair
	lda sortsprylow,y
	ldy sortorder+7
	cmp sortsprylow,y
	bcc :+										; swap
	jmp jumpbackforwardsort						; don't swap, continue with where we were in the forward sort
:	lda sortorder+8
	sta sortorder+7
	sty sortorder+8
	jmp backsort6								; and continue with the second pair

backsort8
	ldy sortorder+9								; compare second pair
	lda sortsprylow,y
	ldy sortorder+8
	cmp sortsprylow,y
	bcc :+										; swap
	jmp jumpbackforwardsort						; don't swap, continue with where we were in the forward sort
:	lda sortorder+9
	sta sortorder+8
	sty sortorder+9
	jmp backsort7								; and continue with the second pair

backsort9
	ldy sortorder+10							; compare second pair
	lda sortsprylow,y
	ldy sortorder+9
	cmp sortsprylow,y
	bcc :+										; swap
	jmp jumpbackforwardsort						; don't swap, continue with where we were in the forward sort
:	lda sortorder+10
	sta sortorder+9
	sty sortorder+10
	jmp backsort8								; and continue with the second pair

sortmultsprites

	;jmp oldsortmultsprites

; rewrite to go forward and increase counter, go backwards and don't increase counter

	lda #$00
	sta sortcounter

sortskip0

	ldy sortorder+1								; compare first and second sprite
	lda sortsprylow,y
	ldy sortorder+0
	cmp sortsprylow,y
	bcs sortskip1incsortcounter					; don't swap, continue with second and third sprite
	lda sortorder+1								; swap
	sta sortorder+0
	sty sortorder+1								; and continue with second and third sprite
	
sortskip1incsortcounter
	inc sortcounter								; we're now sorting the second pair
sortskip1
	ldy sortorder+2								; compare second and third sprite
	lda sortsprylow,y
	ldy sortorder+1
	cmp sortsprylow,y
	bcs sortskip2incsortcounter					; don't swap, continue with third and fourth sprite
	lda sortorder+2								; swap
	sta sortorder+1
	sty sortorder+2
	jmp backsort0								; and jump to backwards sort
	
sortskip2incsortcounter
	inc sortcounter								; sorting third pair
sortskip2
	ldy sortorder+3
	lda sortsprylow,y
	ldy sortorder+2
	cmp sortsprylow,y
	bcs sortskip3incsortcounter
	lda sortorder+3
	sta sortorder+2
	sty sortorder+3
	jmp backsort1

sortskip3incsortcounter
	inc sortcounter
sortskip3
	ldy sortorder+4
	lda sortsprylow,y
	ldy sortorder+3
	cmp sortsprylow,y
	bcs sortskip4incsortcounter
	lda sortorder+4
	sta sortorder+3
	sty sortorder+4
	jmp backsort2

sortskip4incsortcounter
	inc sortcounter
sortskip4
	ldy sortorder+5
	lda sortsprylow,y
	ldy sortorder+4
	cmp sortsprylow,y
	bcs sortskip5incsortcounter
	lda sortorder+5
	sta sortorder+4
	sty sortorder+5
	jmp backsort3

sortskip5incsortcounter
	inc sortcounter
sortskip5
	ldy sortorder+6
	lda sortsprylow,y
	ldy sortorder+5
	cmp sortsprylow,y
	bcs sortskip6incsortcounter
	lda sortorder+6
	sta sortorder+5
	sty sortorder+6
	jmp backsort4

sortskip6incsortcounter
	inc sortcounter
sortskip6
	ldy sortorder+7
	lda sortsprylow,y
	ldy sortorder+6
	cmp sortsprylow,y
	bcs sortskip7incsortcounter
	lda sortorder+7
	sta sortorder+6
	sty sortorder+7
	jmp backsort5
	
sortskip7incsortcounter
	inc sortcounter
sortskip7
	ldy sortorder+8
	lda sortsprylow,y
	ldy sortorder+7
	cmp sortsprylow,y
	bcs sortskip8incsortcounter
	lda sortorder+8
	sta sortorder+7
	sty sortorder+8
	jmp backsort6
	
sortskip8incsortcounter
	inc sortcounter
sortskip8
	ldy sortorder+9
	lda sortsprylow,y
	ldy sortorder+8
	cmp sortsprylow,y
	bcs sortskip9incsortcounter
	lda sortorder+9
	sta sortorder+8
	sty sortorder+9
	jmp backsort7
	
sortskip9incsortcounter
	inc sortcounter
sortskip9
	ldy sortorder+10
	lda sortsprylow,y
	ldy sortorder+9
	cmp sortsprylow,y
	bcs sortskip10incsortcounter
	lda sortorder+10
	sta sortorder+9
	sty sortorder+10
	jmp backsort8
	
sortskip10incsortcounter
	inc sortcounter
sortskip10
	ldy sortorder+11
	lda sortsprylow,y
	ldy sortorder+10
	cmp sortsprylow,y
	bcs sortskip11incsortcounter
	lda sortorder+11
	sta sortorder+10
	sty sortorder+11
	jmp backsort9
	
sortskip11incsortcounter
sortskip11
	rts

oldsortmultsprites
	
;	ldx #$00
;	stx sreload+1
;sloop
;	ldy sortorder+1,x							; y = second sprite index
;	lda sortsprylow,y							; a = ypos of second sprite
;	ldy sortorder,x								; y = first sprite index
;	cmp sortsprylow,y							; subtract ypos of second sprite with ypos of first sprite 
;	bcs sskip									; branch (continue) if the ypos of second sprite is equal to or larger than the ypos of the first sprite
;
;	stx sreload+1								; the ypos of the second sprite is lower - store current sort sprite index
;sswap
;	lda sortorder+1,x							; swap the first and second sprite
;	sta sortorder,x
;	tya
;	sta sortorder+1,x
;	cpx #$00									; are we at the start of the sort order list?
;	beq sreload									; yes - no need to swap more, continue with the rest of the sprites
;	dex											; no, decrease the sprite index
;	ldy sortorder+1,x							; and compare the two sprite indices
;	lda sortsprylow,y
;	ldy sortorder,x
;	cmp sortsprylow,y
;	bcc sswap
;sreload
;	ldx #$00
	
;sskip
;	inx
;	cpx #MAXMULTPLEXSPR-1
;	bcc sloop

;	rts

; -----------------------------------------------------------------------------------------------	

plotdummymultsprites
	rts

plotfirstufomultsprites

	ldy sortorder								; y = index to highest sprite
	lda sortsprc,y
	sta $d02c
	lda sortsprp,y
	sta $83fd
	sta $43fd
	lda sortsprxhigh,y
	beq msbluw
	lda $d010
	ora #%00100000
	sta $d010
	jmp :+

msbluw
	lda $d010
	and #%11011111
	sta $d010
:	lda sortsprxlow,y
	sta $d00a
	lda sortsprylow,y
	sta $d00b

	ldy sortorder+1								; y = index to second highest sprite
	lda sortsprc,y
	sta $d02d
	lda sortsprp,y
	sta $83fe
	sta $43fe
	lda sortsprxhigh,y
	beq msbluw2
	lda $d010
	ora #%01000000
	sta $d010
	jmp :+

msbluw2
	lda $d010
	and #%10111111
	sta $d010
:	lda sortsprxlow,y
	sta $d00c
	lda sortsprylow,y
	sta $d00d

	ldy sortorder+2								; y = index to third highest sprite
	lda sortsprc,y
	sta $d02e
	lda sortsprp,y
	sta $83ff
	sta $43ff
	lda sortsprxhigh,y
	beq msbluw3
	lda $d010
	ora #%10000000
	sta $d010
	jmp :+

msbluw3
	lda $d010
	and #%01111111
	sta $d010
:	lda sortsprxlow,y
	sta $d00e
	lda sortsprylow,y
	sta $d00f

	rts

plotrestufomultsprites

	lda #$03
	sta restmultspritesindex

pruloop
	ldx restmultspritesindex					; x = virtual sprite index (1-MAXMULTPLEXSPR)
	ldy sortorder,x								; y = index to real sprite index
	lda sortsprylow,y
	cmp #$ff
	bne hctst2

	jmp puend

hctst2
	ldx restmultspritesindex					; see how much time we have before the next sprite
	ldy sortorder,x
	lda sortsprylow,y
	cmp #$ff
	beq puend

	sec
	sbc $d012
	clc
	cmp #$28									; #$28 rasterlines left? do some stuff!
	bcc :+
	jsr handlecollisions
	jmp hctst2

:	lda sortsprylow,y
	sec
	sbc #$03
:	cmp $d012
	bcs :-										; wait until rasterline reached

	lda sprtbl,x
	tax
	lda sortsprc,y
	sta $d02c,x
	lda sortsprp,y
	sta $83fd,x
	sta $43fd,x
	lda sortsprxhigh,y
	beq msbluw4
	lda $d010
	ora ortbl,x
	sta $d010
	jmp :+

msbluw4
	lda $d010
	and andtbl,x
	sta $d010
:	txa
	asl
	tax
	lda sortsprxlow,y
	sta $d00a,x
	lda sortsprylow,y
	sta $d00b,x

	inc restmultspritesindex
	lda restmultspritesindex
	cmp #MAXMULTPLEXSPR
	beq puend
	jmp pruloop

puend
	jsr handlerestcollisions
	
	rts

plotfirstmissilemultsprites

	ldy sortorder								; y = index to highest sprite
	lda sortsprc,y
	sta $d02d
	lda sortsprp,y
	sta $83fe
	sta $43fe
	lda sortsprxhigh,y
	beq msblow
	lda $d010
	ora #%01000000
	sta $d010
	
	jmp :+

msblow
	lda $d010
	and #%10111111
	sta $d010
:	lda sortsprxlow,y
	sta $d00c
	lda sortsprylow,y
	sta $d00d

	ldy sortorder+1								; y = index to second highest sprite
	lda sortsprc,y
	sta $d02e
	lda sortsprp,y
	sta $83ff
	sta $43ff
	lda sortsprxhigh,y
	beq msblow2
	lda $d010
	ora #%10000000
	sta $d010
	jmp :+

msblow2
	lda $d010
	and #%01111111
	sta $d010
:	lda sortsprxlow,y
	sta $d00e
	lda sortsprylow,y
	sta $d00f

	sta cvsppos+1

	rts

plotrestmissilemultsprites

	lda #$02
	sta restmultspritesindex

prmloop
	ldx restmultspritesindex					; x = virtual sprite index (1-MAXMULTPLEXSPR)
	ldy sortorder,x								; y = index to real sprite index
	lda sortsprylow,y
	cmp #$ff
	bne hctest

	jmp msend
	
hctest
	ldx restmultspritesindex					; see how much time we have before the next sprite
	ldy sortorder,x
	lda sortsprylow,y
	cmp #$ff
	beq msend
	
	sec
	sbc $d012
	clc
	cmp #$28									; #$28 rasterlines left? do some stuff!
	bcc :+
	jsr handlecollisions
	jmp hctest

:	lda sortsprylow,y
	sec
	sbc #$0c
:	cmp $d012
	bcs :-										; wait until rasterline reached
	
	txa
	and #$01
	tax
	lda sortsprc,y
	sta $d02d,x
	lda sortsprp,y
	sta $83fe,x
	sta $43fe,x
	lda sortsprxhigh,y
	beq msblow3
	lda $d010
	ora ortbl+1,x
	sta $d010
	jmp :+

msblow3
	lda $d010
	and andtbl+1,x
	sta $d010
:	txa
	asl
	tax
	lda sortsprxlow,y
	sta $d00c,x
	lda sortsprylow,y
	sta $d00d,x

	inc restmultspritesindex
	lda restmultspritesindex
	cmp #MAXMULTPLEXSPR
	beq msend
	
	jmp prmloop

msend
	jsr handlerestcollisions
	
	rts

sprtbl
.byte $00,$01,$02,$00,$01,$02,$00,$01,$02,$00,$01,$02
ortbl
.byte %00100000, %01000000, %10000000
andtbl
.byte %11011111, %10111111, %01111111

; -----------------------------------------------------------------------------------------------	

.segment "SCROLLER"

plottiles

	ldy #$03

plotloop
	clc
gett1
	lda loadeddata1+0*2
	sta currenttile+0
	sta currenttiletimes8+0
	;adc #$00
	sta plotc1+1
gett2
	lda loadeddata1+1+0*2
	sta currenttile+1
	sta currenttiletimes8+1
	adc #>maptilecolors
	sta plotc1+2
	
	lda currenttile+1							; > 256 = always solid tile
	;cmp #$00
	bne solidtile
	
	lda currenttile+0
	;cmp #$00
	bmi solidtile								; < 0 = solid tile
	cmp #$43
	bpl solidtile								; > 62 = solid tile
	
	lda currenttile+0
	cmp #$20
	bpl transtile								; > 32 && < 63 = transparent tile

missilefuelspecialtile
	lda currenttile+0
	and #%00011111
	sta currenttile+0
	jmp skipspecialtiles
	
transtile
	lda #$20
	sta currenttile+0
	jmp skipspecialtiles

solidtile
	lda #$ff
	sta currenttile+0
	jmp skipspecialtiles

skipspecialtiles
	asl currenttiletimes8+0
	rol currenttiletimes8+1
	asl currenttiletimes8+0
	rol currenttiletimes8+1
	asl currenttiletimes8+0
	rol currenttiletimes8+1
	
	clc
	lda currenttiletimes8+0
	;adc #$00
	sta ploth1+1
	lda currenttiletimes8+1
	adc #>maptiles
	sta ploth1+2

	ldx #$07
ploth1
	lda $e000,x
ploth2
	sta bitmap2+1*320,x
ploth3
	sta bitmap1+0*320,x
	dex
	bpl ploth1

plotc1
	lda maptilecolors+1
plotc2
	sta screen2+1*40
plotc3
	sta screen1+0*40

	lda currenttile+0
plott1
	sta screenspecial

	clc
	add16bit gett1, 2
	add16bit gett2, 2
	add16bit ploth2, 320
	add16bit ploth3, 320
	add16bit plotc2, 40
	add16bit plotc3, 40
	add16bit plott1, 40
	inc row
	
	dey
	beq plotdone
	
	jmp plotloop

plotdone
	lda row
	cmp #$18
	bne incrow2
	
	jmp inccol

incrow2
	rts

;-------------------------------------

inccol
	lda #$00
	sta row

	inc column
	lda column
	cmp #$28
	bne inccol2

	jmp incpag

inccol2
	lda gett2+1									; do missile stuff
	sta plott2+1
	lda gett2+2
	sta plott2+2

	lda plott1+1
	sta plott3+1
	lda plott1+2
	sta plott3+2
	
plott2	lda loadeddata1
plott3	sta $c3c0

	clc
	add16bit gett1, 2
	add16bit gett2, 2							; end of do missile stuff

	sec
	sub16bit ploth2, 24*320-8
	sub16bit ploth3, 24*320-8
	sub16bit plotc2, 24*40-1
	sub16bit plotc3, 24*40-1
	sub16bit plott1, 24*40-1

	rts

;-------------------------------------

incpag
	lda #$00
	sta column
	
	jsr incsubzone
	jsr loadfile

	inc flip
	lda flip
	cmp #$02
	beq incpag2
	
	jmp incpag3

incpag2
	lda #$00
	sta flip
	lda #$01
	sta page+1
	store16bit gett1, loadeddata1+0*2
	store16bit gett2, loadeddata1+1+0*2
	store16bit ploth2, bitmap2+1*320
	store16bit ploth3, bitmap1+0*320
	store16bit plotc2, screen2+1*40
	store16bit plotc3, screen1+0*40
	store16bit plott1, screenspecial+0*40
	rts
	
incpag3
	lda #$02
	sta page+1
	store16bit gett1, loadeddata2+0*2
	store16bit gett2, loadeddata2+1+0*2
	store16bit ploth2, bitmap1+1*320
	store16bit ploth3, bitmap2+0*320
	store16bit plotc2, screen1+1*40
	store16bit plotc3, screen2+0*40
	store16bit plott1, screenspecial+0*40
	rts

; -----------------------------------------------------------------------------------------------

incsubzone

	inc subzone									; increase screen/subzone
	ldx subzone
	lda subzones,x
	cmp #$ff									; is it 255?
	bne :++
	
:	inc subzone									; yes, keep increasing until it's not 255 any more
	ldx subzone
	lda subzones,x
	cmp #$ff
	beq :-
	inc zone									; increase zone
	inc subzone									; increase subzone one more time to jump over the 'you're dead, start on this empty screen'-subzone
	jmp :++
	
:	cmp #$31									; is it the boss screen?
	bne :+
	dec subzone
	
:	ldx subzone									; load next subzone
	lda subzones,x
	sta file
	
	rts

findstartofzone

	lda subzone									; decrease twice, to make sure we don't skip to the next zone if we die at the end of a zone
	cmp #$03
	bmi :++
	dec subzone
	dec subzone

:	dec subzone
	ldx subzone
	lda subzones,x
	cmp #$ff
	beq :-

:	ldx subzone									; decrease subzone until end of previous zone is found

	cpx #$00
	beq :+
	dec subzone
	ldx subzone
	lda subzones,x
	cmp #$ff
	bne :-
	inc subzone
	
:	ldx subzone
	lda subzones,x
	sta file
	
	rts
	
; -----------------------------------------------------------------------------------------------

subzones
.byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.byte $0a,$0b,$0c,$0d,$0e,$0f,$10,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.byte $12,$13,$14,$15,$16,$17,$18,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.byte $1a,$1b,$1c,$1d,$1e,$1f,$20,$21,$22,$23,$24,$ff,$ff,$ff,$ff,$ff
.byte $26,$27,$28,$29,$2a,$2b,$2c,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
.byte $2e,$2f,$30,$31,$32,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff

zonetab
.byte $01,$0d,$15,$1d,$29,$31

loadfile
	lda file

	;cmp #$02
	;bne :+
	
	ldx #$00
:	lda zonetab,x
	cmp file
	beq :+
	inx
	cpx #$06
	bne :-
	jmp :++

:	lda zonecodeptrslow,x
	sta handlezonecode+1
	lda zonecodeptrshigh,x
	sta handlezonecode+2

	lda zonecode2ptrslow,x
	sta handlezonecode2+1
	lda zonecode2ptrshigh,x
	sta handlezonecode2+2

	lda zonecode3ptrslow,x
	sta handlezonecode3+1
	lda zonecode3ptrshigh,x
	sta handlezonecode3+2

	lda zonecode4ptrslow,x
	sta handlezonecode4+1
	lda zonecode4ptrshigh,x
	sta handlezonecode4+2

	jsr initmultsprites

:	ldx zone
	dex

	lda zonecolour1
	sta zonecolours,x

	lda file
	and #%00001111
	tax
	lda filenameconvtab,x
	sta file01+1
	
	lda file
	lsr
	lsr
	lsr
	lsr
	tax
	lda filenameconvtab,x
	sta file01

	lda #states::loadingsubzone
	sta state+1

	rts

; -----------------------------------------------------------------------------------------------

scrollspeed
.byte $01

scrollscreen

	sec
	lda screenposlow
	sbc scrollspeed
	sta screenposlow
	lda screenposhigh
	sbc #$00
	sta screenposhigh
	cmp #$ff
	bne :+
	
	ldx #>(bitmapwidth-1)
	ldy #<(bitmapwidth-1)
	stx screenposhigh
	sty screenposlow
	
:	rts

; -----------------------------------------------------------------------------------------------

calcvsp

	sec											; first calculate the inverse numbers
	lda #<(bitmapwidth-1)
	sbc screenposlow
	sta invscreenposlow
	lda #>(bitmapwidth-1)
	sbc screenposhigh
	sta invscreenposhigh

	clc
	lda invscreenposlow
	and #$07
	eor #$07
	adc #$10
	sta scrlow+1

	clc
	lda invscreenposhigh						; divide the 16 bit number by 8
	ror											; shift bit into carry
	lda invscreenposlow
	ror											; shift carry back in
	lsr
	lsr
	
	sta foo3+1
	
	rts

; -----------------------------------------------------------------------------------------------

correctvspsprites

	lda #$36

	clc
cvsppos
	ldx #$ff
	cpx #$33
	bcs not1
	adc #$07									; #$07 for 2 sprites
	cpx #$32
	bcs not1
	adc #$07

not1
	sta vspcor+1
	
	rts

; -----------------------------------------------------------------------------------------------

plotfuelplotscoreupdatefuel

	lda $01
	pha
	lda #$35
	sta $01
	
.macro tick arg1, arg2
	sec
	lda fuel									; load fuel
	sbc #(arg2)									; deduct arg2
	bcs :+
	lda #$00
:	tax
	lda fuelticks,x
	;sta arg1+0*3
	sta arg1+1*3
	sta arg1+2*3
	sta arg1+3*3
	sta arg1+4*3
	;sta arg1+5*3
.endmacro

	;tick scoreandfuelsprites+$0086+(0*64), 0+(0*3*4)		; 3 * 4 expanded pixels in a sprite horizontally
	tick scoreandfuelsprites+$0087+(0*64), 0+(0*3*4)
	tick scoreandfuelsprites+$0088+(0*64), 4+(0*3*4)

	tick scoreandfuelsprites+$0086+(1*64), 8+(0*3*4)
	tick scoreandfuelsprites+$0087+(1*64), 0+(1*3*4)
	tick scoreandfuelsprites+$0088+(1*64), 4+(1*3*4)

	tick scoreandfuelsprites+$0086+(2*64), 8+(1*3*4)
	tick scoreandfuelsprites+$0087+(2*64), 0+(2*3*4)
	tick scoreandfuelsprites+$0088+(2*64), 4+(2*3*4)

	tick scoreandfuelsprites+$0086+(3*64), 8+(2*3*4)
	tick scoreandfuelsprites+$0087+(3*64), 0+(3*3*4)
	tick scoreandfuelsprites+$0088+(3*64), 4+(3*3*4)

	tick scoreandfuelsprites+$0086+(4*64), 8+(3*3*4)
	tick scoreandfuelsprites+$0087+(4*64), 0+(4*3*4)
	tick scoreandfuelsprites+$0088+(4*64), 4+(4*3*4)

; plotscore

updatedigit0
	lda score+0
	cmp prevscore+0
	beq updatedigit1
	plotdigit score+0, scoredigit0

updatedigit1
	lda score+1
	cmp prevscore+1
	beq updatedigit2
	plotdigit score+1, scoredigit1

updatedigit2
	lda score+2
	cmp prevscore+2
	beq updatedigit3
	plotdigit score+2, scoredigit2
	lda lives
	cmp #$09
	beq :+
	inc lives									; award extra life at every 10000 points
:	plotdigit lives, livesdigit0

updatedigit3
	lda score+3
	cmp prevscore+3
	beq updatedigit4
	plotdigit score+3, scoredigit3

updatedigit4
	lda score+4
	cmp prevscore+4
	beq updatedigit5
	plotdigit score+4, scoredigit4

updatedigit5
	lda score+5
	cmp prevscore+5
	beq updateprevscore
	plotdigit score+5, scoredigit5

updateprevscore
	lda score+0
	sta prevscore+0
	lda score+1
	sta prevscore+1
	lda score+2
	sta prevscore+2
	lda score+3
	sta prevscore+3
	lda score+4
	sta prevscore+4
	lda score+5
	sta prevscore+5
	
updatefuel

	inc fueltimer
	lda fueltimer
	cmp fueldecreaseticks							
	bne :+

	lda #$00
	sta fueltimer

.if fueldecreases
	dec fuel
.endif
	lda fuel
	cmp #$ff
	bne :+

	lda #$00
	sta fuel

:	pla
	sta $01
	
	rts

; -----------------------------------------------------------------------------------------------

updatescore

	ldx #$05
usloop
	clc
	lda score,x
	cmp #$0a
	bcc :+
	sec
	sbc #$0a
	sta score,x
	clc
	lda score-1,x
	adc #$01
	sta score-1,x
:	dex
	bne usloop

	rts

; -----------------------------------------------------------------------------------------------

calcspritepostospritepos

	lda #$00
	sta calcsprhit

	ldx #$00
cssloop
	lda sortsprylow,x
	cmp #$ff
	beq dontintersect

	cmp calcylowmax
	bcs dontintersect

	clc
	lda sortsprylow,x
	adc sortsprheight,x
	sec
	cmp calcylow
	bcc dontintersect

	sec
	lda sortsprxlow,x
	sbc calcxlowmax
	lda sortsprxhigh,x
	sbc calcxhighmax
	bcs dontintersect

	clc
	lda sortsprxlow,x
	adc sortsprwidth,x
	sta sortsprxlowmax,x
	lda sortsprxhigh,x
	adc #$00
	sta sortsprxhighmax,x

	sec
	lda sortsprxlowmax,x
	sbc calcxlow
	lda sortsprxhighmax,x
	sbc calcxhigh
	bcc dontintersect

	lda sortsprtype,x
	cmp #$03
	bne :+
	lda #$02
	sta calcsprhit
	jmp dontintersect
:	lda #$01
	sta calcsprhit
	lda #$ff
	sta sortsprylow,x
	jsr updateflyingscore

dontintersect	
	inx
	cpx #MAXMULTPLEXSPR
	bne cssloop
	
	rts

; -----------------------------------------------------------------------------------------------	

calcshippostospritepos

	lda #$00
	sta calcsprhit

	ldx #$00
cssloop2
	lda sortsprylow,x
	cmp #$ff
	beq dontintersect2

	cmp calcylowmax
	bcs dontintersect2
	
	clc
	lda sortsprylow,x
	adc sortsprheight,x
	sec
	cmp calcylow
	bcc dontintersect2
	
	sec
	lda sortsprxlow,x
	sbc calcxlowmax
	lda sortsprxhigh,x
	sbc calcxhighmax
	bcs dontintersect2
	
	clc
	lda sortsprxlow,x
	adc sortsprwidth,x
	sta sortsprxlowmax,x
	lda sortsprxhigh,x
	adc #$00
	sta sortsprxhighmax,x

	sec
	lda sortsprxlowmax,x
	sbc calcxlow
	lda sortsprxhighmax,x
	sbc calcxhigh
	bcc dontintersect2

	lda sortsprtype,x
	cmp #$03
	bne :+
	lda #$02
	sta calcsprhit
	jmp dontintersect2
:	lda #$01
	sta calcsprhit

dontintersect2
	inx
	cpx #MAXMULTPLEXSPR
	bne cssloop2
	
	rts

; -----------------------------------------------------------------------------------------------	

calcspritepostoscreenpos

	clc											; add inverse vsp position
	lda calcxlow
	adc invscreenposlow
	sta calcxlow
	lda calcxhigh
	adc invscreenposhigh
	sta calcxhigh

	lsr calcxhigh								; divide xpos by 8 to get column
	ror calcxlow
	lsr calcxhigh
	ror calcxlow
	lsr calcxhigh
	ror calcxlow

	lda #$00
	sta flipflop

	lda calcxlow
	cmp #$28
	bmi :+

	lda #$01
	sta flipflop

	sec
	lda calcxlow
	sbc #$28
	sta calcxlow

:	lsr calcylow								; divide ypos by 8 to get row
	lsr calcylow
	lsr calcylow

	clc
	ldx calcylow
	lda times40lowtable,x
	sta csptsp0+1
	lda times40hightable,x
	sta csptsp0+2

	clc
	lda csptsp0+1
	adc calcxlow
	sta csptsp0+1
	lda csptsp0+2
	adc #$c0
	sta csptsp0+2

csptsp0	lda $c001
	sta calchit
	cmp #$ff
	beq csend

	lda #$00
	sta calcspryoffset

	lda calchit									; find top left position of object hit
	and #%00000001
	beq :+
	dec calcxlow

:	lda calchit
	and #%00000010
	beq :+
	dec calcylow
	lda #$08
	sta calcspryoffset
:	
	lda calchit
	and #%00010000
	beq :+
	lda #$00
	sta calcbkghit
	jmp :++
	
:	lda #$55
	sta calcbkghit
:

csbkghit

	lda calcylow								; calculate vsp'ed position of hit tile
	sta calcylowvsped
	lda flipflop
	bne :+
	dec calcylowvsped

:	jsr updategroundscore

csend
	rts

; -----------------------------------------------------------------------------------------------	

calcshippostoscreenpos

	clc											; add inverse vsp position
	lda calcxlow
	adc invscreenposlow
	sta calcxlow
	lda calcxhigh
	adc invscreenposhigh
	sta calcxhigh

	lsr calcxhigh								; divide xpos by 8 to get column
	ror calcxlow
	lsr calcxhigh
	ror calcxlow
	lsr calcxhigh
	ror calcxlow

	lda #$00
	sta flipflop

	lda calcxlow
	cmp #$28
	bmi :+

	lda #$01
	sta flipflop

	sec
	lda calcxlow
	sbc #$28
	sta calcxlow

:	lsr calcylow								; divide ypos by 8 to get row
	lsr calcylow
	lsr calcylow

	clc
	ldx calcylow
	lda times40lowtable,x
	sta csptsp1+1
	lda times40hightable,x
	sta csptsp1+2

	clc
	lda csptsp1+1
	adc calcxlow
	sta csptsp1+1
	lda csptsp1+2
	adc #>screenspecial
	sta csptsp1+2

csptsp1
	lda screenspecial+1
	sta calchit

	rts

; -----------------------------------------------------------------------------------------------	

inithandlecollisions

	lda #$00
	sta shiptested
	sta bullet0tested
	sta bullet1tested
	sta bomb0tested
	sta bomb1tested
	sta handlezonetested
	sta collisionshandled

	rts

handlerestcollisions

	lda collisionshandled
	cmp #$07
	bcs :+
	
	jsr handlecollisions
	inc collisionshandled
	jmp handlerestcollisions

:	rts

handlecollisions

	lda handlezonetested
	bne :+
	lda #$01
	sta handlezonetested

handlezonecode
	jsr handlezone1								; self modified jsr
	jmp hcend

:	lda bullet0tested
	bne :+
	lda #$01
	sta bullet0tested
	inc collisionshandled
	lda shootingbullet0
	beq :+
	lda bull0+sprdata::isexploding
	bne :+
	jsr testbullet0bkgcollision
	jsr testbullet0sprcollision
	jmp hcend
	
:	lda bullet1tested
	bne :+
	lda #$01
	sta bullet1tested
	inc collisionshandled
	lda shootingbullet1
	beq :+
	lda bull1+sprdata::isexploding
	bne :+
	jsr testbullet1bkgcollision
	jsr testbullet1sprcollision
	jmp hcend

:	lda bomb0tested
	bne :+
	lda #$01
	sta bomb0tested
	inc collisionshandled
	lda shootingbomb0
	beq :+
	lda bomb0+sprdata::isexploding
	bne :+
	jsr testbomb0bkgcollision
	jsr testbomb0sprcollision
	jmp hcend

:	lda bomb1tested
	bne :+
	lda #$01
	sta bomb1tested
	inc collisionshandled
	lda shootingbomb1
	beq :+
	lda bomb1+sprdata::isexploding
	bne :+
	jsr testbomb1bkgcollision
	jsr testbomb1sprcollision

:	lda shiptested
	bne :+
	lda #$01
	sta shiptested
	inc collisionshandled
	lda hascontrol
	bne :+
	lda ship0+sprdata::isexploding
	bne :+
.if shipbkgcollision
	jsr testshipbkgcollision
.endif
.if shipsprcollision
	jsr testshipsprcollision
.endif
:
hcend
	
	rts

; -----------------------------------------------------------------------------------------------

handlezone1										; missiles	
	jsr launchmissile
	jsr animmissiles
	jmp handlemissilemovement

handlezone2										; ufos
	jsr launchufo
	jsr animufos
	jmp handleufomovement

handlezone3										; comets
	jsr launchcomet
	jsr animcomets
	jmp handlecometmovement

handlezone4										; missiles
	jsr launchmissile
	jsr animmissiles
	jmp handlemissilemovement

handlezone5										; avoid fuel
	lda gamefinished
	cmp #$01
	bpl :+										; if 1 or higher!
	jmp handlezone5rest
	
:	inc gamefinished
	cmp #$30
	beq handlegamefinished
	jmp handlezone5rest
	
handlegamefinished
	lda flags
	cmp #$09
	beq :+
	inc flags
:	lda #states::congratulations
	sta state+1
	rts

handlezone5rest
	jsr animmissiles
	jmp handlemissilemovement
	
; -----------------------------------------------------------------------------------------------

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
	
	jmp :+++

wedied

	ldy #$04
:	ldx #$40
:	dex
	bne :-
	dey
	bne :--
	
:	;lda #$00
	;sta $d020
	; we are below the bottom border sprites - set up the top border sprites now
	
	.repeat 6,i
	lda #$16									; was 16
	sta $d001+i*2
	lda #$d8+i
	sta $c3f8+i
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
	
	lda #$cf									; empty sprites for missiles in top border (make sure F3C0 - F400 is empty)
	sta $c3fe
	sta $c3ff

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

.segment "TITLESCREEN"

clearscreen

	lda #$18
	sta $d016
	lda #%00000100 ; s = screen, c = charset - ssssccc0
	sta $d018
	
	lda #$0c
	sta $d022
	lda #$09
	sta $d023

	ldx #$00
:	lda #$00
	sta screenui+(0*$0100),x
	sta screenui+(1*$0100),x
	sta screenui+(2*$0100),x
	sta screenui+(3*$0100),x
	inx
	bne :-

	sta $d020
	sta $d021

	sta $dd00
	
	rts
	
titlescreen

	sei
	
	lda #$37
	sta $01

	lda #$7b
	sta $d011
	
	jsr clearscreen

	;jsr loadloadinstall

	ldx #<titletext
	ldy #>titletext
	stx zp0
	sty zp1
	jsr plottext

; -----------------------------------------------------------------------------------------------

.macro ploticonsetup iconptr, location
	ldx #<iconptr
	ldy #>iconptr
	stx zp0
	sty zp1
	ldx #<location
	ldy #>location
	stx iconposlow
	sty iconposhigh
	jsr ploticon
.endmacro

	ploticonsetup textmissile0, (4*40+4)
	ploticonsetup textmissile1, (7*40+4)
	ploticonsetup textmystery, (10*40+4)
	ploticonsetup textufo, (13*40+4)
	ploticonsetup textfuel, (16*40+4)
	ploticonsetup textboss, (19*40+4)

	lda #$01
	sta $d01a

	lda #$31
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
	
	lda #$1b
	sta $d011

	jsr waitkey

	jmp ingamefresh
	
waitkey
	lda $dc00
	and #%00010000								; fire
	bne waitkey
	rts

livesleftscreen

	sei
	
	lda #$37
	sta $01

	lda #$7f
	sta $d011
	
	jsr clearscreen
	
	lda lives
	adc #$2f
	sta screenui+12*40+14
	lda #$01
	sta colormem+12*40+14

	ldx #<liveslefttext
	ldy #>liveslefttext
	stx zp0
	sty zp1
	jsr plottext
	
	lda #$00
	sta timerlow
	sta timerhigh
	
	lda #$80
	sta timerreachedlow
	lda #$00
	sta timerreachedhigh

	lda #$00
	sta timerreached
	
	lda #$01
	sta $d01a

	lda #$31
	sta $d012

	lda #<irqlivesleft
	ldx #>irqlivesleft
	sta $fffe
	sta $0314
	stx $ffff
	stx $0315

	lda $dc0d
	lda $dd0d
	dec $d019
	cli

	lda #$1b
	sta $d011
	
:	lda timerreached
	cmp #$01
	bcc :-
	
	lda #states::initlevel
	sta state+1

	jmp ingamefromlivesleftscreen

congratulations

	sei
	
	lda #$37
	sta $01

	lda #$7f
	sta $d011
	
	jsr clearscreen
	
	ldx #<congratstext
	ldy #>congratstext
	stx zp0
	sty zp1
	jsr plottext

	lda #$00
	sta timerlow
	sta timerhigh
	
	lda #$00
	sta timerreachedlow
	lda #$02
	sta timerreachedhigh

	lda #$00
	sta timerreached
	
	lda #$01
	sta $d01a

	lda #$31
	sta $d012

	lda #<irqlivesleft
	ldx #>irqlivesleft
	sta $fffe
	sta $0314
	stx $ffff
	stx $0315

	lda $dc0d
	lda $dd0d
	dec $d019
	cli

	lda #$1b
	sta $d011
	
:	lda timerreached
	cmp #$01
	bcc :-
	
	lda #states::initlevel
	sta state+1

	jmp ingamefromcongratulations

; -----------------------------------------------------------------------------------------------

plottext
	ldy #$00

	clc
	lda #<screenui
	adc (zp0),y
	sta pt2+1
	lda #<colormem
	adc (zp0),y
	sta pt1+1
	iny

	clc
	lda #>screenui
	adc (zp0),y
	sta pt2+2
	lda #>colormem
	adc (zp0),y
	sta pt1+2
	iny

	lda (zp0),y
	sta pt0+1

	clc
	lda zp0
	adc #$03
	sta zp0
	sta pt3+1
	sta pt5+1
	lda zp1
	adc #$00
	sta zp1
	sta pt3+2
	sta pt5+2

	sec
	ldx #$ff
:	inx
pt0	lda #$08
pt1	sta colormem,x
pt3	lda titletext,x
	sbc #$60
pt2	sta screenui,x
	cmp #$00
	bne :-
	inx
pt5	lda titletext,x
	cmp #$ff
	beq :+

	clc
	stx zptemp
	lda pt5+1
	adc zptemp
	sta zp0
	lda zp1
	adc #$00
	sta zp1

	jmp plottext

:	rts

; -----------------------------------------------------------------------------------------------

ploticon
	ldy #$00
:	lda (zp0),y
	clc
	adc iconposlow
	sta itxt+1
	lda #<screenui
	adc iconposhigh
	adc #>screenui
	sta itxt+2
	lda (zp0),y
	clc
	adc iconposlow
	sta icol+1
	lda #$00
	adc iconposhigh
	adc #>colormem
	sta icol+2
	iny
	lda (zp0),y
itxt sta screenui
	iny
	lda (zp0),y
icol sta colormem
	iny
	cpy #6*3
	bne :-

	rts

; -----------------------------------------------------------------------------------------------

titletext
.byte <( 0*40+18), >( 0*40+18), $07, "play", $60
.byte <( 2*40+14), >( 2*40+14), $03, "scramble", $80, $92,$90,$92,$90, $60
.byte <(11*40+ 9), >(11*40+ 9), $02, "how", $80, "far", $80, "can", $80, "you", $80, "invade", $60
.byte <(13*40+10), >(13*40+10), $02, "our", $80, "skramble", $80, "system", $9f, $60
.byte <(22*40+12), >(22*40+12), $01, $a0, $80, "copyright", $80, $92,$90,$92,$90, $60
.byte <(24*40+11), >(24*40+11), $01, "press", $80, "fire", $80, "to", $80, "play", $60, $ff

congratstext
.byte <(10*40+12), >(10*40+12), $02, "congratulations", $60
.byte <(12*40+ 7), >(12*40+ 7), $07, "you", $80, "completed", $80, "your", $80, "duties", $60
.byte <(14*40+ 7), >(14*40+ 7), $03, "good", $80, "luck", $80, "next", $80, "time", $80, "again", $60, $ff

liveslefttext
.byte <(12*40+16), >(12*40+16), $01, "lives", $80, "left", $60, $ff

iconposlow
.byte $00
iconposhigh
.byte $00

textmissile0
.byte (0*40+0),$60,$09,(0*40+1),$61,$0a
.byte (1*40+0),$62,$0b,(1*40+1),$63,$0a
.byte (2*40+0),$64,$08,(2*40+1),$65,$08
textmissile1
.byte (0*40+0),$60,$09,(0*40+1),$61,$0a
.byte (1*40+0),$62,$0b,(1*40+1),$63,$0a
.byte (2*40+0),$66,$0f,(2*40+1),$67,$0f
textmystery
.byte (0*40+0),$68,$09,(0*40+1),$69,$0f
.byte (1*40+0),$6a,$0f,(1*40+1),$6b,$0a
.byte (2*40+0),$6c,$0a,(2*40+1),$6d,$0a
textufo
.byte (0*40+0),$20,$08,(0*40+1),$20,$08
.byte (1*40+0),$6e,$0b,(1*40+1),$6f,$0d
.byte (2*40+0),$20,$08,(2*40+1),$20,$08
textfuel
.byte (0*40+0),$70,$09,(0*40+1),$71,$0b
.byte (1*40+0),$72,$0b,(1*40+1),$73,$0d
.byte (2*40+0),$74,$0b,(2*40+1),$75,$08
textboss
.byte (0*40+0),$76,$09,(0*40+1),$77,$0c
.byte (1*40+0),$78,$0f,(1*40+1),$79,$0c
.byte (2*40+0),$7a,$0c,(2*40+1),$7b,$08

; -----------------------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------------------

.segment "TABLES"

; put stuff that's indexed a lot first to keep runtime cost low

;sortorder = ($a0)
;.repeat MAXMULTPLEXSPR
;.byte $00
;.endrep

sortsprylow
.repeat MAXMULTPLEXSPR
.byte $ff
.endrep
sortsprxlow
.repeat MAXMULTPLEXSPR
.byte $00
.endrep
sortsprxlowmax
.repeat MAXMULTPLEXSPR
.byte $00
.endrep
sortsprxhigh
.repeat MAXMULTPLEXSPR
.byte $00
.endrep
sortsprxhighmax
.repeat MAXMULTPLEXSPR
.byte $00
.endrep
sortsprc
.repeat MAXMULTPLEXSPR
.byte $00
.endrep
sortsprp
.repeat MAXMULTPLEXSPR
.byte $00
.endrep
sortsprwidth
.repeat MAXMULTPLEXSPR
.byte $00
.endrep
sortsprheight
.repeat MAXMULTPLEXSPR
.byte $00
.endrep
sortsprtype
.repeat MAXMULTPLEXSPR
.byte $00
.endrep
sortsprlifetime
.repeat MAXMULTPLEXSPR
.byte $00
.endrep

fuelticks
.byte %01010101									; 01 = empty, 10,11 = full
.byte %10010101
.byte %10110101
.byte %10111001
.repeat 64-4
.byte %10111011
.endrepeat

timesufotable
.byte $00, $40, $80, $c0

times8lowtable									; multiplication tables
.repeat 80,i
	.byte <(i*8)
.endrep

times8hightable
.repeat 80,i
	.byte >(i*8)
.endrep

times40lowtable
.repeat 25,i
	.byte <(i*40)
.endrep

times40hightable
.repeat 25,i
	.byte >(i*40)
.endrep

times320lowtable
.repeat 25,i
	.byte <(i*320)
.endrep

times320hightable
.repeat 25,i
	.byte >(i*320)
.endrep

sinyufo
.byte $92,$95,$98,$9b,$9e,$a1,$a3,$a6,$a8,$aa,$ac,$ae,$af,$b0,$b1,$b1
.byte $b1,$b1,$b1,$b0,$af,$ae,$ac,$aa,$a8,$a6,$a3,$a1,$9e,$9b,$98,$95
.byte $92,$8e,$8b,$88,$85,$82,$80,$7d,$7b,$79,$77,$75,$74,$73,$72,$72
.byte $72,$72,$72,$73,$74,$75,$77,$79,$7b,$7d,$80,$82,$85,$88,$8b,$8e

posycomet
.byte $80,$b4,$a0,$80,$40,$60,$90,$b4,$50,$60,$80,$b4,$a0,$80,$50,$40
.byte $38,$b4,$a0,$80,$40,$b4,$90,$60,$50,$60,$80,$a0,$b4,$a0,$50,$40

filenameconvtab
.byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$41,$42,$43,$44,$45,$46

; ---------------------- uninitialised

posycometcount
.byte $00

file											; file loading
.byte $01

zone											; zone handling
.byte $00
subzone
.byte $01

zonecolours
.byte $07,$06,$06,$06,$06,$06,$ff				; intentionally one zone too long

fuel
.byte $20

lives
.byte $03

flags
.byte $00

timeseconds
.byte $00

mysterytimer
.byte $01

fueltimer
.byte $00

fuellowtimer
.byte $00

fuelblink
.byte $07, $02

score
.repeat 6
.byte $00
.endrepeat

prevscore
.repeat 6
.byte $00
.endrepeat

ufotimer
.byte $00
ufonum
.byte $00

comettimer
.byte $00
cometnum
.byte $00

screenposlow									; vsp counters
.byte $3f
screenposhigh
.byte $01
invscreenposlow
.byte $00
invscreenposhigh
.byte $00
currenttile
.byte $00,$00
currenttiletimes8
.byte $00,$00
column
.byte $00
row
.byte $00
flip
.byte $00

ship0: .tag sprdata								; sprite data
bull0: .tag sprdata
bull1: .tag sprdata
bomb0: .tag sprdata
bomb1: .tag sprdata

hascontrol
.byte $30

bulletcooloff									; shooting counters
.byte $10
bombcooloff
.byte $0f
shootingbullet0
.byte $00
shootingbullet1
.byte $00
shootingbomb0
.byte $00
shootingbomb1
.byte $00

getshipbkgcoll
.byte $00

schedulequeue
.byte $ff
scheduledcalcylow
.byte $00, $00, $00, $00, $00
scheduledcalcylowvsped
.byte $00, $00, $00, $00, $00
scheduledcalcxlow
.byte $00, $00, $00, $00, $00
scheduledcalcbkghit
.byte $00, $00, $00, $00, $00

curmulsprite									; multiplex stuff
.byte $00
restmultspritesindex
.byte $02

randomseed										; randomizer missile liftoff
.byte $00

startmissileypos
.byte $00

calcxlow										; collision checking
.byte $00
calcxhigh
.byte $00
calcylow
.byte $00

calcxlowmax										; collision checking
.byte $00
calcxhighmax
.byte $00
calcylowmax
.byte $00

calcylowvsped
.byte $00

calchit
.byte $00
flipflop
.byte $00
calcbkghit
.byte $00

calcspryoffset
.byte $00

calcsprhit
.byte $00

s0counter										; animation counters
.byte $00
s0counter2
.byte $00
bull0counter
.byte $00
bull0counter2
.byte $00
bull1counter
.byte $00
bull1counter2
.byte $00
bomb0counter
.byte $00
bomb0counter2
.byte $00
bomb1counter
.byte $00
bomb1counter2
.byte $00
nofuelcounter
.byte $00

s0anim											; animations
.byte $10,$11,$12,$11
bombanim
.byte $14,$15,$16,$17,$18,$19,$1a
bombcolours
.byte $01,$01,$07,$07,$0f,$0c,$0c
bombexplosionanim
.byte $1b,$1c,$1d,$1e,$1f,$20,$21,$22,$23,$24,$25
bombexplosioncolours
.byte $01,$07,$07,$07,$0a,$0a,$08,$08,$0b,$0b,$0b
bulletexplosionanim
.byte $26,$27,$28,$29,$2a,$2b
bulletexplosioncolours
.byte $01,$07,$0a,$08,$0b,$0b
bulletsmallexplosionanim
.byte $2c,$2d,$2e,$2f
bulletsmallexplosioncolours
.byte $01,$0f,$0c,$09
ufoanim
.byte $3a,$3b,$3c

collisionshandled
.byte $00
shiptested
.byte $00
bullet0tested
.byte $00
bullet1tested
.byte $00
bomb0tested
.byte $00
bomb1tested
.byte $00
handlezonetested
.byte $00

gamefinished
.byte $00

zonecodeptrslow
.byte <handlezone1
.byte <handlezone2
.byte <handlezone3
.byte <handlezone4
.byte <handlezone5
;.byte <handlezone6
zonecodeptrshigh
.byte >handlezone1
.byte >handlezone2
.byte >handlezone3
.byte >handlezone4
.byte >handlezone5
;.byte >handlezone6

zonecode2ptrslow
.byte <plotfirstmissilemultsprites
.byte <plotdummymultsprites
.byte <plotdummymultsprites
.byte <plotfirstmissilemultsprites
.byte <plotfirstmissilemultsprites
.byte <plotdummymultsprites
zonecode2ptrshigh
.byte >plotfirstmissilemultsprites
.byte >plotdummymultsprites
.byte >plotdummymultsprites
.byte >plotfirstmissilemultsprites
.byte >plotfirstmissilemultsprites
.byte >plotdummymultsprites

zonecode3ptrslow
.byte <plotdummymultsprites
.byte <plotfirstufomultsprites
.byte <plotfirstufomultsprites
.byte <plotdummymultsprites
.byte <plotdummymultsprites
.byte <plotdummymultsprites
zonecode3ptrshigh
.byte >plotdummymultsprites
.byte >plotfirstufomultsprites
.byte >plotfirstufomultsprites
.byte >plotdummymultsprites
.byte >plotdummymultsprites
.byte >plotdummymultsprites

zonecode4ptrslow
.byte <plotrestmissilemultsprites
.byte <plotrestufomultsprites
.byte <plotrestufomultsprites
.byte <plotrestmissilemultsprites
.byte <plotrestmissilemultsprites
.byte <plotdummymultsprites
zonecode4ptrshigh
.byte >plotrestmissilemultsprites
.byte >plotrestufomultsprites
.byte >plotrestufomultsprites
.byte >plotrestmissilemultsprites
.byte >plotrestmissilemultsprites
.byte >plotdummymultsprites

sortskipslow
.byte <sortskip1
.byte <sortskip2
.byte <sortskip3
.byte <sortskip4
.byte <sortskip5
.byte <sortskip6
.byte <sortskip7
.byte <sortskip8
.byte <sortskip9
.byte <sortskip10
.byte <sortskip11
sortskipshigh
.byte >sortskip1
.byte >sortskip2
.byte >sortskip3
.byte >sortskip4
.byte >sortskip5
.byte >sortskip6
.byte >sortskip7
.byte >sortskip8
.byte >sortskip9
.byte >sortskip10
.byte >sortskip11

file01
.asciiz "00"

loadinstallfile
.asciiz "LI"

.byte $de,$ad,$be,$ef							; DEADBEEF

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
	;sta $d020
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