
.include "cpu.inc"
.include "via.inc"

.ifdef STANDALONE
    __NO_LOADER_SYMBOLS_IMPORT = 1
    .include "loader.inc"

    .export LOWMEMEND  : absolute
    .export RUNMODULE  : absolute
    .export checkchg   : absolute
    .export ddliteon   : absolute
    .export decodebyte : absolute
    .export dgetbyte   : absolute
    .export drivebusy  : absolute
    .export driveidle  : absolute
    .export dsctcmps   : absolute
    .export gcrencode  : absolute
    .export getblkchid : absolute
    .export getblkstid : absolute
    .export getblock   : absolute
    .export trackseek  : absolute
    .export wait4sct   : absolute
    .export duninstall : absolute
.else; STANDALONE
    .export MAXTRACK41
.endif; !STANDALONE

.include "loader-kernel1541.inc"


.if !UNINSTALL_RUNS_DINSTALL
    ORG = $0037
.else
    ORG = $000c
.endif

.if UNINSTALL_RUNS_DINSTALL
    .ifndef STANDALONE
        .export drvcodebeg41 : absolute
    .endif
    .export drvcodeend41 : absolute

    DINSTALLBUFFER  = KERNEL - drvprgend + dinstall
.endif; UNINSTALL_RUNS_DINSTALL


.macro GETBYTE_IMPL
            lda #%10000000; CLK OUT lo: drive is ready
            sta VIA1_PRB
@0:         ldy #DATA_OUT | DATA_IN
@1:         cpy VIA1_PRB
            bcs @1
            ldy VIA1_PRB
            cpy #CLK_IN | DATA_IN
            ror
@2:         cpy VIA1_PRB
            beq @2
            ldy VIA1_PRB
            cpy #DATA_IN
            ror
            bcc @0
.endmacro


.ifdef STANDALONE

            .org ORG - 1
            .word * + 2
drvcodebeg41:

.else
            .org ORG

drvcodebeg41: .byte .hibyte(drvcodeend41 - * + $0100 - $01); init transfer count hi-byte

.endif; !STANDALONE

dcodinit:   ldy #CLK_OUT
            jsr drivebusy

            lda #T1_IRQ_ON_LOAD | PA_LATCHING_ENABLE; watchdog irq: count phi2 pulses, one-shot;
                                                    ; enable port a latching to grab one gcr byte at a time
                                                    ; rather than letting the gcr bitstream scroll through
                                                    ; port a (applies to 1541-I and Oceanic OC-118, but not
                                                    ; 1541-II)
            sta VIA2_ACR
            lda #READ_MODE | BYTE_SYNC_ENABLE
            sta VIA2_PCR

.if UNINSTALL_RUNS_DINSTALL
            ; header id and track/sector are buffered away to
            ; very low in ram because the install code starts
            ; fairly low as well and overwrites the original
            ; locations - here, the buffer values are copied
            lda JOBCODE0300; from ROMOS_HEADER_ID0
            sta ID0
    .assert * >= ID0, error, "***** 'ID0' written before executed. *****"
            lda JOBCODE0400; from ROMOS_HEADER_ID1
            sta ID1
    .assert * >= ID1, error, "***** 'ID1' written before executed. *****"
            ; the following values are only relevant for LOAD_ONCE != 0
            lda JOBCODE0500; from ROMOS_HEADER_TRACK
            sta FILETRACK
    .assert * >= FILETRACK, error, "***** 'FILETRACK' written before executed. *****"
            lda JOBCODE0600; from ROMOS_HEADER_SECTOR
            sta FILESECTOR
    .assert * >= FILESECTOR, error, "***** 'FILESECTOR' written before executed. *****"
.else
            ; before loading the first file, the current track number is
            ; retrieved by reading any block header on the disk -
            ; however, if the loader is uninstalled before loading anything,
            ; it needs the more or less correct current track number to
            ; seek to track 18
            lda ROMOS_HEADER_TRACK
            sta CURTRACK
.endif

            ; watchdog initialization
.if !UNINSTALL_RUNS_DINSTALL
            lda #IRQ_CLEAR_FLAGS | $7f
            sta VIA1_IER; no irqs from via 1
            sta VIA2_IER; no irqs from via 2
.endif
            lda #IRQ_SET_FLAGS | IRQ_TIMER_1
            sta VIA2_IER; timer 1 irqs from via 2
            lda #$00
            ldx #$04
:           sta JOBCODE0400,x; clear job queue
            dex
            bpl :-
            stx DISKCHANGED
            lda #JOBCODE_EXECUTE
            sta JOBCODE0300; execute watchdog handler at $0300 on watchdog time-out

            ldy #$0f

    .assert * >= SENDGCRTABLE + $1f, error, "***** 'mkgcrdec' overwrites itself. *****"

mkgcrdec:   lda sendgcrraw,y
            ldx GCRENCODE,y
            sta SENDGCRTABLE,x
            dey
            bpl mkgcrdec

            ; before spinning up the motor and finding the current track,
            ; wait until a file is requested to be loaded at all
:           lda VIA1_PRB
            cmp #CLK_OUT | CLK_IN | DATA_IN | ATN_IN
            beq :-; wait until there is something to do

            cmp #CLK_OUT | CLK_IN | DATA_IN
            beq :+
            ldx #$00; don't fade off led because it's not lit
            jmp duninstall; check for reset or uninstallation
:
            lda VIA2_PRB
            ora #MOTOR
            and #~BITRATE_MASK; reset bit-rate
            sta VIA2_PRB
            and #WRITE_PROTECT
            sta DISKCHANGEBUFFER; store light sensor state for disk removal detection

            ldx #NUMMAXSECTORS
            stx NUMSECTORS

            ; find current track number
            ; this assumes the head is on a valid half track
:           clc
            lda #1 << BITRATE_SHIFT
            adc VIA2_PRB
            sta VIA2_PRB; cycle through the 4 bit-rates

            lda #-$01; invalid track number -> no track step
            sta CURTRACK
            ldy #ANYSECTOR
            jsr getblkstid; sector link sanity check is disabled here
            bcs :-

            lda GCRBUFFER+$04
            asl GCRBUFFER+$03
            rol
            asl GCRBUFFER+$03
            rol
            asl GCRBUFFER+$03
            rol
            and #GCR_NIBBLE_MASK
            tay
            lda GCRBUFFER+$03
            jsr decodesub; track
            cmp CURTRACK; getblkstid sets CURTRACK at this stage
            bne :-

            lda #OPC_EOR_ZP
            sta headerchk-$02
            lda #OPC_BNE
            sta headerchk
            lda #OPC_STA_ABS
            sta putbitrate
            lda #OPC_STX_ZP
            sta putnumscts
            jmp beginload


sendgcrraw:
            BIT0DEST = 3
            BIT1DEST = 1
            BIT2DEST = 2
            BIT3DEST = 0

            .repeat $10, I
                .byte (((~I >> 0) & 1) << BIT0DEST) | (((~I >> 1) & 1) << BIT1DEST) | (((~I >> 2) & 1) << BIT2DEST) | (((~I >> 3) & 1) << BIT3DEST)
            .endrep

LOWMEMEND:
KERNEL:

.if UNINSTALL_RUNS_DINSTALL

runcodeget: ldx #getdrcodee - getdrvcode - $01
:           lda .lobyte(getdrvcode),x
            sta GETDRIVECODE,x
            dex
            bpl :-
            jmp GETDRIVECODE

getdrvcode: ldx #.lobyte(stackend-$03)
            txs
            ldx #.lobyte(drvcodebeg41 - $01)
getroutine: inx
            bne :+
getroutputhi = *+$08
            inc getroutputhi - getdrvcode + GETDRIVECODE
:           jsr dgetbyte
            sta a:.hibyte(drvcodebeg41 - $01) << 8,x
            cpx #.lobyte(drvcodeend41 - $01)
            bne getroutine
            dec drvcodebeg41
            bne getroutine
            rts; jumps to dcodinit
getdrcodee:

.endif; UNINSTALL_RUNS_DINSTALL

            ; common code for all configurations
          ; * = $00e8

            ; $0a bytes
checkchg:   lda VIA2_PRB
            and #WRITE_PROTECT
            cmp DISKCHANGEBUFFER
            sta DISKCHANGEBUFFER
            rts

            ; $17 bytes
gcrencode:  pha
            and #BINARY_NIBBLE_MASK
            tax
            lda GCRENCODE,x
            sta LONIBBLES,y
            pla
            lsr
            lsr
            lsr
            lsr
            tax
            lda GCRENCODE,x
            sta HINIBBLES,y
            rts

          ; * >= $0100
stack:
    .assert stack >= $0100, error, "***** 1541 stack too low in memory. *****"

            ; stack frame
.if LOAD_ONCE
            .res 9; padding, best used for bigger stack
.endif
            .word $ff, $ff, $07f3, dcodinit-$01
stackend:

            ; $17 bytes
waitsync:   bit VIA2_T1C_H
            bpl wsynctmout; will return $00 in the accu
            bit VIA2_PRB
            bmi waitsync
            bit VIA2_PRA
            clv
            bvc *
            ldx #$00
            lda VIA2_PRA; is never $00 but usually $52 (header) or $55 (data)
            clv
            rts

            ; $0a bytes
gcrtimeout: jsr checkchg; check light sensor for disk removal
            beq :+
            lda #$ff
            sta DISKCHANGED; set the new disk flag when disks have been changed
:           sec

            ; fall through

wsynctmout: lda #%00000000
            rts

getblock:   sta dsctcmps
            lda CURTRACK
.if LOAD_ONCE
            ; get the block at track a, sector y, check against stored id
getblkchid:
getblkstid: ldx #OPC_CMP_ZP
.else
            ; get the block at track a, sector y, check against stored id
getblkchid: ldx #OPC_CMP_ZP
            SKIPWORD
            ; get the block at track a, sector y, store read id
getblkstid: ldx #OPC_STA_ZP
.endif
            stx storputid1
            dex; OPC_STA_ZP/OPC_CMP_ZP -> OPC_STY_ZP/OPC_CPY_ZP
            stx storputid0
            sty REQUESTEDSECTOR
            jsr trackseek
            ; x contains the number of blocks on the current track here

            lda #OPC_BNE; full gcr fetch and checksumming
wait4sct:   sta scanswt0
            sta scanswt1

            lda #$ff
            sta VIA2_T1C_H; reset the watchdog timer

readblock:  jsr waitsync
            beq gcrtimeout; returns with carry set on time-out
            lsr          ; check if the sync is followed by a sector header
            bcs readblock; if not, wait for next sync mark

            ; read the sector header
            ldx #$06
getheader:  bvc *
            lda VIA2_PRA
            clv
            sta GCRBUFFER+$00,x
            dex
            bpl getheader

            ; check if the sector header's field values match the expectations -
            ; the header is only checksummed after the data fetch since there
            ; is not enough time to do it now

            ; decode sector number
            lda GCRBUFFER+$04
            asl
            tax
            lda GCRBUFFER+$05
            rol
            and #GCR_NIBBLE_MASK
            tay
            txa
            jsr decodesub+$00
            cmp NUMSECTORS; check if sector number is within range of the allowed
                          ; sector numbers for the current track
            bcs readblock
            sta LOADEDSECTOR; store away the sector number, it is returned in the
                            ; x-register on success
            tax             ; current sector number

            lda REQUESTEDSECTOR; bit:bmi:bvs won't work because of
                               ; the BYTESYNC signal on the v-flag
            bmi checkprocd; branch if UNPROCESSEDSECTOR
            asl
            bmi waitdatahd; branch if ANYSECTOR

            cpx REQUESTEDSECTOR
            beq waitdatahd
            bne readblock ; not the desired sector

            ; normal operation and no specific sector requested -
            ; out-of-order sector fetch
checkprocd: lda TRACKLINKTAB,x; check whether the current block has already been
                              ; loaded into the computer's memory
            bmi readblock; if yes, wait for next sector

            sta BLOCKINDEX; store sector index

            ; wait for data block sync
waitdatahd: lda #$ff
            sta VIA2_T1C_H
            jsr waitsync
            lsr          ; check if the sync is followed by a data block
            bcc readblock; if not, wait for next sector

            ; read and partially inflate the gcr digits to 8 bits
           ;ldx #$00
loaddata:   bvc *
            lsr                  ; .0000011
            sta HINIBBLES-$01-0,x
            lda VIA2_PRA         ; 11222223      0 - cycle 13
            ror                  ; 11122222
            sta LONIBBLES-$01-0,x
            and #GCR_NIBBLE_MASK ; ...22222 - 2
            sta HINIBBLES+$00-0,x
            inx
            inx
            lda VIA2_PRA         ; 33334444      1 - cycle 35
            clv                  ;                 - cycle 37
            tay
            ror                  ; 33333444
            lsr                  ; .3333344
            lsr                  ; ..333334
            lsr                  ; ...33333 - 3
            sta LONIBBLES+$00-2,x
               ; 52 cycles

            bvc *
            tya
            ldy VIA2_PRA         ; 45555566      2 - cycle 8
            cpy #$80
            rol                  ; 33344444
            and #GCR_NIBBLE_MASK ; ...44444 - 4
            sta HINIBBLES+$01-2,x
            tya                  ; 45555566
            alr #%01111111       ; ..555556
            sta LONIBBLES+$01-2,x
            inx
            nop
            lda VIA2_PRA         ; 66677777      3 - cycle 36
            tay
            ror                  ; 66667777
            lsr LONIBBLES+$01-3,x; ...55555 - 5
            ror                  ; 66666777
            sta HINIBBLES+$02-3,x
            tya                  ; 66677777
            and #GCR_NIBBLE_MASK ; ...77777 - 7
            sta LONIBBLES+$02-3,x
            lda VIA2_PRA         ; 00000111      4 - cycle 65
            inx
            clv                  ;                 - cycle 69
scanswt0:   bne loaddata
               ; 72 cycles

    .assert .hibyte(* + 1) = .hibyte(loaddata), error, "***** Page boundary crossing in GCR fetch loop, fatal cycle loss. *****"

            lsr                  ; .0000011
            sta HINIBBLES+$ff
            bvc *
            clv
            lda VIA2_PRA         ; 11222223
            ror                  ; 11122222
            sta LONIBBLES+$ff
            and #GCR_NIBBLE_MASK ; ...22222 - 2
            tay
            bvc *
            jsr decodchksm       ; decode data checksum
            tay

            ; finish gcr inflation and checksum the data
            ldx #$00
gcrfinish:  lda HINIBBLES+$02,x  ; 66666777     4
            lsr                  ; .6666677     2
            lsr                  ; ..666667     2
            lsr                  ; ...66666 - 6 2
            sta HINIBBLES+$02,x  ;              5
            lda LONIBBLES+$03,x  ; 11122222     4
            lsr HINIBBLES+$03,x  ; ..000001     7
            ror                  ; 11112222     2
            lsr HINIBBLES+$03,x  ; ...00000 - 0 7
            ror                  ; 11111222     2
            lsr                  ; .1111122     2
            lsr                  ; ..111112     2
            lsr                  ; ...11111 - 1 2
            sta LONIBBLES+$03,x  ;              5 = 48
            tya                  ;              2
            ldy HINIBBLES+$00,x  ;              4
            eor GCRDECODEHI,y    ;              4
            ldy LONIBBLES+$00,x  ;              4
            eor GCRDECODELO,y    ;              4
            ldy HINIBBLES+$01,x  ;              4
            eor GCRDECODEHI,y    ;              4
            ldy LONIBBLES+$01,x  ;              4
            eor GCRDECODELO,y    ;              4
            ldy HINIBBLES+$02,x  ;              4
            eor GCRDECODEHI,y    ;              4
            ldy LONIBBLES+$02,x  ;              4
            eor GCRDECODELO,y    ;              4
            ldy HINIBBLES+$03,x  ;              4
            eor GCRDECODEHI,y    ;              4
            ldy LONIBBLES+$03,x  ;              4
            eor GCRDECODELO,y    ;              4
            tay                  ;              2
            txa                  ;              2
            axs #-$04; x = x + 4 ;              2
scanswt1:   bne gcrfinish        ;              3 = 75
                                 ;                = 123

    .assert .hibyte(* + 1) = .hibyte(gcrfinish), error, "***** Page boundary crossing in GCR finishing loop, unnecessary cycle loss. *****"

            txa
            bne :+; don't check sum if only the first few bytes have been
                  ; decoded for scanning
            tya
            beq :+; check whether data checksum is ok
jmpreadblk: jmp readblock; if not, wait for next sector
:
            ; checksum sector header
            ; this is done only now because there is no time for that between
            ; the sector header and data block
            lda GCRBUFFER+$06
            alr #(GCR_NIBBLE_MASK << 1) | 1
            tay
            lda GCRBUFFER+$05
            jsr decodesub-$01; check sum
            sta GCRBUFFER+$06
            lax GCRBUFFER+$02
            lsr
            lsr
            lsr
            tay
            txa
            asl GCRBUFFER+$01
            rol
            asl GCRBUFFER+$01
            rol
            and #GCR_NIBBLE_MASK
            jsr decodesub+$03; ID1
            sta GCRBUFFER+$05
            lda GCRBUFFER+$01
            lsr
            lsr
            lsr
            tay
            lda GCRBUFFER+$00
            jsr decodesub-$01; ID0
            tay
            eor GCRBUFFER+$05; ID1
            eor LOADEDSECTOR
            eor GCRBUFFER+$06; check sum
            sta CURTRACK; is changed to eor CURTRACK after init
headerchk:  .byte OPC_BIT_ZP, .lobyte(jmpreadblk-*-$01); is changed to bne jmpreadblk
                                        ; after init, wait for next sector if
                                        ; sector header checksum was not ok
            lda GCRBUFFER+$05; ID1
            ldx #$00; set z-flag which won't be altered by the store opcodes
storputid0: cpy ID0; cpy ID0/sty ID0
            bne :+
storputid1: cmp ID1; cmp ID1/sta ID1
:           clc
dsctcmps:   .byte OPC_RTS, .lobyte(jmpreadblk-*-$01); is changed to bne jmpreadblk
                                            ; branch if some error occured while
                                            ; checking the sector header

            ; sector link sanity check
            ldy #$00
            jsr decodebyte; decode the block's first byte (track link)
            cmp #MAXTRACK41 + 1; check whether track link is within the valid range
            bcs jmpreadblk; if not, wait for next sector
            sta LINKTRACK
            jsr decodebyte; decode the block's second byte (sector link)
            sta LINKSECTOR; return the loaded block's sector link sector number
            ldy LINKTRACK ; return the loader block's sector link track number
            beq :+
            cmp NUMSECTORS
            bcs jmpreadblk; branch if sector number too large

:           ldx LOADEDSECTOR; return the loaded block's sector number
           ;clc             ; operation successful
            rts

            ; $19 bytes
lightsub:   txa
            tay
            beq ddliteon-$01
:           adc #$01
            bne :-
            jsr ddliteon
:           dey
            bne :-
            dex
            bne :+
            and #~MOTOR   ; turn off motor
:           and #~BUSY_LED; turn off busy led
store_via2: sta VIA2_PRB
            rts

            ; $07 bytes
ddliteon:   lda #BUSY_LED
            ora VIA2_PRB
            bne store_via2

driveidle:  jsr lightsub; fade off the busy led
            jsr gcrtimeout; check light sensor for disk removal
            lda VIA1_PRB
            cmp #CLK_OUT | CLK_IN | DATA_IN | ATN_IN
            beq driveidle; wait until there is something to do

            cmp #CLK_OUT | CLK_IN | DATA_IN
            bne duninstall; check for reset or uninstallation

            ; execute command

            txa
            beq beginload; check whether the busy led has been completely faded off
            jsr ddliteon ; if not, turn it on
beginload:
.if !LOAD_ONCE ; not with LOAD_ONCE because then, there is no danger of getting stuck
               ; because there is no serial transfer to retrieve the file id
            lda #$ff
            sta VIA2_T1C_H; set watchdog time-out, this also clears the possibly
                          ; pending timer 1 irq flag
            ENABLE_WATCHDOG; enable watchdog, the c64 might be reset while sending over a
                           ; byte, leaving the drive waiting for handshake pulses
.endif
            jmp RUNMODULE


    .if DISABLE_WATCHDOG = 0
        .assert * = $0300, error, "***** 1541 watchdog IRQ handler not located at $0300. *****"
    .endif

            ; configuration-dependent code

.if UNINSTALL_RUNS_DINSTALL

watchdgirq: lda #BUSY_LED | MOTOR
            jsr ddliteon + $02
            lda #$12
            jsr trackseek; ignore error (should not occur)
            ldx #$ff
            ; fade off the busy led and reset the drive
:           jsr lightsub
            txa
            bne :-
            jmp (RESET_VECTOR)
duninstall:
:           jsr lightsub
            txa
            bne :-
            jmp runcodeget

.else

watchdgirq: ldx #$ff

duninstall: txa
            pha
            bne :+
            lda #MOTOR
            SKIPWORD
:           lda #BUSY_LED | MOTOR
            jsr ddliteon+$02
            lda #$12
            jsr trackseek; ignore error (should not occur)
            pla
            ; fade off the busy led (if lit) and reset the drive
            beq :++
            ldx #$ff
:           jsr lightsub
            txa
            bne :-
:           jmp (RESET_VECTOR)
.endif

            ; $0f bytes
decodchksm: lda VIA2_PRA         ; 33334444
            ror
decodesub:  lsr
            lsr
            lsr
            tax
            lda GCRDECODEHI,y
            ora GCRDECODELO,x
            rts

            ; $10 bytes
decodebyte: ldx HINIBBLES,y
            lda GCRDECODEHI,x
            ldx LONIBBLES,y
            ora GCRDECODELO,x
            ldx NUMFILES
            iny
            rts

trackseek:  cmp #MAXTRACK41 + 1
            bcs setbitrate; don't do anything if invalid track
            sec
            tax
            sbc CURTRACK
            beq setbitrate

            ; do the track jump

            stx CURTRACK
            ldy #$00
            sty CURSTPSL
            bcs :+
            eor #~$00; invert track difference
            adc #$01
            iny
:           sty TRACKINC
            asl
            tay
            lda #$80 | (MINSTPSP+1)
trackstep:  pha
            sta VIA2_T1C_H
            tax
            lda TRACKINC
            eor VIA2_PRB
            sec
            rol
            and #TRACK_STEP
            eor VIA2_PRB
            sta VIA2_PRB
            pla
headaccl:   cmp #$80 | MAXSTPSP
            beq noheadac
            pha
           ;sec
            lda CURSTPSL
            sbc #STEPRACC
            sta CURSTPSL
            pla
            sbc #$00
noheadac:   cpx VIA2_T1C_H
            beq noheadac; wait until the counter hi-byte has decreased by 1
            dex
            bmi headaccl
            dey
            bne trackstep

            ; bit-rates:
            ; 31+  : 00
            ; 25-30: 01
            ; 18-24: 10
            ;  1-17: 11
setbitrate: lda VIA2_PRB
            ora #SYNC_MARK | BITRATE_MASK
            ldx #$15
            ldy CURTRACK
            cpy #$12
            bcc putbitrate
            dex
            dex
            sbc #1 << BITRATE_SHIFT
            cpy #$19
            bcc putbitrate
            dex
            sbc #1 << BITRATE_SHIFT
            cpy #$1f
            bcc putbitrate
            dex
            sbc #1 << BITRATE_SHIFT
putbitrate: bit VIA2_PRB  ; is changed to sta VIA2_PRB after init
putnumscts: bit NUMSECTORS; is changed to stx NUMSECTORS after init
            rts

dgetbyte:   GETBYTE_IMPL
            rts

drivebusy:  sty VIA1_PRB
            sei; disable watchdog
            rts

            ; module space
RUNMODULE:

.ifndef STANDALONE
    .if INSTALL_FROM_DISK

            ; load a module
            ; the module file track and sector are stored in
            ; LINKTRACK and LINKSECTOR, respectively

LOADMODULE: ; turn on the motor (but do not turn on the busy led)
            lda #MOTOR
            jsr ddliteon + $02

            lda #OPC_BNE
            sta dsctcmps

:           lda LINKTRACK
            ldy LINKSECTOR
            jsr getblkstid; sector link sanity check
                          ; store id
            bcs :-

            ldy #$02
:           jsr decodebyte
            sta POINTER + $00 - 3,y
            cpy #$05
            bne :-

            ldx #loadmodend - loadmodule - 1
:           lda loadmodule,x
            sta LOWMEM + $03,x
            dex
            bpl :-
            jmp LOWMEM + $03

loadmodule: jsr decodebyte; always decodes the whole block
            dey
            sta (POINTER),y
            iny
            bne loadmodule
            clc
            lda #$fe
            adc POINTER + $00
            sta POINTER + $00
            bcc :+
            inc POINTER + $01
            dec POINTER + $02
            beq modloaded
:           lda LINKTRACK
            beq modloaded
            ldy LINKSECTOR
            jsr getblkchid; compare id, sector link sanity check
            bcs :-
            ldy #$02
            bne loadmodule; jmp

modloaded:  jmp RUNMODULE
loadmodend:

    .assert loadmodend - loadmodule + LOWMEM + $03 < LOWMEMEND, error, "***** loadmodule too large. *****"

    .else; !INSTALL_FROM_DISK
            .include "drivecode1541-loadfile.s"
    .endif; !INSTALL_FROM_DISK
.endif

drvcodeend41:
            ; following code is transferred using KERNAL routines, then it is
            ; run and gets the rest of the code

            ; entry point
dinstall:
            sei

.if UNINSTALL_RUNS_DINSTALL
            ; header id and track/sector are buffered away to
            ; very low in ram because the install code starts
            ; fairly low as well and overwrites the original
            ; locations
            lda ROMOS_HEADER_ID0
            sta JOBCODE0300; to ID0
            lda ROMOS_HEADER_ID1
            sta JOBCODE0400; to ID1
            ; the following values are only relevant for LOAD_ONCE != 0
            lda ROMOS_HEADER_TRACK
            sta JOBCODE0500; to FILETRACK
            lda ROMOS_HEADER_SECTOR
            sta JOBCODE0600; to FILESECTOR
.endif
.if INSTALL_FROM_DISK
            lda ROMOS_HEADER_TRACK
            sta LINKTRACK
            lda ROMOS_HEADER_SECTOR
            sta LINKSECTOR
.endif
            lda #CLK_OUT
            sta VIA1_PRB
            lda #VIA_ATN_IN_INPUT | VIA_PIO7_INPUT | VIA_ATNA_OUT_OUTPUT | VIA_CLK_OUT_OUTPUT | VIA_CLK_IN_INPUT | VIA_DATA_OUT_OUTPUT | VIA_DATA_IN_INPUT | VIA_DEVICE_NUMBER_OUTPUT
            sta VIA1_DDRB

:           lda VIA1_PRB; wait for DATA IN = high
            lsr
instalwait: bcc :-
            ldx #.lobyte(stackend - $03)
            txs

.ifndef STANDALONE

            ldx #.lobyte(drvcodebeg41 - $01)
dgetrout:   inx
            bne :+
            inc dgetputhi
:           GETBYTE_IMPL
dgetputhi = *+$02
            sta a:.hibyte(drvcodebeg41 - $01) << 8,x
            cpx #.lobyte(drvcodeend41 - $01)
            bne dgetrout
            dec drvcodebeg41
            bne dgetrout

.endif; STANDALONE

.if UNINSTALL_RUNS_DINSTALL
            lda #IRQ_CLEAR_FLAGS | $7f
            sta VIA1_IER; no irqs from via 1
            sta VIA2_IER; no irqs from via 2
.endif
            rts; jumps to dcodinit

drvprgend:
            .reloc
