#!/bin/bash

# funció que informa a l'usuari de la sintaxi correcta
# fixeu-vos en 1>&2 que redirecciona a error el missatge
# si cridem aquest programa amb 2> errors.log, deixa traça en fitxer
usage() {
    echo "Usage: $0 [-p <80|443>] [-h <string>] [-f]" 1>&2; exit 1;
}
#El primer : habilita l'opció \?, que recull error
#Els : després d'opcions indiquen que porten argument obligatòriament
while getopts ":p:h:f" o; do
    # OPTIND és variable interna de  getops, índex 
    echo "OPTIND: $OPTIND OPTARG: $OPTARG"
    case "${o}" in
	# OPTARG és una variable pròpia de getops i va canviant a cada 
	# iteració: representa el valor l'opció que està tractant
        p)
            PORT=$OPTARG
            if [ $PORT -ne 80 ] && [ $PORT -ne 443 ]
             then
               echo "Ports 443 o 80"  1>&2
               usage
            fi
            ;;
        h)
            HOST=$OPTARG
            h=$OPTARG
            ;;
	# aquest és l'unica opció que no requereix de paràmetre
	# equival a un flag(booleà)
        f)
            FORCE=1
            ;;
	#entra aquí quan s'introdueix opció però no pas argument, sent aquest
	#obligatori
        :)
            echo "ERROR: Option -$OPTARG requires an argument"
            usage
            ;;
	#entra aqui quan l'opció no és vàlida
        \?)
            echo "ERROR: Invalid option -$OPTARG"
            usage
            ;;
    esac
        #shift $((OPTIND-1))
        #printf "Remaining arguments are: %s\n" "$*"
done
# Check required switches exist
#if [ -z "${PORT}" ] || [ -z "${HOST}" ]
#then
# echo "Please give p and h values"
# usage
#fi
echo "PORT = $PORT"
echo "HOST = $HOST"
echo "FORCE $FORCE"
