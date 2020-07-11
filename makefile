MAKE         = make
CP           = cp
MV           = mv
RM           = rm -f

SRC_DIR      = ./src
EXE_DIR      = ./exe
BIN_DIR      = ./bin
PERL_DIR     = ./perl

CPU          = 6502X

AS           = ca65
ASFLAGS      = -g --cpu $(CPU) -U --feature force_range -I ./exe
LD           = ld65
LDFLAGS      = -C Linkfile -Ln $(EXE_DIR)/symbols --dbgfile $(EXE_DIR)/main.dbg
VICE         = "..\..\..\winvice\x64.exe"
VICEFLAGS    = -truedrive -autostart-warp -moncommands $(EXE_DIR)/symbols
C1541        = c1541

LOADER       = ./loader/loader
CC1541       = cc1541

PU           = pucrunch
BB           = B2
LC           = crush 6
CONV         = perl $(PERL_DIR)/compressedfileconverter.pl
BINSPLIT     = $(EXE_DIR)/binsplit.exe
SPECIALTILES = $(EXE_DIR)/specialtiles.exe
ADDADDR      = $(EXE_DIR)/addaddr.exe
GCC          = gcc

.SUFFIXES: .o .s .out .bin .pu .bb .bbconv .lc .lcconv .a

default: all

# -----------------------------------------------------------------------------

$(LOADER)/build/loader-c64.prg:
	;$(MAKE) prg ZP=e8 INSTALL=6000 RESIDENT=ce00

# -----------------------------------------------------------------------------

specialtiles.exe: $(SRC_DIR)/specialtiles.c
	$(GCC) $(SRC_DIR)/specialtiles.c -o $(EXE_DIR)/specialtiles.exe

binsplit.exe: $(SRC_DIR)/binsplit.c
	$(GCC) $(SRC_DIR)/binsplit.c -o $(EXE_DIR)/binsplit.exe

addaddr.exe: $(SRC_DIR)/addaddr.c
	$(GCC) $(SRC_DIR)/addaddr.c -o $(EXE_DIR)/addaddr.exe

loader-c64.prg: $(LOADER)/build/loader-c64.prg
	$(CP) $(LOADER)/build/loader-c64.prg $(EXE_DIR)/.
	
install-c64.prg: $(LOADER)/build/install-c64.prg	
	$(CP) $(LOADER)/build/install-c64.prg $(EXE_DIR)/.

loadersymbols-c64.inc: $(LOADER)/build/loadersymbols-c64.inc
	$(CP) $(LOADER)/build/loadersymbols-c64.inc $(EXE_DIR)/.

main.o: $(SRC_DIR)/main.s Makefile Linkfile loader-c64.prg install-c64.prg mt.out mtc.out loadersymbols-c64.inc
	$(AS) $(ASFLAGS) -o $(EXE_DIR)/$*.o $(SRC_DIR)/$*.s

main_unpacked.prg: main.o loader-c64.prg install-c64.prg loadersymbols-c64.inc
	$(LD) $(LDFLAGS) --mapfile $(EXE_DIR)/main.map -o $(EXE_DIR)/$@ $(EXE_DIR)/main.o

main.prg: main_unpacked.prg
	$(PU) -d -l 0x0800 -x 0x0820 -g 0x37 -i 0 $(EXE_DIR)/$? $(EXE_DIR)/$@

# -----------------------------------------------------------------------------

# Usage: binsplit [type] [add startaddress] [new startaddress] [infile] [outfile] [startaddress] [endaddress]
# type: 0 = relative, 1 = absolute, 2 = same size chunks
# add startaddress: 1 = yes, 0 = no
# new startaddress: 0-65535
# endaddress = -1 = end of file


# wholemap.bin             -> mth.out, mt.out, mtc.out, mtm.out
# mtm.out                  -> mtmmis.out
# mtmmis.out               -> m00.out, m01.out, etc.
# m00.out, m01.out, etc.   -> ma00.out, ma01.out, etc.
# ma00.out, ma01.out, etc. -> ma00.bb, ma01.bb, etc.
# ma00.bb, ma01.bb, etc.   -> ma00.bc, ma01.bc, etc.
# ma00.bc, ma01.bc, etc.   -> 


wholemap.bin: $(BIN_DIR)/wholemap.bin


# REAL TILE DATA
# mth.bin = map tiles header
mth.out: wholemap.bin
	$(BINSPLIT) 1 1 16256 $(BIN_DIR)/wholemap.bin $(EXE_DIR)/mth.out 0 16

# mt.out = map tiles
# $(BINSPLIT) 0 1 57344 wholemap.bin mt.out 0 2
mt.out: wholemap.bin
	$(BINSPLIT) 0 0 0 $(BIN_DIR)/wholemap.bin $(EXE_DIR)/mt.out 0 2

# mtc.out = map tiles chars
# $(BINSPLIT) 0 1 64512 wholemap.bin mtc.out 2 4
mtc.out: wholemap.bin
	$(BINSPLIT) 0 0 0 $(BIN_DIR)/wholemap.bin $(EXE_DIR)/mtc.out 2 4

# mtm.out = map tiles map
mtm.out: wholemap.bin
	$(BINSPLIT) 0 0 0 $(BIN_DIR)/wholemap.bin $(EXE_DIR)/mtm.out 6 -1

#mtmmis.out = map tiles map with missile information in 25th rows
mtmmis.out : mtm.out
	$(SPECIALTILES) $(EXE_DIR)/mtm.out $(EXE_DIR)/mtmmis.out
	$(BINSPLIT) 2 0 0 $(EXE_DIR)/mtmmis.out $(EXE_DIR)/m 0 2000
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
ma30.out ma31.out ma32.out ma33.out : mtmmis.out

# -----------------------------------------------------------------------------

#mth.bc: $(EXE_DIR)/mth.out
#	$(BB) $(EXE_DIR)/mth.out
#	$(MV) $(EXE_DIR)/mth.out.bb $(EXE_DIR)/mth.bb
#	$(CONV) bb 3 $(EXE_DIR)/mth.out $(EXE_DIR)/mth.bb $(EXE_DIR)/mth.bc

%.bb: %.out
	$(BB) $(EXE_DIR)/$*.out
	$(MV) $(EXE_DIR)/$*.out.b2 $(EXE_DIR)/$*.b2

%.bc: %.bb
	cp $(EXE_DIR)/$*.b2 $(EXE_DIR)/$*.bc
	# $(CONV) $(EXE_DIR)/$*.out $(EXE_DIR)/$*.b2 $(EXE_DIR)/$*.bc

#.out.bb:
#	$(BB) $(EXE_DIR)/$*.out
#	$(MV) $(EXE_DIR)/$*.out.bb $(EXE_DIR)/$*.bb

#.bb.bc:
#	$(CONV) bb 3 $(EXE_DIR)/$*.out $(EXE_DIR)/$*.bb $(EXE_DIR)/$*.bc

#.bb.bc: $(EXE_DIR)/$*.bb
#	$(CONV) bb 3 $(EXE_DIR)/$*.out $(EXE_DIR)/$*.bb $(EXE_DIR)/$*.bc

.out.pu:
	$(PU) -c0 $(EXE_DIR)/$*.out $(EXE_DIR)/$*.pu

# -----------------------------------------------------------------------------

	 # -f MH -w mth.bc \
	

main.d64: main.prg \
          mth.out mth.bb mth.bc \
          ma00.bc ma01.bc ma02.bc ma03.bc ma04.bc ma05.bc ma06.bc ma07.bc ma08.bc ma09.bc \
          ma0a.bc ma0b.bc ma0c.bc ma0d.bc ma0e.bc ma0f.bc ma10.bc ma11.bc ma12.bc ma13.bc \
          ma14.bc ma15.bc ma16.bc ma17.bc ma18.bc ma19.bc ma1a.bc ma1b.bc ma1c.bc ma1d.bc \
          ma1e.bc ma1f.bc ma20.bc ma21.bc ma22.bc ma23.bc ma24.bc ma25.bc ma26.bc ma27.bc \
          ma28.bc ma29.bc ma2a.bc ma2b.bc ma2c.bc ma2d.bc ma2e.bc ma2f.bc ma30.bc ma31.bc \
          ma32.bc ma33.bc 
	$(RM) $(EXE_DIR)/$@
	$(CC1541) -n " skramble  2020 " -i "     " -S 8\
	 \
	 -f "skramble 2020" -w $(EXE_DIR)/main.prg \
	 \
	 -f "00" -w $(EXE_DIR)/ma00.bc \
	 -f "01" -w $(EXE_DIR)/ma01.bc \
	 -f "02" -w $(EXE_DIR)/ma02.bc \
	 -f "03" -w $(EXE_DIR)/ma03.bc \
	 -f "04" -w $(EXE_DIR)/ma04.bc \
	 -f "05" -w $(EXE_DIR)/ma05.bc \
	 -f "06" -w $(EXE_DIR)/ma06.bc \
	 -f "07" -w $(EXE_DIR)/ma07.bc \
	 -f "08" -w $(EXE_DIR)/ma08.bc \
	 -f "09" -w $(EXE_DIR)/ma09.bc \
	 -f "0a" -w $(EXE_DIR)/ma0a.bc \
	 -f "0b" -w $(EXE_DIR)/ma0b.bc \
	 -f "0c" -w $(EXE_DIR)/ma0c.bc \
	 -f "0d" -w $(EXE_DIR)/ma0d.bc \
	 -f "0e" -w $(EXE_DIR)/ma0e.bc \
	 -f "0f" -w $(EXE_DIR)/ma0f.bc \
	 -f "10" -w $(EXE_DIR)/ma10.bc \
	 -f "11" -w $(EXE_DIR)/ma11.bc \
	 -f "12" -w $(EXE_DIR)/ma12.bc \
	 -f "13" -w $(EXE_DIR)/ma13.bc \
	 -f "14" -w $(EXE_DIR)/ma14.bc \
	 -f "15" -w $(EXE_DIR)/ma15.bc \
	 -f "16" -w $(EXE_DIR)/ma16.bc \
	 -f "17" -w $(EXE_DIR)/ma17.bc \
	 -f "18" -w $(EXE_DIR)/ma18.bc \
	 -f "19" -w $(EXE_DIR)/ma19.bc \
	 -f "1a" -w $(EXE_DIR)/ma1a.bc \
	 -f "1b" -w $(EXE_DIR)/ma1b.bc \
	 -f "1c" -w $(EXE_DIR)/ma1c.bc \
	 -f "1d" -w $(EXE_DIR)/ma1d.bc \
	 -f "1e" -w $(EXE_DIR)/ma1e.bc \
	 -f "1f" -w $(EXE_DIR)/ma1f.bc \
	 -f "20" -w $(EXE_DIR)/ma20.bc \
	 -f "21" -w $(EXE_DIR)/ma21.bc \
	 -f "22" -w $(EXE_DIR)/ma22.bc \
	 -f "23" -w $(EXE_DIR)/ma23.bc \
	 -f "24" -w $(EXE_DIR)/ma24.bc \
	 -f "25" -w $(EXE_DIR)/ma25.bc \
	 -f "26" -w $(EXE_DIR)/ma26.bc \
	 -f "27" -w $(EXE_DIR)/ma27.bc \
	 -f "28" -w $(EXE_DIR)/ma28.bc \
	 -f "29" -w $(EXE_DIR)/ma29.bc \
	 -f "2a" -w $(EXE_DIR)/ma2a.bc \
	 -f "2b" -w $(EXE_DIR)/ma2b.bc \
	 -f "2c" -w $(EXE_DIR)/ma2c.bc \
	 -f "2d" -w $(EXE_DIR)/ma2d.bc \
	 -f "2e" -w $(EXE_DIR)/ma2e.bc \
	 -f "2f" -w $(EXE_DIR)/ma2f.bc \
	 -f "30" -w $(EXE_DIR)/ma30.bc \
	 -f "31" -w $(EXE_DIR)/ma31.bc \
	 -f "32" -w $(EXE_DIR)/ma32.bc \
	 -f "33" -w $(EXE_DIR)/ma33.bc \
	$(EXE_DIR)/$@
	cat $(EXE_DIR)/main.map

# -----------------------------------------------------------------------------

tools: specialtiles.exe binsplit.exe addaddr.exe

all: tools main.d64

run: specialtiles.exe binsplit.exe addaddr.exe main.d64
	$(VICE) $(VICEFLAGS) "$(EXE_DIR)/main.d64:skramble 2020"

clean:
	$(RM) $(EXE_DIR)/*.*
	$(RM) $(EXE_DIR)/*
	# $(RM) $(LOADER)/build/*.*
	# $(RM) $(LOADER)/build/intermediate/*.*
	