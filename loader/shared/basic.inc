
.ifndef _BASIC_INC_
_BASIC_INC_ = 1

BASIC_ROM         = $a000
BASIC_ROM_SIZE    = $2000

LINNUM            = $14

TOKEN_SYS         = $9e

PETSCII_WHITE     = $05
PETSCII_RETURN    = $0d
PETSCII_LIGHTBLUE = $9a
PETSCII_YELLOW    = $9e

STROUT            = $ab1e; Output String
PIVAL             = $aea8; Constant PI in floating point
N32768            = $b1a5; Constant -32768 in floating point
GIVAYF            = $b391; Convert Integer in (AC/YR) to FAC
STRLIT            = $b487; Set Up String
GETADR            = $b7f7; Convert FAC to Integer in LINNUM
FSUB              = $b850; Perform Subtraction
FADD              = $b867; Perform Addition
FONE              = $b9bc; Floating point constant: 1
FMULT             = $ba28; Perform Multiply of float in (AC/YR) with FAC
TENC              = $baf9; Constant 10 in floating point
DIV10             = $bafe; Divide FAC#1 by 10
FDIVT             = $bb0f; Divide float in (AC/YR) by FAC
MOVFM             = $bba2; Move floating point number from memory to FAC#1
MOV2M             = $bbd4; Store FAC#1 in memory at (XR/YR)
MOVAF             = $bc0c; Copy FAC#1 into FAC#2
FOUT              = $bddd; Convert FAC#1 to ASCII String

.macro LOAD_ADDRESS
                .word *+$02
.endmacro; LOAD_ADDRESS

.macro BASIC_STARTLINE linenumber
                .assert * = $0801, warning, "***** PC is not $0801 *****"
                .word $080d, linenumber
                .byte TOKEN_SYS, "2061", $00, $00, $00
.endmacro; BASIC_STARTLINE

.endif; !_BASIC_INC_
