.segment "SFX"

.define sfx_zp0 $1a

sfx_init
		lda #$00
		tax
:		sta sidstart,x
		inx
		cpx #$19
		bne :-
		lda #%00011111								; % 0001 1111
		sta sidvolumefilter
		lda #$60
		sta sidfilter+fcutoff2
		lda #$00
		sta sfx_tablevoice2+0
		lda #$00
		sta sfx_tablevoice3+0
		lda #$38
		sta sidvoice1+attkd
		sta sidvoice3+attkd
		lda #$00
		sta sidvoice1+susvr
		sta sidvoice3+susvr
		lda #$00
		sta sidvoice1+pulswlo
		sta sidvoice3+pulswlo
		lda #$08
		sta sidvoice1+pulswhi
		sta sidvoice3+pulswhi

		rts

; ------------------------------------------- init voices

sfx_initwoopsound							; initialise for woop,woop-sound
		lda #$00							; sfx_tablevoice1 = 00   0b 0b   00 03   00 03   c0
		sta sfx_tablevoice1+0
		lda #$0b
		sta sfx_tablevoice1+1
		sta sfx_tablevoice1+2
		lda #$00
		sta sfx_tablevoice1+3
		sta sfx_tablevoice1+5
		lda #$03
		sta sfx_tablevoice1+4
		sta sfx_tablevoice1+6
		lda #$c0
		sta sfx_tablevoice1+7

		lda #$00
		sta sidvoice1+attkd
		lda #$c0
		sta sidvoice1+susvr

		lda #ctriangle+cvoiceoff
		sta sidvoice1+ctrl
		lda #ctriangle+cvoiceon
		sta sidvoice1+ctrl

		rts

sfx_initfuellowsound						; initialise for fuel low sound
		lda #$04							; sfx_tablevoice1 = 04   30 30   9c 0d   9c 0d   20
		sta sfx_tablevoice1+0
		lda #$30
		sta sfx_tablevoice1+1
		sta sfx_tablevoice1+2
		lda #$9c
		sta sfx_tablevoice1+3
		sta sfx_tablevoice1+5
		lda #$0d
		sta sfx_tablevoice1+4
		sta sfx_tablevoice1+6
		lda #$20
		sta sfx_tablevoice1+7

		lda #$00
		sta sidvoice1+attkd
		lda #$c0
		sta sidvoice1+susvr

		lda #ctriangle+cvoiceoff
		sta sidvoice1+ctrl
		lda #ctriangle+cvoiceon
		sta sidvoice1+ctrl

		rts

sfx_initextralifesoundvoice1				; sfx_tablevoice1 = 06   40 40
		lda #$06
		sta sfx_tablevoice1+0
		lda #$40
		sta sfx_tablevoice1+1
		sta sfx_tablevoice1+2

		lda #$00
		sta sidvoice1+freqlo
		lda #$60
		sta sidvoice1+freqhi
		lda #$30
		sta sidvoice1+attkd
		lda #$f3
		sta sidvoice1+susvr

		lda #csaw+cvoiceoff
		sta sidvoice1+ctrl
		lda #csaw+cvoiceon
		sta sidvoice1+ctrl

		rts

sfx_initshipexplodessoundvoice1
		lda #$08							; sfx_tablevoice1 = 08
		sta sfx_tablevoice1+0

		lda #$00
		sta sidvoice1+freqlo
		lda #$0a
		sta sidvoice1+freqhi
		lda #$0b
		sta sidvoice1+attkd
		lda #$00
		sta sidvoice1+susvr

		lda #cnoise+cvoiceoff
		sta sidvoice1+ctrl
		lda #cnoise+cvoiceon
		sta sidvoice1+ctrl
		rts

sfx_silencevoice1
		lda #cvoiceoff
		sta sidvoice1+ctrl
		rts

sfx_initfirebulletsoundvoice2
		lda #$0a							; sfx_tablevoice2 = 0a 00 40
		sta sfx_tablevoice2+0
		lda #$00
		sta sfx_tablevoice2+1
		lda #$20
		sta sfx_tablevoice2+2

		lda #$09
		sta sidvoice2+attkd
		lda #$00
		sta sidvoice2+susvr

		lda #cnoise+cvoiceoff
		sta sidvoice2+ctrl
		lda #cnoise+cvoiceon
		sta sidvoice2+ctrl

		rts

sfx_initbulletexplosionsoundvoice2
		lda #$00							; sfx_tablevoice2 = 00
		sta sfx_tablevoice2+0

		lda #$00
		sta sidvoice2+freqlo
		lda #$80
		sta sidvoice2+freqhi
		lda #$0a
		sta sidvoice2+attkd
		lda #$00
		sta sidvoice2+susvr

		lda #cnoise+cvoiceoff
		sta sidvoice2+ctrl
		lda #cnoise+cvoiceon
		sta sidvoice2+ctrl
		rts

sfx_initcometsoundvoice2
		lda #$00							; sfx_tablevoice2 = 00
		sta sfx_tablevoice2+0

		lda #$00
		sta sidvoice2+freqlo
		lda #$c8
		sta sidvoice2+freqhi
		lda #$99
		sta sidvoice2+attkd
		lda #$00
		sta sidvoice2+susvr

		lda #cnoise+cvoiceoff
		sta sidvoice2+ctrl
		lda #cnoise+cvoiceon
		sta sidvoice2+ctrl

		rts

; ------------------------------------------- init voices with compare

sfx_initfirebombsoundvoice3
		lda sfx_zp0
		bpl :+
		lda #$78							; sfx_tablevoice3 = 78 58 73
		sta sfx_tablevoice3+0
		lda #$00
		sta sidvoice3+attkd
		lda #$ab
		sta sidvoice3+susvr
		lda #$58
		sta sfx_tablevoice3+1
		lda #$33
		sta sfx_tablevoice3+2
		lda #ctriangle+cvoiceoff
		sta sidvoice3+ctrl
		lda #ctriangle+cvoiceon
		sta sidvoice3+ctrl
		lda #$00
		sta sidfilter+fctrl
:		rts

sfx_initbombexplosionsoundvoice3
		lda sfx_zp0
		bpl :+
		lda #$00							; sfx_tablevoice3 = 00
		sta sfx_tablevoice3+0
		lda #$0a
		sta sidvoice3+attkd
		lda #$00
		sta sidvoice3+susvr
		lda #$00
		sta sidvoice3+freqlo
		lda #$05
		sta sidvoice3+freqhi
		lda #cnoise+cvoiceoff
		sta sidvoice3+ctrl
		lda #cnoise+cvoiceon
		sta sidvoice3+ctrl
		lda #$04
		sta sidfilter+fctrl

:		rts

; ------------------------------------------- update call

sfx_update
		lda sfx_zp0								; if sfx_zp0 >= $00 && sfx_zp0 <= $80 then skip jsr to 'something'
		bpl sfx_skipjsrptr
		ldy sfx_tablevoice1+0
		lda sfx_jsrtab+0,y
		sta jsrptr+1
		lda sfx_jsrtab+1,y
		sta jsrptr+2
jsrptr	jmp $0000

sfx_skipjsrptr
		lda sfx_tablevoice2+0					; check sfx_tablevoice2 for 0
		beq sfx_tablevoice2is0
		dec sfx_tablevoice2+0						; sfx_tablevoice2 is not 0 - decrease sfx_tablevoice2, decrease frequency by #$0600 and set to voice2
		lda sfx_tablevoice2+1
		sta sidvoice2+freqlo
		sec
		sbc #$00
		sta sfx_tablevoice2+1
		lda sfx_tablevoice2+2
		sta sidvoice2+freqhi
		sbc #$06
		sta sfx_tablevoice2+2
sfx_tablevoice2is0
		lda sfx_tablevoice3+0					; check if sfx_tablevoice3 is 0
		beq sfx_tablevoice3is0
		cmp #$6e								; sfx_tablevoice3 is not 0, check if it's #$6e
		bne sfx_tablevoice3isnot6e
sfx_tablevoice3is6e
		lda #ctriangle+cvoiceoff					; sfx_tablevoice3 is #$6e - turn voice3 off
		sta sidvoice3+ctrl
sfx_tablevoice3isnot6e
		dec sfx_tablevoice3+0						; sfx_tablevoice3 is not #$6e - decrease frequency by #$80 and set to voice3
		lda sfx_tablevoice3+1
		sta sidvoice3+freqlo
		sec
		sbc #$80
		sta sfx_tablevoice3+1
		lda sfx_tablevoice3+2
		sta sidvoice3+freqhi
		sbc #$00
		sta sfx_tablevoice3+2
sfx_tablevoice3is0								; both sfx_tablevoice2 and sfx_tablevoice3 are 0 - don't do anything
		rts

sfx_ptrjsr1
		dec sfx_tablevoice1+2					; decrease sfx_tablevoice1+2
		bne :+

		lda sfx_tablevoice1+1					; sfx_tablevoice1+2 reached 0 - copy values: 1->2, 34->56
		sta sfx_tablevoice1+2
		lda sfx_tablevoice1+3
		sta sfx_tablevoice1+5
		lda sfx_tablevoice1+4
		sta sfx_tablevoice1+6

:		lda sfx_tablevoice1+5					; sfx_tablevoice1+2 has NOT reached 0 - set voice 1 low and high frequency and add tablevoice1+7
		sta sidvoice1+freqlo
		clc
		adc sfx_tablevoice1+7
		sta sfx_tablevoice1+5
		lda sfx_tablevoice1+6
		sta sidvoice1+freqhi
		adc #$00
		sta sfx_tablevoice1+6
		lda sfx_fuelorwoop						; should we play fuel low or woopwoop sound
		cmp #$02
		bcs sfx_playwoop
sfx_playfuellow
		lda sfx_tablevoice1+0					; if sfx_tablevoice1+0 is 4 then play woop sound, otherwise play fuellowsound
		cmp #$04
		beq :+
		jsr sfx_initfuellowsound
:		rts
sfx_playwoop
		lda sfx_tablevoice1+0
		cmp #$04
		bne :+
		jsr sfx_initwoopsound
:		rts

sfx_ptrjsr2	dec sfx_tablevoice1+2					; decrease sfx_tablevoice1+2
		bne :+
		jmp sfx_initwoopsound					; sfx_tablevoice1+2 reached 0 - start woopwoop sound

:		lda sfx_tablevoice1+2					; sfx_tablevoice1+2 has NOT reached 0
		and #$07
		bne :+
		lda #csaw+cvoiceon					; lower 7 bits are 0 - set saw wave and turn voice on
		sta sidvoice1+ctrl
		rts

:		cmp #$03
		bne :+
		lda #csaw+cvoiceoff					; lower 3 bits are 3 - set saw wave and turn voice off
		sta sidvoice1+ctrl
:		rts

sfx_ptrrts	rts

; ------------------------------------------- play get ready

/*
sfx_playgetready
		dec $1b
		bne playgetready_end
		ldy sfx_zp0
		ldx getreadytune+0,y
		lda getreadytune+25,y
		cpy #$19
		bne :+
		lda #$ff
		sta sfx_zp0
		jmp sfx_initwoopsound
:		iny
		sty sfx_zp0
		ldy $1c
		bne :+
		sta $1b
		asl
		asl
		adc $1b
		sta $1b
		lda sfx_freqtable+0,x
		sta sidvoice1+freqlo
		lda sfx_freqtable+4,x
		sta sidvoice1+freqhi
		inx
		lda sfx_freqtable+0,x
		sta sidvoice3+freqlo
		lda sfx_freqtable+4,x
		sta sidvoice3+freqhi
		jmp :++
:		asl
		asl
		sta $1b
		lda sfx_freqtable+8,x
		sta sidvoice1+freqlo
		lda sfx_freqtable+12,x
		sta sidvoice1+freqhi
		inx
		lda sfx_freqtable+8,x
		sta sidvoice3+freqlo
		lda sfx_freqtable+12,x
		sta sidvoice3+freqhi
:		lda #crectangle+cvoiceoff
		sta sidvoice1+ctrl
		sta sidvoice3+ctrl
		lda #crectangle+cvoiceon
		sta sidvoice1+ctrl
		sta sidvoice3+ctrl
playgetready_end
		rts
*/

; -----------------------------------------------------------------------------------------------

sfx_jsrtab
.byte <sfx_ptrjsr1, >sfx_ptrjsr1
.byte <sfx_ptrjsr1, >sfx_ptrjsr1
.byte <sfx_ptrjsr1, >sfx_ptrjsr1
.byte <sfx_ptrjsr2, >sfx_ptrjsr2
.byte <sfx_ptrrts,  >sfx_ptrrts

; -------------------------------------------

sfx_fuelorwoop
.byte $00									; 0 = out of fuel, 2 = woop,woop,woop

; -------------------------------------------

sfx_freqtable
.byte  $db, $d3, $f0, $b6
.byte  $0b, $0f, $13, $17
.byte  $4e, $6d, $b2, $9c
.byte  $0c, $10, $14, $18

/*
getreadytune
.byte  $01, $01, $01, $01, $01, $01, $01, $00, $01, $02, $01, $00, $01		; get ready tune freqlo
.byte  $00, $01, $02, $01, $00, $01, $00, $01, $02, $01, $00, $02
.byte  $06, $01, $01, $06, $01, $01, $02, $02, $02, $02, $02, $02, $02		; get ready tune freqhi
.byte  $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
*/

; -------------------------------------------

sfx_tablevoice1
.byte $00									; pointer into jsr table
											; 0 (ptrjsr1)
											; 2 (ptrjsr1)
											; 4 (ptrjsr1)
											; 6 (ptrjsr2)
											; 8 (ptrrts)
.byte $00, $00								; duration
.byte $00, $00								; voice1 freqlo, freqhi
.byte $00, $00								; voice1 freqlo, freqhi
.byte $00									; voice1 freqlo-increase-add

.byte $00									; not used

; -------------------------------------------

sfx_tablevoice2
.byte $00									; #$0a or #$00
.byte $00									; voice2 freqlo
.byte $00									; voice2 freqhi

; -------------------------------------------

sfx_tablevoice3
.byte $00									; #$78 or #$00
.byte $00									; voice3 freqlo
.byte $00									; voice3 freqhi

; -----------------------------------------------------------------------------------------------

