.segment "PARALLAX"

drawstars

    lda #%01010101                      ; clear previous stars
    jsr doplot

    ldy #$00                            ; see if it's gone past 32*8=256, otherwise add $0100
    lda vspoffset+1
    cmp #$20
    bmi :+
    ldy #$01
:   sty starsadd256

    lda #>(bitmap1+$0200)               ; check if we need to draw on bitmap 1 or 2
    ldx flipstored
	bne flipchecked
	lda #>(bitmap2+$0200)

flipchecked
    clc
    adc starsadd256
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

drawstarsoffsetlo
    ldx #$00
    lda stars,x
    jsr doplot
    rts

doplot

ds1 sta bitmap1+$0800
ds2 sta bitmap1+$0800
ds3 sta bitmap1+$0800
ds4 sta bitmap1+$0800
ds5 sta bitmap1+$0800
ds6 sta bitmap1+$0800

    rts

starsadd256
    .byte $00

stars
    .byte %01010111
    .byte %01010111
    .byte %01011101
    .byte %01011101
    .byte %01110101
    .byte %01110101
    .byte %11010101
    .byte %11010101