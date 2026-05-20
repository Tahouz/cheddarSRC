// CEC 09
// computing IGD for a test result

#define CEC_PF_DATA_DIR "../CEC09Benchmark/testproblemsourcecode0904/pf_data"

#include <stdio.h>
#include <math.h>
#include <stdlib.h>

// sets of form [ p1obj1 p1obj2 ... p2obj1 p2ob2 ... ... pnObj1 pnObj2 .... pnObjm ]

double IGD(double* PF, double* A, int nobjs, int PFsize, int Asize)
{
        int i, j, k;
        double d,min,dis;

        dis=0.0;
        for( i=0; i<PFsize; i++ )
        {
                min = 1.0E200;
                for( j=0; j<Asize; j++ ) 
                {
                        d=0.0;
                        for( k=0; k<nobjs; k++ )
                                d += ( PF[i*nobjs+k] - A[j*nobjs+k] ) * ( PF[i*nobjs+k] - A[j*nobjs+k] );
                        if( d < min ) min = d;
                }
                dis += sqrt(min);
        }
        return dis/(double)(PFsize);
}

double *readSet(char *fdata, int nobjs, int *setSize)
{
	int i, r, size;
	int ok = 1;
	double val, *set, *valp;
	FILE *fp = fopen(fdata, "r");

	size = 0;
	if (!fp) { printf("error reading front in file %s\n", fdata); return (double *)0; }
	ok = 1;
	while (ok == 1) {
		for(i=0; i<nobjs; i++) {
			ok = fscanf(fp, "%lf", &val);
			if (ok != 1) break;
		}
		if (ok != 1) break;
		size++;
	}
	rewind(fp); 

	set = (double *)malloc(nobjs*size*sizeof(double));
	valp = set;
	for(r=0; r<size; r++)
		for(i=0; i<nobjs; i++) 
			fscanf(fp, "%lf", valp++);

	fclose(fp);
	*setSize = size;
	return set;
}

double printSetFP(FILE *fp, double *set, int nobjs, int setSize)
{
	int i, r;

	for(r=0; r<setSize; r++) {
		for(i=0; i<nobjs; i++) {
			fprintf(fp, "%5.5lf ", *set);
			set++;
		}
		fprintf(fp, "\n");
	}
}

#define printSet(set, n, size) printSetFP(stdout, set, n, size) 

// only compute IGD for the moment
// syntax: igd <#objectives> <PF file> <A file>
int main(int argc, char **argv)
{

	if (argc != 4) { printf("syntax: igd <#objectives> <PF file> <A file>\n"); exit(-1); }

	int nobjs = atoi(argv[1]);
	int setsize, pfsize;
	double *pf = readSet(argv[2], nobjs, &pfsize);
	double *set = readSet(argv[3], nobjs, &setsize);

	double igd = IGD(pf, set, nobjs, pfsize, setsize);

	printf("%5.5lf\n", igd);
}




