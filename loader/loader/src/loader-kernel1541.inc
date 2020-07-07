
JOBCODE0300          = $00
JOBCODE0400          = $01
JOBCODE0500          = $02
JOBCODE0600          = $03
JOBCODE0700          = $04
JOBCODE0800          = $05
LINKTRACK            = $06
LINKSECTOR           = $07
GCRBUFFER            = $08; $07 bytes
CURSTPSL             = $08; these two bytes are only clobbered between
TRACKINC             = $09; fetching and decoding blocks
DISKCHANGEBUFFER     = $0f
LOADEDSECTOR         = $10
SENDGCRTABLE         = $11
BLOCKINDEX           = $11
NUMSECTORS           = $12
NUMFILES             = $13
DISKCHANGED          = $14
UNUSED_ZP            = $15
ID0                  = $16; = ROMOS_HEADER_ID0
ID1                  = $17; = ROMOS_HEADER_ID1
FILETRACK            = $18; = ROMOS_HEADER_TRACK
FILESECTOR           = $19; = ROMOS_HEADER_SECTOR
FILEINDEX            = FILETRACK
;GCR_8               = $1a
;GCR_0               = $1b
;GCR_1               = $1c
BLOCKINDEXBASE       = $1d
;GCR_C               = $1e
;GCR_4               = $1f
;GCR_5               = $20
NEXTSECTOR           = $21
SECTORTOFETCH        = $22
;GCR_2               = $23
;GCR_3               = $24
SECTORCOUNT          = $25
;GCR_F               = $26
;GCR_7               = $27
;GCR_8               = $28
CURTRACK             = $29
;GCR_9               = $2a
;GCR_A               = $2b
;GCR_B               = $2c
REQUESTEDSECTOR      = $2d
;GCR_D               = $2e
;GCR_E               = $2f

TRACKLINKTAB         = $30; $15 bytes

LOWMEM               = $45

POINTER              = LOWMEM; $02 bytes

HINIBBLES            = $0600
LONIBBLES            = $0700
TEMPTRACKLINKTAB     = $07c0

GETDRIVECODE         = $07e6

ROMOS_HEADER_ID0     = $16
ROMOS_HEADER_ID1     = $17
ROMOS_HEADER_TRACK   = $18
ROMOS_HEADER_SECTOR  = $19

GCRENCODE            = $f77f
GCRDECODEHI          = $f8a0
GCRDECODELO          = $f8c0


BINARY_NIBBLE_MASK   = %00001111
GCR_NIBBLE_MASK      = %00011111

NUMMAXSECTORS        = 21
MAXTRACK41           = 41


JOBCODE_EXECUTE      = $d0

ANYSECTOR            = $40
UNPROCESSEDSECTOR    = $ff


.if DISABLE_WATCHDOG
    .macro ENABLE_WATCHDOG
        sei
    .endmacro
.else
    .macro ENABLE_WATCHDOG
        cli
    .endmacro
.endif
