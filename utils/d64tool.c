#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define D64_SIZE 174848
#define D64_FILE_ENTRY_SIZE 32
typedef unsigned char u8;

/*
positions in d64:

  Track #Sect #SectorsIn D64 Offset   Track #Sect #SectorsIn D64 Offset
  ----- ----- ---------- ----------   ----- ----- ---------- ----------
    1     21       0       $00000      21     19     414       $19E00
    2     21      21       $01500      22     19     433       $1B100
    3     21      42       $02A00      23     19     452       $1C400
    4     21      63       $03F00      24     19     471       $1D700
    5     21      84       $05400      25     18     490       $1EA00
    6     21     105       $06900      26     18     508       $1FC00
    7     21     126       $07E00      27     18     526       $20E00
    8     21     147       $09300      28     18     544       $22000
    9     21     168       $0A800      29     18     562       $23200
   10     21     189       $0BD00      30     18     580       $24400
   11     21     210       $0D200      31     17     598       $25600
   12     21     231       $0E700      32     17     615       $26700
   13     21     252       $0FC00      33     17     632       $27800
   14     21     273       $11100      34     17     649       $28900
   15     21     294       $12600      35     17     666       $29A00
   16     21     315       $13B00      36*    17     683       $2AB00
   17     21     336       $15000      37*    17     700       $2BC00
   18     19     357       $16500      38*    17     717       $2CD00
   19     19     376       $17800      39*    17     734       $2DE00
   20     19     395       $18B00      40*    17     751       $2EF00
*/

/*
BAM area (sector 18/0)

    00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
    -----------------------------------------------
00: 12 01 41 00 12 FF F9 17 15 FF FF 1F 15 FF FF 1F
10: 15 FF FF 1F 12 FF F9 17 00 00 00 00 00 00 00 00
20: 00 00 00 00 0E FF 74 03 15 FF FF 1F 15 FF FF 1F
30: 0E 3F FC 11 07 E1 80 01 15 FF FF 1F 15 FF FF 1F
40: 15 FF FF 1F 15 FF FF 1F 0D C0 FF 07 13 FF FF 07
50: 13 FF FF 07 11 FF CF 07 13 FF FF 07 12 7F FF 07
60: 13 FF FF 07 0A 75 55 01 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 01 08 00 00 03 02 48 00
80: 11 FF FF 01 11 FF FF 01 11 FF FF 01 11 FF FF 01
90: 53 48 41 52 45 57 41 52 45 20 31 20 20 A0 A0 A0
A0: A0 A0 56 54 A0 32 41 A0 A0 A0 A0 00 00 00 00 00
B0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
C0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
D0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
E0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
F0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

  Bytes:$00-01: Track/Sector location of the first directory sector (should
                be set to 18/1 but it doesn't matter, and don't trust  what
                is there, always go to 18/1 for first directory entry)
            02: Disk DOS version type (see note below)
                  $41 ("A")
            03: Unused
         04-8F: BAM entries for each track, in groups  of  four  bytes  per
                track, starting on track 1 (see below for more details)
         90-9F: Disk Name (padded with $A0)
         A0-A1: Filled with $A0
         A2-A3: Disk ID
            A4: Usually $A0
         A5-A6: DOS type, usually "2A"
         A7-AA: Filled with $A0
         AB-FF: Normally unused ($00), except for 40 track extended format,
                see the following two entries:
         AC-BF: DOLPHIN DOS track 36-40 BAM entries (only for 40 track)
         C0-D3: SPEED DOS track 36-40 BAM entries (only for 40 track)
*/

/*
Directory entry:

  Bytes: $00-1F: First directory entry
          00-01: Track/Sector location of next directory sector ($00 $00 if
                 not the first entry in the sector)
             02: File type.
                 Typical values for this location are:
                   $00 - Scratched (deleted file entry)
                    80 - DEL
                    81 - SEQ
                    82 - PRG
                    83 - USR
                    84 - REL
                 Bit 0-3: The actual filetype
                          000 (0) - DEL
                          001 (1) - SEQ
                          010 (2) - PRG
                          011 (3) - USR
                          100 (4) - REL
                          Values 5-15 are illegal, but if used will produce
                          very strange results. The 1541 is inconsistent in
                          how it treats these bits. Some routines use all 4
                          bits, others ignore bit 3,  resulting  in  values
                          from 0-7.
                 Bit   4: Not used
                 Bit   5: Used only during SAVE-@ replacement
                 Bit   6: Locked flag (Set produces ">" locked files)
                 Bit   7: Closed flag  (Not  set  produces  "*", or "splat"
                          files)
          03-04: Track/sector location of first sector of file
          05-14: 16 character filename (in PETASCII, padded with $A0)
          15-16: Track/Sector location of first side-sector block (REL file
                 only)
             17: REL file record length (REL file only)
          18-1D: Unused (except with GEOS disks)
          1E-1F: File size in sectors, low/high byte  order  ($1E+$1F*256).
                 The approx. filesize in bytes is <= #sectors * 254
          20-3F: Second dir entry. From now on the first two bytes of  each
                 entry in this sector  should  be  $00  $00,  as  they  are
                 unused.
          40-5F: Third dir entry
          60-7F: Fourth dir entry
          80-9F: Fifth dir entry
          A0-BF: Sixth dir entry
          C0-DF: Seventh dir entry
          E0-FF: Eighth dir entry

  // directory chain. normally: 0 (BAM), 1, 4, 7, 10, 13, 16, 2, 5, 8, 11, 14, 17, 3, 6, 9, 12, 15, 18.

  // 16500 -> 16600 -> 16900 -> 16c00 -> 16f00 -> 17200 -> 

*/

static const int TrackOffsets[] =
{
	0x00000, 0x01500, 0x02A00, 0x03F00, 0x05400, 0x06900, 0x07E00, 0x09300,						// $1500 / 256 = 21 sectors per track
	0x0A800, 0x0BD00, 0x0D200, 0x0E700, 0x0FC00, 0x11100, 0x12600, 0x13B00,						// 17 tracks * 21 = 357
	0x15000,

	// track 18
	0x16500, 0x17800, 0x18B00, 0x19E00, 0x1B100, 0x1C400, 0x1D700,								// $1300 / 256 = 19 sectors per track
																								// 7 tracks * 19 = 133

	0x1EA00, 0x1FC00, 0x20E00, 0x22000, 0x23200, 0x24400,										// $1200 / 256 = 18 sectors per track
																								// 6 tracks * 18 = 108

	0x25600, 0x26700, 0x27800, 0x28900, 0x29A00,												// $1100 / 256 = 17 sectors per track
																								// 5 tracks * 17 = 85
	// end of track 35

	0x2AB00, 0x2BC00, 0x2CD00, 0x2DE00, 0x2EF00													// $1100 / 256 = 17 sectors per track
																								// 5 tracks * 17 = 85

};

// 357 + 133 + 108 + 85			= 683 sectors on a 35 track disk		683*256 = 174,848		174,848/1024 = 171KB		174,848/256 = 683 blocks (-19 for directory = 664 blocks/sectors free)
// 357 + 133 + 108 + 85 + 85	= 768 sectors on a 40 track disk		768*256 = 196,608		196,608/1024 = 192KB


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// REAL directory (0x16500) with dir-art:

// 0 "________________" _____
// 1    "----scramble----" prg<
// 0    " ---        --- " prg
// 0    " |            | " prg
// 0    " --          -- " prg
// 0    "  |          |  " prg
// 0    "  --infinity--  " prg
// 0    "                " prg
// 624 blocks free.
// ready.

// 16600:
//		 fl tr sc                                                 .. .. .. xx xx xx xx xx xx fs fs
//		 tp lc lc                                                 .. .. .. xx xx xx xx xx xx lo hi
// 12 04 00 00 00 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 00 00 00 00 00 00 00 00 00 00 00
// 00 00 C2 01 00 60 60 60 69 53 43 52 41 4D 42 4C 45 75 60 60 60 00 00 00 00 00 00 00 00 00 01 00
// 00 00 00 00 00 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 00 00 00 00 00 00 00 00 00 00 00		xxxxxxxxxxxxxxxxxx		byte $02/$03 is $00 - Scratched (deleted file entry)
// 00 00 82 00 00 20 75 60 6B 20 20 20 20 20 20 20 20 6A 60 69 20 00 00 00 00 00 00 00 00 00 00 00
// 00 00 82 00 00 20 7D 20 20 20 75 69 2E 20 20 2E 20 20 20 7D 20 00 00 00 00 00 00 00 00 00 00 00
// 00 00 82 00 00 20 6A AE B0 69 7D 6A AE B0 69 B0 7B 69 75 6B 20 00 00 00 00 00 00 00 00 00 00 00
// 00 00 00 00 00 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 00 00 00 00 00 00 00 00 00 00 00      xxxxxxxxxxxxxxxxxx
// 00 00 82 00 00 20 20 7D 7D 6A BD 20 6A BD 6A 6B 6A 6A B3 20 20 00 00 00 00 00 00 00 00 00 00 00

// 12 04 C2 01 00 60 60 60 69 53 43 52 41 4D 42 4C 45 75 60 60 60 00 00 00 00 00 00 00 00 00 01 00		"----scramble----"
// 00 00 82 00 00 20 75 60 6B 20 20 20 20 20 20 20 20 6A 60 69 20 00 00 00 00 00 00 00 00 00 00 00		" ---        --- "
// 00 00 82 00 00 20 7D 20 20 20 75 69 2E 20 20 2E 20 20 20 7D 20 00 00 00 00 00 00 00 00 00 00 00		" |            | "
// 00 00 82 00 00 20 6A AE B0 69 7D 6A AE B0 69 B0 7B 69 75 6B 20 00 00 00 00 00 00 00 00 00 00 00		" --          -- "
// 00 00 82 00 00 20 20 7D 7D 6A BD 20 6A BD 6A 6B 6A 6A B3 20 20 00 00 00 00 00 00 00 00 00 00 00		"  |          |  "
// 00 00 82 00 00 20 20 6A 6B 49 4E 46 49 4E 49 54 59 6A 6B 20 20 00 00 00 00 00 00 00 00 00 00 00		"  --infinity--  "
// 00 00 82 00 00 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 00 00 00 00 00 00 00 00 00 00 00		"                "
// 00 00 00 00 00 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 A0 00 00 00 00 00 00 00 00 00 00 00


// 12 01 41 00

// 35 tracks:
// 00 00 00 00															TRACK 1: completely full: 00 00000000 00000000 00000000
// 0B AA EA 0A															TRACK 2: 11 free sectors: 0B 10101010 11101010 00001010 -> 01010101 01010111 01010000
// 15 FF FF 1F		15 FF FF 1F
// 15 FF FF 1F		15 FF FF 1F		15 FF FF 1F		15 FF FF 1F
// 15 FF FF 1F		15 FF FF 1F		15 FF FF 1F		15 FF FF 1F
// 15 FF FF 1F		15 FF FF 1F		15 FF FF 1F		15 FF FF 1F
// 15 FF FF 1F		0A 24 DB 06		0A 24 DB 06		13 FF FF 07
// 13 FF FF 07		13 FF FF 07		13 FF FF 07		13 FF FF 07
// 12 FF FF 03		12 FF FF 03		12 FF FF 03		12 FF FF 03
// 12 FF FF 03		12 FF FF 03		11 FF FF 01		11 FF FF 01
// 11 FF FF 01		11 FF FF 01		11 FF FF 01

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// SHADOW directory (0x17800) with real filenames:

// 13 01 41 00 -> #$13 (19!) = track of first directory!

// 35 tracks:
// 15 FF FF 1F		15 FF FF 1F		15 FF FF 1F		15 FF FF 1F			FFFF1F = 11111111 11111111 00011111
// 15 FF FF 1F		15 FF FF 1F		15 FF FF 1F		15 FF FF 1F
// 15 FF FF 1F		15 FF FF 1F		15 FF FF 1F		15 FF FF 1F
// 15 FF FF 1F		15 FF FF 1F		15 FF FF 1F		15 FF FF 1F
// 15 FF FF 1F
// track 18:		11 FC FF 07											FCFF07 = 11111100 11111111 00000111
// track 19:		11 FC FF 07
// 13 FF FF 07
// 13 FF FF 07		13 FF FF 07		13 FF FF 07		13 FF FF 07
// 12 FF FF 03		12 FF FF 03		12 FF FF 03		12 FF FF 03
// 12 FF FF 03		12 FF FF 03		11 FF FF 01		11 FF FF 01
// 11 FF FF 01		11 FF FF 01		11 FF FF 01

// 20 20 20 20 53 43 52 41 4D 42 4C 45 20 20 20 20 ....SCRAMBLE....
// A0 A0 20 20 20 20 20 A0 A0 A0 A0 00 00 00 00 00 aa22222aaaa00000

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

static const char* filetypes[] =
{
	"DEL", "SEQ", "PRG", "USR", "REL", "???", "???", "???"
};

int d64sector(u8 track, u8 sector)
{
	return TrackOffsets[track-1] + 256 * (int)sector;
}

void printfile(u8* file)
{
	u8 type = file[2];	
	char name[17];
	for(int n = 0; n<16; ++n)
	{
		name[n] = file[n + 5] == 0xa0 ? '.' : file[n + 5];
	}
	name[16] = 0;

	printf("\"%s\" %s\n", name, filetypes[type & 7]);
}

int filecount(u8* d64, int list)
{
	int numfiles = 0;
	u8* curr = d64 + d64sector(18, 0);

	while(curr[0])
	{
		curr = d64 + d64sector(curr[0], curr[1]);
		u8* file = curr;

		while((file - curr) < 256)
		{
			if(file[2] != 0)	// type == 0 => "deleted"
			{
				if(list)
				{
					printfile(file);
				}

				++numfiles;
			}

			file += D64_FILE_ENTRY_SIZE;
		}
	}
	return numfiles;
}

u8* dirmerge(u8* data, u8* artdir, int skip, int list, int append, int firstindex, int shadowdirtrack)
{
	if(list)
	{
		printf("\nFILES IN DATA:\n");
	}

	int datafilecount = filecount(data, list);

	if(list)
	{
		printf("\nFILES IN DIR:\n");
	}

	int artdirfilecount = filecount(artdir, list);

	printf("Number of files in data d64   : %d\n", datafilecount);
	printf("Number of files in art dir d64: %d\n", artdirfilecount);

	if((datafilecount + skip) > artdirfilecount)
	{
		printf("Error: files in data d64 plus files to skip exceeds the number of files in the art dir d64.\n");
		return 0;
	}

	// allocate a d64 for the output
	u8* out = (u8*)malloc(D64_SIZE);
	if(out == 0)
	{
		return out;
	}

	// all the data on the disk comes from the data d64
	memcpy(out, data, D64_SIZE);

	// the folder structure comes from the artdir d64
	// copy disk name and dos type
	int diskNameOffset = d64sector(18, 0) + 0x90;
	memcpy(out + diskNameOffset, artdir + diskNameOffset, 0xab-0x90);

	// copy track 18 from artdir to out
	memcpy(out + d64sector(18, 1), artdir + d64sector(18, 1), d64sector(19, 0) - d64sector(18, 1));

	// use the BAM for the directory sector from the art directory disk
	int BAMoffs = d64sector(18, 0) + (18-1) * 4 + 4;
	memcpy(out + BAMoffs, artdir + BAMoffs, 4);

	// copy file type, disk location, file name prefix from the data disk
	int currfile     = 0;
	u8* data_file    = 0;
	u8* artdir_file  = 0;
	u8* data_curr    = data   + d64sector(18, 0);
	u8* artdir_curr  = artdir + d64sector(18, 0);

	int data_files_left = datafilecount;
	(void)firstindex;

	if(list)
	{
		printf("\nFILES IN OUTPUT D64:\n");
	}

	// only update files from the data directory
	int first = firstindex + 1;
	while(currfile < artdirfilecount)
	{
		if(data_files_left)
		{
			if(!skip || first)
			{
				for(;;)
				{
					// grab the next data file
					if(!data_file || (data_file - data_curr) >= 0x100)
					{
						data_curr = data + d64sector(data_curr[0], data_curr[1]);
						data_file = data_curr;
						break;
					}

					data_file += D64_FILE_ENTRY_SIZE;

					if((data_file - data_curr) < 0x100 && data_file[2])
					{
						break;
					}
				}

				data_files_left--;
			}
		}
		else
		{
			data_file = 0;
		}

		for(;;)
		{
			// grab the next art directory file
			if(!artdir_file || (artdir_file - artdir_curr) >= 0x100)
			{
				artdir_curr = artdir + d64sector(artdir_curr[0], artdir_curr[1]);
				artdir_file = artdir_curr;
				break;
			}

			artdir_file += D64_FILE_ENTRY_SIZE;

			if((artdir_file - artdir_curr) < 0x100 && artdir_file[2])
			{
				break;
			}
		}

		// the out file is relative to the art dir d64
		u8* out_file = out + (artdir_file - artdir);

		if(data_file && (!skip || first==1))
		{
			if(append)
			{
				int shift = 0;

				for(int i=0; i<16 && data_file[5+i] != 0xa0 && (artdir_file[20-i] & 0x7f) == 0x20; i++)
				{
					shift++;
				}
				
				if(shift && shift<16)
				{
					memcpy(out_file + 5 + shift, artdir_file + 5, 16-shift);
				}
			}

			// copy the file info from the data file into the out file
			memcpy(out_file+2,  data_file+2,  3);
			memcpy(out_file+21, data_file+21, 11);

			if(first == 1)
			{
				memcpy(out_file+5, data_file+5, 16);
			}

			// first filename entirely from art dir disk
			if(currfile && !first)
			{
				for(int i=5; i<21 && data_file[i] != 0xa0; ++i)
				{
					out_file[i] = data_file[i];
				}
			}
		}
		else
		{
			out_file[2] = 0x80; // make sure remaining files are all DEL
			out_file[3] = 0x00;
			out_file[4] = 0x00;
			memset(out_file+21, 0, 11);
		}

		if(list)
		{
			printfile(out_file);
		}

		++currfile;

		if(skip)
		{
			--skip;
		}

		if(first)
		{
			--first;
		}
	}

	return out;
}

void* load(const char* filename, size_t* size_ret)
{
	FILE* f = fopen(filename, "rb");

	if(f)
	{
		fseek(f, 0, SEEK_END);
		size_t size = ftell(f);
		fseek(f, 0, SEEK_SET);

		void* buf = malloc(size);
		if(buf)
		{
			fread(buf, size, 1, f);
			if(size_ret)
			{
				*size_ret = size;
			}
		}
		fclose(f);

		return buf;
	}

	return 0;
}

int save(void* buf, const char* filename, size_t size)
{
	FILE* f = fopen(filename, "wb");

	if(f)
	{
		fwrite(buf, size, 1, f);
		fclose(f);
		return 0;
	}

	return 1;
}

int main(int argc, char* argv[])
{
	int			skip			= 0;
	int			list			= 0;
	int			append			= 0;
	int			first			= 0;
	int			shadowdirtrack	= 0;
	const char*	data			= 0;
	const char*	artdir			= 0;
	const char*	out				= 0;

	for(int i = 1; i < argc; ++i)
	{
		if(argv[i][0] == '-')
		{
			const char* cmd = argv[i]+1;
			const char* eq = strchr(cmd, '=');
			size_t len = eq ? (eq - cmd) : strlen(cmd);

			if(strncmp("skip", cmd, len) == 0 && eq)
			{
				skip = atoi(eq+1);
			}
			else if(strncmp("first", cmd, len) == 0 && eq)
			{
				first = atoi(eq+1);
			}
			else if(strncmp("list", cmd, len) == 0)
			{
				list = 1;
			}
			else if(strncmp("append", cmd, len) == 0)
			{
				append = eq ? atoi(eq+1) : 1;
			}
			else if(strncmp("shadowdir", cmd, len) == 0)
			{
				shadowdirtrack = eq ? atoi(eq+1) : 18;
			}
		}
		else if(!data)
		{
			data = argv[i];
		}
		else if(!artdir)
		{
			artdir  = argv[i];
		}
		else if(!out)
		{
			out  = argv[i];
		}
		else
		{
			printf("Too many file arguments passed in\n");
			return 1;
		}
	}

	if(!data || !artdir || !out)
	{
		printf("\n");
		printf("Usage: d64tool [-skip=x] [-first=x] [-shadowdirtrack=x] [-append] [-list] <data.d64> <artdir.d64> <out.d64>\n");
		printf("\n");
		printf("    Arguments:\n");
		printf("        -skip=n              Don't assign data files to directory n files after the first entry\n");
		printf("        -first=n             Set first file at index n\n");
		printf("        -shadowdirtrack=n    Set shadow directory at track n\n");
		printf("        -list                Show directory of data, dir and result\n");
		printf("        -append              Append dir name after data name instead of overwriting initial part of dir name with data name\n");
		printf("        -chain               Print the track/sector sequence for the directory and each file.\n");
		printf("\n");
		printf("    Notes:\n");
		printf("        .d64 files all need different names\n");
		printf("        .d64 dir should have more files than d64 data.\n");
		printf("\n");

		return 0;
	}

	printf("- Files names from \"%s\" will be padded with corresponding file names from \"%s\"\n", data, artdir);
	printf("  and saved out as a new disk named \"%s\".\n", out);
	printf("- Put first file in target index %d.\n", first);
	printf("- Shadow directory is at track %d.\n", shadowdirtrack);

	size_t data_size, dir_size;

	u8* data_d64   = (u8*)load(data,   &data_size);
	u8* artdir_d64 = (u8*)load(artdir, &dir_size);
	u8* out_d64    = 0;

	int ret = 0;

	if(data_d64 && artdir_d64 && data_size == D64_SIZE && dir_size == D64_SIZE)
	{
		out_d64 = dirmerge(data_d64, artdir_d64, skip, list, append, first, shadowdirtrack);

		if(!out_d64)
		{
			ret = 1;
		}
		else
		{
			ret = save(out_d64, out, D64_SIZE);
		}
	}
	else if(!data_d64)
	{
		printf("Failed to open data disk file \"%s\"\n", data);
		ret = 1;
	}
	else if(!artdir_d64)
	{
		printf("Failed to open directory disk file \"%s\"\n", artdir);
		ret = 1;
	}
	else if(data_size != D64_SIZE)
	{
		printf("Data d64 file \"%s\" is not a standard size (%d bytes)\n", data, D64_SIZE);
		ret = 1;
	}
	else if(data_size != D64_SIZE)
	{
		printf("Directory d64 file \"%s\" is not a standard size (%d bytes)\n", artdir, D64_SIZE);
		ret = 1;
	}

	if(data_d64)   { free(data_d64  ); }
	if(artdir_d64) { free(artdir_d64); }
	if(out_d64)    { free(out_d64   ); }

	return out_d64 ? 0 : 1;
}
