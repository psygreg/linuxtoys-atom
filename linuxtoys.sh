#!/bin/bash
# functions
# error handler
fatal() {
    zenity --error --title "Fatal Error" --text "$1" --height=300 --width=300
    exit 1
}

# updater
current_ltver="2.0"
ver_upd () {
    local ver
    ver=$(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/src/ver)
    if [[ "$ver" != "$current_ltver" ]]; then
        if zenity --question --title "$msg001" --text "$msg002" --height=300 --width=300; then
            zenity --info --title "$msg001" --text "$msg157" --height=300 --width=300
            xdg-open https://github.com/psygreg/linuxtoys-atom/releases/latest
        fi
    fi
}

# sudo request
sudo_rq () {
    zenity --password | sudo -Sv || fatal "Wrong password. Do you have sudo?"
}

# runtime
# check internet connection
. /etc/os-release
wget -q -O - "https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/README.md" > /dev/null || fatal "LinuxToys requires an internet connection to proceed."
# call linuxtoys atom lib
sleep 1
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/linuxtoys-atom.lib)
# logger
logfile="$HOME/.local/linuxtoys-log.txt"
_log_
# language and upd checks
_lang_
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/src/lang/${langfile})
sleep 1
# update checker
ver_upd
# request sudo for future usage
sudo_rq

# main menu
while true; do

    CHOICE=$(zenity --list --title="LinuxToys Atom" \
        --column="${msg274}" \
        "${msg120}" \
        "${msg121}" \
        "${msg122}" \
        "${msg123}" \
        "${msg143}" \
        "${msg227}" \
        "${msg199}" \
        "" \
        "${msg124}" \
        "GitHub" \
        "${msg275}" \
        "${msg059}" \
        --height=500 --width=360)
        #"7" "UniWine" \ -- disabled option

    if [ $? -ne 0 ]; then
        find "$HOME" -maxdepth 1 -type f -name '*.sh' -exec rm -f {} + && break
   	fi

    case $CHOICE in
    "${msg120}") script="utils" && _invoke_ ;;
    "${msg121}") script="office" && _invoke_ ;;
    "${msg122}") script="game" && _invoke_ ;;
    "${msg123}") script="extras" && _invoke_ ;;
    "${msg143}") script="devs" && _invoke_ ;;
    "${msg227}") script="autosetup" && _invoke_ ;;
    "${msg199}") script="console" && _invoke_ ;;
    # 7) subscript="uniwine" && _invoke_ ;; -- disabled option
    "${msg124}") zenity --info --title "LinuxToys Atom v${current_ltver}" --text "$msg125" --height=300 --width=300;;
    "GitHub") xdg-open https://github.com/psygreg/linuxtoys ;;
    "${msg275}") xdg-open https://ko-fi.com/psygreg ;;
    "${msg059}") break ;;
    *) echo "Invalid Option" ;;
    esac
done
