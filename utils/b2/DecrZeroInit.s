; ByteBoozer Decruncher    /HCL May.2003
; B2..                      October 2014
; Short decruncher for execs    Dec 2014

; -----------------------------------------------------------------------------------------------

.feature pc_assignment
.feature labels_without_colons
.feature c_comments

; -----------------------------------------------------------------------------------------------

.segment "DECRZEROINIT"

	.byte $0b, $08, $00, $00							; start address
	.byte $9e, $32, $30, $36, $31, $00, $00, $00		; sys 2061

	sei

	;lda #$09
	;sta $d020
	;sta $d021

	lda #$34
	sta $01
decruncherlength	
	ldx #$b7
:	lda decruncher-1,x
	sta $10-1,x
	dex
	bne :-
	jmp $0010

decruncher
	; decruncher to be moved to $0010