#!/bin/bash
# initialize variables for reboot status
flatpak_run=""
# supermenu checklist
usupermenu () {

    local selection_str
    local selection
    local selected
    local search_item
    local item
    declare -a search_item=(
        "GPU Screen Recorder"
        "OBS Studio"
        "HandBrake"
        "Solaar"
        "OpenRazer"
        "StreamController"
        "OpenRGB"
        "Flatseal"
        "Warehouse"
        "Easy Effects"
        "QPWGraph"
        "LACT"
        "Waydroid"
        "Docker"
        "Rusticl"
        "ROCm"
    )

    while true; do
        selection_str=$(zenity --list --checklist --title="Utilities Menu" \
        	--column="" \
        	--column="Apps" \
            FALSE "GPU Screen Recorder" \
            FALSE "OBS Studio" \
            FALSE "HandBrake" \
            FALSE "Solaar" \
            FALSE "OpenRazer" \
            FALSE "StreamController" \
            FALSE "OpenRGB" \
            FALSE "Flatseal" \
            FALSE "Warehouse" \
            FALSE "Easy Effects" \
            FALSE "QPWGraph" \
            FALSE "LACT" \
            FALSE "Waydroid" \
            FALSE "Docker" \
            FALSE "Rusticl" \
            FALSE "ROCm" \
            --height=720 --width=300 --separator="|")

        if [ $? -ne 0 ]; then
            break
        fi

        IFS='|' read -ra selection <<< "$selection_str"

        # compare array elements
        for item in "${search_item[@]}"; do
            for selected in "${selection[@]}"; do
                if [[ "$selected" == "$item" ]]; then
                # if item is found, set the corresponding variable
                    case $item in
                        "GPU Screen Recorder") _gsr="com.dec05eba.gpu_screen_recorder" ;;
                        "OBS Studio") _obs="com.obsproject.Studio" ;;
                        "HandBrake") _hndbrk="fr.handbrake.ghb" ;;
                        "Solaar") _slar="io.github.pwr_solaar.solaar" ;;
                        "OpenRazer") _oprzr="yes" ;;
                        "StreamController") _sc="com.core447.StreamController" ;;
                        "OpenRGB") _oprgb="org.openrgb.OpenRGB" ;;
                        "Flatseal") _fseal="com.github.tchx84.Flatseal" ;;
                        "Warehouse") _wrhs="io.github.flattool.Warehouse" ;;
                        "Easy Effects") _efx="com.github.wwmm.easyeffects" ;;
                        "QPWGraph") _qpw="org.rncbc.qpwgraph" ;;
                        "LACT") _lact="io.github.ilya_zlobintsev.LACT" ;;
                        "Waydroid") _droid="waydroid" ;;
                        "Docker") _dckr="yes" ;;
                        "Rusticl") _rcl="yes" ;;
                        "ROCm") _rocm="yes" ;;
                    esac
                fi
            done
        done

        install_flatpak
        install_native
        if [[ -n "$flatpak_run" || -n "$_oprzr" || -n "$_rocm" ]]; then
            zenity --info --title="$msg006" --text="$msg036" --height=300 --width=300
        else
            zenity --info --title="$msg006" --text="$msg018" --height=300 --width=300
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
        rm docker-ce.repo
        _packages+=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)
    fi
    # add openrazer
    if [[ -n "$_oprzr" ]]; then
        curl -O https://openrazer.github.io/hardware:razer.repo
        sudo install -o 0 -g 0 -m644 hardware:razer.repo /etc/yum.repos.d/hardware:razer.repo
        rm razer.repo
        _packages+=(openrazer-meta kernel-devel)
    fi
    # add mesa openCL
    if [[ -n "$_rcl" ]]; then
        _packages+=(mesa-libOpenCL clinfo)
    fi
    # add ROCm
    if [[ -n "$_rocm" ]]; then
        _packages+=(rocm-comgr rocm-runtime rccl rocalution rocblas rocfft rocm-smi rocsolver rocsparse rocm-device-libs rocminfo rocm-hip hiprand rocm-opencl clinfo)
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
            if zenity --question --title "$msg006" --text "$msg085" --height=300 --width=300; then
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
                nonfatal "$msg132"
            fi
        fi
    fi

}

# runtime
. /etc/os-release
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/linuxtoys-atom.lib)
_lang_
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/src/lang/${langfile})
sleep 1
usupermenu
