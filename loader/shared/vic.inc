; MOS6567/MOS6569

.ifndef _VIC_INC_
_VIC_INC_ = 1

.define CYCLES_PER_LINE_PAL    63
.define CYCLES_PER_LINE_NTSC   64

.define VIC2_IDLE_PATTERN      $3fff

.define CHARSET_ADDR_UPPERGRAPHIC $d000
.define CHARSET_ADDR_UPPERLOWER   $d800


.define VIC2_BASE              $d000

.define ROM_CHARSET_UPGFX      $d000
.define ROM_CHARSET_UPLOW      $d800

.define VIC2_COLOURRAM         $d800

.define COLOUR_BLACK           $00
.define COLOUR_WHITE           $01
.define COLOUR_RED             $02
.define COLOUR_CYAN            $03
.define COLOUR_VIOLET          $04
.define COLOUR_PURPLE          COLOUR_VIOLET
.define COLOUR_LILAC           COLOUR_VIOLET
.define COLOUR_GREEN      	   $05
.define COLOUR_BLUE   	       $06
.define COLOUR_YELLOW     	   $07
.define COLOUR_ORANGE          $08
.define COLOUR_BROWN      	   $09
.define COLOUR_LIGHTRED        $0a
.define COLOUR_DARKGREY        $0b
.define COLOUR_MEDIUMGREY      $0c
.define COLOUR_LIGHTGREEN      $0d
.define COLOUR_LIGHTBLUE       $0e
.define COLOUR_LIGHTGREY       $0f

.define SPRITE_0               %00000001
.define SPRITE_1               %00000010
.define SPRITE_2               %00000100
.define SPRITE_3               %00001000
.define SPRITE_4               %00010000
.define SPRITE_5               %00100000
.define SPRITE_6               %01000000
.define SPRITE_7               %10000000

.define SPRITE0_X              VIC2_BASE+$00; Sprite 0, x-coordinate bits 0-7
.define SPRITE0_Y              VIC2_BASE+$01; Sprite 0, y-coordinate
.define SPRITE1_X              VIC2_BASE+$02; Sprite 1, x-coordinate bits 0-7
.define SPRITE1_Y              VIC2_BASE+$03; Sprite 1, y-coordinate
.define SPRITE2_X              VIC2_BASE+$04; Sprite 2, x-coordinate bits 0-7
.define SPRITE2_Y              VIC2_BASE+$05; Sprite 2, y-coordinate
.define SPRITE3_X              VIC2_BASE+$06; Sprite 3, x-coordinate bits 0-7
.define SPRITE3_Y              VIC2_BASE+$07; Sprite 3, y-coordinate
.define SPRITE4_X              VIC2_BASE+$08; Sprite 4, x-coordinate bits 0-7
.define SPRITE4_Y              VIC2_BASE+$09; Sprite 4, y-coordinate
.define SPRITE5_X              VIC2_BASE+$0a; Sprite 5, x-coordinate bits 0-7
.define SPRITE5_Y              VIC2_BASE+$0b; Sprite 5, y-coordinate
.define SPRITE6_X              VIC2_BASE+$0c; Sprite 6, x-coordinate bits 0-7
.define SPRITE6_Y              VIC2_BASE+$0d; Sprite 6, y-coordinate
.define SPRITE7_X              VIC2_BASE+$0e; Sprite 7, x-coordinate bits 0-7
.define SPRITE7_Y              VIC2_BASE+$0f; Sprite 7, y-coordinate

.define SPRITES_X_MSB          VIC2_BASE+$10; Sprites 0-7, x-coordinates bit 8

.define VIC2_CTRL1             VIC2_BASE+$11; Control register 1
 .define SCROLLY_0             %00000000
 .define SCROLLY_1             %00000001
 .define SCROLLY_2             %00000010
 .define SCROLLY_3             %00000011
 .define SCROLLY_4             %00000100
 .define SCROLLY_5             %00000101
 .define SCROLLY_6             %00000110
 .define SCROLLY_7             %00000111
 .define SCROLLY_MASK          %00000111
 .define LINES_24              %00000000
 .define LINES_25              %00001000
 .define DISPLAY_ENABLE        %00010000
 .define DISPLAY_DISABLE       %00000000
 .define BITMAP_MODE           %00100000
 .define TEXT_MODE             %00000000
 .define EBCM_MODE             %01000000
 .define RASTERLINE_BIT8       %10000000
 .define RASTERLINE_BIT8_SHIFT 7
 .define RASTERLINE_MSB        %10000000
 .define RASTERLINE_MSB_SHIFT  7

.define VIC2_RASTERLINE    VIC2_BASE+$12; Current raster line, raster IRQ trigger line
 .define MAX_RASTERLINE_PAL    $0137
 .define MAX_RASTERLINE_NTSC   $0105

.define VIC2_STROBE_X          VIC2_BASE+$13; Light pen x-position
.define VIC2_STROBE_Y          VIC2_BASE+$14; Light pen y-position

.define VIC2_SPR_ENABLE        VIC2_BASE+$15; Enabled sprites

.define VIC2_CTRL2             VIC2_BASE+$16; Control register 2
 .define SCROLLX_0             %00000000
 .define SCROLLX_1             %00000001
 .define SCROLLX_2             %00000010
 .define SCROLLX_3             %00000011
 .define SCROLLX_4             %00000100
 .define SCROLLX_5             %00000101
 .define SCROLLX_6             %00000110
 .define SCROLLX_7             %00000111
 .define SCROLLX_MASK          %00000111
 .define COLUMNS_38            %00000000
 .define COLUMNS_40            %00001000
 .define SINGLECOLOUR_MODE     %00000000
 .define MULTICOLOUR_MODE      %00010000

.define VIC2_SPR_EXPANDY       VIC2_BASE+$17; y-expanded sprites

.define VIC2_ADDR              VIC2_BASE+$18; Character set and bitmap locations
 .define SCREEN_MASK           %11110000
 .define CHARSET_UPPERGRAPHIC  %00000100
 .define CHARSET_UPPERLOWER    %00000110
 .define CHARSET_MASK          %00001110
 .define BITMAP_MASK           %00001000
  .define VIC2_MAKE_ADDR(screen, charset) .lobyte(((screen & $3fff) >> 6) | ((charset & $3fff) >> 10))
 
.define VIC2_IRR               VIC2_BASE+$19; Interrupt Request Register
 .define RASTER_IRQ            %00000001
 .define SPR_BGR_COLL_IRQ      %00000010
 .define SPR_SPR_COLL_IRQ      %00000100
 .define LIGHTPEN_IRQ          %00001000
 .define IRQ_FLAG              %10000000

.define VIC2_IMR               VIC2_BASE+$1a; Interrupt Mask Register
;.define RASTER_IRQ            %00000001
;.define SPR_BGR_COLL_IRQ      %00000010
;.define SPR_SPR_COLL_IRQ      %00000100
;.define LIGHTPEN_IRQ          %00001000

.define VIC2_BG_PRIORITY       VIC2_BASE+$1b; Sprite-to-background priority

.define VIC2_SPR_MCOLOUR       VIC2_BASE+$1c; Sprites multicolour enabled

.define VIC2_SPR_EXPANDX       VIC2_BASE+$1d; Sprites x-expansion

.define VIC2_SPR_COLL          VIC2_BASE+$1e; Sprite-to-sprite collision
.define VIC2_SPR_BG_COLL       VIC2_BASE+$1f; Sprite-to-background collision

.define VIC2_BORDERCOLOUR      VIC2_BASE+$20; Overscan colour
.define VIC2_BGCOLOUR          VIC2_BASE+$21; Background colour
.define VIC2_BGCOLOUR0         VIC2_BASE+$21; Background colour 0
.define VIC2_BGCOLOUR1         VIC2_BASE+$22; Background colour 1
.define VIC2_MULTICOLOUR0      VIC2_BGCOLOUR1; Multicolour 1
.define VIC2_BGCOLOUR2         VIC2_BASE+$23; Background colour 2
.define VIC2_MULTICOLOUR1      VIC2_BGCOLOUR2; Multicolour 2
.define VIC2_BGCOLOUR3         VIC2_BASE+$24; Background colour 3

.define VIC2_SPR_MCOLOUR0      VIC2_BASE+$25; Sprite multicolour 0
.define VIC2_SPR_MCOLOUR1      VIC2_BASE+$26; Sprite multicolour 1

.define VIC2_SPR0_COLOUR       VIC2_BASE+$27; Sprite colour 0
.define VIC2_SPR1_COLOUR       VIC2_BASE+$28; Sprite colour 1
.define VIC2_SPR2_COLOUR       VIC2_BASE+$29; Sprite colour 2
.define VIC2_SPR3_COLOUR       VIC2_BASE+$2a; Sprite colour 3
.define VIC2_SPR4_COLOUR       VIC2_BASE+$2b; Sprite colour 4
.define VIC2_SPR5_COLOUR       VIC2_BASE+$2c; Sprite colour 5
.define VIC2_SPR6_COLOUR       VIC2_BASE+$2d; Sprite colour 6
.define VIC2_SPR7_COLOUR       VIC2_BASE+$2e; Sprite colour 7

.define VIC2_C128_EXT_KB       VIC2_BASE+$2f; Expanded keyboard matrix line
.define C128_EXT_KB            VIC2_C128_EXT_KB
.define VIC2_C128_CLOCK        VIC2_BASE+$30; Extended clock control
.define C128_CLOCK             VIC2_C128_CLOCK
 .define C128_TWO_MHZ          %00000001
 .define C128_INC_LINECNTR     %00000010
 
.endif; !_VIC_INC_
