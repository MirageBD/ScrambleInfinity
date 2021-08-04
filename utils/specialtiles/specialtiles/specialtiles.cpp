// project->properties->Configuration Properties->c/C++->Preprocessor->Preprocessor Definitions-> add ;_CRT_SECURE_NO_DEPRECATE

#include "stdafx.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(int argc, char* argv[])
{
	FILE *infile, *outfile;
	unsigned char in1, in2, row, missilefound, missileposition;

	if(argc < 3)
	{
		printf("\nUsage: specialtiles [infile] [outfile]\n");
		exit(1);
	}

	infile = fopen(argv[1], "rb");
	outfile = fopen(argv[2], "wb");

	while(!feof(infile))
	{
		missilefound = 0;
		missileposition = 0;
		for(row = 0; row < 24; row++)
		{
			fread(&in1,sizeof(unsigned char),1,infile);
			fread(&in2,sizeof(unsigned char),1,infile);
			fwrite((const void *) &in1, sizeof(unsigned char), 1, outfile);
			fwrite((const void *) &in2, sizeof(unsigned char), 1, outfile);
			if(in1 == 0 && (in2 == 0 || in2 == 16))
			{
				missilefound = (unsigned char)1;
				missileposition = (unsigned char)row;
			}
		}
		fread(&in1,sizeof(unsigned char),1,infile);
		fread(&in2,sizeof(unsigned char),1,infile);
		fwrite((const void *) &missilefound, sizeof(unsigned char), 1, outfile);
		fwrite((const void *) &missileposition, sizeof(unsigned char), 1, outfile);
	}

	fclose(outfile);
	fclose(infile);

	return 0;
}

