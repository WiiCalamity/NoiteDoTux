#!/bin/bash
source ASCIIs.sh # Imports functions defined by ASCIIs.sh

################################################
# __      __        _       _     _            #
# \ \    / /       (_)     | |   | |           #
#  \ \  / /_ _ _ __ _  __ _| |__ | | ___  ___  #
#   \ \/ / _` | '__| |/ _` | '_ \| |/ _ \/ __| #
#    \  / (_| | |  | | (_| | |_) | |  __/\__ \ #
#     \/ \__,_|_|  |_|\__,_|_.__/|_|\___||___/ #
#                                              #
################################################

declare -i charge=100
declare -i temperature=100
declare -i currentRoom=2
declare -i currentCam=1
declare -i timeCap=1
declare -i SECONDS=1
room=("otherdoor" "maindoor" "window" "oven")
botName=("beastie" "duke" "freedo" "gnu" "kiki" "konqi" "replicant" "tux")
freedoData=("31" "32" "41" "42" "ww" "md" 00 -1)
cameraFeed=(00 00 00 00 00 00 00 00)
botPathIndex=(-1 -1 -1 -1 -1 -1 -1 -1)
aiLevel=(00 00 20 00 00 00 00 00)

#################################################
#  ______                _   _                  #
# |  ____|              | | (_)                 #
# | |__ _   _ _ __   ___| |_ _  ___  _ __  ___  #
# |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __| #
# | |  | |_| | | | | (__| |_| | (_) | | | \__ \ #
# |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/ #
#                                               #
#################################################

maindoorFlash() {
    if [[ ${charge} -ge 35 ]]; then
        ascii.maindoorFlash
        charge+=-35
        sleep 0.2
    fi
}

otherdoorFlash() {
    if [[ ${charge} -ge 35 ]]; then
        ascii.otherdoorFlash
        charge+=-35
        sleep 0.2
    fi
}

freedoMovement() {
    freedoData[-1]=$((freedoData[-1]+1))
    freedoData[-2]="${freedoData[${freedoData[-1]}]}"
    cameraFeed[$i]=${freedoData[-2]}
    printf "Freedo MOVED!!!!!!"
}

movementOpportunity() {
    if [[ $((timeCap%5)) -eq 0 ]]; then
        for i in $(seq ${#botName[@]}); do # seq n -> 1 2 3 .. n
            i+=-1
            [[ $((RANDOM%20+1)) -le ${aiLevel[$i]} ]] && "${botName[$i]}"Movement
        done
    fi
}

controlCharge() {
    [[ ${charge} -lt 100 ]] && charge+=1
}

controlTemperature() {
    if [[ ${currentRoom} -eq 3 ]]; then
        [[ ${temperature} -lt 100 ]] && temperature+=3
    elif [[ ${temperature} -le 0 ]]; then
        reason="frio"
        gameOver
    else
        temperature+=-2
    fi
}

callMechanics() {
    # Calls the functions that control the mechanics.
    # It's a hub of functions! Awesumsaucez!
    movementOpportunity
    controlCharge
    controlTemperature
}

gameOver() {
    printf "Perdestes."
    printf "Causa: ${reason}"
    exit
}

####################################

while :; do
    read -s -t 0.1 -n 1 input
    clear
    if [[ ${cameraUp} ]]; then
        ascii.cam"${currentCam}"
        [[ ${input} -ge 1 ]] && [[ ${input} -le 6 ]] && currentCam=${input}
        [[ ${input} = "s" ]] && cameraUp=
    else
        ascii."${room[${currentRoom}]}"
        case ${input} in
            a) [[ ${currentRoom} -gt 0 ]] && currentRoom+=-1;;
            s) [[ ${currentRoom} -eq 2 ]] && cameraUp=1;;
            d) [[ ${currentRoom} -lt 3 ]] && currentRoom+=1;;
            f) [[ ${currentRoom} -eq 1 ]] && maindoorFlash
               [[ ${currentRoom} -eq 0 ]] && otherdoorFlash;;
        esac
    fi
    printf "Carga: %s%%\n" "${charge}"
    printf "Temperatura: %s%%\n" "${temperature}"
    printf "%s " "freedoData:" "${freedoData[@]}"; printf "\n"
    [[ ${timeCap} -ne ${SECONDS} ]] && callMechanics
    timeCap=${SECONDS}
done
