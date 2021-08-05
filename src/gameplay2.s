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
