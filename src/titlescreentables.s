.segment "TITLESCREENTABLES"

spriterowxstartlo									; these values get filled from the easing tables
.byte <(104),<(104),<(104),<(104),<(104),<(104)
spriterowxstarthi									; these values get filled from the easing tables
.byte >(104),>(104),>(104),>(104),>(104),>(104)

spriterowoffs0
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00

spriterowoffs1
.byte $00,$00,$18,$30,$48,$60,$68-0*4,$80			; total width 152 - middle start = 24 + (320-152) / 2 = 108 (-4 for some sprite variation on the left) = 104
.byte $00,$00,$18,$30,$48,$60,$68-0*4,$80			; sin wave needs to go from (344 -> 104 -> -136) = ( $0158 -> $0068 -> $0178)
.byte $00,$00,$18,$30,$48,$60,$68-1*4,$80			; ./easefunc 344 104 64 0
.byte $00,$00,$18,$30,$48,$60,$68-1*4,$80			; ./easefunc 104 -136 64 1
.byte $00,$00,$18,$30,$48,$60-0*4,$68,$80
.byte $00,$00,$18,$30,$48-3*4,$50,$68,$80

spriterowoffs2
.byte $00,$08,$20,$38,$50,$68,$80,$80
.byte $00,$08,$20,$38,$50,$68,$80,$80
.byte $00,$08,$20,$38,$50,$68,$80,$80
.byte $00,$08,$20,$38,$50,$68,$80,$80
.byte $00,$08,$20,$38,$50,$68,$80,$80
.byte $00,$08,$20,$38,$50,$68,$80,$80

tsro1lo
.byte <(spriterowoffs0+0*8), <(spriterowoffs0+1*8), <(spriterowoffs0+2*8), <(spriterowoffs0+3*8), <(spriterowoffs0+4*8), <(spriterowoffs0+5*8)
tsro1hi
.byte >(spriterowoffs0+0*8), >(spriterowoffs0+1*8), >(spriterowoffs0+2*8), >(spriterowoffs0+3*8), >(spriterowoffs0+4*8), >(spriterowoffs0+5*8)

tsplposlo
.byte <(pointlinespositions+0*10), <(pointlinespositions+1*10), <(pointlinespositions+2*10), <(pointlinespositions+3*10), <(pointlinespositions+4*10), <(pointlinespositions+5*10)
tsplposhi
.byte >(pointlinespositions+0*10), >(pointlinespositions+1*10), >(pointlinespositions+2*10), >(pointlinespositions+3*10), >(pointlinespositions+4*10), >(pointlinespositions+5*10)

; ---------------------------------------------------------------

pointlinespositions
.byte $64+0*24,$00,$00,$00,$00,$00,$00,$00,$00,$00	; yoffset, $d010, $d000++
.byte $64+1*24,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byte $64+2*24,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byte $64+3*24,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byte $64+4*24,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byte $64+5*24,$00,$00,$00,$00,$00,$00,$00,$00,$00

pointlineanims
.byte bytespriteptrforaddress(titlescreenpointsspr+0*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+1*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+4*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+3*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+2*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+5*(6*64)+0*64)

pointlinesdata1
.byte bytespriteptrforaddress(titlescreenpointsspr+0*(6*64)+1*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+0*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+1*64)	; 50
.byte $09,$02, $01,$0a,$01,$01,$01,$01,$01,$01

.byte bytespriteptrforaddress(titlescreenpointsspr+1*(6*64)+1*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+1*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+2*64)	; 80
.byte $09,$02, $07,$0a,$01,$01,$01,$01,$01,$01

.byte bytespriteptrforaddress(titlescreenpointsspr+4*(6*64)+1*64)					; this will bite me in the ass later... fuel = 2, boss = 4
.byte bytespriteptrforaddress(titlescreenpointsspr+4*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+3*64)	; 100
.byte $09,$08, $01,$05,$01,$01,$01,$01,$01,$01

.byte bytespriteptrforaddress(titlescreenpointsspr+3*(6*64)+1*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+3*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+4*64)	; 150
.byte $09,$08, $01,$05,$01,$01,$01,$01,$01,$01

.byte bytespriteptrforaddress(titlescreenpointsspr+2*(6*64)+1*64)					; this will bite me in the ass later... fuel = 2, boss = 4
.byte bytespriteptrforaddress(titlescreenpointsspr+2*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+5*64)	; 800
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+6*64)
.byte $09,$02, $07,$0a,$01,$01,$01,$01,$01,$01

.byte bytespriteptrforaddress(titlescreenpointsspr+5*(6*64)+1*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+5*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+0*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+7*64)	; mystery
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+8*64)
.byte bytespriteptrforaddress(titlescreenpointsspr+6*(6*64)+9*64)
.byte $06,$04, $03,$0e,$01,$01,$01,$01,$01,$01

; ---------------------------------------------------------------

; how far can you invade data
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)		; how far
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+ 1*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+ 2*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+ 3*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+ 4*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)
.byte $04,$0e, $03,$03,$03,$03,$03,$03,$03,$03

.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)		; can you
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+5*64+ 0*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+5*64+ 1*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+5*64+ 2*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+5*64+ 3*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)
.byte $06,$04, $0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e

.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)		; invade
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+9*64+ 0*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+9*64+ 1*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+9*64+ 2*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+9*64+ 3*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)
.byte $09,$02, $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a

.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)		; our
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+13*64+ 0*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+13*64+ 1*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)
.byte $09,$08, $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a

.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)		; scramble
.byte bytespriteptrforaddress(titlescreenhowfarspr+15*64+ 0*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+15*64+ 1*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+15*64+ 2*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+15*64+ 3*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+15*64+ 4*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+15*64+ 5*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)
.byte $09,$08, $05,$05,$05,$05,$05,$05,$05,$05

.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)		; system
.byte bytespriteptrforaddress(titlescreenhowfarspr+21*64+ 0*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+21*64+ 1*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+21*64+ 2*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+21*64+ 3*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+21*64+ 4*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+21*64+ 5*64)
.byte bytespriteptrforaddress(titlescreenhowfarspr+0*64+0*64)
.byte $09,$05, $0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d

; ---------------------------------------------------------------

tsanimframe
.byte $00
tsanimframedelay
.byte $00