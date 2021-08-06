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
	sbc #$2a
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
	lda #explosiontypes::big
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
	lda #explosiontypes::big
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

	lda calchit
	and #%11111100
	cmp #bkgcollision::mysterynoncave
	beq bullet0bkgmystery
	cmp #bkgcollision::mysterycave
	beq bullet0bkgmystery

	lda #explosiontypes::big						; set big explosion anim
	sta bull0+sprdata::isexploding
	lda #$ff
	sta bull0+sprdata::xvel
	lda #$00
	sta bull0+sprdata::yvel
	sta bull0counter
	rts

bullet0bkgmystery
	lda mysterytimer								; store 1,2,3 in higher 4 bits
	asl
	asl
	asl
	asl
	ora #explosiontypes::mystery					; set mystery explosion anim
	sta bull0+sprdata::isexploding
	lda #$ff
	sta bull0+sprdata::xvel
	lda #$00
	sta bull0+sprdata::yvel
	sta bull0counter
	rts

bullet0bkgsmallexplosion

	lda #explosiontypes::small						; set small explosion anim
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

	lda calchit
	and #%11111100
	cmp #bkgcollision::mysterynoncave
	beq bullet1bkgmystery
	cmp #bkgcollision::mysterycave
	beq bullet1bkgmystery

	lda #explosiontypes::big					; set big explosion anim
	sta bull1+sprdata::isexploding
	lda #$ff
	sta bull1+sprdata::xvel
	lda #$00
	sta bull1+sprdata::yvel
	sta bull1counter
	rts

bullet1bkgmystery
	lda mysterytimer							; store 1,2,3 in higher 4 bits
	asl
	asl
	asl
	asl
	ora #explosiontypes::mystery				; set mystery explosion anim
	sta bull1+sprdata::isexploding
	lda #$ff
	sta bull1+sprdata::xvel
	lda #$00
	sta bull1+sprdata::yvel
	sta bull1counter
	rts

bullet1bkgsmallexplosion

	lda #explosiontypes::small					; set small explosion anim
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

	lda calchit
	and #%11111100
	cmp #bkgcollision::mysterynoncave
	beq bomb0explodemystery
	cmp #bkgcollision::mysterycave
	beq bomb0explodemystery

	lda #explosiontypes::big					; set big explosion anim
	sta bomb0+sprdata::isexploding
	lda #$00
	sta bomb0+sprdata::xvel
	sta bomb0+sprdata::yvel
	sta bomb0counter
	rts

bomb0explodemystery
	lda mysterytimer							; store 1,2,3 in higher 4 bits
	asl
	asl
	asl
	asl
	ora #explosiontypes::mystery				; set mystery explosion anim
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

	lda calchit
	and #%11111100
	cmp #bkgcollision::mysterynoncave
	beq bomb1explodemystery
	cmp #bkgcollision::mysterycave
	beq bomb1explodemystery

	lda #explosiontypes::big					; set big explosion anim
	sta bomb1+sprdata::isexploding
	lda #$00
	sta bomb1+sprdata::xvel
	sta bomb1+sprdata::yvel
	sta bomb1counter
	rts

bomb1explodemystery
	lda mysterytimer							; store 1,2,3 in higher 4 bits
	asl
	asl
	asl
	asl
	ora #explosiontypes::mystery				; set mystery explosion anim
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
	
	jmp cleartiles
	
notflipped	
	clc
	lda hbo1+1
	adc #$40
	sta hbo1+1
	lda hbo1+2
	adc #$01
	sta hbo1+2

cleartiles
	clc
	lda hbo0+1
	adc #$40
	sta hbo2+1
	lda hbo0+2
	adc #$01
	sta hbo2+2
	
	clc
	lda hbo1+1
	adc #$40
	sta hbo3+1
	lda hbo1+2
	adc #$01
	sta hbo3+2

	clc
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
	and #%00001111
	cmp #explosiontypes::big
	beq bull0biganim
	cmp #explosiontypes::small
	beq bull0smallanim
	cmp #explosiontypes::mystery
	beq bull0mysteryanim

bull0normalanim
	lda spriteptrforaddress(sprites2+bulletanimstart*64)
	sta bull0+sprdata::pointer
	lda #$01
	sta bull0+sprdata::colour
	rts

bull0smallanim
	ldx bull0counter
	lda bulletsmallexplosionanim,x
	sta bull0+sprdata::pointer
	
	lda bulletsmallexplosioncolours,x
	sta bull0+sprdata::colour
	
	inc bull0counter
	lda bull0counter
	cmp #bulletsmallexplosionanimframes
	beq bull0explosiondone

	rts
	
bull0biganim
	ldx bull0counter
	lda bulletbigexplosionanim,x
	sta bull0+sprdata::pointer
	
	lda bulletbigexplosioncolours,x
	sta bull0+sprdata::colour
	
	inc bull0counter
	lda bull0counter
	cmp #bulletbigexplosionanimframes
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

bull0mysteryanim
	ldx bull0counter
	cpx #$03
	bmi :+
	lda bull0+sprdata::isexploding
	lsr
	lsr
	lsr
	lsr
	tay
	lda mystery100200300spriteptrs,y
	jmp :++
:	lda mysteryanim,x
:	sta bull0+sprdata::pointer
	
	lda mysterycolours,x
	sta bull0+sprdata::colour
	
	inc bull0counter
	lda bull0counter
	cmp #mysteryanimframes
	beq bull0explosiondone

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
	and #%00001111
	cmp #explosiontypes::big
	beq bull1biganim
	cmp #explosiontypes::small
	beq bull1smallanim
	cmp #explosiontypes::mystery
	beq bull1mysteryanim

bull1normalanim
	lda spriteptrforaddress(sprites2+bulletanimstart*64)
	sta bull1+sprdata::pointer
	lda #$01
	sta bull1+sprdata::colour
	rts

bull1smallanim

	ldx bull1counter
	lda bulletsmallexplosionanim,x
	sta bull1+sprdata::pointer
	
	lda bulletsmallexplosioncolours,x
	sta bull1+sprdata::colour
	
	inc bull1counter
	lda bull1counter
	cmp #bulletsmallexplosionanimframes
	beq bull1explosiondone

	rts
	
bull1biganim

	ldx bull1counter
	lda bulletbigexplosionanim,x
	sta bull1+sprdata::pointer
	
	lda bulletbigexplosioncolours,x
	sta bull1+sprdata::colour
	
	inc bull1counter
	lda bull1counter
	cmp #bulletbigexplosionanimframes
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
	sta shootingbullet1
	
	lda #$01									; shoot immediately after bullet is gone
	sta bulletcooloff

	rts

bull1mysteryanim
	ldx bull1counter
	cpx #$03
	bmi :+
	lda bull1+sprdata::isexploding
	lsr
	lsr
	lsr
	lsr
	tay
	lda mystery100200300spriteptrs,y
	jmp :++
:	lda mysteryanim,x
:	sta bull1+sprdata::pointer
	
	lda mysterycolours,x
	sta bull1+sprdata::colour
	
	inc bull1counter
	lda bull1counter
	cmp #mysteryanimframes
	beq bull1explosiondone

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
	and #%00001111
	cmp #explosiontypes::big
	beq bomb0explosionanim
	cmp #explosiontypes::mystery
	beq bomb0mysteryanim

bomb0normalanim

	ldx bomb0counter
	lda bombanim,x
	sta bomb0+sprdata::pointer

	lda bombcolours,x
	sta bomb0+sprdata::colour

	inc bomb0counter
	lda bomb0counter
	cmp #bombanimframes
	bne :+

	lda #bombanimloopframe
	sta bomb0counter

:	rts

bomb0explosionanim
	ldx bomb0counter
	lda bombexplosionanim,x
	sta bomb0+sprdata::pointer
	
	lda bombexplosioncolours,x
	sta bomb0+sprdata::colour
	
	inc bomb0counter
	lda bomb0counter
	cmp #bombexplosionanimframes
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
	sta shootingbomb0
	
	lda #$01
	sta bombcooloff
	
	rts

bomb0mysteryanim
	ldx bomb0counter
	cpx #$03
	bmi :+
	lda bomb0+sprdata::isexploding
	lsr
	lsr
	lsr
	lsr
	tay
	lda mystery100200300spriteptrs,y
	jmp :++
:	lda mysteryanim,x
:	sta bomb0+sprdata::pointer
	
	lda mysterycolours,x
	sta bomb0+sprdata::colour
	
	inc bomb0counter
	lda bomb0counter
	cmp #mysteryanimframes
	beq bomb0explosiondone

	rts

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
	and #%00001111
	cmp #explosiontypes::big
	beq bomb1explosionanim
	cmp #explosiontypes::mystery
	beq bomb1mysteryanim

bomb1normalanim

	ldx bomb1counter
	lda bombanim,x
	sta bomb1+sprdata::pointer

	lda bombcolours,x
	sta bomb1+sprdata::colour

	inc bomb1counter
	lda bomb1counter
	cmp #bombanimframes
	bne :+

	lda #bombanimloopframe
	sta bomb1counter

:	rts

bomb1explosionanim
	ldx bomb1counter
	lda bombexplosionanim,x
	sta bomb1+sprdata::pointer
	
	lda bombexplosioncolours,x
	sta bomb1+sprdata::colour
	
	inc bomb1counter
	lda bomb1counter
	cmp #bombexplosionanimframes
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
	sta shootingbomb1
	
	lda #$01
	sta bombcooloff

	rts

bomb1mysteryanim
	ldx bomb1counter
	cpx #$03
	bmi :+
	lda bomb1+sprdata::isexploding
	lsr
	lsr
	lsr
	lsr
	tay
	lda mystery100200300spriteptrs,y
	jmp :++
:	lda mysteryanim,x
:	sta bomb1+sprdata::pointer
	
	lda mysterycolours,x
	sta bomb1+sprdata::colour
	
	inc bomb1counter
	lda bomb1counter
	cmp #mysteryanimframes
	beq bomb1explosiondone

	rts

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
	cmp spriteptrforaddress(sprites2+(missileanimstart+missileanimframes)*64)	; missile end
	bcc :+
	sec
	lda sortsprp,x
	sbc #missileanimframes							; missile anim frames
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
	sta screen1+$03f8+0
	sta screen2+$03f8+0
	lda bull0+sprdata::pointer
	sta screen1+$03f8+1
	sta screen2+$03f8+1
	lda bull1+sprdata::pointer
	sta screen1+$03f8+2
	sta screen2+$03f8+2
	lda bomb0+sprdata::pointer
	sta screen1+$03f8+3
	sta screen2+$03f8+3
	lda bomb1+sprdata::pointer
	sta screen1+$03f8+4
	sta screen2+$03f8+4

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

	lda spriteptrforaddress(sprites2+cometanimstart*64)		; comet start
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
	cmp spriteptrforaddress(sprites2+(cometanimstart+cometanimframes)*64)	; comet end
	bcc :+
	lda spriteptrforaddress(sprites2+cometanimstart*64)						; comet start
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

	lda spriteptrforaddress(sprites2+cometanimstart*64)		; comet start
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
	cmp spriteptrforaddress(sprites2+(ufoanimstart+ufoanimframes)*64)	; ufo end
	bcc :+
	lda spriteptrforaddress(sprites2+ufoanimstart*64)		; ufo start - 8E80, 8ec0, 8f00
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
	lda screenspecial+$03c0,x
	beq :+
	jmp missilefound

:	rts

missilefound

	sta calcylow
	sta calcylowvsped
	stx calcxlow
	lda clearbmptile
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

	lda spriteptrforaddress(sprites2+(missileanimstart+1)*64)	; missile start + 1 for highlight
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

	lda spriteptrforaddress(sprites2+missileanimstart*64)	; missile highlight start
	sta sortsprp,y
	lda #$07												; missile highlight colour
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

;oldsortmultsprites
	
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

plotfirstufocometmultsprites

	;lda scrollspeed
	;bne :+
	;rts

:	ldy sortorder								; y = index to highest sprite
	lda sortsprc,y
	sta $d02c
	lda sortsprp,y
	sta screen1+$03f8+5
	sta screen2+$03f8+5
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
	sta screen1+$03f8+6
	sta screen2+$03f8+6
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
	sta screen1+$03f8+7
	sta screen2+$03f8+7
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

plotrestufocometmultsprites

	lda scrollspeed
	bne :+
	rts

:	lda #$03
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
	cmp #$28
	bcc :+
	lda zone									; #$28 rasterlines left? do some stuff, but not in zone 2, because it's heavy on multiplex
	cmp #$01
	beq :+
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
	sta screen1+$03f8+5,x
	sta screen2+$03f8+5,x
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
	sta screen1+$03f8+6
	sta screen2+$03f8+6
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
	sta screen1+$03f8+7
	sta screen2+$03f8+7
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
	sta screen1+$03f8+6,x
	sta screen2+$03f8+6,x
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