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

diedclearline
.byte $00
diedclearlinehigh
.byte $00
diedclearlinelow
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
.byte bytespriteptrforaddress(sprites2+(shipanimstart+0)*64)
.byte bytespriteptrforaddress(sprites2+(shipanimstart+1)*64)
.byte bytespriteptrforaddress(sprites2+(shipanimstart+2)*64)
.byte bytespriteptrforaddress(sprites2+(shipanimstart+1)*64)
bombanim
.byte bytespriteptrforaddress(sprites2+(bombanimstart+0)*64)
.byte bytespriteptrforaddress(sprites2+(bombanimstart+1)*64)
.byte bytespriteptrforaddress(sprites2+(bombanimstart+2)*64)
.byte bytespriteptrforaddress(sprites2+(bombanimstart+3)*64)
.byte bytespriteptrforaddress(sprites2+(bombanimstart+4)*64)
.byte bytespriteptrforaddress(sprites2+(bombanimstart+5)*64)
.byte bytespriteptrforaddress(sprites2+(bombanimstart+6)*64)
bombcolours
.byte $01,$01,$07,$07,$0f,$0c,$0c
bombexplosionanim
.byte bytespriteptrforaddress(sprites2+11*64)
.byte bytespriteptrforaddress(sprites2+12*64)
.byte bytespriteptrforaddress(sprites2+13*64)
.byte bytespriteptrforaddress(sprites2+14*64)
.byte bytespriteptrforaddress(sprites2+15*64)
.byte bytespriteptrforaddress(sprites2+16*64)
.byte bytespriteptrforaddress(sprites2+17*64)
.byte bytespriteptrforaddress(sprites2+18*64)
.byte bytespriteptrforaddress(sprites2+19*64)
.byte bytespriteptrforaddress(sprites2+20*64)
.byte bytespriteptrforaddress(sprites2+21*64)
bombexplosioncolours
.byte $01,$07,$07,$07,$0a,$0a,$08,$08,$0b,$0b,$0b
bulletbigexplosionanim
.byte bytespriteptrforaddress(sprites2+22*64)
.byte bytespriteptrforaddress(sprites2+23*64)
.byte bytespriteptrforaddress(sprites2+24*64)
.byte bytespriteptrforaddress(sprites2+25*64)
.byte bytespriteptrforaddress(sprites2+26*64)
.byte bytespriteptrforaddress(sprites2+27*64)
bulletbigexplosioncolours
.byte $01,$07,$0a,$08,$0b,$0b
bulletsmallexplosionanim
.byte bytespriteptrforaddress(sprites2+28*64)
.byte bytespriteptrforaddress(sprites2+29*64)
.byte bytespriteptrforaddress(sprites2+30*64)
.byte bytespriteptrforaddress(sprites2+31*64)
bulletsmallexplosioncolours
.byte $01,$0f,$0c,$09

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
.byte <plotdummymultsprites						; ufos
.byte <plotdummymultsprites						; comets
.byte <plotfirstmissilemultsprites
.byte <plotfirstmissilemultsprites
.byte <plotdummymultsprites
zonecode2ptrshigh
.byte >plotfirstmissilemultsprites
.byte >plotdummymultsprites						; ufos
.byte >plotdummymultsprites						; comets
.byte >plotfirstmissilemultsprites
.byte >plotfirstmissilemultsprites
.byte >plotdummymultsprites

zonecode3ptrslow
.byte <plotdummymultsprites
.byte <plotfirstufocometmultsprites				; ufos
.byte <plotfirstufocometmultsprites				; comets
.byte <plotdummymultsprites
.byte <plotdummymultsprites
.byte <plotdummymultsprites
zonecode3ptrshigh
.byte >plotdummymultsprites
.byte >plotfirstufocometmultsprites				; ufos
.byte >plotfirstufocometmultsprites				; comets
.byte >plotdummymultsprites
.byte >plotdummymultsprites
.byte >plotdummymultsprites

zonecode4ptrslow
.byte <plotrestmissilemultsprites
.byte <plotrestufocometmultsprites				; ufos
.byte <plotrestufocometmultsprites				; comets
.byte <plotrestmissilemultsprites
.byte <plotrestmissilemultsprites
.byte <plotdummymultsprites
zonecode4ptrshigh
.byte >plotrestmissilemultsprites
.byte >plotrestufocometmultsprites				; ufos
.byte >plotrestufocometmultsprites				; comets
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

titlescreen1bmpfile
.asciiz "T1"
titlescreen10400file
.asciiz "T2"
titlescreen1d800file
.asciiz "T3"
titlescreenpointsprfile
.asciiz "T4"
titlescreenbkgfile
.asciiz "T5"
titlescreenhowfar
.asciiz "T6"

barsd022
.byte $07,$0a,$0a,$0a,$08,$08,$02,$02,$02,$02,$02,  $00,  $03,$0e,$04,$0e,$04,$0e,$04,$04,$04,$04,$04,  $00,  $0d,$03,$05,$03,$05,$05,$08,$05,$08,$08,$08
barsd023
.byte $01,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a,  $00,  $01,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,  $00,  $01,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
barswait
.byte $08,$08,$07,$07,$06,$01,$07,$07,$08,$07,$01,  $36,  $08,$08,$07,$07,$06,$01,$07,$07,$08,$06,$01,  $36,  $08,$08,$07,$07,$06,$01,$07,$07,$08,$07,$01

mysteryanim
.byte bytespriteptrforaddress(sprites2+22*64)
.byte bytespriteptrforaddress(sprites2+23*64)
.byte bytespriteptrforaddress(sprites2+24*64)
; rest of anim ptrs are handled by code and read from mystery100200300spriteptrs
mysterycolours
.byte $01,$07,$0a,$01,$01,$01,$01,$03,$0e,$04,$06

mystery100200300spriteptrs
.byte 0
.byte bytespriteptrforaddress(sprites2+mystery100start*64)
.byte bytespriteptrforaddress(sprites2+mystery200start*64)
.byte bytespriteptrforaddress(sprites2+mystery300start*64)

easetimer
.byte $00

bkgpulsetimer
.byte $00

bkgpulsecolors
.byte $00,$09,$08,$0a,$0f,$07d,$01,$07,$0f,$0a,$08,$09,$00,$00,$00,$00

.byte $de,$ad,$be,$ef							; DEADBEEF