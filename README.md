# syracuse
Script Bash et programme C permettant de calculer les termes de la conjecture de syracuse ainsi que plusieurs données annexes ( durée de vol, durée en altitude etc .. ) et des visualisations graphiques au format jpeg grâce à gnuplot.

## How to : 

 A la racine du projet, il y a un makefile qui permet de :
1. Executer le programme c avec la commande :
>  make 
2. Nettoyer le fichier executable syracuse avec la commande :
> make clean
3. Nettoyer les fichiers de données .dat avec la commande :
> make mrProper

Il existe également un script bash qui s'éxecute en faisant la commande : 

> ./syracuse.bash [-h|-c] début fin 

où début et fin sont deux entiers positifs et -h et -c sont deux options permettants respectivement d'afficher un message d'aide et de nettoyer l'ensemble des fichiers temporaires créés.

