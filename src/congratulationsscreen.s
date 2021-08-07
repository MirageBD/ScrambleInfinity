.segment "CONGRATULATIONSSCREEN"

congratulations

	sei
	
	lda #$37
	sta $01

	lda #$7f
	sta $d011
	
	jsr clearscreen
	
	lda #$09
	sta $d021

	ldx #$00
:	lda congratulationsscreen,x
	sta screenui+9*40,x
	inx
	bne :-

	lda #$00
	sta timerlow
	sta timerhigh
	
	lda #$00
	sta timerreachedlow
	lda #$02
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
	
	lda #gameflow::initlevel
	sta gameflowstate+1

	jmp ingamefromcongratulations
    
; -----------------------------------------------------------------------------------------------