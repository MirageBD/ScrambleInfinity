.segment "LOADERINSTALL"
.incbin "./exe/install-c64.prg", $02
.segment "LOADER"
.incbin "./exe/loader-c64.prg", $02

.segment "LOADBARFONT"
.incbin "./bin/loaderbar.bin"
.segment "LOADBARSCR"
.incbin "./bin/loaderbarscr.bin"

.include "loadersymbols-c64.inc"

.feature pc_assignment
.feature labels_without_colons

; -----------------------------------------------------------------------------------------------

.define d018forscreencharset(scr,cst)	#(((scr&$3fff)/$0400) << 4) | (((cst&$3fff)/$0800) << 1)
.define bankforaddress(addr)			#(3-(addr>>14))
.define spriteptrforaddress(addr)		#((addr&$3fff)>>6)

screen = $4400
loadbarfont = $4800
loadbarsrc = $4c00

; -----------------------------------------------------------------------------------------------

.segment "MAIN"

	jmp mainentry

; -----------------------------------------------------------------------------------------------

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

cols
.byte $04,$0a,$0a,$0a,$02,$02,$09,$09,$01
tims
.byte $01,$09,$09,$09,$09,$09,$09,$09,$01

; -----------------------------------------------------------------------------------------------

mainentry
	sei
	
	jsr install							; init drive code

	ldx #$00
	bcc :++
	cmp #$04							; #STATUS::DEVICE_INCOMPATIBLE
	beq :+
	ldx #$04
:	cmp #$05							; #STATUS::TOO_MANY_DEVICES
	beq :+
	ldx #$00
:	cli

	sei

	lda #$00							; Disable all interferences
	sta $d015							; for a stable timer
	lda #$35
	sta $01
	lda #$7f
	sta $dc0d
	bit $dc0d

	ldx #$01							; Wait for raster line 0 twice
:	bit $d011							; to make sure there are no sprites
	bpl :-
:	bit $d011
	bmi :-
	dex
	bpl :--

	ldx $d012							; Achieve an initial stable raster point
	inx									; using halve invariance method
:	cpx $d012
	bne :-
	ldy #$0a
:	dey
	bne :-
	inx
	cpx $d012
	nop
	beq :+
	nop
	bit $24
:	ldy #$09
:	dey
	bne :-
	nop
	nop
	inx
	cpx $d012
	nop
	beq :+
	bit $24
:	ldy #$0a
:	dey
	bne :-
	inx
	cpx $d012
	bne :+
:	.repeat 5
	nop
	.endrepeat							; Raster is stable here
	
	.repeat 13							; add offset to timer (95 cycles)
		pha
		pla
	.endrep
	nop
	nop

	lda #$3e							; Start a continious timer
	sta $dc04							; with 63 ticks each loop
	sty $dc05
	lda #%00010001
	sta $dc0e

	lda #$37
	sta $01

	lda #$1b
	sta $d011

	lda #$0c
	sta $d020
	sta $d021

	ldx #$00
:	lda #$08
	sta $d800+0*256,x
	sta $d800+1*256,x
	sta $d800+2*256,x
	sta $d800+3*256,x
	lda #$10
	sta screen+0*256,x
	sta screen+1*256,x
	sta screen+2*256,x
	sta screen+3*256,x
	inx
	bne :-

	ldx #$00
:	lda loadbarsrc,x
	sta screen+9*40,x
	inx
	cpx #$50
	bne :-

	; draw loading bar

	; long horizontal bits
	ldx #$00
:	lda #$05
	sta screen+11*40+1,x
	lda #$09
	sta screen+12*40+1,x
	lda #$0d
	sta screen+13*40+1,x
	lda #$0d
	inx
	cpx #38
	bne :-

	; upper corners
	lda #$03
	sta screen+11*40+0
	lda #$04
	sta screen+11*40+1
	lda #$06
	sta screen+11*40+38
	lda #$07
	sta screen+11*40+39

	; middle sides
	lda #$08
	sta screen+12*40+0
	lda #$0a
	sta screen+12*40+39

	; bottom corners
	lda #$0b
	sta screen+13*40+0
	lda #$0c
	sta screen+13*40+1
	lda #$0e
	sta screen+13*40+38
	lda #$0f
	sta screen+13*40+39

	lda d018forscreencharset(screen,loadbarfont)
	sta $d018
	lda bankforaddress(screen)
	sta $dd00
	lda #$18
	sta $d016
	lda #$01
	sta $d022
	lda #$0b
	sta $d023

	; copy loader to $0400
	ldx #$00
:	lda $5800+0*256,x
	sta $0400+0*256,x
	lda $5800+1*256,x
	sta $0400+1*256,x
	lda $5800+2*256,x
	sta $0400+2*256,x
	inx
	bne :-

	lda #$01
	sta $d01a

	lda #$00
	sta $d012

	lda #<irq0
	ldx #>irq0
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

	lda #$36
	sta $01

	ldx #<file01
	ldy #>file01
	jsr loadcompd ; loadraw
	bcs error

	lda #$37
	sta $01

	lda #$00
	sta loading

	ldx #$00
	lda #$10
:	sta screen+9*40,x
	inx
	bne :-
	
	lda #$1b
	sta $d011
	jmp $9000 ; $c400 ; $080d

error
	lda #$02
:	sta $d020
	jmp :-

loading
.byte $00

; -----------------------------------------------------------------------------------------------
; - START OF IRQ CODE
; -----------------------------------------------------------------------------------------------

irq0
	pha

 	lda #$1b
	sta $d011

	lda #$40							; #$4c
	jsr cycleperfect

	lda #<irq1
	ldx #>irq1
	ldy #50 + 12*8 - 1
	jmp endirq
	
; -----------------------------------------------------------------------------------------------

irq1

	pha

	lda #$40							; #$4c
	jsr cycleperfect

	ldy #$00
:	lda cols,y
	sta $d022
	ldx tims,y
:	dex
	bne :-
	iny
	cpy #$09
	bne :--

	lda loading
	cmp #$01
	bne :+

	jsr drawloadbar

:
	lda #<irq0
	ldx #>irq0
	ldy #$00
	jmp endirq

; -----------------------------------------------------------------------------------------------
; - END OF IRQ CODE
; -----------------------------------------------------------------------------------------------

file01
.asciiz "LS"

; -----------------------------------------------------------------------------------------------

drawloadbar
	lda endaddrhi				; don't do anything if too low endaddrhi/endeddrlo loadaddrhi/loadaddrlo - starts with $84
	cmp #$00
	beq :+
	cmp #$b8
	bpl :+
	jmp dlb2
:
	rts

dlb2
:
	lda initialized
	bne :+
	ldx endaddrhi				; get first loadaddress and subtract one
	dex
	stx sub+1
	lda #$01
	sta initialized

:	sec
	lda endaddrhi
sub	sbc #$84-1					; starts loading at $8400 for some reason, so extract $84-1
	inc timer
	ldx timer
	sta endtmp+1,x
	cmp #36
	bmi :+						; not 36 yet, so draw partial bar
	lda #$02
	sta screen+12*40+38			; it is 36, so draw the right parts of the bar
	lda #36
:	sta endtmp

	lda #$00
	sta screen+12*40+1			; draw left part of bar

	lda #$01
	ldx #$00
:	sta screen+12*40+2,x
	inx
	cpx endtmp
	bne :-

	rts
	
	.byte $00

timer
.byte $00

endtmp
.byte $00

initialized
.byte $00

; -----------------------------------------------------------------------------------------------	
