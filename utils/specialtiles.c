#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(int argc, char* argv[])
{
	FILE *infile, *outfile;
	unsigned char tileByteHi, tileByteLo;
	unsigned char row;
	unsigned char missilefound, missileposition;

	if(argc < 3)
	{
		printf("\nUsage: specialtiles [infile] [outfile]\n");
		exit(1);
	}

	infile  = fopen(argv[1], "rb");
	outfile = fopen(argv[2], "wb");

	while(!feof(infile)) // Go through all the columns in the giant map file
	{
		missilefound    = 0;
		missileposition = 0;

		for(row = 0; row < 24; row++)
		{
			// Each char contains high and low bytes of the map tile (Currently there are 618 tiles, so that won't fit into 1 byte)

			// Read high and low byte of tile number
			fread(&tileByteHi, sizeof(unsigned char), 1, infile);
			fread(&tileByteLo, sizeof(unsigned char), 1, infile);

			// Write the exact same values
			fwrite((const void *)&tileByteHi, sizeof(unsigned char), 1, outfile);
			fwrite((const void *)&tileByteLo, sizeof(unsigned char), 1, outfile);

			// If a missile is found (tile $0000 (non-cave missile) or $0010 (cave missile) set missile found to true and record the row height
			// Cave missiles don't lift off, so commented that bit out for now.
			if(
				(tileByteHi == 0 && tileByteLo ==  0) /* ||
				(tileByteHi == 0 && tileByteLo == 16) */
			)
			{
				missilefound    = (unsigned char)1;
				missileposition = (unsigned char)row;
			}
		}

		// Dummy read - There is nothing in row 25
		fread(&tileByteHi, sizeof(unsigned char), 1, infile);
		fread(&tileByteLo, sizeof(unsigned char), 1, infile);

		// Write a 0 or 1 depending on if a missile was found to row 25
		fwrite((const void *)&missilefound,    sizeof(unsigned char), 1, outfile);
		// Write the missile row height to row 25
		fwrite((const void *)&missileposition, sizeof(unsigned char), 1, outfile);
	}

	fclose(outfile);
	fclose(infile);

	return 0;
}

