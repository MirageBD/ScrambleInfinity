.SEGMENT "RECORDEDSESSION"

.if playback

recordedsession

.byte  $00, $01, $77, $00,  $85, $76, $00, $87,  $77, $00, $b9, $7f,  $00, $ba, $7b, $00
.byte  $be, $6b, $00, $c3,  $7b, $01, $0a, $6b,  $01, $0e, $7b, $01,  $21, $7f, $01, $26
.byte  $7d, $01, $37, $7f,  $01, $51, $7d, $01,  $65, $7f, $01, $66,  $6f, $01, $72, $67
.byte  $01, $9c, $66, $01,  $a6, $6e, $01, $bf,  $66, $01, $c1, $77,  $01, $d5, $67, $01
.byte  $d6, $6b, $01, $eb,  $6f, $01, $f9, $6d,  $02, $1b, $7d, $02,  $23, $7f, $02, $2d
.byte  $7d, $02, $78, $7f,  $02, $7c, $6f, $02,  $97, $6b, $02, $b1,  $6f, $02, $c9, $67
.byte  $02, $e2, $6f, $02,  $e5, $6b, $03, $01,  $6f, $03, $05, $6e,  $03, $07, $66, $03
.byte  $09, $67, $03, $29,  $6f, $03, $2b, $6b,  $03, $3e, $6f, $03,  $44, $67, $03, $5e
.byte  $6f, $03, $79, $6b,  $03, $a1, $6f, $03,  $b0, $6b, $03, $bd,  $6f, $03, $c1, $67
.byte  $03, $d4, $66, $03,  $e3, $67, $03, $e5,  $6f, $03, $fc, $6e,  $04, $04, $6f, $04
.byte  $1e, $67, $04, $29,  $66, $04, $33, $67,  $04, $48, $66, $04,  $4d, $67, $04, $4e
.byte  $6f, $04, $54, $6b,  $04, $63, $6a, $04,  $64, $6e, $04, $6c,  $6f, $04, $71, $67
.byte  $04, $7b, $6f, $04,  $7d, $6e, $04, $84,  $6f, $04, $90, $67,  $04, $93, $66, $04
.byte  $96, $67, $04, $b6,  $66, $04, $bb, $67,  $04, $d4, $66, $04,  $d9, $67, $04, $ea
.byte  $77, $04, $f0, $76,  $05, $12, $77, $05,  $39, $7f, $05, $3b,  $6b, $05, $43, $7b
.byte  $05, $55, $6b, $05,  $5d, $7b, $05, $5f,  $7f, $05, $85, $7d,  $05, $aa, $7f, $05
.byte  $ae, $7d, $05, $b4,  $7f, $05, $be, $6f,  $05, $c8, $6e, $05,  $d2, $6f, $05, $d7
.byte  $67, $05, $e0, $6f,  $05, $f2, $6e, $06,  $1b, $67, $06, $27,  $6f, $06, $4b, $6b
.byte  $06, $5c, $6f, $06,  $7f, $6d, $06, $91,  $6f, $06, $9f, $6b,  $06, $a1, $69, $06
.byte  $a9, $6b, $06, $c5,  $6f, $06, $c9, $67,  $06, $ec, $6f, $06,  $f9, $6b, $07, $1c
.byte  $6f, $07, $1f, $67,  $07, $41, $6f, $07,  $52, $6d, $07, $59,  $69, $07, $5c, $6b
.byte  $07, $64, $6f, $07,  $72, $6d, $07, $7f,  $69, $07, $8d, $6d,  $07, $90, $6f, $07
.byte  $98, $6b, $07, $9d,  $69, $07, $a9, $6b,  $07, $b4, $6f, $07,  $cd, $67, $07, $ce
.byte  $6f, $07, $cf, $6d,  $07, $d0, $6f, $07,  $d4, $6d, $07, $e2,  $6f, $07, $f0, $6e
.byte  $08, $02, $66, $08,  $10, $67, $08, $2f,  $6f, $08, $30, $6b,  $08, $4a, $6f, $08
.byte  $55, $6d, $08, $62,  $65, $08, $66, $67,  $08, $75, $65, $08,  $81, $67, $08, $82
.byte  $6f, $08, $8a, $6b,  $08, $94, $6f, $08,  $ac, $6d, $08, $b8,  $69, $08, $c7, $6b
.byte  $08, $d2, $6f, $08,  $db, $6b, $08, $e0,  $6f, $08, $e9, $6e,  $08, $f6, $6f, $09
.byte  $01, $6e, $09, $24,  $6f, $09, $4d, $6b,  $09, $7b, $6a, $09,  $7d, $6e, $09, $81
.byte  $66

; this is where the clear-bug happens:
.byte $09, $83, $67
; insert code to move the ship up:
.byte $09, $c8, $7f

.endif