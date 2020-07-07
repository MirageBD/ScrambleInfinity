
; this module loads a file
; it is currently a dead-end, so once loaded, it cannot switch to another module

.ifdef MODULE
    .include "cpu.inc"
    .include "via.inc"

    __NO_LOADER_SYMBOLS_IMPORT = 1
    .include "loader.inc"
    .include "loader-kernel1541.inc"
    .include "kernelsymbols1541.inc"

    .org RUNMODULE - 3
    .word * - 2

    .byte (MODULEEND - MODULESTART + 3) / 256 + 1; number of module blocks, not quite accurate, but works for now

.endif; MODULE

SECTORLINKTAB        = $0780

.if (::FILESYSTEM = FILESYSTEMS::DIRECTORY_NAME) && (LOAD_ONCE = 0)
DIRCYCLECOUNT        = UNUSED_ZP

CYCLESTARTENDSECTOR  = TRACKLINKTAB + 0
HASHVALUE0LO         = TRACKLINKTAB + 1
HASHVALUE0HI         = TRACKLINKTAB + 2
HASHVALUE1LO         = TRACKLINKTAB + 3
HASHVALUE1HI         = TRACKLINKTAB + 4
FILENAME             = TRACKLINKTAB + 5; $10 bytes

CURRDIRBLOCKSECTOR   = LOWMEM + 0
DIRBLOCKPOS          = LOWMEM + 1
NEXTDIRBLOCKTRACK    = LOWMEM + 2
NEXTDIRBLOCKSECTOR   = LOWMEM + 3

DDIRBUFF             = LOWMEM + 4
DIRBUFFSIZE          = (LOWMEMEND - DDIRBUFF) / 4;
DIRTRACKS            = DDIRBUFF
DIRSECTORS           = DIRTRACKS + DIRBUFFSIZE
FILENAMEHASHVAL0     = DIRSECTORS + DIRBUFFSIZE
FILENAMEHASHVAL1     = FILENAMEHASHVAL0 + DIRBUFFSIZE
DIRBUFFEND           = FILENAMEHASHVAL1 + DIRBUFFSIZE

.assert DIRBUFFSIZE >= 9, error, "***** Dir buffer too small. *****"
.endif; (::FILESYSTEM = FILESYSTEMS::DIRECTORY_NAME) && (LOAD_ONCE = 0)


MODULESTART:
            ; get starting track and sector of the file to load
getstartts:
.if !LOAD_ONCE

    .if ::FILESYSTEM = FILESYSTEMS::DIRECTORY_NAME

            ldx #-$01
            stx DIRCYCLECOUNT
getfilenam: inx
            jsr dgetbyte; get filename
            beq :+
            sta FILENAME,x
            cpx #FILENAME_MAXLENGTH
            bne getfilenam
:           jsr drvwait0
            jsr gethashval
            sta FILESECTOR
            stx FILETRACK

    .elseif ::FILESYSTEM = FILESYSTEMS::TRACK_SECTOR

            jsr dgetbyte; get starting track
            sta FILETRACK
            jsr dgetbyte; get starting sector
            jsr drvwait0
            sta FILESECTOR

   .endif
.endif; !LOAD_ONCE

.if (::FILESYSTEM = FILESYSTEMS::TRACK_SECTOR) || LOAD_ONCE
            ; check for illegal track or sector
            ldy FILETRACK
            beq toillegal + $00
            cpy #MAXTRACK41 + 1
            bcs toillegal + $01
            ldx FILESECTOR
            cpx NUMSECTORS
            bcc :+
toillegal:  sec
            jmp illegalts
:
.endif
            ; turn on the motor (but do not turn on the busy led yet)
            lda #MOTOR
            jsr ddliteon + $02

spinloop:   lda #OPC_RTS  ; get any block on the current track,
            ldy #ANYSECTOR; no sector link sanity check,
            jsr getblock  ; don't store id;
            bcs spinloop  ; retry until any block has been loaded correctly

; XXX TODO FIX
            beq :+; branch if disk id is the same, if not, re-read the dir
            lda #$ff
            sta DISKCHANGED; set the new disk flag when disks have been changed
:           lda #OPC_BNE
            sta dsctcmps
            lda DISKCHANGED
            beq samedisk; jumps to samedisk if no disk changes have happened

            ; a new disk has been inserted

.if (::FILESYSTEM = FILESYSTEMS::DIRECTORY_NAME) && (!LOAD_ONCE)

:           lda #DIRTRACK
            ldy #DIRSECTOR
            jsr getblkstid; sector link sanity check
                          ; store id
            bcs :-
           ;clc
            sta CYCLESTARTENDSECTOR

dirwrap:    sta NEXTDIRBLOCKSECTOR
            sty NEXTDIRBLOCKTRACK
            bcs dnxtdirs
            ; directory cycling: fill the dir buffer
filldirbuf: lda #$00
            sta NUMFILES
dnxtdirs:   jsr checkchg
            bne :-; store disk id and start over if disk changed
            lda NEXTDIRBLOCKTRACK
            bne noendofdir
            ; end of directory, so wrap the cycle
            ; little flaw for the sake of saving on code size:
            ; if there are fewer files in the directory than the
            ; dir buffer can hold, they are stored multiple
            ; times until the buffer is full. this costs some extra
            ; time but only matters when changing disks
            lda #DIRSECTOR
            ldy #DIRTRACK
           ;sec; carry is set by checkchg
            bcs dirwrap; jmp

noendofdir: ldy NEXTDIRBLOCKSECTOR
            jsr getblkchid; compare id, sector link sanity check
            bcs dnxtdirs; retry on error
            sta NEXTDIRBLOCKSECTOR
            stx CURRDIRBLOCKSECTOR
            sty NEXTDIRBLOCKTRACK

            ; when reading the dir, the DIRCYCLECOUNT variable
            ; is increased every time the CYCLESTARTENDSECTOR
            ; is read
            cpx CYCLESTARTENDSECTOR
            bne :+
            inc DIRCYCLECOUNT; on cycle start: $ff->$00

:           ldy #$03
dgdirloop:  ldx NUMFILES
            jsr fnamehash; does not change y
            pha
            txa
            ldx NUMFILES
            sta FILENAMEHASHVAL0,x
            pla
            sta FILENAMEHASHVAL1,x

            ; there is no check for non-files (start track 0) here
            ; to save some space

            inc NUMFILES
            cpx #DIRBUFFSIZE - 1
            ; branch if dir buffer is full
            ; little flaw for the sake of saving on code size:
            ; when starting to cycle through the directory, the
            ; files in the dir block the last file currently in the dir
            ; buffer is in, will all be added to the buffer when it will
            ; be filled on the subsequent file load - this is why the
            ; minimum dir buffer size is 9 files
            bcs samedisk
            tya
            and #%11100000
           ;clc
            adc #$23
            tay
            bcc dgdirloop; process all entries in a dir block
            bcs dnxtdirs ; check next dir block

            ; the disk was not changed, or the dir has just been read
samedisk:   ldx #$00; clear new disk flag
            stx DISKCHANGED
            dex
findfile:   inx
            cpx NUMFILES
            bne nextfile; check all dir entries in the buffer

            ; the dir buffer does not contain the file,
            ; so cycle through the directory to find it

           ;lda #DIRTRACK        ; not needed since NEXTDIRBLOCKTRACK
           ;sta NEXTDIRBLOCKTRACK; is always left holding DIRTRACK

            ldy DIRCYCLECOUNT    ; check if a cycle
            dey                  ; is complete
            bmi filldirbuf       ; the counter will increase on cycle start
            jmp filenotfnd

            ; must not change y
fnamehash:  jsr decodebyte; get file's start track
            sta DIRTRACKS,x
            jsr decodebyte; get file's start sector
            sta DIRSECTORS,x
            ldx #$00
:           stx HASHVALUE0LO
            jsr decodebyte
            ldx HASHVALUE0LO
            cmp #' ' | $80
            beq gethashval
            sta FILENAME,x
            inx
            cpx #FILENAME_MAXLENGTH
            bne :-

            ; must not change y
gethashval: clc
            lda #$ff
            sta HASHVALUE0LO
            sta HASHVALUE1LO
            lda #$00
            sta HASHVALUE0HI
            sta HASHVALUE1HI
hashloop:   lda FILENAME - 1,x
            adc HASHVALUE0LO
            sta HASHVALUE0LO
            bcc :+
            inc HASHVALUE0HI
:           adc HASHVALUE1LO
            sta HASHVALUE1LO
            lda HASHVALUE0HI
            adc HASHVALUE1HI
            sta HASHVALUE1HI
            dex
            bne hashloop
            adc HASHVALUE1LO
            tax
            lda HASHVALUE0LO
            adc HASHVALUE0HI
            rts

nextfile:   lda FILETRACK
            cmp FILENAMEHASHVAL0,x
            bne findfile
            lda FILESECTOR
            cmp FILENAMEHASHVAL1,x
            bne findfile

            ; file found

; XXX TODO FIX
           ;lda #samedisk - diskbranch - 2; clear new disk flag
           ;sta diskbranch + 1

            stx FILEINDEX; store index of file to jump to the track of the file
                         ; following this one in the dir, after loading

            ; store track and sector of the dir block the file was found in,
            ; they are used to start the dir check cycle if the next file is not found
            ; in the dir buffer;
            ; they are also checked on the subsequent load to determine if the dir check
            ; cycle is complete and the file be said to be not found
            lda CURRDIRBLOCKSECTOR
            sta CYCLESTARTENDSECTOR
            sta NEXTDIRBLOCKSECTOR
            lda #DIRTRACK
            sta NEXTDIRBLOCKTRACK

            jsr ddliteon
            lda DIRTRACKS,x
            ldy DIRSECTORS,x

            ; actually there should be a check for illegal track or sector
            ; here - unfortunately, there is no memory left for it

.else; ::FILESYSTEM = FILESYSTEMS::TRACK_SECTOR || (!LOAD_ONCE)

; XXX TODO what if not same disk?

samedisk:
            ; spin up and store new disk id
:           lda CURTRACK
            ldy #ANYSECTOR
            jsr getblkstid; sector link sanity check
                          ; store id
            bcs :-

            jsr ddliteon
            lda FILETRACK; track
            ldy FILESECTOR; sector

.endif; !(::FILESYSTEM = FILESYSTEMS::TRACK_SECTOR || (!LOAD_ONCE))

            ; a contains the file's starting track here
            ; y contains the file's starting sector here
            ldx #$00
            stx BLOCKINDEXBASE
trackloop:  sty SECTORTOFETCH
            jsr trackseek

            ; scan the track for the file links
           ;lda #UNPROCESSEDSECTOR      ; the accu contains that already, effectively
:           sta TRACKLINKTAB - $01,x    ; mark all sectors as not processed
            sta TEMPTRACKLINKTAB - $01,x; mark all sectors as not processed
            dex
            bne :-
scantrloop: lda #OPC_BIT_ZP; only fetch the first few bytes to track the links
            ; this is a weak point since there is no data checksumming here
            ldy #ANYSECTOR
            sty REQUESTEDSECTOR
            jsr wait4sct
            bcs scantrloop; branch until fetch successful

            ; x contains the loaded block's sector number here
            sta SECTORLINKTAB,x
            tya
            sta TEMPTRACKLINKTAB,x; store sector's track link and mark the sector as
                                  ; processed

            ; go through the link list to find the blocks's order on the track
            ldy #$00
            sty BLOCKINDEX
            ldx SECTORTOFETCH
numblklp:   lda TEMPTRACKLINKTAB,x
            bmi scantrloop; branch if not all of the file's blocks on this track
                          ; have been scanned yet
            pha; store link track
            tya
            sta TRACKLINKTAB,x ; store sector index
            lda SECTORLINKTAB,x; get link sector
            tax
            iny; increase sector index
            pla
            cmp CURTRACK; check whether link track is the current track
            beq numblklp; branch until all the file's blocks on the current
                        ; track have been ordered

            ; read and transfer all the blocks that belong to the file
            ; on the current track, the blocks are read in quasi-random order
            pha         ; next track
            tya         ; number of the file's blocks on the current track
            pha
            stx NEXTSECTOR; first sector on the next track
            sty SECTORCOUNT; number of the file's blocks on the current track

loadblock:  ldy #UNPROCESSEDSECTOR; find any yet unprocessed block belonging to the file
            lda BLOCKINDEXBASE
            bne :+
            ldy SECTORTOFETCH; on loading begin, first get the file's first block to
                             ; determine its loading address
:           lda #OPC_BNE
            jsr getblock     ; read any of the files's sectors on track, compare
                             ; id, sector link sanity check
            bcs loadblock    ; retry until a block has been successfully loaded

            ; mark the block as processed and send it over
            ldy #UNPROCESSEDSECTOR; $ff
            sty SECTORTOFETCH; BLOCKINDEXBASE is 0 for the whole 1st file track
            sty TRACKLINKTAB,x; mark the loaded block as processed
            lda LINKTRACK
            bne :+
            ldy LINKSECTOR; the file's last block's length

:           sty dsendcmp + $01
            dey
            dey
            tya
            ldy #$01
            jsr gcrencode; block length
            clc
            lda BLOCKINDEX
            adc BLOCKINDEXBASE
            jsr sendblock; send the block over

            lda SECTORCOUNT; sector count for the current track
            bne loadblock
            clc
            pla; number of file's blocks on the current track
            adc BLOCKINDEXBASE
            sta BLOCKINDEXBASE
            ldy NEXTSECTOR
            pla          ; next track
            bne trackloop; process next track

            ; loading is finished

.if (::FILESYSTEM = FILESYSTEMS::DIRECTORY_NAME) && (!LOAD_ONCE)

            ldx FILEINDEX
:           inx
            cpx NUMFILES
            lda DIRTRACKS,x
            beq :-; track number might be 0 since non-files may be in the dir buffer as well
            bcc :+
            lda #DIRTRACK
:           jsr trackseek; move head to the start track of the next file in the
                         ; directory
.endif

            ; all ok after loading
            clc

filenotfnd: ; branches here with carry set on
illegalts:  ; file not found or illegal t or s
            lda #$00
            sta dsendcmp + $01; just send over one byte
            sbc #$01; carry clear: result is $00 - $02 = $fe - loading finished successfully
                    ; carry set:   result is $00 - $01 = $ff - load error
            jsr sendblock; send status

            ldx #$01; turn motor and busy led off
            lda #BUSY_LED; check if busy led is lit
            and VIA2_PRB
            beq :+
            ldx #$ff; fade off the busy led, then turn motor off
.if LOAD_ONCE
:           jmp duninstall

            .res 64; some padding to satisfy non-page-boundary-crossing asserts
.else
:           ENABLE_WATCHDOG
:           bit VIA1_PRB
            bpl :-; wait until the computer has acknowledged the file transfer
            sei; disable watchdog
            jmp driveidle
.endif

            ; accu: status byte
sendblock:  ldy #$00
            jsr gcrencode; block index

            ldx #$ff
            ldy #$04; here, the watchdog timer is polled manually because
                    ; an extra-long time-out period is needed since the c64 may
                    ; still be busy decompressing a large chunk of data;
                    ; this is the round counter
            stx VIA2_T1C_H; set watchdog time-out, this also clears the possibly
                          ; pending timer 1 irq flag
            lda #DATA_OUT
            sta VIA1_PRB; block ready signal
            ; a watchdog is used because the c64 might be reset while sending
            ; over the block, leaving the drive waiting for handshake pulses
waitready:  bit VIA2_IFR; see if the watchdog barked
            bpl :+
            dey        ; if yes, decrease the round counter
            beq timeout; and see if we've already timed out
            stx VIA2_T1C_H; set watchdog time-out and clear irq flag
:           bit VIA1_PRB
            bpl waitready
            stx VIA2_T1C_H; set watchdog time-out and clear possibly set irq flag

timeout:    ENABLE_WATCHDOG
            ldy #$00
sendloop:   ldx LONIBBLES+$00,y; 4
            lda SENDGCRTABLE,x ; 4
            ldx HINIBBLES+$00,y; 4

:           bit VIA1_PRB
            bmi :-
            sta VIA1_PRB

            asl                ; 2
            ora #ATNA_OUT      ; 2
            sec                ; 2

:           bit VIA1_PRB
            bpl :-
            sta VIA1_PRB

            ror VIA2_T1C_H     ; 6 ; set watchdog time-out
            lda SENDGCRTABLE,x ; 4

:           bit VIA1_PRB
            bmi :-
            sta VIA1_PRB

            asl                ; 2
            ora #ATNA_OUT      ; 2
dsendcmp:   cpy #$00           ; 2
            iny                ; 2

:           bit VIA1_PRB
            bpl :-
            sta VIA1_PRB
            bcc sendloop

    .assert .hibyte(* + 1) = .hibyte(sendloop), error, "***** Page boundary crossing in byte send loop, fatal cycle loss. *****"

:           bit VIA1_PRB
            bmi :-
            ldy #CLK_OUT
            dec SECTORCOUNT
            bne todrvbusy; pull DATA_OUT high when changing tracks
drvwait0:   ldy #CLK_OUT | DATA_OUT; flag track change
todrvbusy:  jmp drivebusy

MODULEEND:

    .assert * <= $05ff, error, "***** 1541 drive code too large, please try changing options in config.inc. *****"
