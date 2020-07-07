
.ifndef _LOADER_INC_
_LOADER_INC_ = 1

.include "diskio.inc"

; available protocols, file systems, and decompressors

.enum PROTOCOLS     ; the available transfer protocols - in this version, only TWO_BITS_ATN is implemented

   ;ONE_BIT         ; clocking every bit. allows for arbitrary interrupts, yet it's slower than TWO_BITS_ATN
                    ; and TWO_BITS but has no iec bus restrictions - not implemented yet    
   ;TWO_BITS        ; clocking every byte, the 8 bits within a byte are transferred strictly synchronously
                    ; and in groups of 2, no iec bus restrictions
                    ; the fastest protocol that allows for badlines, but does not allow for arbitrary
                    ; interrupts, so sprites are forbidden in the main loop, also sei and cli are used,
                    ; so interrupts are delayed for maximum 2 rasterlines - not implemented yet
   ;TWO_BITS_NOBL   ; same as TWO_BITS but without bad line checks, so bad lines are not allowed outside irq handlers.
                    ; the fastest available protocol. has the same drive-side routine as TWO_BITS. - not implemented yet
    TWO_BITS_ATN    ; the fastest protocol that allows for arbitrary interrupts (sprites, bad lines, etc.)
                    ; but it works with only 1 iec device on the bus.
.endenum

.enum FILESYSTEMS   ; the available file systems - in this version, only DIRECTORY_NAME, and TRACK_SECTOR is implemented

    DIRECTORY_NAME  ; operation on single files that are referenced using the directory, where the filenames
                    ; can be 1 to 16 chars long - no wildcard matching, so * and ? are treated as normal characters;
                    ; each file of the maximum 144 per 1541 disk side is accessible
    DIRECTORY_INDEX ; operation on single files that are identified by their position in the directory,
                    ; non-files (track 0) are counted
    TRACK_SECTOR    ; operation on single files that are referenced using track and sector position,
                    ; the filename does not have to appear in the directory
   ;DIRECTORY_HASH  ; operation on single files that are referenced using the directory, where the "filenames"
                    ; are a 16 bit hash number on the actual file names
   ;IFFL            ; operation on large iffl files (file databases in single files, one for each disk side)
                    ; where the files are referenced by indices into the iffl files. one big file looks cooler
                    ; than lots of small single files and also removes sector allocation overhead - not implemented yet
.endenum

.enum DECOMPRESSORS ; the available decompression routines - in this version, STREAM, EXOSTREAM and OXYPACKER are not implemented yet

    ;POLLING        ; query for ready-to-send blocks in the main program, do own processing until a block has
                    ; arrived, then download it from the drive, an optional optimized NMI-based polling system is provided (see below)
                    ; the POLLING "decompressor" is always available and cannot be explicitly selected

    STREAM          ; stream in data using a cyclic stream buffer, see below for options
    EXOSTREAM       ; Magnus Lind's Exomizer in streaming mode - no fast decompression,
                    ; but nearly optimal compression ratio (rle+lz+huffman), see below for options - not implemented yet -
                    ; compression ratio is dependent on the buffer size used

    EXOMIZER        ; Magnus Lind's Exomizer - no fast decompression, but nearly optimal compression ratio (rle+lz+huffman)
    PUCRUNCH        ; Pasi Ojala's Pucrunch - not so fast decompression but very good compression ratio (rle+lz+huffman)
    BYTEBOOZER      ; HCL/Booze Design's ByteBoozer - pretty fast decompression and good compression ratio (lz, a little better than Levelcrush)
    LEVELCRUSH      ; Taboo Levelcrush - pretty fast decompression and good compression ratio (lz)
    OXYPACKER       ; Graham/Oxyron's OxyPacker - very fast decompression and okay compression ratio (rle) - not implemented yet
    
    NONE            ; no decompressor used

.endenum


.include "cia.inc"  ; for the UPLOAD_DRIVECODE macros

.ifdef EXTCONFIG
    .include "loaderconfig.inc"
.else
    .include "config.inc"
.endif; !EXTCONFIG

.include "option-check.inc"


.if FILESYSTEM = FILESYSTEMS::DIRECTORY_NAME
    FILE_NOT_FOUND = diskio::status::INVALID_PARAMETERS
.elseif FILESYSTEM = FILESYSTEMS::DIRECTORY_INDEX
    INVALID_INDEX = diskio::status::INVALID_PARAMETERS
.elseif FILESYSTEM = FILESYSTEMS::TRACK_SECTOR
    ILLEGAL_TRACK_OR_SECTOR = diskio::status::INVALID_PARAMETERS
.endif


.ifndef __NO_LOADER_SYMBOLS_IMPORT

; Blocking calls

; Import the loader code from a dynamically linked library file
; in:  a/x - lo/hi to 0-terminated library filename string
; out: c   - set on error
;      a   - diskio::status, on diskio::status::GENERIC_KERNAL_ERROR, the KERNAL error code is returned in x
;      x   - if status is diskio::status::OK, lo-byte of version string address,
;            if status is diskio::status::WRONG_VERSION, required major version number
;      y   - if status is diskio::status::OK, hi-byte of version string address,
;            if status is diskio::status::WRONG_VERSION, found (but bad) major version number
.import importldr
.macro IMPORT_LOADER request
        lda #.lobyte(request)
        ldx #.hibyte(request)
        jsr importldr
.endmacro

; Install the loader
; in:  x/y - if LOAD_ONCE, lo/hi to 0-terminated filename string
; out: c   - set on error
;      a   - status
;      x   - drive type (one of diskio::drivetypes)
;      y   - if status is diskio::status::OK, zeropage address of version string address
.import install
.if LOAD_ONCE || INSTALL_FROM_DISK
    .macro LOADER_INSTALL filename_lo, filename_hi
        ldx filename_lo
        ldy filename_hi
        .if DYNLINKLDR
        jsr __LOADERINSTALL_RUN__
        .else
        jsr install
        .endif
    .endmacro
.else
    .macro LOADER_INSTALL
        .if DYNLINKLDR
        jsr __LOADERINSTALL_RUN__
        .else
        jsr install
        .endif
    .endmacro
.endif

.if LOAD_UNCOMPD_API
; Load an uncompressed file
; in:  x/y - if FILESYSTEM = FILESYSTEMS::DIRECTORY_NAME, lo/hi to 0-terminated filename string
;            if FILESYSTEM = FILESYSTEMS::TRACK_SECTOR, a: track, x: sector
;      c   - if LOAD_TO_API != 0, c = 0: load to address as stored in the file
;                                 c = 1: load to caller-specified address
; out: c   - set on error
;      a   - status
.import loaduncompd
.if !LOAD_ONCE
    .macro LOADUNCOMPD addrlo_or_track, addrhi_or_sector
    .if LOAD_TO_API
        clc
    .endif
        ldx addrlo_or_track
        ldy addrhi_or_sector
    .if DYNLINKLDR
        jsr __LOADER_RUN__
    .else
        jsr loaduncompd
    .endif
    .endmacro

    .if LOAD_TO_API
    .macro LOADUNCOMPD_LOADTO addrlo_or_track, addrhi_or_sector, dest_lo, dest_hi
        sec
    .if DYNLINKLDR
        lda dest_lo
        sta .lobyte(__LOADERZP_RUN__ + diskio::LOADADDRLOFFS)
        lda dest_hi
        sta .lobyte(__LOADERZP_RUN__ + diskio::LOADADDRHOFFS)
    .else
        lda dest_lo
        sta loadaddrl
        lda dest_hi
        sta loadaddrh
    .endif
        ldx addrlo_or_track
        ldy addrhi_or_sector
    .if DYNLINKLDR
        jsr __LOADER_RUN__
    .else
        jsr loaduncompd
    .endif
    .endmacro
    .endif;  LOAD_TO_API
.else; LOAD_ONCE
    .macro LOADUNCOMPD
    .if LOAD_TO_API
        clc
    .endif
    .if DYNLINKLDR
        jsr __LOADER_RUN__
    .else
        jsr loaduncompd
    .endif
    .endmacro

    .if LOAD_TO_API
    .macro LOADUNCOMPD_LOADTO dest_lo, dest_hi
        sec
    .if DYNLINKLDR
        lda dest_lo
        sta .lobyte(__LOADERZP_RUN__ + diskio::LOADADDRLOFFS)
        lda dest_hi
        sta .lobyte(__LOADERZP_RUN__ + diskio::LOADADDRHOFFS)
    .else
        lda dest_lo
        sta loadaddrl
        lda dest_hi
        sta loadaddrh
    .endif
    .if DYNLINKLDR
        jsr __LOADER_RUN__
    .else
        jsr loaduncompd
    .endif
    .endmacro
    .endif; LOAD_TO_API
.endif; LOAD_ONCE
.endif; LOAD_UNCOMPD_API

.if LOAD_COMPD_API
; Load a compressed file
; in:  x/y - if FILESYSTEM = FILESYSTEMS::DIRECTORY_NAME, lo/hi to 0-terminated filename string
;            if FILESYSTEM = FILESYSTEMS::TRACK_SECTOR, a: track, x: sector
;      c   - if LOAD_TO_API != 0, c = 0: load to address as stored in the file
;                                 c = 1: load to caller-specified address
; out: c   - set on error
;      a   - status
.import loadcompd
.if !LOAD_ONCE
    .macro LOADCOMPD addrlo_or_track, addrhi_or_sector
        ldx addrlo_or_track
        ldy addrhi_or_sector
    .if DYNLINKLDR
        jsr __LOADER_RUN__+_A_
    .else
        jsr loadcompd
    .endif
    .endmacro
.else; LOAD_ONCE
    .macro LOADCOMPD
    .if DYNLINKLDR
        jsr __LOADER_RUN__+_A_
    .else
        jsr loadcompd
    .endif
    .endmacro
.endif
.endif; LOAD_COMPD_API

.if OPEN_FILE_POLL_BLOCK_API
; Open a file
; in:  x/y - if FILESYSTEM = FILESYSTEMS::DIRECTORY_NAME, lo/hi to 0-terminated filename string
;            if FILESYSTEM = FILESYSTEMS::TRACK_SECTOR, a: track, x: sector
;      c   - if LOAD_TO_API != 0, c = 0: load to address as stored in the file
;                                 c = 1: load to caller-specified address
; out: c - set on error
;      a - status
.import openfile
.if !LOAD_ONCE
    .macro OPENFILE addrlo_or_track, addrhi_or_sector
    .if LOAD_TO_API
        clc
    .endif
        ldx addrlo_or_track
        ldy addrhi_or_sector
    .if DYNLINKLDR
        jsr __LOADER_RUN__+_A_+_B_+_C_+_D_
    .else
        jsr openfile
    .endif
    .endmacro

    .if LOAD_TO_API
    .macro OPENFILE_LOADTO addrlo_or_track, addrhi_or_sector, dest_lo, dest_hi
        sec
    .if DYNLINKLDR
        lda dest_lo
        sta .lobyte(__LOADERZP_RUN__ + diskio::LOADADDRLOFFS)
        lda dest_hi
        sta .lobyte(__LOADERZP_RUN__ + diskio::LOADADDRHOFFS)
    .else
        lda dest_lo
        sta loadaddrl
        lda dest_hi
        sta loadaddrh
    .endif
        ldx addrlo_or_track
        ldy addrhi_or_sector
    .if DYNLINKLDR
        jsr __LOADER_RUN__+_A_+_B_+_C_+_D_
    .else
        jsr openfile
    .endif
    .endmacro
    .endif; LOAD_TO_API
.else; LOAD_ONCE
    .macro OPENFILE
    .if LOAD_TO_API
        clc
    .endif
    .if DYNLINKLDR
        jsr __LOADER_RUN__+_A_+_B_+_C_+_D_
    .else
        jsr openfile
    .endif
    .endmacro

    .if LOAD_TO_API
    .macro OPENFILE_LOADTO dest_lo, dest_hi
        sec
    .if DYNLINKLDR
        lda dest_lo
        sta .lobyte(__LOADERZP_RUN__ + diskio::LOADADDRLOFFS)
        lda dest_hi
        sta .lobyte(__LOADERZP_RUN__ + diskio::LOADADDRHOFFS)
    .else
        lda dest_lo
        sta loadaddrl
        lda dest_hi
        sta loadaddrh
    .endif
    .if DYNLINKLDR
        jsr __LOADER_RUN__+_A_+_B_+_C_+_D_
    .else
        jsr openfile
    .endif
    .endmacro
    .endif; LOAD_TO_API
.endif;  LOAD_ONCE

; Check if a block is ready to download
; in:  nothing
; out: v - set if a block is ready to download, cleared otherwise
.macro BLOCKREADY
        bit CIA2_PRA
.endmacro

; Poll for a block after successfully opening a file
; in:  nothing
; out: c - cleared if no block is ready to download, set otherwise
;      a - status
.import pollblock
.macro POLLBLOCK
    .if DYNLINKLDR
        jsr __LOADER_RUN__+_A_+_B_+_C_+_D_+_E_
    .else
        jsr pollblock
    .endif
.endmacro
.endif; OPEN_FILE_POLL_BLOCK_API

.if MEM_DECOMP_API
; Decompress a compressed file from memory
; in:  x/y - lo/hi of compressed file in memory
;      c   - if MEMDECOMP_TO_API != 0, c = 0: decompress to address as stored in the file
;                                      c = 1: decompress to caller-specified address
; out: undefined
.import memdecomp
.macro MEMDECOMP source_lo, source_hi
    .if MEM_DECOMP_TO_API
        clc
    .endif
        ldx source_lo
        ldy source_hi
    .if DYNLINKLDR
        jsr __LOADER_RUN__+_A_+_B_
    .else
        jsr memdecomp
    .endif
.endmacro

.if MEM_DECOMP_TO_API
    .macro MEMDECOMP_TO source_lo, source_hi, dest_lo, dest_hi
        sec
    .if DYNLINKLDR
        lda dest_lo
        sta .lobyte(__LOADERZP_RUN__ + diskio::DECDESTLOFFS)
        lda dest_hi
        sta .lobyte(__LOADERZP_RUN__ + diskio::DECDESTHOFFS)
    .else
        lda dest_lo
        sta decdestl
        lda dest_hi
        sta decdesth
    .endif
        ldx source_lo
        ldy source_hi
    .if DYNLINKLDR
        jsr __LOADER_RUN__+_A_+_B_
    .else
        jsr memdecomp
    .endif
    .endmacro
.endif

.if CHAINED_COMPD_FILES
; Decompress a compressed file from memory
; in:  c - if MEMDECOMP_TO_API != 0, c = 0: decompress to address as stored in the file
;                                    c = 1: decompress to caller-specified address
; out: undefined
.import cmemdecomp
.macro CMEMDECOMP
    .if MEM_DECOMP_TO_API
        clc
    .endif
    .if DYNLINKLDR
        jsr __LOADER_RUN__+_A_+_B_+_C_
    .else
        jsr cmemdecomp
    .endif
.endmacro

.if MEM_DECOMP_TO_API
    .macro CMEMDECOMP_TO dest_lo, dest_hi
        sec
    .if DYNLINKLDR
        lda dest_lo
        sta .lobyte(__LOADERZP_RUN__ + diskio::DECDESTLOFFS)
        lda dest_hi
        sta .lobyte(__LOADERZP_RUN__ + diskio::DECDESTHOFFS)
    .else
        lda dest_lo
        sta decdestl
        lda dest_hi
        sta decdesth
    .endif
    .if DYNLINKLDR
        jsr __LOADER_RUN__+_A_+_B_+_C_
    .else
        jsr cmemdecomp
    .endif
    .endmacro
.endif
.endif; CHAINED_COMPD_FILES
.endif; MEM_DECOMP_API

.if UNINSTALL_API
; Uninstall the loader
; in:  nothing
; out: undefined
.import uninstall
.macro UNINSTALL
    .if DYNLINKLDR
        jsr __LOADER_RUN__+_A_+_B_+_C_+_D_+_E_+_F_
    .else
        jsr uninstall
    .endif
.endmacro
.endif; UNINSTALL_API

.if NONBLOCKING_API
; Non-blocking calls

.import installnb

.import loaduncompdnb
.import uninstallnb
.endif; NONBLOCKING_API


; Loader segments symbols

.import __LOADERZP_START__
.import __LOADERZP_END__
.import __LOADERZP_RUN__
.import __LOADERZP_SIZE__

.import __LOADERINSTALL_START__
.import __LOADERINSTALL_END__
.import __LOADERINSTALL_RUN__
.import __LOADERINSTALL_SIZE__

.import __LOADER_START__
.import __LOADER_END__
.import __LOADER_RUN__
.import __LOADER_SIZE__

.endif ; !__NO_LOADER_SYMBOLS_IMPORT


.ifndef DYNLINKLDR
    DYNLINKLDR = 0
.endif

.if DYNLINKLDR
    .macro PREPARE_IMPORT request
        lda #.lobyte(__LOADERINSTALL_RUN__)
        sta request + diskio::IMPORT::INSTALL_BASE + 0
        lda #.hibyte(__LOADERINSTALL_RUN__)
        sta request + diskio::IMPORT::INSTALL_BASE + 1
        lda #.lobyte(__LOADERINSTALL_SIZE__)
        sta request + diskio::IMPORT::INSTALL_SIZE + 0
        lda #.hibyte(__LOADERINSTALL_SIZE__)
        sta request + diskio::IMPORT::INSTALL_SIZE + 1

        lda #.lobyte(__LOADER_RUN__)
        sta request + diskio::IMPORT::RESIDENT_BASE + 0
        lda #.hibyte(__LOADER_RUN__)
        sta request + diskio::IMPORT::RESIDENT_BASE + 1
        lda #.lobyte(__LOADER_SIZE__)
        sta request + diskio::IMPORT::RESIDENT_SIZE + 0
        lda #.hibyte(__LOADER_SIZE__)
        sta request + diskio::IMPORT::RESIDENT_SIZE + 1
    .endmacro
.endif

.ifndef __NOIMPORTVARS
    .importzp loadstatus

    .importzp loadaddrl
    .importzp loadaddrh

    .importzp decdestl
    .importzp decdesth

    .importzp endaddrl
    .importzp endaddrh

    .importzp bytesloadedl
    .importzp bytesloadedh

    .importzp param4
    .importzp param5
.endif  ; !__NOIMPORTVARS

.if UNINSTALL_RUNS_DINSTALL

    .include "cia.inc"

    .ifndef __NO_LOADER_SYMBOLS_IMPORT
        .import drivecode41
        .import drvcodebeg41
        .import drvcodeend41

        .import drivecode71
        .scope cbm1571
            .import drvcodebeg
            .import drivebusy
        .endscope

        .scope cbm1581
            .import drivecode
            .import drvcodebeg
            .import drivebusy
        .endscope
    .endif  ; !__NO_LOADER_SYMBOLS_IMPORT

    .macro __UPLOAD drivecode_address, driveprgend, driveprg

            .local uploadloop

            .if DYNLINKLDR
                jsr __LOADER_RUN__+_A_+_B_+_C_+_D_+_E_+_F_
            .else
                jsr uninstall
            .endif

            lda #CIA_SERIAL_DATA_IN_INPUT | CIA_SERIAL_CLK_IN_INPUT | CIA_SERIAL_DATA_OUT_INPUT | CIA_SERIAL_CLK_OUT_OUTPUT | CIA_SERIAL_ATN_OUT_OUTPUT | CIA_RS232_OUTPUT | CIA_VIC2_BANK_OUTPUT
            sta CIA2_DDRA

            lda #.hibyte(drivecode_address)
            sta uploadloop+$02
            ldx #.lobyte(drivecode_address)
uploadloop: lda a:$0000,x
            ldy #$08
            lsr
            nop
            nop
            pha
            lda CIA2_DDRA
            and #~CIA_SERIAL_DATA_OUT_OUTPUT
            bcs :+
            ora #CIA_SERIAL_DATA_OUT_OUTPUT
:           eor #CIA_SERIAL_CLK_OUT_OUTPUT
            sta CIA2_DDRA
            pla
            dey
            bne uploadloop+$05
            inx
            bne :+
            inc uploadloop+$02
:           cpx #.lobyte(drivecode_address + driveprgend - driveprg)
            bne uploadloop
            ldy uploadloop+$02
            cpy #.hibyte(drivecode_address + driveprgend - driveprg)
            bne uploadloop
    .endmacro

    .macro UPLOAD_DRIVECODE_1541 drivecode_address
            __UPLOAD drivecode_address, drvcodeend41, drvcodebeg41
    .endmacro; UPLOAD_DRIVECODE

    .macro UPLOAD_DRIVECODE_1571 drivecode_address
            __UPLOAD drivecode_address, cbm1571::drivebusy, cbm1571::drvcodebeg
    .endmacro; UPLOAD_DRIVECODE

    .macro UPLOAD_DRIVECODE_1581 drivecode_address
            ;__UPLOAD drivecode_address, cbm1581::drivebusy, cbm1581::drvcodebeg
    .endmacro; UPLOAD_DRIVECODE
.endif; UNINSTALL_RUNS_DINSTALL

.endif; _LOADER_INC_
