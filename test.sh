while getopts hvf:q OPT; do

    case $OPT in

        h) pomoc;;

        v) wersja;;

        f) PLIK=$OPTARG;;

        q) echo "Wypisanie komunikatu i wyjście"

    exit;;

        *) echo "Nieznana opcja";;

    esac

done