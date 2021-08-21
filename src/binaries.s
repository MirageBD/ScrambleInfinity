.segment "MUSIC"
.incbin "./bin/jammer.bin"

.segment "DIGITSPRITEFONT"						; referenced by code. digits to plot into sprites
.incbin "./bin/font.bin"

.segment "FUELANDSCORESPRITES"					; referenced by code. score and hicore are plotted in here
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

.segment "CONGRATULATIONS"
.incbin "./bin/ingamemetamap.bin"

.segment "UIFONT"
.incbin "./bin/ingamemeta.bin"

; ------------------------------------------------------------------------------------------------------------------------

.segment "SCREEN1"
	.res 1024
.segment "BITMAP1"
	.res 8192
.segment "SCREENSPECIAL"
	.res 1024
;.segment "SPRITES1"
;	.res 24*64
.segment "SPRITES2"
	.res 24*64
.segment "EMPTYSPRITE"
	.res 64

; ------------------------------------------------------------------------------------------------------------------------