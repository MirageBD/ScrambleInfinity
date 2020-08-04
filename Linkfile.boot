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

	MAIN:			load=RAM,	start=$c000;
	IRQ:			load=RAM,	align=256;
	CYCLEPERFECT:   load=RAM,	align=256;

	LOADER:			load=RAM,	start=$c400, define=yes;
	SCREEN:			load = RAM, start = $c400;
}
