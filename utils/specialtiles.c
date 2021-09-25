#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(int argc, char* argv[])
{
	FILE *infile, *outfile;
	unsigned char tileByteHi, tileByteLo;
	unsigned char row;
	unsigned char missileFound, missilePosition;
	unsigned int column;

	unsigned int firstSolidTileColumn = 75;
	unsigned char clearTileHi = 0;
	unsigned char clearTileLo = 33;		// 33 is transparent/black, 32 is blue

	if(argc < 3)
	{
		printf("\nUsage: specialtiles [infile] [outfile]\n");
		exit(1);
	}

	infile  = fopen(argv[1], "rb");
	outfile = fopen(argv[2], "wb");

	column = 0;

	while(!feof(infile)) // Go through all the columns in the giant map file
	{
		missileFound    = 0;
		missilePosition = 0;

		for(row = 0; row < 24; row++)
		{
			// Each char contains high and low bytes of the map tile (Currently there are 618 tiles, so that won't fit into 1 byte)

			// Read high and low byte of tile number
			fread(&tileByteLo, sizeof(unsigned char), 1, infile);
			fread(&tileByteHi, sizeof(unsigned char), 1, infile);

			if(row == 0 && column < firstSolidTileColumn)
			{
				// While we're at it, clear tiles used for index reordering
				fwrite((const void *)&clearTileLo, sizeof(unsigned char), 1, outfile);
				fwrite((const void *)&clearTileHi, sizeof(unsigned char), 1, outfile);
			}
			else
			{
				// Write the exact same values
				fwrite((const void *)&tileByteLo, sizeof(unsigned char), 1, outfile);
				fwrite((const void *)&tileByteHi, sizeof(unsigned char), 1, outfile);
			}

			// If a missile is found (tile $0000 (non-cave missile) or $0010 (cave missile) set missile found to true and record the row height
			// Cave missiles don't lift off, so commented that bit out for now.
			if(
				(tileByteHi == 0 && tileByteLo ==  0) /* ||
				(tileByteHi == 0 && tileByteLo == 16) */
			)
			{
				missileFound    = (unsigned char)1;
				missilePosition = (unsigned char)row;
			}
		}

		// Dummy read - There is nothing in row 25
		fread(&tileByteLo, sizeof(unsigned char), 1, infile);
		fread(&tileByteHi, sizeof(unsigned char), 1, infile);

		// Write a 0 or 1 depending on if a missile was found to row 25
		fwrite((const void *)&missileFound,    sizeof(unsigned char), 1, outfile);
		// Write the missile row height to row 25
		fwrite((const void *)&missilePosition, sizeof(unsigned char), 1, outfile);

		column++;
	}

	fclose(outfile);
	fclose(infile);

	return 0;
}

