#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

// Exemple d'execution: ./syracuse n fn.dat
// avec n>0 et fn.dat  le nom du fichier de sortie contenant l'entier n.

// fonction qui vérifie si une chaine de charactère est bien un nombre.
int isNumber(char s[])
{
    for (int i = 0; s[i] != '\0'; i++)
    {
        if (isdigit(s[i]) == 0)
            return 0;
    }
    return 1;
}

int main(int argc, char **argv)
{
    // On vérifie le bon nombre d'arguments
    if (argc != 3)
    {
        printf("Veuillez entrer 2 arguments en ligne de commande.\nExemple : ./syracuse 15 f15.dat\n");
        exit(1);
    }

    int Uo;
    if (isNumber(argv[1]))
    {
        Uo = atoi(argv[1]); // on convertit le 1er argument entrée en ligne de commande dans une variable Uo
    }
    else
    {
        printf("Votre 1er argument ne semble pas être un nombre. Veuillez entrer un entier positif");
        exit(1);
    }
    if (Uo <= 0)
    {
        printf("Argument invalide, veuillez entrer un entier positif.\n");
        exit(1);
    }

    // ouverture du fichier passé en argument en mode écriture
    FILE *pFile = fopen(argv[2], "w");
    if (pFile == NULL) // verifie que le fichier c'est bien créé
    {
        printf("Le fichier semble introuvable. Verifiez votre chemin relatif.");
        exit(1);
    }
    fprintf(pFile, "n Un\n");     // écriture de l'en tete
    fprintf(pFile, "0 %d\n", Uo); // écriture du cas initial

    // initiation des variables à calculer
    int Un = Uo;              // valeur de la suite au terme n
    int altimax = Uo;         // plus grand entier par lequel on passe
    int dureeVol = 0;         // nombre d'etapes avant d'arriver à 1
    int dureeAltitude = 0;    // nombre max de pts consécutifs ayant une valeur >Uo
    int IncrementationDureeAltitude = 1;  //incrémentation, permet d'avoir la plus grande série de durée en altitude
    // conjecture de syracuse
    while (Un != 1) // tant que Un different de 1
    {
        if (Un % 2 == 0) // si Un est pair
        {
            Un = Un / 2;
        }
        else // si Un est impair
        {
            Un = Un * 3 + 1;
        }
        dureeVol++;
        fprintf(pFile, "%d %d\n", dureeVol, Un); // écriture de l'étape n

        // Mis a jour de l'altitude max
        if (Un > altimax)
            altimax = Un;

        // Mis a jour duree en altitude
        if (Un < Uo)
            IncrementationDureeAltitude = 0;
        if (Un > Uo)
            dureeAltitude += IncrementationDureeAltitude;
    }

    // écriture des variables à calculer , altitude max , durée de vol , durée en altitude
    fprintf(pFile, "altimax=%d \ndureevol=%d \ndureealtitude=%d", altimax, dureeVol, dureeAltitude);
    fclose(pFile); // fermeture du fichier
    return 0;
}