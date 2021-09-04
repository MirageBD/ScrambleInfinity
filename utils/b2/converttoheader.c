#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

int main(int argc, char* argv[])
{
	FILE *decrunchprg, *decrunchinitprg, *headerfile, *decrunchsymbols, *decrunchinitsymbols;
	unsigned char in;
	int address;
	char buf[100];
	int decruncherlength = 0;
	int decrunchinitlength = 0;
	int decrunchinitlooplength = 0;

	if(argc < 6)
	{
		printf("\nUsage: converttoheader [decruncher.prg] [decrunchinit.prg] [decruncher.symbols] [decrunchinit.symbols] [output header file]\n");
		exit(1);
	}

	// open all files for reading/writing
	decrunchprg         = fopen(argv[1], "rb");
	decrunchinitprg     = fopen(argv[2], "rb");
	decrunchsymbols     = fopen(argv[3], "r");
	decrunchinitsymbols = fopen(argv[4], "r");
	headerfile          = fopen(argv[5], "wb");

	// get length of decrunch init prg
	fseek(decrunchinitprg, 0L, SEEK_END);
	decrunchinitlength = ftell(decrunchinitprg);
	fprintf(headerfile, "#define decrunchinitlength %d\n\n", decrunchinitlength);
	rewind(decrunchinitprg);

	// get length of decrunch prg, and add the size of the init
	fseek(decrunchprg, 0L, SEEK_END);
	decruncherlength = ftell(decrunchprg);
	fprintf(headerfile, "#define decruncherlength %d\n", decruncherlength + decrunchinitlength);
	rewind(decrunchprg);

	// read all the symbols for the decrunch prg and create defines for them
	while(fscanf(decrunchsymbols, "%s %06x %s\n", buf, &address, buf) == 3)
	{
		fprintf(headerfile, "#define asm_%s %d\n", &(buf[1]), address-16); // 16 is start address of decruncher (0x0010)
	}

	fprintf(headerfile, "\n");

	// read all the symbols for the decrunchinit prg and create defines for them
	int decrunchinitlooplengthfound = 0;
	while(fscanf(decrunchinitsymbols, "%s %06x %s\n", buf, &address, buf) == 3)
	{
		fprintf(headerfile, "#define asm_%s %d\n", &(buf[1]), address-2049); // 2049 is start address of decrunchinit (0x0801)
		if(strcmp(&buf[1], "decruncherlength") == 0)
		{
			decrunchinitlooplength = address-2049+1;	// +1 for ldx #$xx
			decrunchinitlooplengthfound = 1;
		}
	}

	if(decrunchinitlooplengthfound < 1)
		printf("NO DECRUNCHLENGTH SYMBOL FOUND");

	// write decrCode array
	fprintf(headerfile, "\nbyte decrCode[decruncherlength] = {\n");

	// write all bytes for the decrunch init/mover
	int i=0;
	while(fread(&in, sizeof(unsigned char), 1, decrunchinitprg))
	{
		if(i == decrunchinitlooplength)
		fprintf(headerfile, "0x%02x, ", decruncherlength);
			else
		fprintf(headerfile, "0x%02x, ", in);

		i++;
		if(i%16 == 0) fprintf(headerfile, "\n");
	}

	// write all bytes for the decruncher
	i = decrunchinitlength;
	while(fread(&in, sizeof(unsigned char), 1, decrunchprg))
	{
		fprintf(headerfile, "0x%02x, ", in);
		i++;
		if(i%16 == 0) fprintf(headerfile, "\n");
	}

	// close all files
	fprintf(headerfile, "\n};");
	fclose(decrunchprg);
	fclose(decrunchinitprg);
	fclose(decrunchsymbols);
	fclose(decrunchinitsymbols);
	fclose(headerfile);

	return 0;
}
