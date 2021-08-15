.segment "CYCLEPERFECT"
cycleperfect	cycleperfectmacro

.segment "IRQINGAME"

irqingame31

	pha
	sec

vspcor
	lda #$35
	sbc $dc04
	sta bplcode+1
bplcode
	bpl :+
:	.repeat 48
	lda #$a9
	.endrepeat
	lda #$a5									; a5 = lda zp = 3 cycles

	nop

page
	lda bankforaddress(bitmap2)
	sta $dd00
	
	lda d018forscreencharset(screen2,bitmap2)
	sta $d018

	ldx #$6b

vspoffset
	bne :+										; do vsp
:
	.repeat 19
	lda #$a9
	.endrepeat
	lda #$a5
	nop

	stx $d011
	lda #$3c									; vsp
	sta $d011

ingamebkgcolor	
	lda #$00									; ingame bkg colour
	sta $d021

	lda #$ff
	sta $d015
	sta $d01c									; sprite multicolour

	lda #$00
	sta $d01b									; sprite priority

	jsr ingame1

	lda #$40									; #$4c
	jsr cycleperfect
	
	;lda $d012
	;cmp #$80
	;bmi :+
	;cmp #$f2
	;bmi :+
	;lda #$02
	;sta $d020

	lda #<irqingamef2
	ldx #>irqingamef2
	ldy #$f2
	jmp endirq
	
; -----------------------------------------------------------------------------------------------
	
irqingamef2											; start of bottom border irq

	pha

	nop
	nop
	nop
	nop
	nop
	
 	lda #$69
 	sta $d011
 
	lda #$fc
	sta $d001
	sta $d003
	sta $d005
	sta $d007
	sta $d009
	sta $d00b
	sta $d00d
	sta $d00f

	lda #$33
	sta $d000
	
	lda #$72+0*24
	sta $d002
	lda #$72+1*24
	sta $d004
	lda #$72+2*24
	sta $d006
	lda #$72+3*24
	sta $d008
	lda #$72+4*24
	sta $d00a
	lda #$72+5*24
	sta $d00c
	
	lda #$27
	sta $d00e

	lda #%10000000
	sta $d010

	ldx spriteptrforaddress(fuelandscoresprites)
	stx screenbordersprites+$03f8+0
	inx
	stx screenbordersprites+$03f8+1
	inx
	stx screenbordersprites+$03f8+2
	inx
	stx screenbordersprites+$03f8+3
	inx
	stx screenbordersprites+$03f8+4
	inx
	stx screenbordersprites+$03f8+5
	inx
	stx screenbordersprites+$03f8+6
	inx
	stx screenbordersprites+$03f8+7

	lda #<irqingamef8
	ldx #>irqingamef8
	ldy #$f8
	jmp endirq
	
; -----------------------------------------------------------------------------------------------

irqingamef8

	pha
	
 	ldx #$00
	lda #$7f
	ldy #$74
	sta $d011,x									; open border
	sty $d011

	lda d018forscreencharset(screenbordersprites,fontui)
	sta $d018

	lda bankforaddress(screenbordersprites)
	sta $dd00

	lda #$0b
	sta $d025
	lda #$01
	sta $d026
	
	ldy #$07
	lda fuel
	cmp #$10
	bcs :++

	inc fuellowtimer
	lda fuellowtimer
	cmp #$10
	bne :+
	lda #$00
	sta fuellowtimer
:	lda fuellowtimer
	lsr
	lsr
	lsr
	tax
	ldy fuelblink,x
	
:	sty $d027
	sty $d028
	sty $d029
	sty $d02a
	sty $d02b
	sty $d02c
	sty $d02d
	sty $d02e

	jsr ingame2
	
	lda #<irqingame31
	ldx #>irqingame31
	ldy #$31

	jmp endirq

; -----------------------------------------------------------------------------------------------