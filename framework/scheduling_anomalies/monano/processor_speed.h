#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
//#define NOMFICH_CPUINFO "proc/cpuinfo"

///home/tp/CHEDDAR/trunk/src/framework/scheduling_anomalies/monano/

//---------------------------------------------------------------------------

// Affichage d'une fréquence en utilisant le suffixe adapté (GHz, MHz, KHz, Hz)
void AfficheFrequence (double frequence);


//---------------------------------------------------------------------------

// Lit la fréquence du processeur et Renvoie la fréquence en Hz dans 'frequence' si le code de retour est  différent de 1. Renvoie 0 en cas d'erreur.
int LitFrequenceCpu (double* frequence);


//---------------------------------------------------------------------------
int read_processor_speed();
