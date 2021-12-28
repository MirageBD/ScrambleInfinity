; repository version 184M, built on Mon, 27 Dec 2021 21:26:00 +0100 for project "scramble" using
; make PLATFORM=c64 save INSTALL=6000 RESIDENT=0400 TRANSIENT=7800 ZP=e8 PROJECT=scramble

; configuration
config_ALLOW_2_MHZ_ON_C128      = 0
config_DECOMPRESSOR             = 2; BYTEBOOZER2
config_DIRTRACK                 = 19
config_DIRTRACK81               = 40
config_END_ADDRESS_API          = 1
config_FILENAME_MAXLENGTH       = 16
config_FILE_EXISTS_API          = 0
config_INTERNAL                 = 0
config_LOAD_COMPD_API           = 1
config_LOAD_RAW_API             = 1
config_LOAD_TO_API              = 0
config_LOAD_UNDER_D000_DFFF     = 0
config_LOAD_VIA_KERNAL_FALLBACK = 0
config_MEM_DECOMP_API           = 0
config_MEM_DECOMP_TO_API        = 0
config_NTSC_COMPATIBILITY       = 0
config_ONLY_1541_AND_COMPATIBLE = 1
config_UNINSTALL_API            = 0

; status codes
status_OK                       = $00
status_FILE_TOO_LARGE           = $f7
status_FILE_ON_DISK_TOO_SMALL   = $f8
status_FILE_ON_DISK_TOO_LARGE   = $f9
status_WRITE_PROTECT_ON         = $fa
status_DEVICE_INCOMPATIBLE      = $fb
status_TOO_MANY_DEVICES         = $fc
status_GENERIC_KERNAL_ERROR     = $fd
status_DEVICE_NOT_PRESENT       = $fe
status_FILE_NOT_FOUND           = $ff

; zeropage $e8-$ff
loader_zp_first                 = $e8
loadaddrlo                      = $e8
loadaddrhi                      = $e9
endaddrlo                       = $ec
endaddrhi                       = $ed
loader_zp_last                  = $f4
plugin_zp_last                  = $fe

; install $6000-$6ca5
install                         = $6000

; resident $0400-$0635
loadraw                         = $0400
loadcompd                       = $040e

; transient $7800-$7cc4
save                            = $7800
swapdrvcod                      = $7a64
restoreldr                      = $7b3c
sendbyte                        = $7b63
receivbyte                      = $7b7f
