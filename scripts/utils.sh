#!/bin/bash

# initialize variables for reboot status
flatpak_run=""
# supermenu checklist
usupermenu () {

    local gsr_status=$([ "$_gsr" = "com.dec05eba.gpu_screen_recorder" ] && echo "ON" || echo "OFF")
    local obs_status=$([ "$_obs" = "com.obsproject.Studio" ] && echo "ON" || echo "OFF")
    local hndbrk_status=$([ "$_hndbrk" = "fr.handbrake.ghb" ] && echo "ON" || echo "OFF")
    local slar_status=$([ "$_slar" = "io.github.pwr_solaar.solaar" ] && echo "ON" || echo "OFF")
    local oprzr_status=$([ "$_oprzr" = "yes" ] && echo "ON" || echo "OFF")
    local oprgb_status=$([ "$_oprgb" = "org.openrgb.OpenRGB" ] && echo "ON" || echo "OFF")
    local lact_status=$([ "$_lact" = "io.github.ilya_zlobintsev.LACT" ] && echo "ON" || echo "OFF")
    local droid_status=$([ "$_droid" = "waydroid" ] && echo "ON" || echo "OFF")
    local dckr_status=$([ "$_dckr" = "yes" ] && echo "ON" || echo "OFF")
    local rocm_status=$([ "$_rocm" = "yes" ] && echo "ON" || echo "OFF")
    local rcl_status=$([ "$_rcl" = "yes" ] && echo "ON" || echo "OFF")
    local fseal_status=$([ "$_fseal" = "com.github.tchx84.Flatseal" ] && echo "ON" || echo "OFF")
    local efx_status=$([ "$_efx" = "com.github.wwmm.easyeffects" ] && echo "ON" || echo "OFF")
    local sc_status=$([ "$_sc" = "com.core447.StreamController" ] && echo "ON" || echo "OFF")
    local qpw_status=$([ "$_qpw" = "org.rncbc.qpwgraph" ] && echo "ON" || echo "OFF")
    local wrhs_status=$([ "$_wrhs" = "io.github.flattool.Warehouse" ] && echo "ON" || echo "OFF")

    while :; do

        local selection
        selection=$(whiptail --title "$msg131" --checklist \
            "$msg131" 20 78 15 \
            "GPU Screen Recorder" "$msg086" $gsr_status \
            "OBS Studio" "Open Broadcaster Software" $obs_status \
            "HandBrake" "$msg087" $hndbrk_status \
            "Solaar" "$msg088" $slar_status \
            "OpenRazer" "$msg089" $oprzr_status \
            "StreamController" "$msg151" $sc_status \
            "OpenRGB" "$msg091" $oprgb_status \
            "Flatseal" "$msg133" $fseal_status \
            "Warehouse" "$msg218" $wrhs_status \
            "Easy Effects" "$msg147" $efx_status \
            "QPWGraph" "$msg179" $qpw_status \
            "LACT" "$msg093" $lact_status \
            "Waydroid" "$msg094" $droid_status \
            "Docker" "$msg095" $dckr_status \
            "Rusticl" "$msg158" $rcl_status \
            "ROCm" "$msg096" $rocm_status \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ $exitstatus != 0 ]; then
        # Exit the script if the user presses Esc
            break
        fi

        [[ "$selection" == *"GPU Screen Recorder"* ]] && _gsr="com.dec05eba.gpu_screen_recorder" || _gsr=""
        [[ "$selection" == *"OBS Studio"* ]] && _obs="com.obsproject.Studio" || _obs=""
        [[ "$selection" == *"HandBrake"* ]] && _hndbrk="fr.handbrake.ghb" || _hndbrk=""
        [[ "$selection" == *"Solaar"* ]] && _slar="io.github.pwr_solaar.solaar" || _slar=""
        [[ "$selection" == *"OpenRazer"* ]] && _oprzr="yes" || _oprzr=""
        [[ "$selection" == *"OpenRGB"* ]] && _oprgb="org.openrgb.OpenRGB" || _oprgb=""
        [[ "$selection" == *"LACT"* ]] && _lact="io.github.ilya_zlobintsev.LACT" || _lact=""
        [[ "$selection" == *"Waydroid"* ]] && _droid="waydroid" || _droid=""
        [[ "$selection" == *"Docker"* ]] && _dckr="yes" || _dckr=""
        [[ "$selection" == *"ROCm"* ]] && _rocm="yes" || _rocm=""
        [[ "$selection" == *"Rusticl"* ]] && _rcl="yes" || _rcl=""
        [[ "$selection" == *"Flatseal"* ]] && _fseal="com.github.tchx84.Flatseal" || _fseal=""
        [[ "$selection" == *"Easy Effects"* ]] && _efx="com.github.wwmm.easyeffects" || _efx=""
        [[ "$selection" == *"StreamController"* ]] && _sc="com.core447.StreamController" || _sc=""
        [[ "$selection" == *"QPWGraph"* ]] && _qpw="org.rncbc.qpwgraph" || _qpw=""
        [[ "$selection" == *"Warehouse"* ]] && _wrhs="io.github.flattool.Warehouse" || _wrhs=""

        install_flatpak
        install_native
        if [[ -n "$flatpak_run" || -n "$_oprzr" || -n "$_rocm" ]]; then
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
# native packages
install_native () {

    # set array
    local _packages=($_droid)
    # add docker
    if [[ -n "$_dckr" ]]; then
        curl -O https://download.docker.com/linux/fedora/docker-ce.repo
        sudo install -o 0 -g 0 -m644 docker-ce.repo /etc/yum.repos.d/docker-ce.repo
        _packages+=("docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin")
    fi
    # add openrazer
    if [[ -n "$_oprzr" ]]; then
        curl -O https://openrazer.github.io/hardware:razer.repo
        sudo install -o 0 -g 0 -m644 hardware:razer.repo /etc/yum.repos.d/hardware:razer.repo
        _packages+=("openrazer-meta kernel-devel")
    fi
    # add mesa openCL
    if [[ -n "$_rcl" ]]; then
        _packages+=("mesa-libOpenCL clinfo")
    fi
    # add ROCm
    if [[ -n "$_rocm" ]]; then
        _packages+=("rocm-comgr rocm-runtime rccl rocalution rocblas rocfft rocm-smi rocsolver rocsparse rocm-device-libs rocminfo rocm-hip hiprand rocm-opencl ocl-icd clinfo")
    fi
    _install_
    # final setup adjustments
    if [[ -n "$_droid" ]]; then
        sudo systemctl enable --now waydroid-container
    fi
    if [[ -n "$_rocm" ]]; then
        sudo usermod -aG render,video $USER
    fi
    # enable docker services and set up portainer
    if [[ -n "$_dckr" ]]; then\
        sudo systemctl enable --now docker
        sudo systemctl enable --now docker.socket
        sudo usermod -aG docker $USER
        sudo docker volume create portainer_data
        sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:lts
    fi
    # add rusticl patches
    if [[ -n "$_rcl" ]]; then
        local GPU=$(lspci | grep -Ei 'vga|3d' | grep -Ei 'amd|ati|radeon|amdgpu')
        if [[ -n "$GPU" ]]; then
            curl -sL https://raw.githubusercontent.com/psygreg/linuxtoys-atom/main/src/patches/rusticl-amd \
                | sudo tee -a /etc/environment > /dev/null
        else
            local GPU=$(lspci | grep -Ei 'vga|3d' | grep -Ei 'intel')
            if [[ -n "$GPU" ]]; then
                curl -sL https://raw.githubusercontent.com/psygreg/linuxtoys-atom/main/src/patches/rusticl-intel \
                    | sudo tee -a /etc/environment > /dev/null
            fi
        fi
    fi

}

# obs pipewire audio capture plugin installation
obs_pipe () {

    local ver=$(curl -s "https://api.github.com/repos/dimtpap/obs-pipewire-audio-capture/releases/latest" | grep -oP '"tag_name": "\K(.*)(?=")')
    cd $HOME
    mkdir obspipe
    cd obspipe
    wget https://github.com/dimtpap/obs-pipewire-audio-capture/releases/download/${ver}/linux-pipewire-audio-${ver}-flatpak-30.tar.gz || { echo "Download failed"; cd ..; rm -rf obspipe; return 1; }
    tar xvzf linux-pipewire-audio-${ver}-flatpak-30.tar.gz
    mkdir -p $HOME/.var/app/com.obsproject.Studio/config/obs-studio/plugins/linux-pipewire-audio
    cp -rf linux-pipewire-audio/* $HOME/.var/app/com.obsproject.Studio/config/obs-studio/plugins/linux-pipewire-audio/
    sudo flatpak override --filesystem=xdg-run/pipewire-0 com.obsproject.Studio
    cd ..
    rm -rf obspipe

}

# flatpak packages
install_flatpak () {

    local _flatpaks=($_slar $_obs $_hndbrk $_lact $_fseal $_sc $_qpw $_wrhs)
    if [[ -n "$_flatpaks" ]]; then
        if command -v flatpak &> /dev/null; then
            flatpak_in_lib
            _flatpak_
            if [[ -n "$_hndbrk" ]]; then
                if lspci | grep -iE 'vga|3d' | grep -iq 'intel'; then
                    flatpak install --or-update -y fr.handbrake.ghb.Plugin.IntelMediaSDK --system
                fi
            fi
            if [[ -n "$_efx" ]]; then
                flatpak install --or-update -y $_efx --system
            fi
            if [[ -n "$_gsr" ]]; then
                flatpak install --or-update -y $_gsr --system
            fi
            if [[ -n "$_obs" ]]; then
                obs_pipe
            fi
        else
            if whiptail --title "$msg006" --yesno "$msg085" 8 78; then
                flatpak_run="1"
                flatpak_in_lib
                _flatpak_
                if [[ -n "$_hndbrk" ]]; then
                    if lspci | grep -iE 'vga|3d' | grep -iq 'intel'; then
                        flatpak install --or-update -y fr.handbrake.ghb.Plugin.IntelMediaSDK --system
                    fi
                fi
                if [[ -n "$_efx" ]]; then
                    flatpak install --or-update -y $_efx --system
                fi
                if [[ -n "$_gsr" ]]; then
                    flatpak install --or-update -y $_gsr --system
                fi
                if [[ -n "$_obs" ]]; then
                    obs_pipe
                fi
            else
                local title="$msg030"
                local msg="$msg132"
                _msgbox_
            fi
        fi
    fi

}

# runtime
. /etc/os-release
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/linuxtoys-atom.lib)
_lang_
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/src/lang/${langfile})
usupermenu
