#!/bin/bash
#Array donde almacena los paquetes.
arrayPaquetes=()

#Función para revisar el estado del paquete.
function ifEstado(){
    #Este if en función de la variable $estado nos dirá si está instalado o no el paquete.
    if [[ $estado -gt 0 ]]; then
        echo "$nombre | Instalado"
    else
        echo "$nombre | No instalado"
    fi
}

#Este if comprueba el id del usuario, si no es root deniega la ejecución.
id=$(id -u) #!comprobamos id del usuario idroot=0.
if  [[ $id == 0 ]] ; then
    echo "Preparando script..."
    sudo apt update &>/dev/null #!Actualizar paquetes
    while IFS=":" read -r nombre accion || [[ -n "$nombre" ]]; do
        estado=$(whereis $nombre | grep bin | wc -l) #!Comprueba si el programa está instaldo +1=sí 0=no.
        #Este if comprueba que acción debe realizar.
        if [[ $accion == "add" ]]; then #!Instalación
            if [[ $estado -eq 0 ]]; then #!Revisamos si el programa está instalado
                sudo apt install "$nombre" -y #?Instalamos el paquete
            else
                echo "El programa $nombre ya está instalado"
            fi
        elif [[ $accion == "remove" ]]; then #!Eliminar paquete y autoremove
            sudo apt purge "$nombre" -y #?Borramos el paquete
            sudo apt autoremove &>/dev/null
        elif [[ $accion == "status" ]]; then #!Ver estado
            echo
            ifEstado #?Mostrar
            echo
        else #!Si no contiene 'add', 'remove' o 'status' dará error.
            echo "ERROR, no se que hacer con el paquete $nombre. Añade 'add', 'remove' o 'status' en el fichero para continuar."
        fi
        arrayPaquetes+=("$nombre" "$accion")
    done < ./paquetes.txt
else
    echo "Permiso denegado, solo el root tiene acceso."
    exit 1
fi