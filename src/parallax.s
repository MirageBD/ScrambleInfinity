.segment "PARALLAX"

drawstars

drawstarsoffsetlo
    ldy #$00
    tya                                 ; only check/clear/plot if the frame is odd - 7,5,3,1
    and #$01
    bne startstarcleardraw
    rts

startstarcleardraw

    ldx #$00							; see if it's gone past 32*8=256, otherwise add $0100
    lda vspoffset+1
    cmp #$20
    bmi :+
    ldx #$01
:   stx starsplothiadd256+1

    clc
    lda #>(bitmap1+$0200)				; check if we need to draw on bitmap 1 or 2
    ldx flipstored
	bne starsplothiadd256
	lda #>(bitmap2+$0200)

starsplothiadd256
    adc #$00							; add 0 or $0100
    sta starsoffset0or100

    lda #%01010101                      ; clear previous stars
    jsr dostarplot

    cpy #$07                            ; if it's 7 check if the bitmap to plot to is clear
    bne setupstarplotptrs
    jsr setupcheckplotptrs
    jmp doactualstarplot

setupstarplotptrs
    clc
    lda starsoffset0or100
    sta ds1+2
	adc #$02
    sta ds2+2
	adc #$04
    sta ds3+2
	adc #$03
    sta ds4+2
	adc #$03
    sta ds5+2
	adc #$03
    sta ds6+2
    
    ldx vspoffset+1
    lda times8lowtable,x
    sta ds1+1
    sta ds2+1
    sta ds3+1
    sta ds4+1
    sta ds5+1
    sta ds6+1

doactualstarplot
    lda starsoffset,y
    jsr dostarplot
    rts

; -----------------------------------------------------------------------------------------------

dostarplot

    ldx starsallowedtodraw+0
    beq :+
ds1 sta bitmap1							; bitmap 1 or 2 (+$0100)
:
    ldx starsallowedtodraw+1
    beq :+
ds2 sta bitmap1
:
    ldx starsallowedtodraw+2
    beq :+
ds3 sta bitmap1
:
    ldx starsallowedtodraw+3
    beq :+
ds4 sta bitmap1
:
    ldx starsallowedtodraw+4
    beq :+
ds5 sta bitmap1
:
    ldx starsallowedtodraw+5
    beq :+
ds6 sta bitmap1
:
    rts

; -----------------------------------------------------------------------------------------------

setupcheckplotptrs

    clc
    lda starsoffset0or100
    sta ds1+2
    sta cs1+2
	adc #$02
    sta ds2+2
    sta cs2+2
	adc #$04
    sta ds3+2
    sta cs3+2
	adc #$03
    sta ds4+2
    sta cs4+2
	adc #$03
    sta ds5+2
    sta cs5+2
	adc #$03
    sta ds6+2
    sta cs6+2
    
    ldx vspoffset+1
    lda times8lowtable,x
    sta ds1+1
    sta ds2+1
    sta ds3+1
    sta ds4+1
    sta ds5+1
    sta ds6+1
    sta cs1+1
    sta cs2+1
    sta cs3+1
    sta cs4+1
    sta cs5+1
    sta cs6+1

    lda #$00
    sta starsallowedtodraw+0
    sta starsallowedtodraw+1
    sta starsallowedtodraw+2
    sta starsallowedtodraw+3
    sta starsallowedtodraw+4
    sta starsallowedtodraw+5

    ldx #$01

cs1 lda bitmap1
    cmp #%01010101
    bne :+
    stx starsallowedtodraw+0
:
cs2 lda bitmap1
    cmp #%01010101
    bne :+
    stx starsallowedtodraw+1
:
cs3 lda bitmap1
    cmp #%01010101
    bne :+
    stx starsallowedtodraw+2
:
cs4 lda bitmap1
    cmp #%01010101
    bne :+
    stx starsallowedtodraw+3
:
cs5 lda bitmap1
    cmp #%01010101
    bne :+
    stx starsallowedtodraw+4
:
cs6 lda bitmap1
    cmp #%01010101
    bne :+
    stx starsallowedtodraw+5
:
    rts

; -----------------------------------------------------------------------------------------------

starsallowedtodraw
    .byte $01, $01, $01, $01, $01, $01

starsoffset0or100
    .byte $00

starsoffset
    .byte %01010111
    .byte %01010111
    .byte %01011101
    .byte %01011101
    .byte %01110101
    .byte %01110101
    .byte %11010101
    .byte %11010101

    ;.byte %01010101 ; empty

; -----------------------------------------------------------------------------------------------
