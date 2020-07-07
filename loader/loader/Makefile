
CD            = cd
ECHO          = echo
MKDIR         = mkdir
TOUCH         = touch
ZIP           = zip -9
ZIPFILE       = loader.zip
SVNVERSION    = svnversion

SHAREDFOLDER  = shared
LOADERFOLDER  = loader
DOCSFOLDER    = $(LOADERFOLDER)/docs
SRCFOLDER     = $(LOADERFOLDER)/src
INCFOLDER     = $(LOADERFOLDER)/include
SAMPLESFOLDER = $(LOADERFOLDER)/samples
BUILDFOLDER   = $(LOADERFOLDER)/build
TOOLSFOLDER   = $(LOADERFOLDER)/tools

ZIPLIST      += $(SHAREDFOLDER)/cpu.inc
ZIPLIST      += $(SHAREDFOLDER)/vic.inc
ZIPLIST      += $(SHAREDFOLDER)/cia.inc
ZIPLIST      += $(SHAREDFOLDER)/kernal.inc
ZIPLIST      += $(SHAREDFOLDER)/basic.inc
ZIPLIST      += $(SHAREDFOLDER)/via.inc
ZIPLIST      += $(SHAREDFOLDER)/float.inc

ZIPLIST      += $(LOADERFOLDER)/Makefile
ZIPLIST      += $(LOADERFOLDER)/version.inc

ZIPLIST      += $(DOCSFOLDER)/Prerequisites.txt
ZIPLIST      += $(DOCSFOLDER)/FastFileFormat.txt
ZIPLIST      += $(DOCSFOLDER)/Protocols.txt
ZIPLIST      += $(DOCSFOLDER)/GCRTiming.txt
ZIPLIST      += $(DOCSFOLDER)/FilenameHashFunction.txt

ZIPLIST      += $(SRCFOLDER)/zp-c64.s
ZIPLIST      += $(SRCFOLDER)/loader.s
ZIPLIST      += $(SRCFOLDER)/install.s
ZIPLIST      += $(SRCFOLDER)/pudecomp.s
ZIPLIST      += $(SRCFOLDER)/lcdecomp.s
ZIPLIST      += $(SRCFOLDER)/bbdecomp.s
ZIPLIST      += $(SRCFOLDER)/exodecomp.s
ZIPLIST      += $(SRCFOLDER)/exostreamdecr1.s
ZIPLIST      += $(SRCFOLDER)/install-jumptable.inc
ZIPLIST      += $(SRCFOLDER)/loader-jumptable.inc
ZIPLIST      += $(SRCFOLDER)/common-features.inc
ZIPLIST      += $(SRCFOLDER)/option-check.inc
ZIPLIST      += $(SRCFOLDER)/loader-kernel1541.inc
ZIPLIST      += $(SRCFOLDER)/drivecode1541.s
ZIPLIST      += $(SRCFOLDER)/drivecode1541-loadfile.s
ZIPLIST      += $(SRCFOLDER)/drivecode1571.s
ZIPLIST      += $(SRCFOLDER)/drivecode1581.s
ZIPLIST      += $(SRCFOLDER)/dynlink.s
ZIPLIST      += $(SRCFOLDER)/debug.s
ZIPLIST      += $(SRCFOLDER)/make-loadersymbolsinc.pl
ZIPLIST      += $(SRCFOLDER)/make-kernelsymbolsinc.pl
ZIPLIST      += $(SRCFOLDER)/Makefile

ZIPLIST      += $(INCFOLDER)/config.inc
ZIPLIST      += $(INCFOLDER)/loader.inc
ZIPLIST      += $(INCFOLDER)/diskio.inc

ZIPLIST      += $(SAMPLESFOLDER)/test.s
ZIPLIST      += $(SAMPLESFOLDER)/zp.inc
ZIPLIST      += $(SAMPLESFOLDER)/sheba.bin
ZIPLIST      += $(SAMPLESFOLDER)/prlogo.bin
ZIPLIST      += $(SAMPLESFOLDER)/Linkfile
ZIPLIST      += $(SAMPLESFOLDER)/Makefile

ZIPLIST      += $(BUILDFOLDER)/loadertest.d64
ZIPLIST      += $(BUILDFOLDER)/loadertest.d71
ZIPLIST      += $(BUILDFOLDER)/loadertest.d81

ZIPLIST      += $(TOOLSFOLDER)/CompressedFileConverter.java
ZIPLIST      += $(TOOLSFOLDER)/CompressedFileConverter.class
ZIPLIST      += $(TOOLSFOLDER)/CRUSH.EXE
ZIPLIST      += $(TOOLSFOLDER)/cc1541_source/cc1541.cpp
ZIPLIST      += $(TOOLSFOLDER)/cc1541_source/filefinder.cpp
ZIPLIST      += $(TOOLSFOLDER)/cc1541_source/XGetOpt.cpp
ZIPLIST      += $(TOOLSFOLDER)/cc1541_source/XGetOpt.h
ZIPLIST      += $(TOOLSFOLDER)/cc1541_source/Makefile


default: loader

loader:
	$(MAKE) -C src

$(BUILDFOLDER)/loadertest.d64 $(BUILDFOLDER)/loadertest.d71 $(BUILDFOLDER)/loadertest.d81:
	$(CD) ..; $(MAKE) -C $(SAMPLESFOLDER) all

zip: $(BUILDFOLDER)/loadertest.d64 $(BUILDFOLDER)/loadertest.d71 $(BUILDFOLDER)/loadertest.d81 version.inc
	$(CD) ..; $(ZIP) $(ZIPFILE) $(ZIPLIST)


.svn/entries:
	$(MKDIR) ./.svn
	$(TOUCH) $@

$(SRCFOLDER)/.svn/entries:
	$(MKDIR) $(SRCFOLDER)/.svn
	$(TOUCH) $@

$(SAMPLESFOLDER)/.svn/entries:
	$(MKDIR) $(SAMPLESFOLDER)/.svn
	$(TOUCH) $@

version.inc: .svn/entries ../$(SRCFOLDER)/.svn/entries ../$(SAMPLESFOLDER)/.svn/entries
	$(ECHO) -n '.define REPOSITORY_VERSION "' > $@
	$(SVNVERSION) | tr -d [:cntrl:] >> $@
	$(ECHO) '"' >> $@
