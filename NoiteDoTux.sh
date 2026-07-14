#!/bin/bash

source ASCIIs.sh # Imports functions defined by ASCIIs.sh

declare -i charge
declare -i temp
declare -i tempDrain
charge=100
temp=100
tempDrain=-2
SECONDS=0
timeCap=0
currentCam=1

window() {
    while :; do
        ascii_window
        routine
        read -s -t 0.1 -n 1 input
        case $input in
            a) room="oven"; return;;
            s) room="camera"; return;;
            d) room="maindoor"; return;;
        esac
    done
}

oven() {
    tempDrain=4
    while :; do
        ascii_oven
        routine
        read -s -t 0.1 -n 1 input
        case $input in
            d) room="window"; tempDrain=-2; return;;
        esac
    done
}

maindoor() {
    while :; do
        ascii_maindoor
        routine
        read -s -t 0.1 -n 1 input
        case $input in
            f)
                if [[ $charge -ge 20 ]]; then
                    ascii_maindoor_flash
                    charge+=-20
                    sleep 0.2
                fi;;
            a) room="window"; return;;
            d) room="otherdoor"; return;;
        esac
    done
}

otherdoor() {
    while :; do
        ascii_otherdoor
        routine
        read -s -t 0.1 -n 1 input
        case $input in
            f)
                if [[ $charge -ge 20 ]]; then
                    ascii_otherdoor_flash
                    charge+=-20
                    sleep 0.2
                fi;;
            a) room="maindoor"; return
        esac
    done
}

camera() {
    input=""
    while [[ $input != "s" ]]; do
        ascii_cam"$currentCam"
        routine
        read -s -t 0.1 -n 1 input
        if [[ $input -ge 1 ]] && [[ $input -le 6 ]]; then
            currentCam=$input
        fi
    done
    room="window"
}

###############################

routine() {
    if [[ $timeCap -ne $SECONDS ]]; then

        temp+=$tempDrain
        if [[ $charge -lt 100 ]]; then
            charge+=1
        fi
        if [[ $temp -le 0 ]]; then
            reason="frio"
            game_over
        fi
    fi
    echo "Carga: $charge%"
    echo "Temperatura: $temp%"
    timeCap=$SECONDS
}

game_over() {
    echo "Perdestes."
    echo "Causa: $reason"
    exit
}

window
while :; do
    # Redirect player input into its designated function
    $room
done
