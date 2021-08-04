// project->properties->Configuration Properties->c/C++->Preprocessor->Preprocessor Definitions-> add ;_CRT_SECURE_NO_DEPRECATE

#include "stdafx.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(int argc, char* argv[])
{
	FILE *infile, *outfile;
	unsigned char in;

	if(argc < 8)
	{
		printf("\nUsage: binsplit [type] [add startaddress] [new startaddress] [infile] [outfile] [startaddress] [endaddress]\n");
		printf("type: 0 = relative, 1 = absolute, 2 = same size chunks\n");
		printf("add startaddress: 1 = yes, 0 = no\n");
		printf("new startaddress: 0-65535\n");
		printf("endaddress = -1 = end of file\n");
		exit(1);
	}

	int type = atoi(argv[1]);
	int addstartaddress = atoi(argv[2]);
	int newstartaddress = atoi(argv[3]);
	int start = atoi(argv[6]);
	int end = atoi(argv[7]);
	int size = end - start;

	infile = fopen(argv[4], "rb");


	if(type == 0)
	{
		unsigned int relativestart;
		unsigned int relativeend;
		unsigned int relativesize;

		fseek(infile, start, SEEK_SET);
		fread(&in,sizeof(unsigned char),1,infile); relativestart = in;
		printf("in = %d - %x\n", in, in);
		fread(&in,sizeof(unsigned char),1,infile); relativestart += in * 256;
		printf("in = %d - %x\n", in, in);

		if(end >= 0)
		{
			fseek(infile, end, SEEK_SET);
			fread(&in,sizeof(unsigned char),1,infile); relativeend = in;
			printf("in = %d - %x\n", in, in);
			fread(&in,sizeof(unsigned char),1,infile); relativeend += in * 256;
			printf("in = %d - %x\n", in, in);
		
			relativesize = relativeend - relativestart;
		}
		else
		{
			relativeend = 99999999;
			relativesize = 99999999;
		}

		printf("relative start address = %d - %x\n", relativestart, relativestart);
		printf("relative end address   = %d - %x\n", relativeend, relativeend);
		printf("relative size          = %d - %x\n", relativesize, relativesize);

		fseek(infile, relativestart, SEEK_SET);

		outfile = fopen(argv[5], "wb");

		if(addstartaddress == 1)
		{
			in = newstartaddress%256;
			fwrite((const void *) &in, sizeof(unsigned char), 1, outfile);
			in = newstartaddress/256;
			fwrite((const void *) &in, sizeof(unsigned char), 1, outfile);
		}
	
		while(fread(&in,sizeof(unsigned char),1,infile) && relativesize-- > 0)
		{
			// printf("%2x ", in);
			fwrite((const void *) &in, sizeof(unsigned char), 1, outfile);
		}

		fclose(outfile);
	}
	else if(type == 1)
	{
		printf("start address = %d - %x\n", start, start);
		printf("end address   = %d - %x\n", end, end);
		printf("size          = %d - %x\n", size, size);

		fseek(infile, start, SEEK_SET);

		outfile = fopen(argv[5], "wb");

		if(addstartaddress == 1)
		{
			in = newstartaddress%256;
			fwrite((const void *) &in, sizeof(unsigned char), 1, outfile);
			in = newstartaddress/256;
			fwrite((const void *) &in, sizeof(unsigned char), 1, outfile);
		}

		while(fread(&in,sizeof(unsigned char),1,infile) && size-- > 0)
		{
			// printf("%2x ", in);
			fwrite((const void *) &in, sizeof(unsigned char), 1, outfile);
		}

		fclose(outfile);
	}
	else if(type == 2)
	{
		char outfilechunk[16];
		int outfilenum = 0;

		printf("start address = %d - %x\n", start, start);
		printf("end address   = %d - %x\n", end, end);
		printf("size          = %d - %x\n", size, size);

		unsigned int chunksize = size;

		fseek(infile, start, SEEK_SET);

		while(!feof(infile))
		{
			sprintf(outfilechunk, "%s%02x.out", argv[5], outfilenum++);

			outfile = fopen(outfilechunk, "wb");

			if(addstartaddress == 1)
			{
				in = newstartaddress%256;
				fwrite((const void *) &in, sizeof(unsigned char), 1, outfile);
				in = newstartaddress/256;
				fwrite((const void *) &in, sizeof(unsigned char), 1, outfile);
			}

			size = chunksize;

			while(size-- > 0)
			{
				if(fread(&in,sizeof(unsigned char),1,infile))
				{
					// printf("%2x ", in);
					fwrite((const void *) &in, sizeof(unsigned char), 1, outfile);
				}
			}

			fclose(outfile);
		}
	}
	else
	{
	}

	fclose(infile);

	return 0;
}

