; ByteBoozer Decruncher    /HCL May.2003
; B2..                      October 2014
; Short decruncher for execs    Dec 2014

; -----------------------------------------------------------------------------------------------

.feature pc_assignment
.feature labels_without_colons
.feature c_comments

; -----------------------------------------------------------------------------------------------

.segment "ZEROPAGE" : zeropage

transferfrom
		lda $4000-$100,x ; PackEnd-$100,x					; .C:0010  BD ED 24    LDA $24ED,X
transferto
		sta $ff00,x											; .C:0013  9D 00 FF    STA $FF00,X
		inx													; .C:0016  E8          INX
		bne transferfrom									; .C:0017  D0 F7       BNE $0010
		dec z:transferfrom+2								; .C:0019  C6 12       DEC $12
		dec z:transferto+2									; .C:001b  C6 15       DEC $15
		lda z:transferfrom+2								; .C:001d  A5 12       LDA $12
		cmp #7												; .C:001f  C9 07       CMP #$07
		bcs transferfrom									; .C:0021  B0 ED       BCS $0010

decrunch
dloop
		jsr getnextbit										; .C:0023  20 A0 00    JSR $00A0
		bcs match											; .C:0026  B0 17       BCS $003F

		; Literal run.. get length.
		jsr getlen											; .C:0028  20 8E 00    JSR $008E
		sta z:llen+1										; .C:002b  85 36       STA $36

		ldy #0												; .C:002d  A0 00       LDY #$00
:		jsr getnextbyte										; .C:002f  20 AD 00    JSR $00AD
		sta (msta+1),y										; .C:0032  91 77       STA ($77),Y
		iny													; .C:0034  C8          INY
llen	cpy #0												; .C:0035  C0 00       CPY #$00
		bne :-												; .C:0037  D0 F6       BNE $002F

		jsr addput											; .C:0039  20 83 00    JSR $0083

		iny													; .C:003c  C8          INY
		beq dloop											; .C:003d  F0 E4       BEQ $0023

		; has to continue with a match..

match	; match.. get length.
		jsr getlen											; .C:003f  20 8E 00    JSR $008E

		; length 255 -> EOF
		tax													; .C:0042  AA          TAX
		inx													; .C:0043  E8          INX
		beq end												; .C:0044  F0 71       BEQ $00B7
		stx z:mlen+1										; .C:0046  86 7B       STX $7B

		; Get num bits
		lda #0												; .C:0048  A9 00       LDA #$00
		cpx #3												; .C:004a  E0 03       CPX #$03
		rol													; .C:004c  2A          ROL A
		jsr rolnextbit										; .C:004d  20 9B 00    JSR $009B
		jsr rolnextbit										; .C:0050  20 9B 00    JSR $009B
		tax													; .C:0053  AA          TAX
		lda z:tab,x											; .C:0054  B5 BF       LDA $BF,X
		beq m8												; .C:0056  F0 07       BEQ $005F

		; Get bits < 8
:		jsr rolnextbit										; .C:0058  20 9B 00    JSR $009B
		bcs :-												; .C:005b  B0 FB       BCS $0058
		bmi mshort											; .C:005d  30 07       BMI $0066
m8
		; Get byte
		eor #$ff											; .C:005f  49 FF       EOR #$FF
		tay													; .C:0061  A8          TAY
		jsr getnextbyte										; .C:0062  20 AD 00    JSR $00AD

		.byte $ae ; = jmp mdone								; .C:0065  AE A0 FF    LDX $FFA0
mshort
		ldy #$ff											;
mdone

		; clc
		adc z:msta+1										; .C:0068  65 77       ADC $77
		sta z:mlda+1										; .C:006a  85 74       STA $74
		tya													; .C:006c  98          TYA
		adc z:msta+2										; .C:006d  65 78       ADC $78
		sta z:mlda+2										; .C:006f  85 75       STA $75

		ldy #0												; .C:0071  A0 00       LDY #$00
mlda	lda $b00b,y											; .C:0073  B9 AD DE    LDA $DEAD,Y
depackto
msta	sta $babe,y											; .C:0076  99 00 40    STA $4000,Y
		iny													; .C:0079  C8          INY
mlen	cpy #0												; .C:007a  C0 00       CPY #$00
		bne mlda											; .C:007c  D0 F5       BNE $0073

		jsr addput											; .C:007e  20 83 00    JSR $0083

		bne dloop											; .C:0081  D0 A0       BNE $0023

addput
		clc													; .C:0083  18          CLC
		tya													; .C:0084  98          TYA
		adc msta+1											; .C:0085  65 77       ADC $77
		sta msta+1											; .C:0087  85 77       STA $77
		bcc :+												; .C:0089  90 02       BCC $008D
		inc msta+2											; .C:008b  E6 78       INC $78
:		rts													; .C:008d  60          RTS

getlen
		lda #1												; .C:008e  A9 01       LDA #$01
glloop
		jsr getnextbit										; .C:0090  20 A0 00    JSR $00A0
		bcc glend											; .C:0093  90 05       BCC $009A
		jsr rolnextbit										; .C:0095  20 9B 00    JSR $009B
		bpl glloop											; .C:0098  10 F6       BPL $0090
glend
		rts													; .C:009a  60          RTS

rolnextbit
		jsr getnextbit										; .C:009b  20 A0 00    JSR $00A0
		rol													; .C:009e  2A          ROL A
		rts													; .C:009f  60          RTS

getnextbit
		asl z:bits											; .C:00a0  06 BE       ASL $BE
		bne dgend											; .C:00a2  D0 08       BNE $00AC
		pha													; .C:00a4  48          PHA
		jsr getnextbyte										; .C:00a5  20 AD 00    JSR $00AD
		rol													; .C:00a8  2A          ROL A
		sta z:bits											; .C:00a9  85 BE       STA $BE
		pla													; .C:00ab  68          PLA
dgend
		rts													; .C:00ac  60          RTS

depackfrom
getnextbyte
		lda $feed											; .C:00ad  AD E9 E2    LDA $E2E9
		inc getnextbyte+1									; .C:00b0  E6 AE       INC $AE
		bne :+												; .C:00b2  D0 02       BNE $00B6
		inc getnextbyte+2									; .C:00b4  E6 AF       INC $AF
:		rts													; .C:00b6  60          RTS

end
		lda #$37											; .C:00b7  A9 37       LDA #$37
		sta $01												; .C:00b9  85 01       STA $01
jumpto
		jmp $c0de											; .C:00bb  4C 00 40    JMP $4000

bits	.byte $80

tab
		; Short offsets

		.byte %11011111 ; 3
		.byte %11111011 ; 6
		.byte %00000000 ; 8
		.byte %10000000 ; 10

		; Long offsets
		.byte %11101111 ; 4
		.byte %11111101 ; 7
		.byte %10000000 ; 10
		.byte %11110000 ; 13
