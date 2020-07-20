; built on Mon, 13 Jul 2020 17:56:59 +0100 using
; make PLATFORM=c64 prg INSTALL=6000 RESIDENT=8C00 ZP=e8

; configuration
config_ALLOW_2_MHZ_ON_C128      = $00
config_DECOMPRESSOR             = $01
config_DIRTRACK                 = $12
config_DIRTRACK81               = $28
config_DISABLE_WATCHDOG         = $00
config_END_ADDRESS_API          = $00
config_FILENAME_MAXLENGTH       = $10
config_IDLE_BUS_LOCK            = $00
config_LC_SPEED                 = $06
config_LOAD_COMPD_API           = $01
config_LOAD_RAW_API             = $01
config_LOAD_TO_API              = $00
config_LOAD_UNDER_D000_DFFF     = $00
config_LOAD_VIA_KERNAL_FALLBACK = $00
config_MEM_DECOMP_API           = $00
config_MEM_DECOMP_TO_API        = $00
config_NTSC_COMPATIBILITY       = $00
config_ONLY_1541_AND_COMPATIBLE = $00
config_UNINSTALL_API            = $00

; status codes
status_OK                       = $00
status_DEVICE_INCOMPATIBLE      = $fb
status_TOO_MANY_DEVICES         = $fc
status_GENERIC_KERNAL_ERROR     = $fd
status_DEVICE_NOT_PRESENT       = $fe
status_FILE_NOT_FOUND           = $ff

; zeropage
loader_zp_first                 = $e8
loadaddrlo                      = $e8
loadaddrhi                      = $e9
decdestlo                       = $ea
decdesthi                       = $eb
loader_zp_last                  = $f4

; install
install                         = $6000

; resident
loadraw                         = $8c00
loadcompd                       = $8c0b
