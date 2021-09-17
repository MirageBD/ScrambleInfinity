.SEGMENT "RECORDEDSESSION"

.if recordplayback

recordedsession

; tiny playthrough that shows multiplexer running out of cycles

.byte  $a8, $6f, $ee, $6e,  $00, $6f, $0a, $6b,  $11, $6a, $19, $6b,  $21, $6f, $30, $6b
.byte  $5e, $6f, $62, $6e,  $79, $6f, $83, $67,  $97, $6f, $9d, $6b,  $ba, $6f, $da, $67
.byte  $00, $67, $6c, $6f,  $73, $6b, $86, $6f,  $91, $6b, $ad, $6f,  $b6, $6b, $e2, $6f
.byte  $ed, $6b, $f2, $6f,  $00, $6f, $09, $67,  $11, $6f, $3c, $6b,  $55, $6f, $61, $6b
.byte  $76, $6f, $85, $6d,  $c1, $6f, $cb, $7f,  $e8, $7e, $00, $7e,  $07, $76, $20, $77
; .byte  $21, $7f


/*
.byte  $01, $77, $72, $76,  $7a, $77, $ac, $7f,  $af, $7b, $b0, $6b,  $db, $6f, $00, $6f
.byte  $11, $6d, $3b, $6f,  $61, $67, $71, $66,  $9a, $67, $c9, $6f,  $dc, $6d, $e3, $69
.byte  $f9, $6b, $fa, $6f,  $00, $6f, $0d, $6d,  $12, $69, $1a, $6d,  $1b, $6f, $2c, $6b
.byte  $2d, $69, $38, $6f,  $49, $6b, $4a, $69,  $53, $6d, $55, $6f,  $5e, $6d, $8e, $6f
.byte  $a2, $6d, $af, $6f,  $b2, $6b, $d2, $6f,  $da, $67, $ee, $6f,  $ef, $6b, $00, $6b
.byte  $03, $6f, $15, $6b,  $1c, $67, $21, $66,  $27, $67, $37, $6f,  $38, $6b, $51, $6f
.byte  $65, $67, $8b, $6f,  $8c, $6b, $9f, $6f,  $ab, $6b, $b7, $6f,  $b8, $67, $c3, $66
.byte  $ce, $67, $dc, $66,  $e1, $67, $ee, $66,  $f4, $67, $00, $67,  $09, $66, $0d, $67
.byte  $17, $66, $1d, $67,  $2c, $66, $31, $67,  $3f, $66, $45, $67,  $4c, $66, $53, $67
.byte  $68, $66, $6b, $67,  $78, $66, $7d, $67,  $92, $66, $96, $67,  $a8, $66, $ac, $67
.byte  $fd, $66, $00, $66,  $08, $76, $21, $77,  $3d, $67, $42, $6b,  $60, $6f, $86, $6d
.byte  $b4, $6f, $c1, $6e,  $cd, $66, $d0, $67,  $da, $6f, $e8, $6e,  $00, $6e, $05, $6f
.byte  $1f, $6b, $2b, $6f,  $2d, $6e, $34, $66,  $3a, $67, $4c, $6f,  $4e, $6b, $61, $6f
.byte  $77, $6d, $80, $69,  $8b, $6b, $8c, $6f,  $98, $6b, $a0, $6f,  $d6, $6d, $db, $6f
.byte  $f5, $6d, $fe, $6f,  $00, $6f, $05, $6b,  $11, $6f, $16, $67,  $36, $6f, $37, $6b
.byte  $5b, $6f, $69, $6d,  $7b, $6f, $8a, $6b,  $90, $69, $93, $6b,  $c8, $6f, $d5, $6d
.byte  $ef, $6f, $fe, $6e,  $00, $6e, $0f, $66,  $13, $67, $3b, $6b,  $50, $6f, $6a, $6d
.byte  $77, $65, $7b, $67,  $94, $6f, $96, $6b,  $a6, $6f, $b7, $6d,  $d8, $6f, $f6, $67
.byte  $f8, $66, $00, $66,  $20, $67, $24, $6f,  $37, $6b, $67, $6a,  $6e, $6e, $6f, $66
.byte  $70, $67, $b5, $6f,  $b6, $6b, $cc, $6f,  $ce, $67, $ea, $6f,  $ed, $6b, $00, $6b
.byte  $04, $6f, $29, $6b,  $3b, $6f, $5b, $6b,  $66, $6a, $68, $6e,  $71, $66, $87, $67
.byte  $a8, $6b, $c0, $6f,  $d7, $6d, $de, $65,  $00, $65, $0f, $67,  $23, $6f, $2c, $65
.byte  $2e, $67, $31, $6f,  $41, $6e, $45, $6f,  $bd, $6b, $00, $6b,  $47, $6f, $4e, $6d
.byte  $52, $6f, $63, $6b,  $7e, $6f, $81, $67,  $99, $66, $9c, $67,  $ee, $6f, $f7, $6d
.byte  $fa, $6f, $00, $6f,  $14, $67, $42, $6f,  $48, $6b, $5f, $6f,  $78, $6b, $93, $6f
.byte  $a1, $67, $d0, $6f,  $de, $6b, $fe, $6f,  $00, $6f, $16, $67,  $31, $6f, $41, $67
.byte  $69, $6f, $b9, $6b,  $dd, $6f, $00, $6f,  $1e, $6b, $3e, $6f,  $63, $67, $97, $6f
.byte  $a3, $6b, $a9, $6f,  $f8, $6b, $00, $6b,  $0a, $6f, $10, $67,  $2d, $6f, $38, $6b
.byte  $58, $6f, $bb, $6b,  $e4, $6f, $ec, $67,  $00, $67, $24, $6f,  $28, $6b, $47, $6f
.byte  $65, $67, $82, $6f,  $d4, $6d, $db, $6f,  $e0, $67, $00, $67,  $2e, $6f, $5f, $6b
.byte  $a1, $6f, $b3, $67,  $d0, $65, $d6, $67,  $e6, $6f, $e7, $6b,  $00, $6b, $13, $6f
.byte  $23, $7f, $2c, $7b,  $39, $7f, $3b, $7e,  $3d, $76, $43, $77,  $5a, $75, $62, $65
.byte  $6c, $67, $70, $6f,  $77, $6b, $8f, $6f,  $9a, $7f, $9f, $7b,  $aa, $7f, $b2, $7b
.byte  $d3, $7a, $d9, $7e,  $df, $76, $e2, $77,  $fe, $75, $00, $75,  $0a, $65, $0c, $67
.byte  $8b, $6f, $a4, $6b,  $c0, $6f, $f1, $6e,  $00, $6e, $01, $67,  $1f, $65, $30, $6f
.byte  $42, $6e, $45, $6f,  $67, $6b, $78, $6f,  $7b, $67, $96, $66,  $a5, $67, $ce, $65
.byte  $d6, $6d, $df, $6f,  $00, $6f, $1f, $6e,  $23, $6f, $47, $6b,  $5e, $6f, $83, $6e
.byte  $93, $67, $b1, $65,  $b7, $6d, $cd, $6f,  $e6, $6e, $ef, $6f,  $00, $6f, $04, $67
.byte  $1c, $6f, $25, $6b,  $41, $6f, $75, $6e,  $83, $66, $84, $67,  $9d, $65, $a3, $6d
.byte  $a7, $6f, $ee, $67,  $ff, $6f, $00, $6f,  $1b, $6e, $2a, $6f,  $32, $67, $3e, $6f
.byte  $4c, $6d, $64, $6f,  $83, $6e, $87, $6f,  $94, $67, $bf, $6f,  $c4, $6b, $f1, $6f
.byte  $f8, $6b, $00, $6b,  $19, $6f, $1b, $6e,  $25, $66, $33, $67,  $45, $6b, $6a, $6f
.byte  $6d, $67, $af, $6f,  $b0, $6b, $ec, $6f,  $00, $6f, $0e, $6e,  $25, $6a, $46, $6e
.byte  $63, $6f, $69, $67,  $94, $66, $ab, $67,  $b9, $6f, $c7, $6b,  $f6, $6f, $fc, $67
.byte  $00, $67, $0e, $6f,  $0f, $6b, $2b, $6f,  $3a, $6b, $53, $6f,  $74, $6d, $97, $6f
.byte  $b1, $6d, $d0, $6f,  $e7, $6d, $ed, $6f,  $00, $6e, $1f, $66,  $24, $6e, $25, $6f
.byte  $3a, $6b, $40, $6a,  $45, $6e, $53, $66,  $5c, $67, $60, $6f,  $71, $67, $79, $6f
.byte  $7e, $6b, $aa, $6f,  $c1, $6e, $c4, $66,  $cd, $67, $f3, $6f,  $f7, $6b, $00, $6b
.byte  $11, $6f, $1b, $67,  $37, $65, $50, $6d,  $56, $6f, $66, $6d,  $7e, $69, $84, $6b
.byte  $a9, $6f, $ad, $67,  $c6, $6f, $c7, $6e,  $d7, $6f, $e9, $6e,  $fa, $6f, $00, $6f
.byte  $02, $67, $08, $66,  $11, $67, $1c, $66,  $24, $6e, $25, $6f,  $3c, $67, $68, $66
.byte  $6b, $67, $89, $6f,  $8c, $6b, $a4, $6f,  $af, $6e, $bb, $6f,  $bd, $67, $ca, $6b
.byte  $00, $6b, $1d, $6f,  $27, $67, $2e, $6f,  $36, $6b, $49, $6f,  $51, $67, $67, $6f
.byte  $6a, $6b, $9b, $67,  $b2, $6f, $c3, $6d,  $d4, $69, $da, $6b,  $e7, $6a, $e8, $6e
.byte  $ee, $6f, $f3, $67,  $fc, $6f, $00, $6f,  $01, $6d, $09, $69,  $14, $6b, $27, $6f
.byte  $28, $6e, $41, $6f,  $59, $67, $67, $6f,  $68, $6b, $75, $6a,  $7b, $66, $80, $6a
.byte  $82, $66, $86, $67,  $a8, $6f, $ad, $6d,  $d8, $6f, $ef, $6d,  $00, $6d, $04, $6f
.byte  $1f, $67, $3d, $66,  $45, $6e, $46, $6f,  $49, $6b, $64, $6a,  $6e, $6e, $72, $6f
.byte  $75, $67, $80, $6f,  $92, $6b, $98, $6a,  $a2, $6e, $aa, $6f,  $ca, $6b, $da, $6a
.byte  $e5, $66, $ec, $67,  $00, $67, $23, $65,  $30, $67, $3f, $6f,  $52, $6b, $6e, $6f
.byte  $7b, $6d, $85, $6f,  $9c, $6d, $c1, $6f,  $c4, $6b, $e4, $6f,  $e8, $67, $00, $67
.byte  $03, $66, $21, $67,  $2b, $66, $38, $6f,  $46, $6e, $50, $6f,  $5a, $67, $86, $6f
.byte  $90, $6b, $ab, $6f,  $ba, $6e, $c0, $6f,  $cb, $6b, $dd, $6f,  $00, $6f, $0b, $6b
.byte  $14, $6f, $1b, $6e,  $22, $6f, $23, $67,  $30, $6f, $5b, $6b,  $85, $6f, $89, $67
.byte  $c6, $6f, $ca, $6b,  $e3, $6f, $00, $6f,  $2d, $6b, $5c, $6f,  $69, $67, $86, $6f
.byte  $88, $6b, $9b, $6f,  $c2, $6d, $e9, $6f,  $f4, $67, $00, $67,  $2e, $6e, $42, $6f
.byte  $43, $67, $65, $6f,  $6d, $6b, $71, $69,  $80, $6f, $81, $67,  $94, $6f, $a0, $67
.byte  $cd, $66, $d0, $6e,  $e2, $6f, $e3, $67,  $00, $67, $3f, $65,  $48, $6d, $58, $69
.byte  $97, $6b, $98, $6f,  $9c, $67, $00, $67,  $12, $65, $1e, $6d,  $1f, $69, $4a, $6b
.byte  $4b, $67, $a3, $66,  $bc, $6e, $d4, $6a,  $00, $6a, $27, $66,  $28, $67, $5d, $65
.byte  $79, $6d, $7b, $69,  $ad, $79, $e0, $75,  $e3, $77, $00, $77,  $27, $76, $33, $7e
.byte  $43, $7a, $50, $6a,  $58, $7a, $9a, $76,  $9c, $77, $c5, $76,  $c6, $7a, $db, $76
.byte  $dd, $77, $00, $77,  $04, $7b, $05, $79,  $12, $7b, $13, $77,  $41, $75, $49, $7d
.byte  $56, $79, $bf, $75,  $c3, $77, $00, $77,  $09, $76, $14, $7e,  $22, $7a, $99, $7e
.byte  $9b, $76, $9c, $77,  $00, $77, $7b, $76,  $80, $77, $aa, $7f,  $cb, $7d, $00, $7d
.byte  $14, $79, $50, $69,  $52, $6b, $55, $7b,  $5c, $7a, $65, $7e,  $00, $00, $00, $00
*/

.endif