
; XXX TODO move this file to /include

.ifndef _OPTION_CHECK_INC_
_OPTION_CHECK_INC_ = 1

.if ((DECOMPRESSOR <> DECOMPRESSORS::STREAM) && (DECOMPRESSOR <> DECOMPRESSORS::NONE))
    HAS_DECOMPRESSOR = 1
.else
    HAS_DECOMPRESSOR = 0
.endif


.if LOAD_VIA_KERNAL_FALLBACK && (FILESYSTEM <> FILESYSTEMS::DIRECTORY_NAME) && (FILESYSTEM <> FILESYSTEMS::DIRECTORY_INDEX)
    .error "***** Option LOAD_VIA_KERNAL_FALLBACK requires FILESYSTEM = FILESYSTEMS::DIRECTORY_NAME or FILESYSTEM = FILESYSTEMS::DIRECTORY_INDEX *****"
.endif

.if LOAD_ONCE && (FILESYSTEM <> FILESYSTEMS::DIRECTORY_NAME)
    .error "***** Option LOAD_ONCE requires FILESYSTEM = FILESYSTEMS::DIRECTORY_NAME *****"
.endif


.if LOAD_COMPD_API && (!HAS_DECOMPRESSOR)
    .error "***** Option LOAD_COMPD_API requires (DECOMPRESSOR != DECOMPRESSORS::STREAM) && (DECOMPRESSOR != DECOMPRESSORS::NONE) *****"
.endif

.if CHAINED_COMPD_FILES && (!HAS_DECOMPRESSOR)
    .error "***** Option CHAINED_COMPD_FILES requires (DECOMPRESSOR != DECOMPRESSORS::STREAM) && (DECOMPRESSOR != DECOMPRESSORS::NONE) *****"
.endif

.if MEM_DECOMP_API && (!HAS_DECOMPRESSOR)
    .error "***** Option MEM_DECOMP_API requires (DECOMPRESSOR != DECOMPRESSORS::STREAM) && (DECOMPRESSOR != DECOMPRESSORS::NONE) *****"
.endif

.if MEM_DECOMP_TO_API && (!MEM_DECOMP_API)
    .error "***** Option MEM_DECOMP_TO_API requires MEM_DECOMP_API *****"
.endif

.if HAS_DECOMPRESSOR && (!LOAD_COMPD_API) && (!MEM_DECOMP_API)
    .error "***** Decompressor included but not used, as neither LOAD_COMPD_API nor MEM_DECOMP_API are enabled *****"
.endif


.if (!LOAD_UNCOMPD_API) && (!LOAD_COMPD_API) && (!OPEN_FILE_POLL_BLOCK_API) && (!NONBLOCKING_API)
    .error "***** No actual loading calls enabled, please select LOAD_UNCOMPD_API, LOAD_COMPD_API, OPEN_FILE_POLL_BLOCK_API, and/or NONBLOCKING_API *****"
.endif

.if (LOAD_ONCE && LOAD_UNCOMPD_API && LOAD_COMPD_API)
    .error "***** LOAD_ONCE and both LOAD_UNCOMPD_API and LOAD_COMPD_API selected, please select only one loading API *****"
.endif

.if (LOAD_ONCE && OPEN_FILE_POLL_BLOCK_API && LOAD_COMPD_API)
    .error "***** LOAD_ONCE and both OPEN_FILE_POLL_BLOCK_API and LOAD_COMPD_API selected, please select only one loading API *****"
.endif

.if UNINSTALL_RUNS_DINSTALL && (!UNINSTALL_API)
    .error "***** UNINSTALL_RUNS_DINSTALL requires UNINSTALL_API *****"
.endif

.endif; _OPTION_CHECK_INC_