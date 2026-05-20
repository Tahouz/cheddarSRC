/******************************************************************************
 * Programme d'exemple permettant de :
 * - Lire la fréquence du processeur
 * - Accéder à l'instruction RDTSC
 * - Chronométrer très précisément une durée.
 *
 * Ce code est prévu pour fonctionner sous Linux ou sous Windows.
 *
 * ATTENTION: Ce programme ne fonctionne que sur des processeurs compatibles
 * Intel Pentium ou supérieur (à cause de l'instruction RDTSC).
 *
 * CE CODE EST SOUS LICENCE GPL : http://www.fsf.org/licenses/gpl.html
 *
 * Historique :
 * - 8 septembre 2003 : Correction pour Visual C++, ce naze ne sait pas 
 *   convertir des uint64 en double, j'ai fait un ptit hack tout naze ...
 * - 5 septembre 2003 : Portage pour Visual C++
 * - 29 mars 2003     : Création, code pour Linux sous GCC, 
 *                      et Borland C++ Builder sous Windows
 *
 * Par Haypo (victor.stinner@haypocalc.com) - http://www.haypocalc.com/
 *****************************************************************************/

// Visual C++ : Définit _Windows

#include "processor_speed.h"

//---------------------------------------------------------------------------

// Affichage d'une fréquence en utilisant le suffixe adapté (GHz, MHz, KHz, Hz)
void AfficheFrequence (double frequence)
{
  if (1e9<frequence)
    printf ("%.1f GHz\n", frequence/1e9);
  else if (1e6<frequence)
    printf ("%.1f MHz\n", frequence/1e6);
  else if (1e3<frequence)
    printf ("%.1f KHz\n", frequence/1e3);
  else
    printf ("%.1f Hz\n", frequence);
}


//---------------------------------------------------------------------------


// Lit la fréquence du processeur et Renvoie la fréquence en Hz dans 'frequence' si le code de retour est  différent de 1. Renvoie 0 en cas d'erreur.
int LitFrequenceCpu (double* frequence)
{
  int F;
  mode_t mode = S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH;
  char *NOMFICH_CPUINFO= "/home/tp/CHEDDAR/trunk/src/framework/scheduling_anomalies/monano/test1.txt";
  
  // Ouvre le fichier

  
  F = creat(NOMFICH_CPUINFO, mode);
  printf("NOMFICH_CPUINFO = %s, F == %d \n", NOMFICH_CPUINFO, F);
  if (F==-1) {
    printf("impossible de créer le fichier %s \n", NOMFICH_CPUINFO);
  return 0;
  }
  else
  {
    printf("ouverture correct \n");
    return 1;
  }
  
/*  // Lit une ligne apres l'autre
  while (!feof(F))
  {
    // Lit une ligne de texte
    fgets (ligne, sizeof(ligne), F);

    // C'est la ligne contenant la frequence?
    if (!strncmp(ligne, prefixe_cpu_mhz, strlen(prefixe_cpu_mhz)))
    {
      // Oui, alors lit la frequence
      pos = strrchr (ligne, ':') +1;
      printf("pos = %s \n", pos);
      if (!pos) break;
      if (pos[strlen(pos)-1] == '\n') 
	pos[strlen(pos)-1] = '\0';
      strcpy (ligne, pos);
      strcat (ligne,"e6");
      *frequence = atof (ligne);
      ok = 1;
      break;
    }
  }
  fclose (F);
  return ok;*/
}




//---------------------------------------------------------------------------

// Fonction principale
int read_processor_speed()
{
  double frequence;
  int r;

  r = LitFrequenceCpu (&frequence);
  
  return 0;

}
