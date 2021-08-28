.segment "FIREBULLET"

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
	lda #bulletspeedx
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
	lda #bulletspeedx
	sta bull1+sprdata::xvel
	lda #$00
	sta bull1+sprdata::yvel

	;lda #$00
	sta bull1counter
	lda #$02
	sta bull1counter2

	; fallthrough

; -----------------------------------------------------------------------------------------------

.segment "FIREBOMB"

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
	lda #bombstartspeedx
	sta bomb0+sprdata::xvel
	lda #bombstartspeedy
	sta bomb0+sprdata::yvel

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
	lda #bombstartspeedx
	sta bomb1+sprdata::xvel
	lda #bombstartspeedy
	sta bomb1+sprdata::yvel

	lda #$00
	sta bomb1counter
	lda #$03
	sta bomb1counter2
	
	;jsr tryfirebomb

no1

	; fall through

; -----------------------------------------------------------------------------------------------

.segment "RESTRICTSHIP"

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
	; fall through

; -----------------------------------------------------------------------------------------------

.segment "HANDLECOOLOFF"

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

.segment "POINTSFORBEINGALIVE"

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

.segment "INCREASEMYSTERYTIMER"

; increasemysterytimer

	inc mysterytimer
	lda mysterytimer
	cmp #$04
	bne :+
	lda #$01
	sta mysterytimer

:	rts

; -----------------------------------------------------------------------------------------------

