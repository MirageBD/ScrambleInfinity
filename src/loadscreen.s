;.segment "LOADERINSTALL"
;.incbin "./exe/install-c64.prg", $02
;.segment "LOADER"
;.incbin "./exe/loader-c64.prg", $02

.include "loadersymbols-c64.inc"

.segment "MUSIC"
.incbin "./bin/sanxiona000.bin"

.segment "TITLE"
.incbin "./bin/title.bin"
.segment "TITLECOL"
.incbin "./bin/titlecol.bin"
.segment "LOGOOVERLAY"
.incbin "./bin/logooverlay.bin"
.segment "LOGOSPR"
.incbin "./bin/logospr.bin"
.segment "WINGSPR"
.incbin "./bin/wingspr.bin"
.segment "EXHAUSTSPR"
.incbin "./bin/exhaustspr.bin"
.segment "SCROLLSPR"
.incbin "./bin/creditssprites.bin"

.feature pc_assignment
.feature labels_without_colons

.define d018forscreencharset(scr,cst)	#(((scr&$3fff)/$0400) << 4) | (((cst&$3fff)/$0800) << 1)
.define bankforaddress(addr)			#(3-(addr>>14))
.define spriteptrforaddress(addr)		#((addr&$3fff)>>6)

zp3							= $fc
zp4							= $fd

titlecol		= $c000
titlecold800	= ($5000 + 40*25)

scrollsprites	= $c400

logooverlay		= $cc00
logospr			= $cc00+$0100
wingspr			= $cc00+$0300
exhaustspr		= $cc00+$0380
emptyspr		= exhaustspr+16*64
title			= $e000

creditssprites	= $6000
creditssize		= $0700

; $0800 for scrollable sprite area

tunestart		= $a000
tuneinit		= $ae00
tuneplay		= $ae20

; -----------------------------------------------------------------------------------------------

.macro copymemblocks from, to, size
	clc
	lda #>from								; copy sprites to other bank
	sta copymemfrom+2
	adc #>size
	sta copymemsize+1
	lda #>to
	sta copymemto+2
	jsr copymem
.endmacro

.macro scrollspritetop sprite
	ldx #0*3

:	lda scrollsprites+((sprite+0)*4*64)+(0*64)+(1*3)+0,x
	sta scrollsprites+((sprite+0)*4*64)+(0*64)+(0*3)+0,x
	lda scrollsprites+((sprite+0)*4*64)+(0*64)+(1*3)+1,x
	sta scrollsprites+((sprite+0)*4*64)+(0*64)+(0*3)+1,x
	lda scrollsprites+((sprite+0)*4*64)+(0*64)+(1*3)+2,x
	sta scrollsprites+((sprite+0)*4*64)+(0*64)+(0*3)+2,x

	lda scrollsprites+((sprite+0)*4*64)+(1*64)+(1*3)+0,x
	sta scrollsprites+((sprite+0)*4*64)+(1*64)+(0*3)+0,x
	lda scrollsprites+((sprite+0)*4*64)+(1*64)+(1*3)+1,x
	sta scrollsprites+((sprite+0)*4*64)+(1*64)+(0*3)+1,x
	lda scrollsprites+((sprite+0)*4*64)+(1*64)+(1*3)+2,x
	sta scrollsprites+((sprite+0)*4*64)+(1*64)+(0*3)+2,x

	lda scrollsprites+((sprite+0)*4*64)+(2*64)+(1*3)+0,x
	sta scrollsprites+((sprite+0)*4*64)+(2*64)+(0*3)+0,x
	lda scrollsprites+((sprite+0)*4*64)+(2*64)+(1*3)+1,x
	sta scrollsprites+((sprite+0)*4*64)+(2*64)+(0*3)+1,x
	lda scrollsprites+((sprite+0)*4*64)+(2*64)+(1*3)+2,x
	sta scrollsprites+((sprite+0)*4*64)+(2*64)+(0*3)+2,x

	lda scrollsprites+((sprite+0)*4*64)+(3*64)+(1*3)+0,x
	sta scrollsprites+((sprite+0)*4*64)+(3*64)+(0*3)+0,x
	lda scrollsprites+((sprite+0)*4*64)+(3*64)+(1*3)+1,x
	sta scrollsprites+((sprite+0)*4*64)+(3*64)+(0*3)+1,x
	lda scrollsprites+((sprite+0)*4*64)+(3*64)+(1*3)+2,x
	sta scrollsprites+((sprite+0)*4*64)+(3*64)+(0*3)+2,x

	inx
	inx
	inx
	cpx #11*3
	bne :-
	rts
.endmacro

.macro scrollspritebottom sprite
	ldx #11*3

:	lda scrollsprites+((sprite+0)*4*64)+(0*64)+(1*3)+0,x
	sta scrollsprites+((sprite+0)*4*64)+(0*64)+(0*3)+0,x
	lda scrollsprites+((sprite+0)*4*64)+(0*64)+(1*3)+1,x
	sta scrollsprites+((sprite+0)*4*64)+(0*64)+(0*3)+1,x
	lda scrollsprites+((sprite+0)*4*64)+(0*64)+(1*3)+2,x
	sta scrollsprites+((sprite+0)*4*64)+(0*64)+(0*3)+2,x

	lda scrollsprites+((sprite+0)*4*64)+(1*64)+(1*3)+0,x
	sta scrollsprites+((sprite+0)*4*64)+(1*64)+(0*3)+0,x
	lda scrollsprites+((sprite+0)*4*64)+(1*64)+(1*3)+1,x
	sta scrollsprites+((sprite+0)*4*64)+(1*64)+(0*3)+1,x
	lda scrollsprites+((sprite+0)*4*64)+(1*64)+(1*3)+2,x
	sta scrollsprites+((sprite+0)*4*64)+(1*64)+(0*3)+2,x

	lda scrollsprites+((sprite+0)*4*64)+(2*64)+(1*3)+0,x
	sta scrollsprites+((sprite+0)*4*64)+(2*64)+(0*3)+0,x
	lda scrollsprites+((sprite+0)*4*64)+(2*64)+(1*3)+1,x
	sta scrollsprites+((sprite+0)*4*64)+(2*64)+(0*3)+1,x
	lda scrollsprites+((sprite+0)*4*64)+(2*64)+(1*3)+2,x
	sta scrollsprites+((sprite+0)*4*64)+(2*64)+(0*3)+2,x

	lda scrollsprites+((sprite+0)*4*64)+(3*64)+(1*3)+0,x
	sta scrollsprites+((sprite+0)*4*64)+(3*64)+(0*3)+0,x
	lda scrollsprites+((sprite+0)*4*64)+(3*64)+(1*3)+1,x
	sta scrollsprites+((sprite+0)*4*64)+(3*64)+(0*3)+1,x
	lda scrollsprites+((sprite+0)*4*64)+(3*64)+(1*3)+2,x
	sta scrollsprites+((sprite+0)*4*64)+(3*64)+(0*3)+2,x

	inx
	inx
	inx
	cpx #20*3
	bne :-

	lda scrollsprites+((sprite+1)*4*64)+(0*64)+( 0*3)+0
	sta scrollsprites+((sprite+0)*4*64)+(0*64)+(20*3)+0
	lda scrollsprites+((sprite+1)*4*64)+(0*64)+( 0*3)+1
	sta scrollsprites+((sprite+0)*4*64)+(0*64)+(20*3)+1
	lda scrollsprites+((sprite+1)*4*64)+(0*64)+( 0*3)+2
	sta scrollsprites+((sprite+0)*4*64)+(0*64)+(20*3)+2

	lda scrollsprites+((sprite+1)*4*64)+(1*64)+( 0*3)+0
	sta scrollsprites+((sprite+0)*4*64)+(1*64)+(20*3)+0
	lda scrollsprites+((sprite+1)*4*64)+(1*64)+( 0*3)+1
	sta scrollsprites+((sprite+0)*4*64)+(1*64)+(20*3)+1
	lda scrollsprites+((sprite+1)*4*64)+(1*64)+( 0*3)+2
	sta scrollsprites+((sprite+0)*4*64)+(1*64)+(20*3)+2

	lda scrollsprites+((sprite+1)*4*64)+(2*64)+( 0*3)+0
	sta scrollsprites+((sprite+0)*4*64)+(2*64)+(20*3)+0
	lda scrollsprites+((sprite+1)*4*64)+(2*64)+( 0*3)+1
	sta scrollsprites+((sprite+0)*4*64)+(2*64)+(20*3)+1
	lda scrollsprites+((sprite+1)*4*64)+(2*64)+( 0*3)+2
	sta scrollsprites+((sprite+0)*4*64)+(2*64)+(20*3)+2

	lda scrollsprites+((sprite+1)*4*64)+(3*64)+( 0*3)+0
	sta scrollsprites+((sprite+0)*4*64)+(3*64)+(20*3)+0
	lda scrollsprites+((sprite+1)*4*64)+(3*64)+( 0*3)+1
	sta scrollsprites+((sprite+0)*4*64)+(3*64)+(20*3)+1
	lda scrollsprites+((sprite+1)*4*64)+(3*64)+( 0*3)+2
	sta scrollsprites+((sprite+0)*4*64)+(3*64)+(20*3)+2

	rts

.endmacro

; -----------------------------------------------------------------------------------------------

.segment "MAIN"

	jmp mainentry

; -----------------------------------------------------------------------------------------------

; time critical code and small tables

cycleperfect
	sec
	sbc $dc04
	sta bplcode2+1
bplcode2
	bpl :+
:	.repeat 48
	lda #$a9
	.endrepeat
	lda #$a5
	nop		
	rts

sprraster
.byte $00,$00,$00,$00,$00,$00,$00,$06,$0e,$03,$06,$06,$04,$06,$04,$04,$0e,$0e,$03,$03,$0d,$01

opensideborder

	ldx #$06
:	sta $d016
	sty $d016
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	
	nop	
	nop
	nop
	nop
	nop
	bit $ea
	dex
	bne :-

	sta $d016,x
	sty $d016
	nop
	nop
	bit $ea
	sta $d016
	sty $d016

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	
	nop	
	nop
	ldx #$06
	stx opensideborder+1

	rts

copymem
	ldx #$00
copymemfrom
	lda $1000,x
copymemto
	sta $2000,x
	dex
	bne copymemfrom
	inc copymemfrom+2
	inc copymemto+2
	lda copymemfrom+2
copymemsize
	cmp #>($1000+$0c00)
	bne copymemfrom
	rts

scrollspritetop0
	scrollspritetop 0
scrollspritetop1
	scrollspritetop 1
scrollspritetop2
	scrollspritetop 2
scrollspritetop3
	scrollspritetop 3
scrollspritetop4
	scrollspritetop 4
scrollspritetop5
	scrollspritetop 5
scrollspritetop6
	scrollspritetop 6
scrollspritetop7
	scrollspritetop 7

scrollspritebottom0
	scrollspritebottom 0
scrollspritebottom1
	scrollspritebottom 1
scrollspritebottom2
	scrollspritebottom 2
scrollspritebottom3
	scrollspritebottom 3
scrollspritebottom4
	scrollspritebottom 4
scrollspritebottom5
	scrollspritebottom 5
scrollspritebottom6
	scrollspritebottom 6
scrollspritebottom7
	scrollspritebottom 7

; -----------------------------------------------------------------------------------------------

mainentry
	sei
	
	lda #$34
	sta $01

	copymemblocks $5000, $c000, $0400	; colors, etc.
	copymemblocks $5800, $cc00, $0a00	; sprites
	copymemblocks $7000, $e000, $2000

	ldx #$00
	lda #%00000000
:	sta scrollsprites+0*256,x
	sta scrollsprites+1*256,x
	sta scrollsprites+2*256,x
	sta scrollsprites+3*256,x
	sta scrollsprites+4*256,x
	sta scrollsprites+5*256,x
	sta scrollsprites+6*256,x
	sta scrollsprites+7*256,x
	inx
	bne :-

	lda #$37
	sta $01

	lda #<creditssprites
	sta zp3
	lda #>creditssprites
	sta zp4

	lda #$00
	sta $d011

	ldx #$00
:	lda titlecold800+0*$0100,x
	sta $d800+0*$0100,x
	lda titlecold800+1*$0100,x
	sta $d800+1*$0100,x
	lda titlecold800+2*$0100,x
	sta $d800+2*$0100,x
	lda titlecold800+3*$0100,x
	sta $d800+3*$0100,x
	inx
	bne :-

	lda d018forscreencharset(titlecol,title)
	sta $d018

	lda #$18
	sta $d016

	lda bankforaddress(title)
	sta $dd00

	lda #$00									; set all default values here
	sta $d017
	sta $d01b
	sta $d01c
	sta $d01d
	sta $d022
	sta $d023
	sta $d024

	lda #$5b
	sta $d011

	lda #$36
	sta $01
	lda #$00
	jsr tuneinit
	lda #$37
	sta $01

	lda #$01
	sta $d01a

	lda #$f8
	sta $d012

	lda #<initialirqopenborder
	ldx #>initialirqopenborder
	sta $fffe
	sta $0314
	stx $ffff
	stx $0315

	lda $dc0d
	lda $dd0d
	dec $d019

	cli

; -----------------------------------------------------------------------------------------------

	lda #$01
	sta loading

	ldx #<file01
	ldy #>file01
	jsr loadraw
	bcs error

	lda #$00
	sta loading

:

checkfire
	lda $dc00
	and #%00010000								; fire
	bne checkspace
waitreleasefire
	lda $dc00
	and #%00010000
	beq waitreleasefire
	jmp startgame

checkspace
	lda #%01111111
	sta $dc00
	lda $dc01
	and #%00010000								; space
	bne checkfire
waitreleasespace
	lda #%01111111
	sta $dc00
	lda $dc01
	and #%00010000
	beq waitreleasespace

startgame

	sei

	lda #$00
	sta $d418
	lda #$7b
	sta $d011
	lda #$00
	sta $d020
	sta $d021
	sta $d015

	jmp $080d

error
	lda #$02
:	sta $d020
	jmp :-

loading
.byte $00

enteringtext
.byte $05,$0e,$14,$05,$12,$09,$0e,$07
.byte $20,$13,$03,$12,$01,$0d,$02,$0c
.byte $05,$20,$13,$19,$13,$14,$05,$0d

; -----------------------------------------------------------------------------------------------
; - START OF IRQ CODE
; -----------------------------------------------------------------------------------------------

;.segment "IRQ"

irqlogosprites
	pha

	lda #$46							; #$4c
	jsr cycleperfect

	lda #$00
	sta $dd00
 	lda #$5b
	sta $d011

	lda #$ff
	sta $d015
	sta $d01c
	lda #$00
	sta $d01b							; sprite priority
	lda #%10000000
	sta $d010

	lda #$02
	sta $d025
	lda #$0b
	sta $d026
	lda #$00
	sta $d027+0
	sta $d027+1
	sta $d027+2
	sta $d027+3
	sta $d027+4
	sta $d027+5
	sta $d027+6
	sta $d027+7

	lda #$1d
	sta $d001+0*2
	sta $d001+1*2
	sta $d001+2*2
	sta $d001+3*2
	sta $d001+4*2
	sta $d001+5*2
	sta $d001+6*2
	sta $d001+7*2

	lda #(88+0*24)&255
	sta $d000+0*2
	lda #(88+1*24)&255
	sta $d000+1*2
	lda #(88+2*24)&255
	sta $d000+2*2
	lda #(88+3*24)&255
	sta $d000+3*2
	lda #(88+4*24)&255
	sta $d000+4*2
	lda #(88+5*24)&255
	sta $d000+5*2
	lda #(88+6*24)&255
	sta $d000+6*2
	lda #(88+7*24)&255
	sta $d000+7*2

	ldx spriteptrforaddress(logospr)
	stx titlecol+$03f8+0
	inx
	stx titlecol+$03f8+1
	inx
	stx titlecol+$03f8+2
	inx
	stx titlecol+$03f8+3
	inx
	stx titlecol+$03f8+4
	inx
	stx titlecol+$03f8+5
	inx
	stx titlecol+$03f8+6
	inx
	stx titlecol+$03f8+7

	ldx #$00
:	lda sprraster,x
	sta $d025
	ldy #$05
:	dey
	bne :-
	bit $ea
	inx
	cpx #22
	bne :--

	nop
	nop

	ldx #$18
	ldy #$3b
	stx $d016
	sty $d011

	; do fancy effects here
:	;inc $d020

	;lda #$94
	;cmp $d012
	;bne :-

	;lda #$0c
	;sta $d020

	; set left wing sprite
	lda #$0b
	sta $d027+7

	lda #%00000000
	sta $d010
	lda #$99
	sta $d001+7*2
	lda #$00
	sta $d000+7*2
	ldx spriteptrforaddress(wingspr)
	stx titlecol+$03f8+7

	; set sprite logo overlay and scrollable sprites
	lda #%00000000
	sta $d010
	lda #$70
	sta $d001+3*2
	sta $d001+4*2
	sta $d001+5*2
	sta $d001+6*2

	lda #(136+0*24)&255
	sta $d000+3*2
	lda #(136+1*24)&255
	sta $d000+4*2
	lda #(136+2*24)&255
	sta $d000+5*2
	lda #(136+3*24)&255
	sta $d000+6*2

	lda #$00
	sta $d025
	lda #$0f
	sta $d026
	lda #$01
	sta $d027+3
	sta $d027+4
	sta $d027+5
	sta $d027+6

	ldx spriteptrforaddress(scrollsprites+0*64)
	stx titlecol+$03f8+3
	ldx spriteptrforaddress(scrollsprites+1*64)
	stx titlecol+$03f8+4
	ldx spriteptrforaddress(scrollsprites+2*64)
	stx titlecol+$03f8+5
	ldx spriteptrforaddress(scrollsprites+3*64)
	stx titlecol+$03f8+6

	jsr scrollspritebottom0
	jsr scrollspritetop1
	jsr scrollspritebottom1

	lda #$70+21
	sta $d001+3*2
	sta $d001+4*2
	sta $d001+5*2
	sta $d001+6*2

	lda #$70+21
:	cmp $d012
	bne :-

	ldx spriteptrforaddress(scrollsprites+4*64)
	stx titlecol+$03f8+3
	ldx spriteptrforaddress(scrollsprites+5*64)
	stx titlecol+$03f8+4
	ldx spriteptrforaddress(scrollsprites+6*64)
	stx titlecol+$03f8+5
	ldx spriteptrforaddress(scrollsprites+7*64)
	stx titlecol+$03f8+6

	lda #<irqleftwing1
	ldx #>irqleftwing1
	ldy #$95
	jmp endirq
	
; -----------------------------------------------------------------------------------------------

irqleftwing1

	pha
	
	lda #<irqleftwing2
	ldx #>irqleftwing2
	ldy #$99							; 2 lines before badline
	jmp endirq

; -----------------------------------------------------------------------------------------------

irqleftwing2

	pha

	lda #$4c							; #$4c
	jsr cycleperfect

	lda #$17
	ldy #$18
	ldx #$00
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bit $ea
	sta $d016
	sty $d016
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	
	nop	
	nop
	ldx #$06
	stx opensideborder+1
	jsr opensideborder
	jsr opensideborder

	; set right wing sprite
	lda #%10000000
	sta $d010
	lda #$db
	sta $d001+7*2
	lda #$58
	sta $d000+7*2
	ldx spriteptrforaddress(wingspr+64)
	stx titlecol+$03f8+7

	lda #<irqrightwing
	ldx #>irqrightwing
	ldy #$db
	jmp endirq

; -----------------------------------------------------------------------------------------------

irqrightwing

	pha

	lda #$54							; #$4c
	jsr cycleperfect

	lda #$17
	ldy #$18
	ldx #$05
	stx opensideborder+1
	jsr opensideborder
	jsr opensideborder

	; set exhaust sprites
	lda #$ff
	sta $d015
	sta $d01c
	lda #%11100000
	sta $d010

	lda #$01
	sta $d025
	lda #$03
	sta $d026
	lda #$0d
	sta $d027+0
	sta $d027+1
	sta $d027+2
	sta $d027+3
	sta $d027+4
	lda #$00
	sta $d027+5
	sta $d027+6
	sta $d027+7

	lda #$fa
	sta $d001+0*2
	sta $d001+1*2
	sta $d001+2*2
	sta $d001+3*2
	sta $d001+4*2
	sta $d001+5*2
	sta $d001+6*2
	sta $d001+7*2

	lda #(56+0*24)&255
	sta $d000+0*2
	lda #(56+1*24)&255
	sta $d000+1*2
	lda #(56+2*24)&255
	sta $d000+2*2
	lda #(56+4*24)&255
	sta $d000+3*2
	lda #(56+5*24)&255
	sta $d000+4*2

	lda #(16+0*24)&255
	sta $d000+5*2
	lda #(16+1*24)&255
	sta $d000+6*2
	lda #(16+2*24)&255
	sta $d000+7*2

	ldx spriteptrforaddress(exhaustspr)
	stx titlecol+$03f8+0
	inx
	stx titlecol+$03f8+1
	inx
	stx titlecol+$03f8+2
	inx
	stx titlecol+$03f8+3
	inx
	stx titlecol+$03f8+4

	lda loading
	cmp #$01
	beq setloadingspritesbase

setpressfiresprites

	ldx spriteptrforaddress(emptyspr)
	stx titlecol+$03f8+5
	ldx spriteptrforaddress(exhaustspr+8*64)
	stx titlecol+$03f8+6
	inx
	stx titlecol+$03f8+7
	jmp setloadingspritesend

setloadingspritesbase

	inc flashtimer
	lda flashtimer
	and #%00100000
	beq setloadingsprites

setloadingspritesempty

	ldx spriteptrforaddress(emptyspr)
	stx titlecol+$03f8+5
	stx titlecol+$03f8+6
	stx titlecol+$03f8+7
	jmp setloadingspritesend

setloadingsprites

	ldx spriteptrforaddress(exhaustspr+5*64)
	stx titlecol+$03f8+5
	inx
	stx titlecol+$03f8+6
	inx
	stx titlecol+$03f8+7
	jmp setloadingspritesend

setloadingspritesend

	lda #<irqopenborder
	ldx #>irqopenborder
	ldy #$f8
	jmp endirq

; -----------------------------------------------------------------------------------------------

irqopenborder
	pha

	nop
	nop

	lda #$32				; open border : unset RSEL bit (and #%00110111) + turn on ECM to move ghostbyte to $f9ff
	sta $d011

	lda #$41							; #$4c
	jsr cycleperfect

	ldx #$54				; open border : unset RSEL bit (and #%00110111) + turn on ECM to move ghostbyte to $f9ff
	ldy #$08				; no multicolour or bitmap, otherwise ghostbyte move won't work
	stx $d011
	sty $d016

	; second row of exhaust sprites
	lda #$0f
	sta $d001+0*2
	sta $d001+1*2
	sta $d001+2*2
	sta $d001+3*2
	sta $d001+4*2
	sta $d001+5*2
	sta $d001+6*2
	sta $d001+7*2

	jsr copyspriteline

	lda #$0d
:	cmp $d012
	bne :-

	lda #$0d
	sta $d027+5

	lda #$48							; #$4c
	jsr cycleperfect

	ldx spriteptrforaddress(exhaustspr+10*64)
	stx titlecol+$03f8+0
	inx
	stx titlecol+$03f8+1
	inx
	stx titlecol+$03f8+2
	inx
	stx titlecol+$03f8+3
	inx
	stx titlecol+$03f8+4
	inx
	stx titlecol+$03f8+5

	lda #(56+3*24)&255
	sta $d000+3*2
	lda #(56+4*24)&255
	sta $d000+4*2
	lda #(56+5*24)&255
	sta $d000+5*2

	lda #%11000000
	sta $d010

	ldx spriteptrforaddress(emptyspr)
	stx titlecol+$03f8+6
	stx titlecol+$03f8+7

	lda #$ff							; put sprites back up so the upper border doesn't draw them again
	sta $d001+0*2
	sta $d001+1*2
	sta $d001+2*2
	sta $d001+3*2
	sta $d001+4*2
	sta $d001+5*2
	sta $d001+6*2
	sta $d001+7*2

	jsr scrollspritetop0

	dec $d020

	lda #$36
	sta $01
	jsr tuneplay
	lda #$37
	sta $01

	inc $d020

	lda #<irqlogosprites
	ldx #>irqlogosprites
	ldy #$18
	jmp endirq

; -----------------------------------------------------------------------------------------------

initialirqopenborder

	pha

	nop
	nop

	ldy #$1f
	sty $d011

	lda #$32				; open border : unset RSEL bit (and #%00110111) + turn on ECM to move ghostbyte to $f9ff
	sta $d011

	lda #<initialirqlowerborder
	ldx #>initialirqlowerborder
	ldy #$fa
	jmp endirq

; -----------------------------------------------------------------------------------------------

initialirqlowerborder
	pha

	nop
	nop

	lda #$54				; open border : unset RSEL bit (and #%00110111) + turn on ECM to move ghostbyte to $f9ff
	sta $d011

	lda #$08				; no multicolour or bitmap, otherwise ghostbyte move won't work
	sta $d016

	lda #<irqlogosprites
	ldx #>irqlogosprites
	ldy #$18
	jmp endirq

; -----------------------------------------------------------------------------------------------
; - END OF IRQ CODE
; -----------------------------------------------------------------------------------------------

file01
.asciiz "FF"

flashtimer
.byte $00

; -----------------------------------------------------------------------------------------------

copyspriteline

	ldy #$ff
	iny
	lda (zp3),y
	sta scrollsprites+(2*4*64)+(0*64)+0
	iny
	lda (zp3),y
	sta scrollsprites+(2*4*64)+(0*64)+1
	iny
	lda (zp3),y
	sta scrollsprites+(2*4*64)+(0*64)+2

	iny
	lda (zp3),y
	sta scrollsprites+(2*4*64)+(1*64)+0
	iny
	lda (zp3),y
	sta scrollsprites+(2*4*64)+(1*64)+1
	iny
	lda (zp3),y
	sta scrollsprites+(2*4*64)+(1*64)+2

	iny
	lda (zp3),y
	sta scrollsprites+(2*4*64)+(2*64)+0
	iny
	lda (zp3),y
	sta scrollsprites+(2*4*64)+(2*64)+1
	iny
	lda (zp3),y
	sta scrollsprites+(2*4*64)+(2*64)+2

	iny
	lda (zp3),y
	sta scrollsprites+(2*4*64)+(3*64)+0
	iny
	lda (zp3),y
	sta scrollsprites+(2*4*64)+(3*64)+1
	iny
	lda (zp3),y
	sta scrollsprites+(2*4*64)+(3*64)+2

	clc
	lda zp3
	adc #$0c
	sta zp3
	lda zp4
	adc #$00
	sta zp4

	cmp #>(creditssprites+creditssize)
	bne :+

	lda #<creditssprites
	sta zp3
	lda #>creditssprites
	sta zp4

:	rts

; -----------------------------------------------------------------------------------------------

endirq	
	sta $fffe
	sta $0314
	stx $ffff
	stx $0315
	sty $d012
	dec $d019

	lda #%00000010
	and $01
	beq :+
	pla
	jmp $ea81
:
	pla
	rti

; -----------------------------------------------------------------------------------------------	
