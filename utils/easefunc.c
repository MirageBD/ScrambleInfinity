#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdbool.h>

#define columns 16

// Easing functions from https://easings.net/

double EaseInSine(double x)		{ return 1.0f - cos((x * M_PI) / 2);	}
double EaseOutSine(double x)	{ return sin((x * M_PI) / 2);			}
double EaseInCubic(double x)	{ return x * x * x;						}
double EaseOutCubic(double x)	{ return 1.0f - pow(1.0f - x, 3);		}

double EaseInElastic(double x)	{ const double c4 = (2 * M_PI) / 3; return x == 0 ? 0 : x == 1 ? 1 : -pow(2,  10 * x - 10) * sin((x * 10 - 10.75) * c4);     }
double EaseOutElastic(double x) { const double c4 = (2 * M_PI) / 3; return x == 0 ? 0 : x == 1 ? 1 :  pow(2, -10 * x     ) * sin((x * 10 -  0.75) * c4) + 1; }

int main(int argc, char* argv[])
{
	if(argc < 5)
	{
		printf("\nUsage: easefunc start end period type\n");
		printf("type 0 = easeInSine\n");
		printf("type 1 = easeOutSine\n");
		printf("type 2 = EaseInCubic\n");
		printf("type 3 = EaseOutCubic\n");
		printf("type 4 = EaseInElastic\n");
		printf("type 5 = EaseOutElastic\n");
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

		switch (type)
		{
			case 0: easetab[i] = (int)(start + size * EaseInSine(x)); break;
			case 1: easetab[i] = (int)(start + size * EaseOutSine(x)); break;
			case 2: easetab[i] = (int)(start + size * EaseInCubic(x)); break;
			case 3: easetab[i] = (int)(start + size * EaseOutCubic(x)); break;
			case 4: easetab[i] = (int)(start + size * EaseInElastic(x)); break;
			case 5: easetab[i] = (int)(start + size * EaseOutElastic(x)); break;
			default: break;
		}
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

