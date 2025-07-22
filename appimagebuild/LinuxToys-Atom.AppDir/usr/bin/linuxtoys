#!/bin/bash
# functions

# updater
current_ltver="1.0"
ver_upd () {
    local ver
    ver=$(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/src/ver)
    if [[ "$ver" != "$current_ltver" ]]; then
        if whiptail --title "$msg001" --yesno "$msg002" 8 78; then
            local title="$msg001"
            local msg="$msg157"
            _msgbox_
            xdg-open https://github.com/psygreg/linuxtoys/releases/latest
        fi
    fi
}

# runtime
# check internet connection
# ping google
. /etc/os-release
wget -q -O - "https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/README.md" > /dev/null || { whiptail --title "Disconnected" --msgbox "LinuxToys requires an internet connection to proceed." 8 78; exit 1; }
# call linuxtoys atom lib
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/linuxtoys-atom.lib)
# logger
logfile="$HOME/.local/linuxtoys-log.txt"
_log_
# language and upd checks
_lang_
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/src/lang/${langfile})
ver_upd

# main menu
while :; do

    CHOICE=$(whiptail --title "LinuxToys Atom" --menu "${current_ltver}" 25 78 16 \
        "0" "$msg120" \
        "1" "$msg121" \
        "2" "$msg122" \
        "3" "$msg123" \
        "4" "$msg143" \
        "5" "$msg227" \
        "6" "$msg199" \
        "" "" \
        "" "" \
        "8" "$msg124" \
        "9" "GitHub" \
        "10" "$msg059" 3>&1 1>&2 2>&3)
        #"7" "UniWine" \ -- disabled option

    exitstatus=$?
    if [ $exitstatus != 0 ]; then
        # Exit the script if the user presses Esc
        find "$HOME" -maxdepth 1 -type f -name '*.sh' -exec rm -f {} + && break
    fi

    case $CHOICE in
    0) script="utils" && _invoke_ ;;
    1) script="office" && _invoke_ ;;
    2) script="game" && _invoke_ ;;
    3) script="extras" && _invoke_ ;;
    4) script="devs" && _invoke_ ;;
    5) script="autosetup" && _invoke_ ;;
    6) script="console" && _invoke_ ;;
    # 7) subscript="uniwine" && _invoke_ ;; -- disabled option
    8) whiptail --title "LinuxToys Atom v${current_ltver}" --msgbox "$msg125" 8 78 ;;
    9) xdg-open https://github.com/psygreg/linuxtoys ;;
    10 | q) break ;;
    *) echo "Invalid Option" ;;
    esac
done
