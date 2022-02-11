#!/bin/bash

function usage {
    echo -e "\e[1mUsage:\e[0m\n\t$0 [-h|-c] [start] [end]\n"
    echo -e "\e[1mOptions:\e[0m"
    echo -e "\t\e[1m-h, --help\e[0m"
    echo -e "\t\tPrint this help message and exit.\n"
    echo -e "\t\e[1m-c, --clean\e[0m"
    echo -e "\t\tClean the project directory. ! Warning ! All data files will be deleted.\n"
    echo -e "\e[1mInformations:\e[0m"
    echo -e "\t[start] and [end] must be strictly positive integer."
    exit 0
}
function clean {
    if [ -d bin ] || [ -d Images ] || [ -d Synthesis ]; then        
        rm -rf bin/ Images/ Synthesis/
        echo "Dossier output supprimé."        
    fi
    exit 0
}
function error_args {
    echo "Veuillez entrer 2 arguments en ligne de commande."
    echo "Exemple : ./syracuse.bash 5 15"
    echo "Executez: ./syracuse.bash --help » pour avoir de l'aide"
    exit 0
}

# $1    data file to collect data
# $2    data file to store data
# $3    U0
function collect_sequence_data {
    head -n-3 $1 | tail -n+2 >> $2 && echo "" >> $2
}
function collect_altitude_max {
    echo "$3 $(tail -n3 $1 | head -n1 | cut -d'=' -f2)" >> $2
}
function collect_flight_time {
    echo "$3 $(tail -n2 $1 | head -n1 | cut -d'=' -f2)" >> $2
}
function collect_altitude_time {
    echo "$3 $(tail -n1 $1 | cut -d'=' -f2)" >> $2
}
function collect_min {
    echo -e "\tmin = $(sort -k2n $1 | sed -n '1p' | cut -d' ' -f2)" >> $2
}
function collect_max {
    echo -e "\tmax = $(sort -k2n $1 | sed -n '$p' | cut -d' ' -f2)" >> $2
}
function collect_average {
    sum=0 && len=$(cat $1 | wc -l) && nums=$(cat $1 | cut -d' ' -f2)
    for i in ${nums[@]}; do
        sum=$((sum + i))   
    done
    avg=$(echo "scale=2; ${sum}/${len}" | bc -l)
    echo -e "\tavg = ${avg}" >> $2
}



# Check options

# Si le nombre d'arguments = 0 ou >2 
if [ $# -eq 0 ] || [ $# -gt 2 ]; then
    error_args
elif [ $# -eq 1 ]; then 
    # Si l'option d'aide ou de nettoyage est appelé
    if [ $1 == "-h" ] || [ $1 == "--help" ]; then
        usage
    elif [ $1 == "-c" ] || [ $1 == "--clean" ]; then
        clean
    fi
fi


isNumber='^[1-9]+[0-9]*$'  #regex pour savoir si c'est un nombre
#on verifie si on a bien 2 arguments et ce sont 2 nombres
if [ $# -eq 2 ] && [[ $1 =~ $isNumber ]] && [[ $2 =~ $isNumber ]]; then
    # Création des répertoires
    mkdir -p bin Images Synthesis
    # compile le programme c si 
    if [ "syracuse.c" -nt "bin/syracuse" ]; then
        gcc syracuse.c -o bin/syracuse
    fi
    for i in $(seq $1 $2); do
        ./bin/syracuse ${i} bin/f${i}.dat
        # Collect data from data files and store them in temporary files
        collect_sequence_data bin/f${i}.dat sequence_data
        collect_altitude_max bin/f${i}.dat altitude_max ${i}
        collect_flight_time bin/f${i}.dat flight_time ${i}
        collect_altitude_time bin/f${i}.dat altitude_time ${i}
    done   
    # Analyze data with gnuplot
    gnuplot -persist <<- EOFMarker
        set terminal jpeg
        set output "Images/vols[$1;$2].dat"
        set title "Un en fonction de n pour tous les U0 dans [$1;$2]"
        set xlabel "n"
        set ylabel "Un"
        plot "sequence_data" w l title "vols.dat"
        reset
        set terminal jpeg
        set output "Images/altitude[$1;$2].dat"
        set title "Altitude maximum atteinte en fonction de U0"
        set xlabel "U0"
        set ylabel "Altitude maximum"
        plot "altitude_max" w l title "altitude.dat"
        reset
        set terminal jpeg
        set output "Images/dureevol[$1;$2].dat"
        set title "Duree de vol en fonction de U0"
        set xlabel "U0"
        set ylabel "Nombres d'occurrences"
        plot "flight_time" w l title "dureevol.dat"
        reset
        set terminal jpeg
        set output "Images/dureealtitude[$1;$2].dat"
        set title "Duree de vol en altitude en fonction de U0"
        set xlabel "U0"
        set ylabel "Nombres d'occurrences"
        plot "altitude_time" w l title "dureealtitude.dat"
EOFMarker
    # Bonus : synthesis of all data
    maxU0=$(sort -k2n sequence_data | sed -n '$p' | cut -d' ' -f2)
    echo -e "Synthese Syracuse [$1;$2]\n" >> Synthesis/synthese-$1-$2.txt
    echo -e "altitude_max:" >> Synthesis/synthese-$1-$2.txt
        collect_min altitude_max Synthesis/synthese-$1-$2.txt
        collect_max altitude_max Synthesis/synthese-$1-$2.txt
        collect_average altitude_max Synthesis/synthese-$1-$2.txt
    echo -e "duree_vol:" >> Synthesis/synthese-$1-$2.txt
        collect_min flight_time Synthesis/synthese-$1-$2.txt
        collect_max flight_time Synthesis/synthese-$1-$2.txt
        collect_average flight_time Synthesis/synthese-$1-$2.txt
    echo -e "duree_altitude:" >> Synthesis/synthese-$1-$2.txt
        collect_min altitude_time Synthesis/synthese-$1-$2.txt
        collect_max altitude_time Synthesis/synthese-$1-$2.txt
        collect_average altitude_time Synthesis/synthese-$1-$2.txt
    # Remove temporary data files 
    rm bin/*.dat && rm sequence_data altitude_max flight_time altitude_time
else
    error_args
fi