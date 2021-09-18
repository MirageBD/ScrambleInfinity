.segment "PARALLAX"

.macro checkorplotstar arg0
    ldx starsallowedtodraw+arg0
    beq :+
    .ident(.sprintf("ds%s", .string(arg0))):
    sta bitmap1
:
.endmacro

.macro checkstar arg0
    .ident(.sprintf("cs%s", .string(arg0))):
    lda bitmap1
    cmp #%01010101
    bne :+
    stx starsallowedtodraw+arg0
:
.endmacro

.macro setupstarplot arg0, arg1
    sta arg0+2
	adc #arg1
.endmacro

.macro setupstarcheckplot arg0, arg1, arg2
    sta arg0+2
    sta arg1+2
	adc #arg2
.endmacro

.macro setstarpattern arg0, arg1
    sta arg0+1
    sta arg1+1
.endmacro


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
    setupstarplot ds0, 2
    setupstarplot ds1, 4
    setupstarplot ds2, 3
    setupstarplot ds3, 3
    setupstarplot ds4, 3
    setupstarplot ds5, 3

    ldx vspoffset+1
    lda times8lowtable,x
    sta ds0+1
    sta ds1+1
    sta ds2+1
    sta ds3+1
    sta ds4+1
    sta ds5+1

doactualstarplot
    lda starsoffset,y
    jsr dostarplot
    rts

; -----------------------------------------------------------------------------------------------


dostarplot

    checkorplotstar 0
    checkorplotstar 1
    checkorplotstar 2
    checkorplotstar 3
    checkorplotstar 4
    checkorplotstar 5

    rts

; -----------------------------------------------------------------------------------------------

setupcheckplotptrs

    clc
    lda starsoffset0or100

    setupstarcheckplot ds0, cs0, 2
    setupstarcheckplot ds1, cs1, 4
    setupstarcheckplot ds2, cs2, 3
    setupstarcheckplot ds3, cs3, 3
    setupstarcheckplot ds4, cs4, 3
    setupstarcheckplot ds5, cs5, 3

    ldx vspoffset+1
    lda times8lowtable,x
    setstarpattern ds0, cs0
    setstarpattern ds1, cs1
    setstarpattern ds2, cs2
    setstarpattern ds3, cs3
    setstarpattern ds4, cs4
    setstarpattern ds5, cs5

    lda #$00
    sta starsallowedtodraw+0
    sta starsallowedtodraw+1
    sta starsallowedtodraw+2
    sta starsallowedtodraw+3
    sta starsallowedtodraw+4
    sta starsallowedtodraw+5

    ldx #$01
    checkstar 0
    checkstar 1
    checkstar 2
    checkstar 3
    checkstar 4
    checkstar 5

    rts

; -----------------------------------------------------------------------------------------------

starsallowedtodraw
    .byte $01, $01, $01, $01, $01, $01

starsoffset0or100
    .byte $00

starsoffset
    .byte %01010110
    .byte %01010110
    .byte %01011001
    .byte %01011001
    .byte %01100101
    .byte %01100101
    .byte %10010101
    .byte %10010101

    ;.byte %01010101 ; empty

; -----------------------------------------------------------------------------------------------
