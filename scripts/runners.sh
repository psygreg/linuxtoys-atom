#!/bin/bash
# functions

# menu
runners_menu () {

    local spritz_status=$([ "$_spritz" = "1" ] && echo "ON" || echo "OFF")
    local osu_status=$([ "$_osu" = "1" ] && echo "ON" || echo "OFF")
    local jade_status=$([ "$_jade" = "1" ] && echo "ON" || echo "OFF")
    local tricks_status=$([ "$_tricks" = "1" ] && echo "ON" || echo "OFF")
    local vngr_status=$([ "$_vngr" = "1" ] && echo "ON" || echo "OFF")

    while :; do

        local selection
        selection=$(whiptail --title "$msg131" --checklist \
            "$msg131" 20 78 15 \
            "Spritz" "$msg153" $spritz_status \
            "Osu!-Wine" "$msg154" $osu_status \
            "Jadeite" "$msg180" $jade_status \
            "Protontricks" "$msg235" $tricks_status \
            "Vinegar" "$msg204" $vngr_status \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ $exitstatus != 0 ]; then
        # Exit the script if the user presses Esc
            break
        fi

        [[ "$selection" == *"Spritz"* ]] && _spritz="1" || _spritz=""
        [[ "$selection" == *"Osu!-Wine"* ]] && _osu="1" || _osu=""
        [[ "$selection" == *"Jadeite"* ]] && _jade="1" || _jade=""
        [[ "$selection" == *"Protontricks"* ]] && _tricks="1" || _tricks=""
        [[ "$selection" == *"Vinegar"* ]] && _vngr="1" || _vngr=""

        if [[ -n "$_spritz" ]]; then
            spritz_in
        fi
        if [[ -n "$_osu" ]]; then
            osu_in
        fi
        if [[ -n "$_jade" ]]; then
            jade_in
        fi
        if [[ -n "$_tricks" ]]; then
            flatpak_in_lib
            local _flatpaks="com.github.Matoking.protontricks"
            _flatpak_
        fi
        if [[ -n "$_vngr" ]]; then
            vinegar_in
        fi
        break

    done

}

spritz_in () {

    cd $HOME
    local krnver=$(uname -r | cut -d- -f1)
    local krnmaj=$(echo "$krnver" | cut -d. -f1)
    local krnmin=$(echo "$krnver" | cut -d. -f2)
    if (( krnmaj > 6 || (krnmaj == 6 && krnmin > 13) )); then
        wget https://github.com/NelloKudo/WineBuilder/releases/download/spritz-v10.9-1/spritz-wine-tkg-ntsync-fonts-wow64-10.9-2-x86_64.tar.xz
        tar -xf spritz-wine-tkg-ntsync-fonts-wow64-10.9-2-x86_64.tar.xz
        if flatpak list | grep -q 'net.lutris.Lutris'; then
            mkdir -p $HOME/.var/app/net.lutris.Lutris/data/lutris/runners/wine
            cp -rf spritz-wine-tkg-ntsync-10.9 $HOME/.var/app/net.lutris.Lutris/data/lutris/runners/wine/
        fi
        if flatpak list | grep -q 'com.heroicgameslauncher.hgl'; then
            mkdir -p $HOME/.var/app/com.heroicgameslauncher.hgl/config/heroic/tools/wine
            cp -rf spritz-wine-tkg-ntsync-10.9 $HOME/.var/app/com.heroicgameslauncher.hgl/config/heroic/tools/wine/
        fi
        rm spritz-wine-tkg-ntsync-fonts-wow64-10.9-2-x86_64.tar.xz
        rm -rf spritz-wine-tkg-ntsync-10.9
    else
        wget https://github.com/NelloKudo/WineBuilder/releases/download/spritz-v10.9-1/spritz-wine-tkg-fonts-wow64-10.9-2-x86_64.tar.xz
        tar -xf spritz-wine-tkg-fonts-wow64-10.9-2-x86_64.tar.xz
        if flatpak list | grep -q 'net.lutris.Lutris'; then
            mkdir -p $HOME/.var/app/net.lutris.Lutris/data/lutris/runners/wine
            cp -rf spritz-wine-tkg-10.9 $HOME/.var/app/net.lutris.Lutris/data/lutris/runners/wine/
        fi
        if flatpak list | grep -q 'com.heroicgameslauncher.hgl'; then
            mkdir -p $HOME/.var/app/com.heroicgameslauncher.hgl/config/heroic/tools/wine
            cp -rf spritz-wine-tkg-10.9 $HOME/.var/app/com.heroicgameslauncher.hgl/config/heroic/tools/wine/
        fi
        rm spritz-wine-tkg-fonts-wow64-10.9-2-x86_64.tar.xz
        rm -rf spritz-wine-tkg-10.9
    fi

}

osu_in () {

    wget https://github.com/NelloKudo/WineBuilder/releases/download/wine-osu-staging-10.8-2/wine-osu-winello-fonts-wow64-10.8-2-x86_64.tar.xz
    tar -xf wine-osu-winello-fonts-wow64-10.8-2-x86_64.tar.xz
    mkdir -p $HOME/.var/app/net.lutris.Lutris/data/lutris/runners/wine
    cp -rf wine-osu $HOME/.var/app/net.lutris.Lutris/data/lutris/runners/wine/
    rm wine-osu-winello-fonts-wow64-10.8-2-x86_64.tar.xz
    rm -rf wine-osu

}

jade_in () {

    if flatpak list | grep -q 'com.valvesoftware.Steam'; then
        local ver=$(curl -s "https://codeberg.org/api/v1/repos/mkrsym1/jadeite/releases" | jq -r '.[0].tag_name')
        cd $HOME
        wget https://codeberg.org/mkrsym1/jadeite/releases/download/${ver}/${ver}.zip
        wget https://raw.githubusercontent.com/psygreg/linuxtoys/refs/heads/main/src/resources/other/cmd.txt
        mkdir -p jadeite
        unzip -d $HOME/jadeite/ ${ver}.zip
        cp cmd.txt jadeite
        cd jadeite
        chmod +x block_analytics.sh
        sudo ./block_analytics.sh
        cd ..
        {
            echo "$msg181"
            echo "$msg182"
            echo "$msg183"
            echo "$msg184"
            echo "$msg185"
            echo "$msg186"
        } > txtbox
        whiptail --textbox txtbox 12 80
        flatpak override com.valvesoftware.Steam --filesystem=${HOME}/jadeite
        rm ${ver}.zip
        rm txtbox
        rm cmd.txt
    else
        local title="$msg030"
        local msg="$msg205"
        _msgbox_
    fi

}

vinegar_in () {

    flatpak_in_lib
    local _flatpaks=(org.vinegarhq.Vinegar)
    _flatpak_

}

# runtime
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/linuxtoys-atom.lib)
_lang_
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/src/lang/${langfile})
title="$msg187"
msg="$msg188"
_msgbox_
if command -v flatpak &> /dev/null && flatpak list | grep -q 'net.lutris.Lutris' || command -v flatpak &> /dev/null && flatpak list | grep -q 'com.heroicgameslauncher.hgl' || command -v flatpak &> /dev/null && flatpak list | grep -q 'com.valvesoftware.Steam'; then
    runners_menu
else
    title="$msg030"
    msg="$msg155"
    _msgbox_
fi
