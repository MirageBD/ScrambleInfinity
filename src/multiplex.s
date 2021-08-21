.segment "MULTIPLEX"

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

plotrestufoloop
	ldx restmultspritesindex					; x = virtual sprite index (1-MAXMULTPLEXSPR)
	ldy sortorder,x								; y = index to real sprite index
	lda sortsprylow,y
	cmp #$ff
	bne hctestufo

	jmp plotrestufoend

hctestufo
	ldx restmultspritesindex					; see how much time we have before the next sprite
	ldy sortorder,x
	lda sortsprylow,y
	cmp #$ff
	beq plotrestufoend

	sec
	sbc $d012
	clc
	cmp #$28									; #$28 rasterlines left? do some stuff
	bcc :+
	jsr handlecollisions
	jmp hctestufo

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
	beq plotrestufoend
	jmp plotrestufoloop

plotrestufoend
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

plotrestmissileloop
	ldx restmultspritesindex					; x = virtual sprite index (1-MAXMULTPLEXSPR)
	ldy sortorder,x								; y = index to real sprite index
	lda sortsprylow,y
	cmp #$ff
	bne hctestmissile

	jmp plotrestmissileend
	
hctestmissile
	ldx restmultspritesindex					; see how much time we have before the next sprite
	ldy sortorder,x
	lda sortsprylow,y
	cmp #$ff
	beq plotrestmissileend
	
	sec
	sbc $d012
	clc
	cmp #$28									; #$28 rasterlines left? do some stuff!
	bcc :+
	jsr handlecollisions
	jmp hctestmissile

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
	beq plotrestmissileend
	
	jmp plotrestmissileloop

plotrestmissileend
	jsr handlerestcollisions
	
	rts

sprtbl
.byte $00,$01,$02,$00,$01,$02,$00,$01,$02,$00,$01,$02
ortbl
.byte %00100000, %01000000, %10000000
andtbl
.byte %11011111, %10111111, %01111111

; -----------------------------------------------------------------------------------------------