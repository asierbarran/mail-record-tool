#!/bin/bash
echo "####################################################################################"
echo "#                                                                                  #"
echo "#  /#######  /##   /## /##       /##       /##   /##  /######   /######  /######## #"
echo "# | ##__  ##| ##  | ##| ##      | ##      | ##  | ## /##__  ## /##__  ##|__  ##__/ #"
echo "# | ##  \ ##| ##  | ##| ##      | ##      | ##  | ##| ##  \ ##| ##  \__/   | ##    #"
echo "# | ####### | ##  | ##| ##      | ##      | ########| ##  | ##|  ######    | ##    #"
echo "# | ##__  ##| ##  | ##| ##      | ##      | ##__  ##| ##  | ## \____  ##   | ##    #"
echo "# | ##  \ ##| ##  | ##| ##      | ##      | ##  | ##| ##  | ## /##  \ ##   | ##    #"
echo "# | #######/|  ######/| ########| ########| ##  | ##|  ######/|  ######/   | ##    #"
echo "# |_______/  \______/ |________/|________/|__/  |__/ \______/  \______/    |__/    #"
echo "#                                                                                  #"
echo "####################################################################################"
dominio=$1
lista="file.txt"
output="Mete el siguiente comando para usar el programa: ./$(basename "$0") 'dominio'"
existe=$(dig -t ns +short $dominio )
if [ -z "$1" ];
then
    echo $output
elif [ ! -f $lista ];
then
    echo "El archivo no existe."
elif [ ${#existe} -lt 1 ];
then
    echo "El dominio no existe"
else

#
# WEB
#
        a=$(dig -t a +short $dominio )
        if [ ${#a} -gt 0 ];
        then
                echo "####################################"
                echo "############### WEB ################"
                echo "####################################"
                echo "$a"
                echo " "
        fi

#
# NS
#
        ns=$(dig -t ns +short $dominio )
        if [ ${#ns} -gt 0 ];
        then
                echo "####################################"
                echo "############### NS #################"
                echo "####################################"
                echo "$ns"
                echo " "
        fi


#
# MX
#
        mx=$(dig -t mx +short $dominio )
        mxa=$(dig -t a +short $mx)
        if [ ${#mx} -gt 0 ];
        then
                echo "####################################"
                echo "################ MX ################"
                echo "####################################"
                echo "$mx  ==>  $mxa"
                echo " "
        fi




#
# SPF
#
    spf=$(dig -t TXT +short $dominio | grep spf)
    if [ ${#spf} -gt 0 ];
        then
                echo "####################################"
                echo "############### SPF ################"
                echo "####################################"
                echo "$spf"
                echo " "
        fi
#
# DKIM
#
    encabezado=0
    exec 3<&0
    exec 0<$lista
    while read line
    do
        comando=$(dig -t TXT +short $line._domainkey.$dominio)
        if [ ${#comando} -gt 0 ];
        then
            if [ $encabezado = "0" ];
            then
                echo "####################################"
                echo "############### DKIM ###############"
                encabezado=1;
            fi
        echo "####################################"
        echo "El selector es: $line y su contenido es : $comando"
        echo " "
        fi
    done
#
# DMARC
#
    dmarc=$(dig -t TXT +short _dmarc.$dominio)
    if [ ${#dmarc} -gt 0 ];
    then
        echo "#######################################"
        echo "################ DMARC ################"
        echo "#######################################"
        echo "$dmarc"
        echo " "

        #
        # Validacion DMARC
        #
        validacion=$(dig -t TXT +short $dominio._report._dmarc.bullhost.es)
        echo "#######################################"
        echo "########## Validacion DMARC ###########"
        echo "#######################################"

        if [ ${#validacion} -gt 0 ];
        then
                echo "Tiene validacion DMARC en bullhost"
        else
                echo "No tiene"
        fi
        exec 0<&3
        echo " "
    fi
    exec 0<&3

    none=$(grep  "${p=none}" <<< "$dmarc")
    echo "#######################################"
    echo "############# Spoofcheck ##############"
    echo "#######################################"
    if [ ${#dmarc} == 0 ] || [ ${#none} -gt 0 ] ;
    then
        echo "El dominio $dominio es spoofeable."
    else
        echo "El dominio $dominio NO es spofeable."
    fi
    exec 0<&3

fi
