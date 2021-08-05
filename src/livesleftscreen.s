.segment "LIVESLEFTSCREEN"

livesleftscreen

	sei
	
	lda #$37
	sta $01

	lda #$00										; no sprites on lives left screen
	sta $d015

	lda #$7f
	sta $d011
	
	jsr clearscreen
	
	lda #$09
	sta $d021

	lda lives
	asl
	asl
	tax
	lda digits,x
	sta screenui+11*40+11+0
	inx
	lda digits,x
	sta screenui+11*40+11+1
	inx
	lda digits,x
	sta screenui+12*40+11+0
	inx
	lda digits,x
	sta screenui+12*40+11+1
	inx

	ldx #$00
:	lda livesleft1,x
	sta screenui+11*40+14,x
	lda livesleft2,x
	sta screenui+12*40+14,x
	inx
	cpx #$10
	bne :-

	lda #$00
	sta timerlow
	sta timerhigh
	
	lda #$80
	sta timerreachedlow
	lda #$00
	sta timerreachedhigh

	lda #$00
	sta timerreached
	
	lda #$01
	sta $d01a

	lda #$32+9*8+2
	sta $d012

	lda #<irqlivesleft
	ldx #>irqlivesleft
	sta $fffe
	sta $0314
	stx $ffff
	stx $0315

	lda $dc0d
	lda $dd0d
	dec $d019
	cli

	lda #$1b
	sta $d011
	
:	lda timerreached
	cmp #$01
	bcc :-
	
	lda #states::initlevel
	sta state+1

	jmp ingamefromlivesleftscreen

digits ; top left, top right, bottom left, bottom right
.byte $01,$02,$21,$22
.byte $00,$03,$00,$23
.byte $04,$05,$24,$25
.byte $06,$07,$26,$27
.byte $08,$09,$28,$29
.byte $0a,$0b,$2a,$2b
.byte $0c,$0d,$2c,$2d
.byte $0e,$0f,$2e,$2f
.byte $10,$11,$30,$31
.byte $10,$12,$32,$33

livesleft1
.byte $13,$14,$15,$16,$17,$18,$19,$0D,$1A,$1B,$1C,$18,$1D,$1E,$1F,$20 
livesleft2
.byte $34,$35,$36,$37,$38,$39,$3A,$2B,$3B,$3C,$3D,$39,$3E,$3F,$40,$00 