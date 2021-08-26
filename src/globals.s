.segment "GLOBALS"

; DEFINES ----------------------------------------------------------------------------------------------------------------

.define firstsolidtile					74+5
.define firsttransparenttile			32

.define bank0							$0000
.define bank1							$4000
.define bank2							$8000
.define bank3							$c000

.define fueladd							#$0c				; how much to add when you destroy a fuel tanker
.define fueldecreaseticks				#$20				; frames before fuel decreases by one
.define fuelfull						#$38				; full tank
.define startlives						#$03				; initial lives
.define ufospawntime					#$50				; time before new ufo spawns - can be more, not less
.define bulletcooldown					#$18
.define zonecolour0						#$0b
.define zonecolour1						#$07

.define clearbmptile					#$55				; calcbkghit = #$55 = clear blue, #$aa = clear blue, #$ff = clear d800 / $0c

.define MAXMULTPLEXSPR					12
.define sortorder						$a0
.define sortcounter						$b2

.define bitmapwidth						320

.define shipanimstart					0
.define shipanimframes					3					; needs to be and-able
.define bulletanimstart					3
.define bombanimstart					4
.define bombanimloopframe				5
.define bombanimframes					7
.define bombanimspeed					5
.define bombexplosionanimframes			12
.define bulletsmallexplosionanimframes	5
.define bulletbigexplosionanimframes	7
.define mysteryanimframes				12
.define missileanimstart				32
.define missileanimframes				10
.define ufoanimstart					42
.define ufoanimframes					3
.define cometanimstart					45
.define cometanimframes					3
.define mystery100start					48
.define mystery200start					49
.define mystery300start					50

.define pointlinespositionsblocksize	10
.define pointlinesdatablocksize			18

; ------------------------------------------------------------------------------------------------------------------------

tuneinit					= $1000
tuneplay					= $1003

maptiles					= $a900		; currently still 36 free chars if I want to use them for zone 6/boss zone. make it blink?
maptilecolors				= $bd00
congratulationsscreen		= $c600
fontui						= $5800

loadeddata1					= $3000
loadeddata2					= $3800

screen1						= $4000
screenui					= $4000
fontdigits					= $bf80
screen2						= $c000
sprites1					= $4b00
titlescreenpointsspr		= $4c00
titlescreenhowfarspr		= $7800
sprites2					= $cb00
tslogosprorg				= $3000
tslogospr					= $a000		; consider moving this to $dc00/$de00
bitmap1						= $6000
bitmap2						= $e000
screenspecial				= $8000
screenbordersprites			= $8000
clearmisilepositiondata		= screenspecial+$03c0

tspressfirespr				= $a200

emptysprite					= $a8c0

fuelandscoresprites			= $a500
livesandzonesprites			= $a700

colormem					= $d800

zp0							= $f9
zp1							= $fa
zp2							= $fb
zp3							= $fc
zp4							= $fd
zp5							= $fe
zptemp						= $ff

livesdigit0					= livesandzonesprites+1*64+ 2*3+2
flagsdigit0 				= livesandzonesprites+5*64+ 2*3+2

scoredigit0 				= fuelandscoresprites+0*64+14*3+0		; see fuel.pdn
scoredigit1 				= fuelandscoresprites+0*64+14*3+1
scoredigit2 				= fuelandscoresprites+0*64+14*3+2
scoredigit3 				= fuelandscoresprites+1*64+14*3+0
scoredigit4 				= fuelandscoresprites+1*64+14*3+1
scoredigit5 				= fuelandscoresprites+1*64+14*3+2

hiscoredigit0 				= fuelandscoresprites+5*64+14*3+0
hiscoredigit1 				= fuelandscoresprites+5*64+14*3+1
hiscoredigit2 				= fuelandscoresprites+5*64+14*3+2
hiscoredigit3 				= fuelandscoresprites+6*64+14*3+0
hiscoredigit4 				= fuelandscoresprites+6*64+14*3+1
hiscoredigit5 				= fuelandscoresprites+6*64+14*3+2

titlescreen1bmp				= bitmap1
titlescreen10400			= screenui
titlescreen1d800			= loadeddata1

; STRUCTS AND ENUMS ------------------------------------------------------------------------------------------------------

.struct sprdata
	xlow					.byte
	xhigh					.byte
	ylow					.byte
	xvel					.byte
	yvel					.byte
	pointer					.byte
	colour					.byte
	isexploding				.byte		; upper 4 bits used for mystery points, lower 4 for small, big, mystery explosion
.endstruct

.enum gameflow
	waiting					= 0
	startingame				= 1
	continueingame			= 2
	loadsubzone				= 3
	titlescreen				= 4
	livesleftscreen			= 5
	gameover				= 6
	congratulations			= 7
.endenum

.enum explosiontypes
	none					= 0
	big						= 1
	small					= 2
	mystery					= 4
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
	cavemask				= %00010000
.endenum

.enum sprcollision
	flyingmissile			= 1
	flyingufo				= 2
	flyingcomet				= 3
.endenum

.enum playerstates
	incontrol				= $00				; doesn't count down. fuel empty checks are done after joystick readout.
	flyingintomission		= $30				; counts down to 0, at which time the player has control
	exploding				= $ff				; doesn't count down.
.endenum

; ------------------------------------------------------------------------------------------------------------------------
