#!/bin/bash

# initialize variables for reboot status
flatpak_run=""
# supermenu checklist
osupermenu () {

    local oofice_status=$([ "$_oofice" = "org.onlyoffice.desktopeditors" ] && echo "ON" || echo "OFF")
    local msteams_status=$([ "$_msteams" = "com.github.IsmaelMartinez.teams_for_linux" ] && echo "ON" || echo "OFF")
    local anyd_status=$([ "$_anyd" = "com.anydesk.Anydesk" ] && echo "ON" || echo "OFF")
    local slck_status=$([ "$_slck" = "com.slack.Slack" ] && echo "ON" || echo "OFF")
    local notion_status=$([ "$_notion" = "io.github.brunofin.Cohesion" ] && echo "ON" || echo "OFF")
    local gimp_status=$([ "$_gimp" = "org.gimp.GIMP" ] && echo "ON" || echo "OFF")
    local inksc_status=$([ "$_inksc" = "org.inkscape.Inkscape" ] && echo "ON" || echo "OFF")
    local fcad_status=$([ "$_fcad" = "org.freecad.FreeCAD" ] && echo "ON" || echo "OFF")
    local drslv_status=$([ "$_drslv" = "yes" ] && echo "ON" || echo "OFF")
    local blender_status=$([ "$_blender" = "org.blender.Blender" ] && echo "ON" || echo "OFF")
    local chrome_status=$([ "$_chrome" = "com.google.Chrome" ] && echo "ON" || echo "OFF")
    local zen_status=$([ "$_zen" = "app.zen_browser.zen" ] && echo "ON" || echo "OFF")
    local drktb_status=$([ "$_drktb" = "org.darktable.Darktable" ] && echo "ON" || echo "OFF")
    local foli_status=$([ "$_foli" = "com.github.johnfactotum.Foliate" ] && echo "ON" || echo "OFF")
    local kcad_status=$([ "$_kcad" = "org.kicad.KiCad" ] && echo "ON" || echo "OFF")
    local fig_status=$([ "$_fig" = "1" ] && echo "ON" || echo "OFF")
    local pnta_status=$([ "$_pnta" = "com.github.PintaProject.Pinta" ] && echo "ON" || echo "OFF")
    local krt_status=$([ "$_krt" = "org.kde.krita" ] && echo "ON" || echo "OFF")
    local klive_status=$([ "$_klive" = "org.kde.kdenlive" ] && echo "ON" || echo "OFF")
    local audc_status=$([ "$_audc" = "org.audacityteam.Audacity" ] && echo "ON" || echo "OFF")

    while :; do

        local selection
        selection=$(whiptail --title "$msg131" --checklist \
            "$msg131" 20 78 15 \
            "Zen" "$msg128" $zen_status \
            "Chrome" "$msg129" $chrome_status \
            "Onlyoffice" "$msg099" $oofice_status \
            "Foliate" "$msg149" $foli_status \
            "MS Teams" "$msg100" $msteams_status \
            "Anydesk" "$msg101" $anyd_status \
            "Slack" "$msg102" $slck_status \
            "Figma" "$msg223" $fig_status \
            "Cohesion" "$msg103" $notion_status \
            "Darktable" "$msg148" $drktb_status \
            "Pinta" "$msg224" $pnta_status \
            "Krita" "$msg225" $krt_status \
            "GIMP" "$msg104" $gimp_status \
            "Audacity" "$msg242" $audc_status \
            "Inkscape" "$msg105" $inksc_status \
            "FreeCAD" "$msg106" $fcad_status \
            "KiCad" "$msg222" $kcad_status \
            "Kdenlive" "$msg241" $klive_status \
            "Blender" "$msg159" $blender_status \
            "DaVinci Resolve" "$msg107" $drslv_status \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ $exitstatus != 0 ]; then
        # Exit the script if the user presses Esc
            break
        fi

        [[ "$selection" == *"Onlyoffice"* ]] && _oofice="org.onlyoffice.desktopeditors" || _oofice=""
        [[ "$selection" == *"MS Teams"* ]] && _msteams="com.github.IsmaelMartinez.teams_for_linux" || _msteams=""
        [[ "$selection" == *"Anydesk"* ]] && _anyd="com.anydesk.Anydesk" || _anyd=""
        [[ "$selection" == *"Slack"* ]] && _slck="com.slack.Slack" || _slck=""
        [[ "$selection" == *"Cohesion"* ]] && _notion="io.github.brunofin.Cohesion" || _notion=""
        [[ "$selection" == *"Darktable"* ]] && _drktb="org.darktable.Darktable" || _drktb=""
        [[ "$selection" == *"GIMP"* ]] && _gimp="org.gimp.GIMP" || _gimp=""
        [[ "$selection" == *"Inkscape"* ]] && _inksc="org.inkscape.Inkscape" || _inksc=""
        [[ "$selection" == *"FreeCAD"* ]] && _fcad="org.freecad.FreeCAD" || _fcad=""
        [[ "$selection" == *"DaVinci Resolve"* ]] && _drslv="yes" || _drslv=""
        [[ "$selection" == *"Blender"* ]] && _blender="org.blender.Blender" || _blender=""
        [[ "$selection" == *"Chrome"* ]] && _chrome="com.google.Chrome" || _chrome=""
        [[ "$selection" == *"Zen"* ]] && _zen="app.zen_browser.zen" || _zen=""
        [[ "$selection" == *"Foliate"* ]] && _foli="com.github.johnfactotum.Foliate" || _foli=""
        [[ "$selection" == *"KiCad"* ]] && _kcad="org.kicad.KiCad" || _kcad=""
        [[ "$selection" == *"Figma"* ]] && _fig="1" || _fig=""
        [[ "$selection" == *"Pinta"* ]] && _pnta="com.github.PintaProject.Pinta" || _pnta=""
        [[ "$selection" == *"Krita"* ]] && _krt="org.kde.krita" || _krt=""
        [[ "$selection" == *"Kdenlive"* ]] && _klive="org.kde.kdenlive" || _klive=""
        [[ "$selection" == *"Audacity"* ]] && _audc="org.audacityteam.Audacity" || _audc=""

        install_flatpak
        install_native
        figma_t
        if [[ -n "$_drslv" ]]; then
            local title="$msg006"
            local msg="$msg034"
            _msgbox_
            local script="davincibox" && _invoke_
        fi
        if [[ -n "$flatpak_run" ]]; then
            local title="$msg006"
            local msg="$msg036"
            _msgbox_
        else
            local title="$msg006"
            local msg="$msg018"
            _msgbox_
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
            if whiptail --title "$msg006" --yesno "$msg085" 8 78; then
                flatpak_run="1"
                flatpak_in_lib
                _flatpak_
            else
                local title="$msg030"
                local msg="$msg132"
                _msgbox_
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
osupermenu
