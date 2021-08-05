#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(int argc, char* argv[])
{
	FILE *infile, *outfile;
	unsigned char in;

	if(argc < 4)
	{
		printf("\nUsage: addaddr [infile] [outfile] [startaddress]\n");
		exit(1);
	}

	infile = fopen(argv[1], "rb");
	outfile = fopen(argv[2], "wb");
	int start = atoi(argv[3]);

	in = start%256;
	fwrite((const void *) &in, sizeof(unsigned char), 1, outfile);
	in = start/256;
	fwrite((const void *) &in, sizeof(unsigned char), 1, outfile);

	while(fread(&in,sizeof(unsigned char),1,infile))
	{
		fwrite((const void *) &in, sizeof(unsigned char), 1, outfile);
	}

	fclose(outfile);
	fclose(infile);

	return 0;
}

