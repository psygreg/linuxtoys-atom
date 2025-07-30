#!/bin/bash
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/linuxtoys-atom.lib)

# enable iwd
iwd_in () {

    # detect wifi adapter
    has_wifi=0
    for iface in /sys/class/net/*; do
        if [ -d "$iface/wireless" ]; then
            has_wifi=1
            break
        fi
    done

    # only install if an adapter is found
    if [ $has_wifi -eq 1 ]; then
        # install iwd
        rpm-ostree install -yA iwd
        # enforce iwd backend for networkmanager
        wget https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/src/patches/iwd.conf
        sudo mv iwd.conf /etc/NetworkManager/conf.d/
        # restart networkmanager with wpasupplicant disabled
        sudo systemctl stop NetworkManager
        sudo systemctl disable --now wpa_supplicant
        sudo systemctl restart NetworkManager
        return 0
    else
        nonfatal "No WiFi adapter found. IWD cannot be installed."
        return 2
    fi

}

# disable iwd
iwd_rm () {

    if [ -f "/etc/NetworkManager/conf.d/iwd.conf" ]; then
        sudo rm /etc/NetworkManager/conf.d/iwd.conf
        sudo systemctl stop NetworkManager
        sudo systemctl enable --now wpa_supplicant
        sudo systemctl restart NetworkManager
        rpm-ostree remove -yA iwd
        return 0
    else
        nonfatal "iwd.conf file not found. IWD was not enabled in this system."
        return 1
    fi

}

# menu
while true; do

    CHOICE=$(zenity --list --title="iNet Wireless Daemon" \
        --column="" \
        "Install" \
        "Remove" \
        "Cancel" \
        --height=320 --width=300)

    if [ $? -ne 0 ]; then
        break
   	fi

    case $CHOICE in
        "Install") iwd_in && break;;
        "Remove") iwd_rm && break;;
        "Cancel") break ;;
        *) echo "Invalid Option" ;;
    esac

done
