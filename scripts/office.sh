#!/bin/bash

# initialize variables for reboot status
flatpak_run=""
# supermenu checklist
osupermenu () {

    local selection_str
    local selection
    local selected
    local search_item
    local item
    declare -a search_item=(
        "Zen Browser"
        "Google Chrome"
        "OnlyOffice"
        "Foliate"
        "Microsoft Teams"
        "Anydesk"
        "Slack"
        "Figma"
        "Cohesion"
        "Darktable"
        "Pinta"
        "Krita"
        "GIMP"
        "Audacity"
        "Inkscape"
        "FreeCAD"
        "KiCad"
        "Kdenlive"
        "Blender"
        "DaVinci Resolve"
    )

    while true; do

        selection_str=$(zenity --list --checklist --title="Office Menu" \
        	--column="" \
        	--column="Apps" \
            FALSE "Zen Browser" \
            FALSE "Google Chrome" \
            FALSE "OnlyOffice" \
            FALSE "Foliate" \
            FALSE "Microsoft Teams" \
            FALSE "Anydesk" \
            FALSE "Slack" \
            FALSE "Figma" \
            FALSE "Cohesion" \
            FALSE "Darktable" \
            FALSE "Pinta" \
            FALSE "Krita" \
            FALSE "GIMP" \
            FALSE "Audacity" \
            FALSE "Inkscape" \
            FALSE "FreeCAD" \
            FALSE "KiCad" \
            FALSE "Kdenlive" \
            FALSE "Blender" \
            FALSE "DaVinci Resolve" \
            --height=700 --width=300 --separator="|")

        if [ $? -ne 0 ]; then
            break
        fi

        IFS='|' read -ra selection <<< "$selection_str"

        # compare array elements
        for item in "${search_item[@]}"; do
            for selected in "${selection[@]}"; do
                if [[ "$selected" == "$item" ]]; then
                    case $item in
                        "Zen Browser") _zen="app.zen_browser.zen" ;;
                        "Google Chrome") _chrome="com.google.Chrome" ;;
                        "OnlyOffice") _oofice="org.onlyoffice.desktopeditors" ;;
                        "Foliate") _foli="com.github.johnfactotum.Foliate" ;;
                        "Microsoft Teams") _msteams="com.github.IsmaelMartinez.teams_for_linux" ;;
                        "Anydesk") _anyd="com.anydesk.Anydesk" ;;
                        "Slack") _slck="com.slack.Slack" ;;
                        "Figma") _fig="1" ;;
                        "Cohesion") _notion="io.github.brunofin.Cohesion" ;;
                        "Darktable") _drktb="org.darktable.Darktable" ;;
                        "Pinta") _pnta="com.github.PintaProject.Pinta" ;;
                        "Krita") _krt="org.kde.krita" ;;
                        "GIMP") _gimp="org.gimp.GIMP" ;;
                        "Audacity") _audc="org.audacityteam.Audacity" ;;
                        "Inkscape") _inksc="org.inkscape.Inkscape" ;;
                        "FreeCAD") _fcad="org.freecad.FreeCAD" ;;
                        "KiCad") _kcad="org.kicad.KiCad" ;;
                        "Kdenlive") _klive="org.kde.kdenlive" ;;
                        "Blender") _blender="org.blender.Blender" ;;
                        "DaVinci Resolve") _drslv="yes" ;;
                    esac
                fi
            done
        done

        install_flatpak
        install_native
        figma_t
        if [[ -n "$_drslv" ]]; then
            zenity --warning --title "DaVinci Resolve" --text "$msg034" --height=300 --width=300
            local script="davincibox" && _invoke_
        fi
        if [[ -n "$flatpak_run" ]]; then
            zenity --info --title "$msg006" --text "$msg036" --height=300 --width=300
        else
            zenity --info --title "$msg006" --text "$msg018" --height=300 --width=300
        fi
        break

    done

}

# installer functions
# native packages -- currently empty but prepared for future additions
install_native () {

    local _packages=()
    cd $HOME
    _install_

}

# flatpak packages
install_flatpak () {

    local _flatpaks=($_oofice $_anyd $_fcad $_gimp $_inksc $_notion $_msteams $_slck $_chrome $_zen $_drktb $_foli $_blender $_kcad $_klive $_audc)
    if [[ -n "$_flatpaks" ]]; then
        if command -v flatpak &> /dev/null; then
            flatpak_in_lib
            _flatpak_
        else
            if zenity --question --title "$msg006" --text "$msg085" --height=300 --width=300; then
                flatpak_run="1"
                flatpak_in_lib
                _flatpak_
            else
                nonfatal "$msg132"
                return 1
            fi
        fi
        if [[ -n "$_gimp" ]]; then
            if zenity --question --title "PhotoGIMP" --text "$msg271" --height=300 --width=300; then
                zenity --info --title "PhotoGIMP" --text "$msg272" --height=300 --width=300
                flatpak run org.gimp.GIMP & sleep 1
                PID=($(pgrep -f "gimp"))
                if [ -z "$PID" ]; then
                    echo "Failed to find Flatpak process."
                    exit 1
                fi
                echo "Found Flatpak app running as PID $PID"
                sleep 20
                for ID in "${PID[@]}"; do
                    kill "$ID"
                done
                wait "$PID" 2>/dev/null
                git clone https://github.com/Diolinux/PhotoGIMP.git
                cd PhotoGIMP
                cp -rf .config/* $HOME/.config/
                cp -rf .local/* $HOME/.local/
                cd ..
                rm -rf PhotoGIMP
            fi
        fi
    fi

}

# figma installer
figma_t () {

    if [[ -n "$_fig" ]]; then
        cd $HOME
        local tag=$(curl -s https://api.github.com/repos/Figma-Linux/figma-linux/releases/latest | grep '"tag_name"' | cut -d '"' -f4 | sed 's/^v//')
        wget https://github.com/Figma-Linux/figma-linux/releases/download/v${tag}/figma-linux_${tag}_linux_x86_64.rpm
        rpm-ostree install -yA figma-linux_${tag}_linux_x86_64.rpm
        sleep 1
        rm figma-linux-*.rpm
    fi

}

# runtime
. /etc/os-release
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/linuxtoys-atom.lib)
_lang_
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/src/lang/${langfile})
sleep 1
osupermenu
