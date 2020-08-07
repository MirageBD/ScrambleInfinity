MEMORY
{
	ZPRAM:			start=$02, size=$fe, type = rw;
	RAM:			start=$4000, size=$f800;
	OVERLAPPING_RAM:start=$0000, size=$10000;
}

SEGMENTS
{
	MAIN:			load=RAM,	start=$4000;

	LOADBARFONT:	load=RAM, start=$4800;
	LOADBARSCR:		load=RAM, start=$4c00;
	
	LOADER:			load=RAM,	start=$5800, define=yes;

	LOADERINSTALL:	load = RAM,	start = $6000, define = yes; # $6000-$7200
}
