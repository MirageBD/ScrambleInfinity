MEMORY
{
	ZPRAM:			start=$02, size=$fe, type = rw;
	RAM:			start=$6000, size=$f800;
	OVERLAPPING_RAM:start=$0000, size=$10000;
}

SEGMENTS
{
	LOADERZP:		load=ZPRAM,	type=zp, define=yes;
	
	LOADERINSTALL:	load = RAM,	start = $6000, define = yes; # $6000-$7200

	LOADER:			load=RAM,	start=$8400, define=yes;

	MAIN:			load=RAM,	start=$9000;
	IRQ:			load=RAM,	align=256;
	CYCLEPERFECT:   load=RAM,	align=256;
}
