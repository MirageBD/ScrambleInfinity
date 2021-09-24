.define fueldecreases					1					; HACKS
.define pointsforbeingalive				1
.define shipbkgcollision				1
.define shipsprcollision				1
.define livesdecrease					1
.define firebullets						1
.define firebombs						1
.define startzone						#$00				; #$00 - #$04 (STARTING BEFORE BOSS WON'T WORK)
.define diedfade						0
.define startlivesleft					#$03				; initial lives left

.define startscore0						#$00
.define startscore1						#$00
.define startscore2						#$00
.define startscore3						#$00
.define startscore4						#$00
.define startscore5						#$00

.define debugrastertime					0
.define enablebreakpoints               0
.define enabledebugkeys					0                   ; press 'q' to quickly end current game end return to title screen

.define recordplayback                  1                   ; 0 or 1

.define bulletspeedx					8					; was 6
.define bombstartspeedx					5
.define bombstartspeedy					1
.define bombthrowspeed                  3					; number of frames the bomb goes forward a lot faster. has to be smaller than bombanimframes

.define ingamesfx                       1                   ; sfx or music

.define continuousshooting              0                   ; pressing down button fires continuously
