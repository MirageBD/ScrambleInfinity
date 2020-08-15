#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdbool.h>

#define columns 16

double EaseInSine(double x)
{
	return 1.0f - cos((x * M_PI) / 2);
}

double EaseOutSine(double x)
{
	return sin((x * M_PI) / 2);
}

int main(int argc, char* argv[])
{
	if(argc < 5)
	{
		printf("\nUsage: easefunc start end period type\n");
		printf("type 0 = easeInSine\n");
		printf("type 1 = easeOutSine\n");
		printf("e.g. easefunc 344 104 64 0\n");
		exit(1);
	}

	double start	= (double)atoi(argv[1]);
	double end		= (double)atoi(argv[2]);
	double size		= end - start;
	int period		= atoi(argv[3]);
	int type		= atoi(argv[4]);

	int* easetab = malloc(sizeof(int) * period);

	for(int i = 0; i < period; i++)
	{
		double x = (double)i / (period-1);

		if (type == 0)
			easetab[i] = (int)(start + size * EaseInSine(x));
		else if (type == 1)
			easetab[i] = (int)(start + size * EaseOutSine(x));
	}

	printf("\neasetablo");
	for (int i = 0; i < period; i++)
	{
		if (i % columns == 0) printf("\n.byte ");
		printf("$%02x", easetab[i] & 0xff);
		if ((i + 1) % columns != 0) printf(",");
	}
	printf("\neasetabhi");
	for (int i = 0; i < period; i++)
	{
		if (i % columns == 0) printf("\n.byte ");
		printf("$%02x", easetab[i] >> 8);
		if ((i + 1) % columns != 0) printf(",");
	}
	printf("\n\n");

	return 0;
}

