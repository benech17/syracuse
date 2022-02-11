#!/bin/bash

#option -h,--help
function print_help {
    echo "Exemple d'execution:"
    echo "          $0 [-h|-c] [début] [fin]"
    echo "          où debut et fin doivent être des entiers positifs"
    echo "Options:"
    echo "          -h,--help : affiche une aide descriptive d'utilisation."
    echo "          -c,--clean: Supprime les dossiers générés d'output"
    exit 0
}

#option -c,--clean
function clean {
    if [ -d bin ] || [ -d Images ] || [ -d synthese ]; then        
        rm -rf bin/ Images/ Synthese/
        echo "Dossier output supprimé."        
    fi
    exit 0
}

#print message d'erreur si il n'y a pas les bons arguments
function erreur_parametres {
    echo "Veuillez entrer 2 arguments en ligne de commande."
    echo "Exemple : ./syracuse.bash 100 500"
    echo "Executez: ./syracuse.bash --help » pour avoir de l'aide"
    exit 0
}

# $1 = fichier fi.dat à explorer | $2 = fichier temporaires où mettre les valeurs calculés pour chaque Un | $3 = U0
function get_sequence {
    head -n-3 $1 | tail -n+2 >> $2 && echo "" >> $2
}

# tail -n3 permet de recuperer les 3 dernieres lignes du fichier .dat puis head -n1, la premiere de ces 3 dernieres lignes, donc on obtient la ligne recherché qu'on délimite par le "=" 
function get_AltiMax {
    echo "$3 $(tail -n3 $1 | head -n1 | cut --delimiter '=' -f2)" >> $2
}

# tail -n2 permet de recuperer les 2 dernieres lignes du fichier .dat puis head -n1, la premiere de ces 2 dernieres lignes, donc on obtient la ligne recherché qu'on délimite par le "=" 
function get_DureeVol {
    echo "$3 $(tail -n2 $1 | head -n1 | cut --delimiter '=' -f2)" >> $2
}

# tail -n1 permet de recuperer la derniere ligne du fichier .dat  donc on obtient la ligne recherché qu'on délimite par le "=" 
function get_DureeAltitude {
    echo "$3 $(tail -n1 $1 | cut --delimiter '=' -f2)" >> $2
}

function get_min {
    echo -e "\tmin = $(sort -k2n $1 | sed -n '1p' | cut --delimiter ' ' -f2)" >> $2
}
function get_max {
    echo -e "\tmax = $(sort -k2n $1 | sed -n '$p' | cut --delimiter ' ' -f2)" >> $2
}
function get_average {
    sum=0 && len=$(cat $1 | wc -l) && nums=$(cat $1 | cut -d' ' -f2)
    for i in ${nums[@]}; do
        sum=$((sum + i))   
    done
    avg=$(echo "scale=2; ${sum}/${len}" | bc -l)
    echo -e "\tavg = ${avg}" >> $2
}


# Fonction principale 

# On verifie que le nombre d'arguments =0 ou >2 
if [ $# -eq 0 ] || [ $# -gt 2 ]; then
    erreur_parametres
elif [ $# -eq 1 ]; then  
    # switch sur les options
    case $1 in
    "-h") print_help;;
    "--help") print_help;;
    "-c") clean;;
    "--clean") clean;;
    esac
fi


isNumber='^[1-9]+[0-9]*$'  #regex pour savoir si c'est un nombre
#on verifie si on a bien 2 arguments et ce sont 2 nombres
if [ $# -eq 2 ] && [[ $1 =~ $isNumber ]] && [[ $2 =~ $isNumber ]]; then
    mkdir --parents bin Images Synthese # Création des répertoires
    gcc syracuse.c -o bin/syracuse       # compile le programme c 

    for i in $(seq $1 $2); do   # boucle entre  début et fin
        ./bin/syracuse ${i} bin/f${i}.dat #execution du programme c 
        # on recupère les données et on les stocke dans des fichiers temporaires
        get_sequence bin/f${i}.dat sequence_data
        get_AltiMax bin/f${i}.dat altitude_max ${i}
        get_DureeVol bin/f${i}.dat flight_time ${i}
        get_DureeAltitude bin/f${i}.dat altitude_time ${i}
    done  

    # visualisation avec gnuplot
    gnuplot -p <<- EOF
        #vols.dat
        set terminal jpeg
        set output "Images/vols[$1;$2].jpeg"
        set title "Un en fonction de n pour tous les U0 dans [$1;$2]"
        set xlabel "n"
        set ylabel "Un"
        plot "sequence_data" with lines title "vols.dat"
        reset

        #altitude.dat
        set terminal jpeg
        set output "Images/altitude[$1;$2].jpeg"
        set title "Altitude maximum atteinte en fonction de Uo"
        set xlabel "Uo"
        set ylabel "Altitude maximum"
        plot "altitude_max" with lines title "altitude.dat"
        reset

        #duréevol.dat
        set terminal jpeg
        set output "Images/dureevol[$1;$2].jpeg"
        set title "Duree de vol en fonction de Uo"
        set xlabel "Uo"
        set ylabel "Nombres d'occurrences"
        plot "flight_time" with lines title "dureevol.dat"
        reset

        #dureealtitude.dat
        set terminal jpeg
        set output "Images/dureealtitude[$1;$2].jpeg"
        set title "Duree de vol en altitude en fonction de Uo"
        set xlabel "Uo"
        set ylabel "Nombres d'occurrences"
        plot "altitude_time" with lines title "dureealtitude.dat"
EOF

    # Synthese
    maxU0=$(sort -k2n sequence_data | sed -n '$p' | cut --delimiter ' ' -f2)
    echo "Synthese Syracuse [$1;$2]" >> Synthese/synthese-$1-$2.txt

    echo "altitude Max :" >> Synthese/synthese-$1-$2.txt
        get_min altitude_max Synthese/synthese-$1-$2.txt
        get_max altitude_max Synthese/synthese-$1-$2.txt
        get_average altitude_max Synthese/synthese-$1-$2.txt

    echo "duree Vol :" >> Synthese/synthese-$1-$2.txt
        get_min flight_time Synthese/synthese-$1-$2.txt
        get_max flight_time Synthese/synthese-$1-$2.txt
        get_average flight_time Synthese/synthese-$1-$2.txt

    echo -e "duree Vol en Altitude:" >> Synthese/synthese-$1-$2.txt
        get_min altitude_time Synthese/synthese-$1-$2.txt
        get_max altitude_time Synthese/synthese-$1-$2.txt
        get_average altitude_time Synthese/synthese-$1-$2.txt

    # Supprime les fichiers temporaires créés
    rm sequence_data altitude_max flight_time altitude_time && rm bin/*.dat
else
    erreur_parametres
fi