
.ifndef _KERNAL_INC_
_KERNAL_INC_ = 1

.define KERNAL_ROM      $e000
.define KERNAL_ROM_SIZE $2000

.define DEVICE_SCREEN   $03

.define FACEXP $61; FAC exponent
.define FACHO  $62; FAC mantissa
.define STRDSC $64; temporary string descriptor
 STRDSC_LEN   = 0
 STRDSC_PTR   = 1
.define FACSGN $66; FAC sign
.define ARG    $69
.define STATUS $90
.define DFLTO  $9a; default output device
.define FA     $ba; current io device
.define PNT    $d1
.define PNTR   $d3
.define LDTB1  $d9

.define COLOR  $0286

.define CINV   $0314
.define CBINV  $0316
.define NMINV  $0318;
.define IBASIN $0324; CHRIN vector
.define IBSOUT $0326; CHROUT vector


.define POLYX  $e059
.define CLRSCR $e544
.define ROWSLO $ecf0

.define LISTEN $ffb1
.define LSTNSA $ff93
 .define SA_TALK               $20
 .define SA_UNTALK             $3f
 .define SA_LISTEN             $40
 .define SA_UNLISTEN           $5f
 .define SA_OPENCHANNEL        $60
 .define SA_CLOSE              $e0
 .define SA_OPEN               $f0
.define TKSA   $ff96
.define IECIN  $ffa5
.define IECOUT $ffa8
.define UNTLK  $ffab
.define UNLSTN $ffae
.define TALK   $ffb4
.define READST $ffb7
.define SETLFS $ffba
 .define COMMAND_ERROR_CHANNEL $0f
.define SETNAM $ffbd
.define OPEN   $ffc0
.define CLOSE  $ffc3
.define CHKIN  $ffc6
.define CHKOUT $ffc9
.define CLRCHN $ffcc
.define CHRIN  $ffcf
.define CHROUT $ffd2

.endif; !_KERNAL_INC_
