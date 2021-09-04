#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(int argc, char* argv[])
{
	FILE *infile, *outfile;
	unsigned char in;

	if(argc < 3)
	{
		printf("\nUsage: addaddr [infile] [outfile]\n");
		exit(1);
	}

	infile  = fopen(argv[1], "rb");
	outfile = fopen(argv[2], "wb");

	fseek(infile, 0L, SEEK_END);
	int numbytes = ftell(infile);
	rewind(infile);

	fprintf(outfile, "#define DECRUNCHER_LENGTH %d\n", numbytes + 30);
	fprintf(outfile, "byte decrCode[DECRUNCHER_LENGTH] = {\n");

	fprintf(outfile, "0x0b, 0x08, 0x00, 0x00, ");							// start address
	fprintf(outfile, "0x9e, 0x32, 0x30, 0x36, 0x31, 0x00, 0x00, 0x00, ");	// SYS 2061
	fprintf(outfile, "0x78, ");												// SEI
	fprintf(outfile, "0xa9, 0x34, ");										// LDA #$34
	fprintf(outfile, "0x85,\n0x01, ");										// STA $01
	fprintf(outfile, "0xa2, 0xb7, ");										// LDX #$B7
	fprintf(outfile, "0xbd, 0x1e, 0x08, ");									// LDA $081E,X
	fprintf(outfile, "0x95, 0x0f, ");										// STA $0F,X
	fprintf(outfile, "0xca, ");												// DEX
	fprintf(outfile, "0xd0, 0xf8, ");										// BNE $0814
	fprintf(outfile, "0x4c, 0x10, 0x00, ");									// JMP $0010

	int i = 14;

	while(fread(&in, sizeof(unsigned char), 1, infile))
	{
		fprintf(outfile, "0x%02x, ", in);

		i++;
		if(i%16 == 0)
			fprintf(outfile, "\n");
	}

	fprintf(outfile, "\n};");

	fclose(outfile);
	fclose(infile);

	return 0;
}

