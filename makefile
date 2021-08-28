MAKE         = make
CP           = cp
MV           = mv
RM           = rm -f

SRC_DIR				= ./src
BOOT_SRC_DIR		= ./src/boot
LOADSCREEN_SRC_DIR	= ./src/loadscreen
UTIL_SRC_DIR		= ./utils
EXE_DIR				= ./exe
BIN_DIR				= ./bin

CPU          = 6502X

AS           = ca65
ASFLAGS      = -g --cpu $(CPU) -U --feature force_range -I ./exe
LD           = ld65
LDFLAGS      = -Ln $(EXE_DIR)/symbols --dbgfile $(EXE_DIR)/main.dbg
VICE         = "..\..\..\winvice\x64sc.exe"
#VICEFLAGS    = -truedrive -autostart-warp -moncommands $(EXE_DIR)/symbols
VICEFLAGS    = -truedrive -moncommands $(EXE_DIR)/symbols
C1541        = c1541

LOADER       = ./loader
CC1541       = cc1541

PU           = pucrunch
BB           = B2
LC           = crush 6
BINSPLIT     = $(EXE_DIR)/binsplit.exe
SPECIALTILES = $(EXE_DIR)/specialtiles.exe
ADDADDR      = $(EXE_DIR)/addaddr.exe
GCC          = gcc

.SUFFIXES: .o .s .out .bin .pu .b2 .a

default: all

# -----------------------------------------------------------------------------

$(LOADER)/loader/build/loader-c64.prg:
	$(MAKE) -C $(LOADER)/loader

# -----------------------------------------------------------------------------

specialtiles.exe: $(UTIL_SRC_DIR)/specialtiles.c
	$(GCC) $(UTIL_SRC_DIR)/specialtiles.c -o $(EXE_DIR)/specialtiles.exe

binsplit.exe: $(UTIL_SRC_DIR)/binsplit.c
	$(GCC) $(UTIL_SRC_DIR)/binsplit.c -o $(EXE_DIR)/binsplit.exe

addaddr.exe: $(UTIL_SRC_DIR)/addaddr.c
	$(GCC) $(UTIL_SRC_DIR)/addaddr.c -o $(EXE_DIR)/addaddr.exe

loader-c64.prg: $(LOADER)/loader/build/loader-c64.prg
	$(CP) $(LOADER)/loader/build/loader-c64.prg $(EXE_DIR)/.
	
install-c64.prg: $(LOADER)/loader/build/install-c64.prg	
	$(CP) $(LOADER)/loader/build/install-c64.prg $(EXE_DIR)/.

loadersymbols-c64.inc: $(LOADER)/loader/build/loadersymbols-c64.inc
	$(CP) $(LOADER)/loader/build/loadersymbols-c64.inc $(EXE_DIR)/.

main.o: $(SRC_DIR)/main.s Makefile Linkfile.main loader-c64.prg install-c64.prg maptiles.out maptilechars.out loadersymbols-c64.inc
	$(AS) $(ASFLAGS) -o $(EXE_DIR)/$*.o $(SRC_DIR)/$*.s

main_unpacked.prg: main.o loader-c64.prg install-c64.prg loadersymbols-c64.inc Linkfile.main
	$(LD) $(LDFLAGS) -C Linkfile.main --mapfile $(EXE_DIR)/main.map -o $(EXE_DIR)/$@ $(EXE_DIR)/main.o

main_unpacked.prg.addr: main_unpacked.prg
	$(ADDADDR) $(EXE_DIR)/$? $(EXE_DIR)/$@ 2080

main.prg: main_unpacked.prg.addr
	$(BB) -e 0820 $(EXE_DIR)/$?
	$(MV) $(EXE_DIR)/$?.b2 $(EXE_DIR)/$@

# -----------------------------------------------------------------------------

loadscreen.o: $(LOADSCREEN_SRC_DIR)/loadscreen.s Makefile Linkfile.loadscreen loader-c64.prg install-c64.prg loadersymbols-c64.inc
	$(AS) $(ASFLAGS) -o $(EXE_DIR)/$*.o $(LOADSCREEN_SRC_DIR)/$*.s

loadscreen_unpacked.prg: loadscreen.o loader-c64.prg install-c64.prg loadersymbols-c64.inc Linkfile.loadscreen
	$(LD) $(LDFLAGS) -C Linkfile.loadscreen --mapfile $(EXE_DIR)/loadscreen.map -o $(EXE_DIR)/$@ $(EXE_DIR)/loadscreen.o

loadscreen_unpacked.prg.addr: loadscreen_unpacked.prg
	$(ADDADDR) $(EXE_DIR)/$? $(EXE_DIR)/$@ 20480

loadscreen.prg: loadscreen_unpacked.prg.addr
	$(BB) $(EXE_DIR)/$?
	$(MV) $(EXE_DIR)/$?.b2 $(EXE_DIR)/$@

# -----------------------------------------------------------------------------

boot.o: $(BOOT_SRC_DIR)/boot.s Makefile Linkfile.boot loader-c64.prg install-c64.prg loadersymbols-c64.inc
	$(AS) $(ASFLAGS) -o $(EXE_DIR)/$*.o $(BOOT_SRC_DIR)/$*.s

boot_unpacked.prg: boot.o loader-c64.prg install-c64.prg loadersymbols-c64.inc Linkfile.boot
	$(LD) $(LDFLAGS) -C Linkfile.boot --mapfile $(EXE_DIR)/boot.map -o $(EXE_DIR)/$@ $(EXE_DIR)/boot.o

boot_unpacked.prg.addr: boot_unpacked.prg
	$(ADDADDR) $(EXE_DIR)/$? $(EXE_DIR)/$@ 16384

boot.prg: boot_unpacked.prg.addr
	$(BB) -e 4000 $(EXE_DIR)/$?
	$(MV) $(EXE_DIR)/$?.b2 $(EXE_DIR)/$@

# -----------------------------------------------------------------------------

# Usage: binsplit [type] [add startaddress] [new startaddress] [infile] [outfile] [startaddress] [endaddress]
# type: 0 = relative, 1 = absolute, 2 = same size chunks
# add startaddress: 1 = yes, 0 = no
# new startaddress: 0-65535
# endaddress = -1 = end of file


# wholemap.bin               -> mapttilesheader.out, maptiles.out, maptilechars.out, maptilesmap.out
# maptilesmap.out            -> maptilesmapmissileinfo.out
# maptilesmapmissileinfo.out -> m00.out,  m01.out,  etc.
# m00.out,  m01.out,  etc.   -> ma00.out, ma01.out, etc.
# ma00.out, ma01.out, etc.   -> ma00.bb,  ma01.bb,  etc.
# ma00.bb,  ma01.bb,  etc.   -> ma00.bc,  ma01.bc,  etc.
# ma00.bc,  ma01.bc,  etc.   -> 


wholemap.bin: $(BIN_DIR)/wholemap.bin

mapttilesheader.out: wholemap.bin
	$(BINSPLIT) 1 1 16256 $(BIN_DIR)/wholemap.bin $(EXE_DIR)/mapttilesheader.out 0 16

maptiles.out: wholemap.bin
	$(BINSPLIT) 0 0 0 $(BIN_DIR)/wholemap.bin $(EXE_DIR)/maptiles.out 0 2

maptilechars.out: wholemap.bin
	$(BINSPLIT) 0 0 0 $(BIN_DIR)/wholemap.bin $(EXE_DIR)/maptilechars.out 2 4

maptilesmap.out: wholemap.bin
	$(BINSPLIT) 0 0 0 $(BIN_DIR)/wholemap.bin $(EXE_DIR)/maptilesmap.out 6 -1

# maptilesmapmissileinfo.out = map tiles map with missile information in 25th rows
maptilesmapmissileinfo.out : maptilesmap.out
	$(SPECIALTILES) $(EXE_DIR)/maptilesmap.out $(EXE_DIR)/maptilesmapmissileinfo.out
	$(BINSPLIT) 2 0 0 $(EXE_DIR)/maptilesmapmissileinfo.out $(EXE_DIR)/m 0 2000
	$(ADDADDR) $(EXE_DIR)/m00.out $(EXE_DIR)/ma00.out 12288
	$(ADDADDR) $(EXE_DIR)/m01.out $(EXE_DIR)/ma01.out 14336
	$(ADDADDR) $(EXE_DIR)/m02.out $(EXE_DIR)/ma02.out 12288
	$(ADDADDR) $(EXE_DIR)/m03.out $(EXE_DIR)/ma03.out 14336
	$(ADDADDR) $(EXE_DIR)/m04.out $(EXE_DIR)/ma04.out 12288
	$(ADDADDR) $(EXE_DIR)/m05.out $(EXE_DIR)/ma05.out 14336
	$(ADDADDR) $(EXE_DIR)/m06.out $(EXE_DIR)/ma06.out 12288
	$(ADDADDR) $(EXE_DIR)/m07.out $(EXE_DIR)/ma07.out 14336
	$(ADDADDR) $(EXE_DIR)/m08.out $(EXE_DIR)/ma08.out 12288
	$(ADDADDR) $(EXE_DIR)/m09.out $(EXE_DIR)/ma09.out 14336
	$(ADDADDR) $(EXE_DIR)/m0a.out $(EXE_DIR)/ma0a.out 12288
	$(ADDADDR) $(EXE_DIR)/m0b.out $(EXE_DIR)/ma0b.out 14336
	$(ADDADDR) $(EXE_DIR)/m0c.out $(EXE_DIR)/ma0c.out 12288
	$(ADDADDR) $(EXE_DIR)/m0d.out $(EXE_DIR)/ma0d.out 14336
	$(ADDADDR) $(EXE_DIR)/m0e.out $(EXE_DIR)/ma0e.out 12288
	$(ADDADDR) $(EXE_DIR)/m0f.out $(EXE_DIR)/ma0f.out 14336
	$(ADDADDR) $(EXE_DIR)/m10.out $(EXE_DIR)/ma10.out 12288
	$(ADDADDR) $(EXE_DIR)/m11.out $(EXE_DIR)/ma11.out 14336
	$(ADDADDR) $(EXE_DIR)/m12.out $(EXE_DIR)/ma12.out 12288
	$(ADDADDR) $(EXE_DIR)/m13.out $(EXE_DIR)/ma13.out 14336
	$(ADDADDR) $(EXE_DIR)/m14.out $(EXE_DIR)/ma14.out 12288
	$(ADDADDR) $(EXE_DIR)/m15.out $(EXE_DIR)/ma15.out 14336
	$(ADDADDR) $(EXE_DIR)/m16.out $(EXE_DIR)/ma16.out 12288
	$(ADDADDR) $(EXE_DIR)/m17.out $(EXE_DIR)/ma17.out 14336
	$(ADDADDR) $(EXE_DIR)/m18.out $(EXE_DIR)/ma18.out 12288
	$(ADDADDR) $(EXE_DIR)/m19.out $(EXE_DIR)/ma19.out 14336
	$(ADDADDR) $(EXE_DIR)/m1a.out $(EXE_DIR)/ma1a.out 12288
	$(ADDADDR) $(EXE_DIR)/m1b.out $(EXE_DIR)/ma1b.out 14336
	$(ADDADDR) $(EXE_DIR)/m1c.out $(EXE_DIR)/ma1c.out 12288
	$(ADDADDR) $(EXE_DIR)/m1d.out $(EXE_DIR)/ma1d.out 14336
	$(ADDADDR) $(EXE_DIR)/m1e.out $(EXE_DIR)/ma1e.out 12288
	$(ADDADDR) $(EXE_DIR)/m1f.out $(EXE_DIR)/ma1f.out 14336
	$(ADDADDR) $(EXE_DIR)/m20.out $(EXE_DIR)/ma20.out 12288
	$(ADDADDR) $(EXE_DIR)/m21.out $(EXE_DIR)/ma21.out 14336
	$(ADDADDR) $(EXE_DIR)/m22.out $(EXE_DIR)/ma22.out 12288
	$(ADDADDR) $(EXE_DIR)/m23.out $(EXE_DIR)/ma23.out 14336
	$(ADDADDR) $(EXE_DIR)/m24.out $(EXE_DIR)/ma24.out 12288
	$(ADDADDR) $(EXE_DIR)/m25.out $(EXE_DIR)/ma25.out 14336
	$(ADDADDR) $(EXE_DIR)/m26.out $(EXE_DIR)/ma26.out 12288
	$(ADDADDR) $(EXE_DIR)/m27.out $(EXE_DIR)/ma27.out 14336
	$(ADDADDR) $(EXE_DIR)/m28.out $(EXE_DIR)/ma28.out 12288
	$(ADDADDR) $(EXE_DIR)/m29.out $(EXE_DIR)/ma29.out 14336
	$(ADDADDR) $(EXE_DIR)/m2a.out $(EXE_DIR)/ma2a.out 12288
	$(ADDADDR) $(EXE_DIR)/m2b.out $(EXE_DIR)/ma2b.out 14336
	$(ADDADDR) $(EXE_DIR)/m2c.out $(EXE_DIR)/ma2c.out 12288
	$(ADDADDR) $(EXE_DIR)/m2d.out $(EXE_DIR)/ma2d.out 14336
	$(ADDADDR) $(EXE_DIR)/m2e.out $(EXE_DIR)/ma2e.out 12288
	$(ADDADDR) $(EXE_DIR)/m2f.out $(EXE_DIR)/ma2f.out 14336
	$(ADDADDR) $(EXE_DIR)/m30.out $(EXE_DIR)/ma30.out 12288
	$(ADDADDR) $(EXE_DIR)/m31.out $(EXE_DIR)/ma31.out 14336
	$(ADDADDR) $(EXE_DIR)/m32.out $(EXE_DIR)/ma32.out 12288
	$(ADDADDR) $(EXE_DIR)/m33.out $(EXE_DIR)/ma33.out 14336

ma00.out ma01.out ma02.out ma03.out ma04.out ma05.out ma06.out ma07.out ma08.out ma09.out ma0a.out ma0b.out ma0c.out ma0d.out ma0e.out ma0f.out \
ma10.out ma11.out ma12.out ma13.out ma14.out ma15.out ma16.out ma17.out ma18.out ma19.out ma1a.out ma1b.out ma1c.out ma1d.out ma1e.out ma1f.out \
ma20.out ma21.out ma22.out ma23.out ma24.out ma25.out ma26.out ma27.out ma28.out ma29.out ma2a.out ma2b.out ma2c.out ma2d.out ma2e.out ma2f.out \
ma30.out ma31.out ma32.out ma33.out : maptilesmapmissileinfo.out

tsbmp1.b2: $(BIN_DIR)/tsbmp1.bin
	$(ADDADDR) $(BIN_DIR)/tsbmp1.bin $(EXE_DIR)/tsbmp1.rel.bin 24576
	$(BB) $(EXE_DIR)/tsbmp1.rel.bin
	$(MV) $(EXE_DIR)/tsbmp1.rel.bin.b2 $(EXE_DIR)/tsbmp1.b2

tsbmp10400.b2: $(BIN_DIR)/tsbmp10400.bin
	$(ADDADDR) $(BIN_DIR)/tsbmp10400.bin $(EXE_DIR)/tsbmp10400.rel.bin 16384
	$(BB) $(EXE_DIR)/tsbmp10400.rel.bin
	$(MV) $(EXE_DIR)/tsbmp10400.rel.bin.b2 $(EXE_DIR)/tsbmp10400.b2

tsbmp1d800.b2: $(BIN_DIR)/tsbmp1d800.bin
	$(ADDADDR) $(BIN_DIR)/tsbmp1d800.bin $(EXE_DIR)/tsbmp1d800.rel.bin 12288
	$(BB) $(EXE_DIR)/tsbmp1d800.rel.bin
	$(MV) $(EXE_DIR)/tsbmp1d800.rel.bin.b2 $(EXE_DIR)/tsbmp1d800.b2

# $4c00 - $5700 = $0c00 (REPLACES SPRITES1 SEGMENT)
tspointspr.b2: $(BIN_DIR)/tspointspr.bin
	$(ADDADDR) $(BIN_DIR)/tspointspr.bin $(EXE_DIR)/tspointspr.rel.bin 19456
	$(BB) $(EXE_DIR)/tspointspr.rel.bin
	$(MV) $(EXE_DIR)/tspointspr.rel.bin.b2 $(EXE_DIR)/tspointspr.b2

# more room for sprites from $7400-$8000 = $0c00... at $7800 for now
tshowfar.b2: $(BIN_DIR)/tshowfar.bin
	$(ADDADDR) $(BIN_DIR)/tshowfar.bin $(EXE_DIR)/tshowfar.rel.bin 30720
	$(BB) $(EXE_DIR)/tshowfar.rel.bin
	$(MV) $(EXE_DIR)/tshowfar.rel.bin.b2 $(EXE_DIR)/tshowfar.b2

# $7000 - $7400
tsbkg.b2:  $(BIN_DIR)/metabkg.bin
	$(ADDADDR) $(BIN_DIR)/metabkg.bin $(EXE_DIR)/metabkg.rel.bin 28672
	$(BB) $(EXE_DIR)/metabkg.rel.bin
	$(MV) $(EXE_DIR)/metabkg.rel.bin.b2 $(EXE_DIR)/tsbkg.b2

# -----------------------------------------------------------------------------

%.b2: %.out
	$(BB) $(EXE_DIR)/$*.out
	$(MV) $(EXE_DIR)/$*.out.b2 $(EXE_DIR)/$*.b2

.out.pu:
	$(PU) -c0 $(EXE_DIR)/$*.out $(EXE_DIR)/$*.pu

# -----------------------------------------------------------------------------

# -f MH -w mapttilesheader.bc \
	

main.d64: boot.prg loadscreen.prg main.prg install-c64.prg \
          mapttilesheader.out mapttilesheader.b2 \
		  tsbmp1.b2 tsbmp10400.b2 tsbmp1d800.b2 tspointspr.b2 tsbkg.b2 tshowfar.b2 \
          ma00.b2 ma01.b2 ma02.b2 ma03.b2 ma04.b2 ma05.b2 ma06.b2 ma07.b2 ma08.b2 ma09.b2 \
          ma0a.b2 ma0b.b2 ma0c.b2 ma0d.b2 ma0e.b2 ma0f.b2 ma10.b2 ma11.b2 ma12.b2 ma13.b2 \
          ma14.b2 ma15.b2 ma16.b2 ma17.b2 ma18.b2 ma19.b2 ma1a.b2 ma1b.b2 ma1c.b2 ma1d.b2 \
          ma1e.b2 ma1f.b2 ma20.b2 ma21.b2 ma22.b2 ma23.b2 ma24.b2 ma25.b2 ma26.b2 ma27.b2 \
          ma28.b2 ma29.b2 ma2a.b2 ma2b.b2 ma2c.b2 ma2d.b2 ma2e.b2 ma2f.b2 ma30.b2 ma31.b2 \
          ma32.b2 ma33.b2 
	$(RM) $(EXE_DIR)/$@
	$(CC1541) -n "    scramble    " -i " 2020" -S 8 -d 19 -v\
	 \
	 -f "scramble 2020" -w $(EXE_DIR)/boot.prg \
	 -f "ls" -w $(EXE_DIR)/loadscreen.prg \
	 -f "ff" -w $(EXE_DIR)/main.prg \
	 -f "li" -w $(EXE_DIR)/install-c64.prg \
	 \
	 -f "00" -w $(EXE_DIR)/ma00.b2 \
	 -f "01" -w $(EXE_DIR)/ma01.b2 \
	 -f "02" -w $(EXE_DIR)/ma02.b2 \
	 -f "03" -w $(EXE_DIR)/ma03.b2 \
	 -f "04" -w $(EXE_DIR)/ma04.b2 \
	 -f "05" -w $(EXE_DIR)/ma05.b2 \
	 -f "06" -w $(EXE_DIR)/ma06.b2 \
	 -f "07" -w $(EXE_DIR)/ma07.b2 \
	 -f "08" -w $(EXE_DIR)/ma08.b2 \
	 -f "09" -w $(EXE_DIR)/ma09.b2 \
	 -f "0a" -w $(EXE_DIR)/ma0a.b2 \
	 -f "0b" -w $(EXE_DIR)/ma0b.b2 \
	 -f "0c" -w $(EXE_DIR)/ma0c.b2 \
	 -f "0d" -w $(EXE_DIR)/ma0d.b2 \
	 -f "0e" -w $(EXE_DIR)/ma0e.b2 \
	 -f "0f" -w $(EXE_DIR)/ma0f.b2 \
	 -f "10" -w $(EXE_DIR)/ma10.b2 \
	 -f "11" -w $(EXE_DIR)/ma11.b2 \
	 -f "12" -w $(EXE_DIR)/ma12.b2 \
	 -f "13" -w $(EXE_DIR)/ma13.b2 \
	 -f "14" -w $(EXE_DIR)/ma14.b2 \
	 -f "15" -w $(EXE_DIR)/ma15.b2 \
	 -f "16" -w $(EXE_DIR)/ma16.b2 \
	 -f "17" -w $(EXE_DIR)/ma17.b2 \
	 -f "18" -w $(EXE_DIR)/ma18.b2 \
	 -f "19" -w $(EXE_DIR)/ma19.b2 \
	 -f "1a" -w $(EXE_DIR)/ma1a.b2 \
	 -f "1b" -w $(EXE_DIR)/ma1b.b2 \
	 -f "1c" -w $(EXE_DIR)/ma1c.b2 \
	 -f "1d" -w $(EXE_DIR)/ma1d.b2 \
	 -f "1e" -w $(EXE_DIR)/ma1e.b2 \
	 -f "1f" -w $(EXE_DIR)/ma1f.b2 \
	 -f "20" -w $(EXE_DIR)/ma20.b2 \
	 -f "21" -w $(EXE_DIR)/ma21.b2 \
	 -f "22" -w $(EXE_DIR)/ma22.b2 \
	 -f "23" -w $(EXE_DIR)/ma23.b2 \
	 -f "24" -w $(EXE_DIR)/ma24.b2 \
	 -f "25" -w $(EXE_DIR)/ma25.b2 \
	 -f "26" -w $(EXE_DIR)/ma26.b2 \
	 -f "27" -w $(EXE_DIR)/ma27.b2 \
	 -f "28" -w $(EXE_DIR)/ma28.b2 \
	 -f "29" -w $(EXE_DIR)/ma29.b2 \
	 -f "2a" -w $(EXE_DIR)/ma2a.b2 \
	 -f "2b" -w $(EXE_DIR)/ma2b.b2 \
	 -f "2c" -w $(EXE_DIR)/ma2c.b2 \
	 -f "2d" -w $(EXE_DIR)/ma2d.b2 \
	 -f "2e" -w $(EXE_DIR)/ma2e.b2 \
	 -f "2f" -w $(EXE_DIR)/ma2f.b2 \
	 -f "30" -w $(EXE_DIR)/ma30.b2 \
	 -f "31" -w $(EXE_DIR)/ma31.b2 \
	 -f "32" -w $(EXE_DIR)/ma32.b2 \
	 -f "33" -w $(EXE_DIR)/ma33.b2 \
	 -f "t1" -w $(EXE_DIR)/tsbmp1.b2 \
	 -f "t2" -w $(EXE_DIR)/tsbmp10400.b2 \
	 -f "t3" -w $(EXE_DIR)/tsbmp1d800.b2 \
	 -f "t4" -w $(EXE_DIR)/tspointspr.b2 \
	 -f "t5" -w $(EXE_DIR)/tsbkg.b2 \
	 -f "t6" -w $(EXE_DIR)/tshowfar.b2 \
	$(EXE_DIR)/$@
	cat $(EXE_DIR)/loadscreen.map
	cat $(EXE_DIR)/main.map

# -----------------------------------------------------------------------------

tools: specialtiles.exe binsplit.exe addaddr.exe

all: tools main.d64

run: specialtiles.exe binsplit.exe addaddr.exe main.d64
	$(VICE) $(VICEFLAGS) "$(EXE_DIR)/main.d64:scramble 2020"

clean:
	$(RM) $(EXE_DIR)/*.*
	$(RM) $(EXE_DIR)/*
	$(RM) $(LOADER)/loader/build/*.*
	$(RM) $(LOADER)/loader/build/intermediate/*.*
	
# -----------------------------------------------------------------------------
