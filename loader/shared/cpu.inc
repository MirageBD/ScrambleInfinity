; MOS6510

.ifndef _CPU_INC_
_CPU_INC_ = 1

CLOCK_PAL                       = 985248 ; Hz
.define CYCLES_PER_SECOND_PAL   .byte $a0,$08,$0f,$00; 985248

CLOCK_NTSC                      = 1022727; Hz
.define CYCLES_PER_SECOND_NTSC  .byte $07,$9b,$0f,$00; 1022727


.define OPC_BRK                   $00
.define OPC_ORA_ZPXI              $01
.define OPC_JAM                   $02; unofficial
.define OPC_SLO_ZPXI              $03; unofficial
;.define OPC_NOP                  $04; unofficial
.define OPC_ORA_ZP                $05
.define OPC_ASL_ZP                $06
.define OPC_SLO_ZP                $07; unofficial
.define OPC_PHP                   $08
.define OPC_ORA_IMM               $09
.define OPC_ASL                   $0a
.define OPC_ANC_IMM               $0b; unofficial
.define OPC_NOP_ABS               $0c
.define OPC_ORA_ABS               $0d
.define OPC_ASL_ABS               $0e
.define OPC_SLO_ABS               $0f; unofficial
.define OPC_BPL                   $10
.define OPC_ORA_ZPIY              $11
;.define OPC_JAM                  $12; unofficial
.define OPC_SLO_ZPIY              $13; unofficial
.define OPC_NOP_ZPX               $14; unofficial
.define OPC_ORA_ZPX               $15
.define OPC_ASL_ZPX               $16
.define OPC_SLO_ZPX               $17; unofficial
.define OPC_CLC                   $18
.define OPC_ORA_ABSY              $19
;.define OPC_NOP                  $1a; unofficial
.define OPC_SLO_ABSY              $1b; unofficial
.define OPC_NOP_ABSX              $1c; unofficial
.define OPC_ORA_ABSX              $1d
.define OPC_ASL_ABSX              $1e
.define OPC_SLO_ABSX              $1f; unofficial
.define OPC_JSR_ABS               $20
.define OPC_AND_ZPXI              $21
;.define OPC_JAM                  $22; unofficial
.define OPC_RLA_ZPXI              $23; unofficial
.define OPC_BIT_ZP                $24
.define OPC_AND_ZP                $25
.define OPC_ROL_ZP                $26
.define OPC_RLA_ZP                $27; unofficial
.define OPC_PLP                   $28
.define OPC_AND_IMM               $29
.define OPC_ROL                   $2a
;.define OPC_ANC_IMM              $2b; unofficial
.define OPC_BIT_ABS               $2c
.define OPC_AND_ABS               $2d
.define OPC_ROL_ABS               $2e
.define OPC_RLA_ABS               $2f; unofficial
.define OPC_BMI                   $30
.define AND_ZPIY                  $31
;.define OPC_JAM                  $32; unofficial
.define OPC_RLA_ZPIY              $33; unofficial
;.define OPC_NOP_ZPX              $34
.define OPC_AND_ZPX               $35
.define OPC_ROL_ZPX               $36
.define OPC_RLA_ZPX               $37; unofficial
.define OPC_SEC                   $38
.define OPC_AND_ABSY              $39
;.define OPC_NOP                  $3a; unofficial
.define OPC_RLA_ABSY              $3b; unofficial
;.define OPC_NOP_ABSX             $3c
.define OPC_AND_ABSX              $3d
.define OPC_ROL_ABSX              $3e
.define OPC_RLA_ABSX              $3f; unofficial
.define OPC_RTI                   $40
.define OPC_EOR_ZPXI              $41
;.define OPC_JAM                  $42; unofficial
.define OPC_SRE_ZPXI              $43; unofficial
.define OPC_NOP_ZP                $44
.define OPC_EOR_ZP                $45
.define OPC_LSR_ZP                $46
.define OPC_SRE_ZP                $47; unofficial
.define OPC_PHA                   $48
.define OPC_EOR_IMM               $49
.define OPC_LSR                   $4a
.define OPC_ASL_IMM               $4b
.define OPC_JMP_ABS               $4c
.define OPC_EOR_ABS               $4d
.define OPC_LSR_ABS               $4e
.define OPC_SRE_ABS               $4f; unofficial
.define OPC_BVS                   $50
.define OPC_EOR_ZPIY              $51
;.define OPC_JAM                  $52; unofficial
.define OPC_SRE_ZPIY              $53; unofficial
;.define OPC_NOP_ZPX              $54; unofficial
.define OPC_EOR_ZPX               $55
.define OPC_LSR_ZPX               $56
.define OPC_SRE_ZPX               $57; unofficial
.define OPC_CLI                   $58
.define OPC_EOR_ABSY              $59
;.define OPC_NOP                  $5a
.define OPC_SRE_ABSY              $5b; unofficial
;.define OPC_NOP_ABSX             $5c
.define OPC_EOR_ABSX              $5d
.define OPC_LSR_ABSX              $5e
.define OPC_SRE_ABSX              $5f; unofficial
.define OPC_RTS                   $60
.define OPC_ADC_ZPIX              $61
;.define OPC_JAM                  $62; unofficial
.define OPC_RRA_ZPIX              $63; unofficial
;.define OPC_NOP_ZP               $64; unofficial
.define OPC_ADC_ZP                $65
.define OPC_ROR_ZP                $66
.define OPC_RRA_ZP                $67; unofficial
.define OPC_PLA                   $68
.define OPC_ADC_IMM               $69
.define OPC_ROR                   $6a
.define OPC_ARR_IMM               $6b; unofficial
.define OPC_JMP_ABSI              $6c
.define OPC_ADC_ABS               $6d
.define OPC_ROR_ABS               $6e
.define OPC_RRA_ABS               $6f; unofficial
.define OPC_BVS_REL               $70
.define OPC_ADC_ZPIY              $71
;.define OPC_JAM                  $72; unofficial
.define OPC_RRA_ZPIY              $73; unofficial
;.define OPC_NOP_ZPX              $74; unofficial
.define OPC_ADC_ZPX               $75
.define OPC_ROR_ZPX               $76
.define OPC_RRA_ZPX               $77; unofficial
.define OPC_SEI                   $78
.define OPC_ADC_ABSY              $79
;.define OPC_NOP                  $7a; unofficial
.define OPC_RRA_ABSY              $7b; unofficial
;.define OPC_NOP_ABSX             $7c; unofficial
.define OPC_ADC_ABSX              $7d
.define OPC_ROR_ABSX              $7e
.define OPC_RRA_ABSX              $7f; unofficial
.define OPC_NOP_IMM               $80; unofficial
.define OPC_STA_ZPXI              $81
;.define OPC_NOP_IMM              $82
.define OPC_SAX_ZPXI              $83; unofficial
.define OPC_STY_ZP                $84
.define OPC_STA_ZP                $85
.define OPC_STX_ZP                $86
.define OPC_SAX_ZP                $87; unofficial
.define OPC_DEY                   $88
;.define OPC_NOP_IMM              $89; unofficial
.define OPC_TXA                   $8a
.define OPC_XAA_IMM               $8b; unofficial
.define OPC_STY_ABS               $8c
.define OPC_STA_ABS               $8d
.define OPC_STX_ABS               $8e
.define OPC_SAX_ABS               $8f; unofficial
.define OPC_BCC                   $90
.define OPC_STA_ZPIY              $91
;.define OPC_JAM                  $92; unofficial
.define OPC_AHX_ZPIY              $93; unofficial
.define OPC_STY_ZPX               $94
.define OPC_STA_ZPX               $95
.define OPC_STY_ZPY               $96
.define OPC_SAX_ZPY               $97; unofficial
.define OPC_TYA                   $98
.define OPC_STA_ABSY              $99
.define OPC_TXS                   $9a
.define OPC_TAS_ABSY              $9b; unofficial
.define OPC_SHF_ABSX              $9c; unofficial
.define OPC_STA_ABSX              $9d
.define OPC_SHX_ABSY              $9e; unofficial
.define OPC_AHX_ABSY              $9f; unofficial
.define OPC_LDY_IMM               $a0
.define OPC_LDA_ZPXI              $a1
.define OPC_LDX_IMM               $a2
.define OPC_LAX_ZPXI              $a3; unofficial
.define OPC_LDY_ZP                $a4
.define OPC_LDA_ZP                $a5
.define OPC_LDX_ZP                $a6
.define OPC_LAX_ZP                $a7
.define OPC_TAY                   $a8
.define OPC_LDA_IMM               $a9
.define OPC_TAX                   $aa
.define OPC_LAX_IMM               $ab; unofficial
.define OPC_LDY_ABS               $ac
.define OPC_LDA_ABS               $ad
.define OPC_LDX_ABS               $ae
.define OPC_LAX_ABS               $af; unofficial
.define OPC_BCS                   $b0
.define OPC_LDA_ZPIY              $b1
;.define OPC_JAM                  $b2; unofficial
;.define OPC_LAX_ZPI              $b3; unofficial
.define OPC_LDY_ZPX               $b4
.define OPC_LDA_ZPX               $b5
.define OPC_LDX_ZPY               $b6
.define OPC_LAX_ZPY               $b7; unofficial
.define OPC_CLV                   $b8
.define OPC_LDA_ABSY              $b9
.define OPC_TSX                   $ba
.define OPC_LAS_ABSY              $bb
.define OPC_LDY_ABSX              $bc
.define OPC_LDA_ABSX              $bd
.define OPC_LDX_ABSY              $be
.define OPC_LAX_ABSY              $bf; unofficial
.define OPC_CPY_IMM               $c0
.define OPC_CMP_ZPXI              $c1
;.define OPC_NOP_IMM              $c2; unofficial
.define OPC_DCP_ZPXI              $c3; unofficial
.define OPC_CPY_ZP                $c4
.define OPC_CMP_ZP                $c5
.define OPC_DEC_ZP                $c6
.define OPC_DCP_ZP                $c7; unofficial
.define OPC_INY                   $c8
.define OPC_CMP_IMM               $c9
.define OPC_DEX                   $ca
.define OPC_SBX_IMM               $cb; unofficial
.define OPC_CPY_ABS               $cc
.define OPC_CMP_ABS               $cd
.define OPC_DEC_ABS               $ce
.define OPC_DCP_ABS               $cf; unofficial
.define OPC_BNE                   $d0
.define OPC_CMP_ZPIY              $d1
;.define OPC_JAM                  $d2; unofficial
.define OPC_DCP_ZPIY              $d3; unofficial
;.define OPC_NOP_ZPX              $d4; unofficial
.define OPC_CMP_ZPX               $d5
.define OPC_DEC_ZPX               $d6
.define OPC_DCP_ZPX               $d7; unofficial
.define OPC_CLD                   $d8
.define OPC_CMP_ABSY              $d9
;.define OPC_NOP                  $da; unofficial
.define OPC_DCP_ABSY              $db; unofficial
;.define OPC_NOP_ABSX             $dc; unofficial
.define OPC_CMP_ABSX              $dd
.define OPC_DEC_ABSX              $de
.define OPC_DCP_ABSX              $df; unofficial
.define OPC_CPX_IMM               $e0
.define OPC_SBC_ZPXI              $e1
;.define OPC_NOP_IMM              $e2; unofficial
.define OPC_ISC_ZPXI              $e3; unofficial
.define OPC_CPX_ZP                $e4
.define OPC_SBC_ZP                $e5
.define OPC_INC_ZP                $e6
.define OPC_ISC_ZP                $e7; unofficial
.define OPC_INX                   $e8
.define OPC_SBC_IMM               $e9
.define OPC_NOP                   $ea
;.define OPC_SBC_IMM              $eb
.define OPC_CPX_ABS               $ec
.define OPC_SBC_ABS               $ed
.define OPC_INC_ABS               $ee
.define OPC_ISC_ABS               $ef; unofficial
.define OPC_BEQ                   $f0
.define OPC_SBC_ZPIY              $f1
;.define OPC_JAM                  $f2; unofficial
.define OPC_ISC_ZPIY              $f3; unofficial
;.define OPC_NOP_ZPX              $f4; unofficial
.define OPC_SBC_ZPX               $f5
.define OPC_INC_ZPX               $f6
.define OPC_ISC_ZPX               $f7; unofficial
.define OPC_SED                   $f8
.define OPC_SBC_ABSY              $f9
;.define OPC_NOP                  $fa; unofficial
.define OPC_ISC_ABSY              $fb; unofficial
;.define OPC_NOP_ABSX             $fc; unofficial
.define OPC_SBC_ABSX              $fd
.define OPC_INC_ABSX              $fe
.define OPC_ISC_ABSX              $ff; unofficial

.define NEGATIVE                  $80; N flag
.define OVERFLOW	              $40; V flag
.define BREAK		              $10; B flag
.define DECIMAL		              $08; D flag
.define INTERRUPT  	              $04; I flag
.define ZERO	   	              $02; Z flag
.define CARRY	   	              $01; C flag

.define FLAG_N		              $80; N flag
.define FLAG_V		              $40; V flag
.define FLAG_B  	              $10; B flag
.define FLAG_D  	              $08; D flag
.define FLAG_I  	              $04; I flag
.define FLAG_Z 	                  $02; Z flag
.define FLAG_C                    $01; C flag

.define IO_PORT                   $01
 LORAM                          = %00000001
 HIRAM                          = %00000010
 CHAREN                         = %00000100
 CASSETTE_WRITE                 = %00001000
 CASSETTE_SENSE                 = %00010000
 CASSETTE_MOTOR                 = %00100000

 MEMCONFIG_IO_KERNAL_BASIC      = CASSETTE_SENSE | CASSETTE_MOTOR | CHAREN | HIRAM | LORAM; $37
 MEMCONFIG_IO_KERNAL            = CASSETTE_SENSE | CASSETTE_MOTOR | CHAREN | HIRAM |   0  ; $36
 MEMCONFIG_IO                   = CASSETTE_SENSE | CASSETTE_MOTOR | CHAREN |   0   | LORAM; $35
;MEMCONFIG_ALL_RAM              = CASSETTE_SENSE | CASSETTE_MOTOR | CHAREN |   0   |   0  ; $34
 MEMCONFIG_CHARGEN_KERNAL_BASIC = CASSETTE_SENSE | CASSETTE_MOTOR |    0   | HIRAM | LORAM; $33
 MEMCONFIG_CHARGEN_KERNAL       = CASSETTE_SENSE | CASSETTE_MOTOR |    0   | HIRAM |   0  ; $32
 MEMCONFIG_CHARGEN              = CASSETTE_SENSE | CASSETTE_MOTOR |    0   |   0   | LORAM; $31
 MEMCONFIG_ALL_RAM              = CASSETTE_SENSE | CASSETTE_MOTOR |    0   |   0   |   0  ; $30

.define STACK                     $0100

.define NMI_VECTOR                $fffa
.define NMI_VECTORLO              $fffa
.define NMI_VECTORHI              $fffb

.define RESET_VECTOR              $fffc
.define RESET_VECTORLO            $fffc
.define RESET_VECTORHI            $fffd

.define IRQ_VECTOR                $fffe
.define IRQ_VECTORLO              $fffe
.define IRQ_VECTORHI              $ffff

.macro SKIPBYTE
    .byte OPC_BIT_ZP
.endmacro

.macro SKIPWORD
    .byte OPC_BIT_ABS
.endmacro

.endif; !_CPU_INC_
