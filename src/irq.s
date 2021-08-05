irq1
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
	bne :+									; do vsp
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

	jsr normalgameplay

	lda #$40									; #$4c
	jsr cycleperfect
	
	lda #<irq2
	ldx #>irq2
	ldy #$f2
	jmp endirq
	
; -----------------------------------------------------------------------------------------------
	
irq2											; start of bottom border irq
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

	ldx spriteptrforaddress(scoreandfuelsprites)
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

	lda #<irq3
	ldx #>irq3
	ldy #$f8
	jmp endirq
	
; -----------------------------------------------------------------------------------------------

irq3
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

	jsr normalgameplay2
	
irq3veclo
	lda #<irq1
irq3vechi
	ldx #>irq1
	ldy #$31
	jmp endirq

; -----------------------------------------------------------------------------------------------

irqloadsubzone
	pha

	lda #<irqloadsubzone
	ldx #>irqloadsubzone
	ldy #$31
	jmp endirq

; -----------------------------------------------------------------------------------------------
		
irqlivesleft

	pha

	lda #$42									; #$4c
	jsr cycleperfect

	jsr drawbarschar

	lda timerreached
	bne timerreacheddone
	
	inc timerlow
	bne :+
	inc timerhigh
	
:	lda timerhigh
	cmp timerreachedhigh
	bne timerreacheddone
	lda timerlow
	cmp timerreachedlow
	bne timerreacheddone
	lda #$01
	sta timerreached
	
timerreacheddone
	lda #<irqlivesleft
	ldx #>irqlivesleft
	ldy #$32+9*8+2
	jmp endirq

timerlow
.byte $00
timerhigh
.byte $00
timerreachedlow
.byte $00
timerreachedhigh
.byte $00
timerreached
.byte $00

drawbarschar
	ldx #$00
:	lda barsd022,x
	sta $d022
	lda barsd023,x
	sta $d023
	ldy barswait,x
:	dey
	bne :-
	inx
	cpx #$23
	bne :--
	rts

; -----------------------------------------------------------------------------------------------
; - END OF IRQ CODE
; -----------------------------------------------------------------------------------------------

animship

	inc s0counter2
	lda s0counter2
	cmp #$08
	beq :+
	
	rts
	
:	lda #$00
	sta s0counter2
	lda ship0+sprdata::isexploding
	cmp #explosiontypes::none
	beq ship0normalanim
	ldx s0counter
	lda bombexplosionanim,x
	sta ship0+sprdata::pointer
	lda bombexplosioncolours,x
	sta ship0+sprdata::colour
	inc s0counter
	lda s0counter
	cmp #$08
	beq ship0explosiondone
	rts
	
ship0explosiondone
	lda #$ff
	sta ship0+sprdata::ylow
	lda #$00
	sta ship0+sprdata::xlow
	sta ship0+sprdata::xhigh
	sta ship0+sprdata::xvel
	sta ship0+sprdata::yvel
	sta ship0+sprdata::isexploding
	rts

ship0normalanim
	inc s0counter
	lda s0counter
	and #shipanimframes
	tax
	lda s0anim,x
	sta ship0+sprdata::pointer
	lda #$01
	sta ship0+sprdata::colour
	rts
    