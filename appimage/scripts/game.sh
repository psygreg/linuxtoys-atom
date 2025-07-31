#!/bin/bash
# initialize variables for reboot status
flatpak_run=""
sboost_run=""

# supermenu checklist
gsupermenu () {

    local selection_str
    local selection
    local selected
    local item
    local search_item
    declare -a search_item=(
        "Steam"
        "Lutris"
        "Heroic Games Launcher"
        "ProtonPlus"
        "SteamTinkerLaunch"
        "Sober"
        "Osu!"
        "Bedrock Launcher"
        "Discord"
        "Gamemode"
        "Lossless Scaling - LSFG-VK"
        "Gamescope"
        "Mangohud"
        "GOverlay"
        "GeForce NOW"
        "Shader Booster"
        "Oversteer"
        "WiVRn"
        "Wine - ${msg112}" # custom runners
    )

    while true; do

        selection_str=$(zenity --list --checklist --title="Gaming Menu" \
        	--column="" \
        	--column="Apps" \
            FALSE "Steam" \
            FALSE "Lutris" \
            FALSE "Heroic Games Launcher" \
            FALSE "ProtonPlus" \
            FALSE "SteamTinkerLaunch" \
            FALSE "Sober" \
            FALSE "Osu!" \
            FALSE "Bedrock Launcher" \
            FALSE "Discord" \
            FALSE "Gamemode" \
            FALSE "Lossless Scaling - LSFG-VK" \
            FALSE "Gamescope" \
            FALSE "Mangohud" \
            FALSE "GOverlay" \
            FALSE "GeForce NOW App" \
            FALSE "Shader Booster" \
            FALSE "Oversteer" \
            FALSE "WiVRn" \
            FALSE "Wine - ${msg112}" \
            --height=810 --width=360 --separator="|")

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
                        "Steam") _steam="com.valvesoftware.Steam" ;;
                        "Lutris") _lutris="net.lutris.Lutris" ;;
                        "Heroic Games Launcher") _heroic="com.heroicgameslauncher.hgl" ;;
                        "ProtonPlus") _pp="com.vysp3r.ProtonPlus" ;;
                        "SteamTinkerLaunch") _stl="com.valvesoftware.Steam.Utility.steamtinkerlaunch" ;;
                        "Sober") _sobst="org.vinegarhq.Sober" ;;
                        "Osu!") _osuf="sh.ppy.osu" ;;
                        "Bedrock Launcher") _mcbe="io.mrarm.mcpelauncher" ;;
                        "Discord") _disc="com.discordapp.Discord" ;;
                        "Gamemode") _gmode="gamemode" ;;
                        "Lossless Scaling - LSFG-VK") _lsfgvk="yes" ;;
                        "Gamescope") _gscope="gamescope" ;;
                        "Mangohud") _mhud="mangohud" ;;
                        "GOverlay") _govl="goverlay" ;;
                        "Shader Booster") _sboost="yes" ;;
                        "WiVRn") _wivrn="io.github.wivrn.wivrn" ;;
                        "Oversteer") _steer="io.github.berarma.Oversteer" ;;
                        "GeForce NOW") _gfn="yes" ;;
                        "Wine - ${msg112}") _runner="runners" ;;
                    esac
                fi
            done
        done

        install_flatpak
        install_native
        # custom runners
        if [[ -n "$_runner" ]]; then
            local script="$_runner" && _invoke_app_
        fi
        # shader booster
        if [ ! -f /.autopatch.state ]; then
            if [[ -n "$_sboost" ]]; then
                local script="shader-patcher-atom" && _invoke_
                sboost_run="1"
            fi
        fi
        # lossless scaling
        if [[ -n "$_lsfgvk" ]]; then
            lsfg_vk_in
        fi
        # check if reboot is needed
        if [[ -n "$flatpak_run" || -n "$dsplitm_run" || -n "$sboost_run" ]]; then
            zenity --info --title "$msg006" --text "$msg036" --height=300 --width=300
        else
            zenity --info --title "$msg006" --text "$msg018" --height=300 --width=300
        fi
        break

    done

}

# installer functions
# native packages
install_native () {

    local _packages=($_gmode $_govl $_gscope $_mhud)
    _install_
    # add proper versions of gamescope and mangohud on flatpak runtimes
    if [[ -n "$_gscope" ]]; then
        if command -v flatpak &> /dev/null; then
            flatpak install --or-update --system -y org.freedesktop.Platform.VulkanLayer.gamescope/x86_64/23.08 org.freedesktop.Platform.VulkanLayer.gamescope/x86_64/24.08
        fi
    fi
    if [[ -n "$_mhud" ]]; then
        if command -v flatpak &> /dev/null; then
            flatpak install --or-update --system -y com.valvesoftware.Steam.VulkanLayer.MangoHud/x86_64/stable org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/23.08 org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08
        fi
    fi

}

# flatpak packages
install_flatpak () {

    local _flatpaks=($_lutris $_heroic $_pp $_stl $_sobst $_disc $_wivrn $_steer $_mcbe $_osuf)
    if [[ -n "$_flatpaks" ]] || [[ -n "$_steam" ]] || [[ -n "$_gfn" ]]; then
        if command -v flatpak &> /dev/null; then
            flatpak_in_lib
            _flatpak_
            # add repository and install GFN app
            if [[ -n "$_gfn" ]]; then
                flatpak remote-add --user --if-not-exists GeForceNOW
                flatpak install -y --user GeForceNOW com.nvidia.geforcenow
            fi
            # add udev rules for Oversteer
            if [[ -n "$_steer" ]]; then
                sudo wget https://github.com/berarma/oversteer/raw/refs/heads/master/data/udev/99-fanatec-wheel-perms.rules -P /etc/udev/rules.d
                sudo wget https://github.com/berarma/oversteer/raw/refs/heads/master/data/udev/99-logitech-wheel-perms.rules -P /etc/udev/rules.d
                sudo wget https://github.com/berarma/oversteer/raw/refs/heads/master/data/udev/99-thrustmaster-wheel-perms.rules -P /etc/udev/rules.d
                zenity --info --title "Oversteer" --text "$msg146" --height=300 --width=300
                xdg-open https://github.com/berarma/oversteer?tab=readme-ov-file#supported-devices
            fi
            # warning about purchase requirement for Bedrock Launcher
            if [[ -n "$_mcbe" ]]; then
                zenity --warning --title "Bedrock Launcher" --text "$msg161" --height=300 --width=300
            fi
        else
            if zenity --question --title "$msg006" --text "$msg085" --height=300 --width=300; then
                flatpak_run="1"
                flatpak_in_lib
                _flatpak_
                if [[ -n "$_gfn" ]]; then
                    flatpak remote-add --user --if-not-exists GeForceNOW
                    flatpak install -y --user GeForceNOW com.nvidia.geforcenow
                fi
                if [[ -n "$_steer" ]]; then
                    sudo wget https://github.com/berarma/oversteer/raw/refs/heads/master/data/udev/99-fanatec-wheel-perms.rules -P /etc/udev/rules.d
                    sudo wget https://github.com/berarma/oversteer/raw/refs/heads/master/data/udev/99-logitech-wheel-perms.rules -P /etc/udev/rules.d
                    sudo wget https://github.com/berarma/oversteer/raw/refs/heads/master/data/udev/99-thrustmaster-wheel-perms.rules -P /etc/udev/rules.d
                    zenity --info --title "Oversteer" --text "$msg146" --height=300 --width=300
                    xdg-open https://github.com/berarma/oversteer?tab=readme-ov-file#supported-devices
                fi
                if [[ -n "$_mcbe" ]]; then
                    zenity --warning --title "Bedrock Launcher" --text "$msg161" --height=300 --width=300
                fi
            else
                nonfatal "$msg132"
            fi
        fi
    fi

}

# install lsfg-vk and flatpak runtimes
lsfg_vk_in () {

    local tag=$(curl -s "https://api.github.com/repos/PancakeTAS/lsfg-vk/releases/latest" | grep -oP '"tag_name": "\K(.*)(?=")')
    local ver="${tag#v}"
    if rpm -qi lsfg-vk &> /dev/null; then
        if [[ "$(rpm -q --queryformat '%{VERSION}' lsfg-vk)" != "$ver" ]]; then
            wget https://github.com/PancakeTAS/lsfg-vk/releases/download/${tag}/lsfg-vk-${ver}.x86_64.rpm
            rpm-ostree install -yA lsfg-vk-${ver}.x86_64.rpm
            if command -v flatpak &> /dev/null; then
                wget https://github.com/PancakeTAS/lsfg-vk/releases/download/${tag}/org.freedesktop.Platform.VulkanLayer.lsfg_vk_23.08.flatpak
                wget https://github.com/PancakeTAS/lsfg-vk/releases/download/${tag}/org.freedesktop.Platform.VulkanLayer.lsfg_vk_24.08.flatpak
                flatpak install --reinstall --user -y ./org.freedesktop.Platform.VulkanLayer.lsfg_vk_23.08.flatpak 
                flatpak install --reinstall --user -y ./org.freedesktop.Platform.VulkanLayer.lsfg_vk_24.08.flatpak
                rm org.freedesktop.Platform.VulkanLayer.lsfg_vk_23.08.flatpak
                rm org.freedesktop.Platform.VulkanLayer.lsfg_vk_24.08.flatpak
                local flatapps=(net.lutris.Lutris com.valvesoftware.Steam com.heroicgameslauncher.hgl org.prismlauncher.PrismLauncher com.stremio.Stremio at.vintagestory.VintageStory org.vinegarhq.Sober)
                for flatapp in "${flatapps[@]}"; do
                    if flatpak info "$flatapp" &> /dev/null; then
                        flatpak override --user --filesystem=$HOME/.config/lsfg-vk:rw "$flatapp"
                        flatpak override --user --env=LSFG_CONFIG=$HOME/.config/lsfg-vk/conf.toml "$flatapp"
                        if [ "$flatapp" != "com.valvesoftware.Steam" ]; then
                            flatpak override --user --filesystem="$DLL_ABSOLUTE_PATH:ro" "$flatapp"
                        fi
                    fi
                done
            fi
            rm lsfg-vk-1.0.0.x86_64.rpm
        else
            zenity --info --text "LSFG-VK - $msg278" --height=300 --width=300
        fi
    else
        wget https://github.com/PancakeTAS/lsfg-vk/releases/download/v1.0.0/lsfg-vk-1.0.0.x86_64.rpm
        rpm-ostree install -yA lsfg-vk-1.0.0.x86_64.rpm
        rm lsfg-vk-1.0.0.x86_64.rpm
        DLL_FIND="$(find / -name Lossless.dll 2>/dev/null | head -n 1)"
        if [ -z "$DLL_FIND" ]; then
            nonfatal "Lossless.dll not found. Did you install Lossless Scaling?"
            return 1
        fi
        DLL_ABSOLUTE_PATH=$(dirname "$(realpath "$DLL_FIND")")
        ESCAPED_DLL_PATH=$(printf '%s\n' "$DLL_ABSOLUTE_PATH" | sed 's/[&/\]/\\&/g')
        CONF_LOC="${HOME}/.config/lsfg-vk/conf.toml"
        if [ ! -f "$CONF_LOC" ]; then
            # make sure target dir exists
            mkdir -p ${HOME}/.config/lsfg-vk/
            wget https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/src/patches/conf.toml
            mv conf.toml ${HOME}/.config/lsfg-vk/
        fi
        # register dll location in config file
        sed -i -E "s|^# dll = \".*\"|dll = \"$ESCAPED_DLL_PATH\"|" ${HOME}/.config/lsfg-vk/conf.toml
        # flatpak runtime
        if command -v flatpak &> /dev/null; then
            wget https://github.com/PancakeTAS/lsfg-vk/releases/download/${tag}/org.freedesktop.Platform.VulkanLayer.lsfg_vk_23.08.flatpak
            wget https://github.com/PancakeTAS/lsfg-vk/releases/download/${tag}/org.freedesktop.Platform.VulkanLayer.lsfg_vk_24.08.flatpak
            flatpak install --reinstall --user -y ./org.freedesktop.Platform.VulkanLayer.lsfg_vk_23.08.flatpak 
            flatpak install --reinstall --user -y ./org.freedesktop.Platform.VulkanLayer.lsfg_vk_24.08.flatpak
            rm org.freedesktop.Platform.VulkanLayer.lsfg_vk_23.08.flatpak
            rm org.freedesktop.Platform.VulkanLayer.lsfg_vk_24.08.flatpak
            local flatapps=(net.lutris.Lutris com.valvesoftware.Steam com.heroicgameslauncher.hgl org.prismlauncher.PrismLauncher com.stremio.Stremio at.vintagestory.VintageStory org.vinegarhq.Sober)
            for flatapp in "${flatapps[@]}"; do
                if flatpak info "$flatapp" &> /dev/null; then
                    flatpak override --user --filesystem=$HOME/.config/lsfg-vk:rw "$flatapp"
                    flatpak override --user --env=LSFG_CONFIG=$HOME/.config/lsfg-vk/conf.toml "$flatapp"
                    if [ "$flatapp" != "com.valvesoftware.Steam" ]; then
                        flatpak override --user --filesystem="$DLL_ABSOLUTE_PATH:ro" "$flatapp"
                    fi
                fi
            done
        fi
        rm lsfg-vk-1.0.0.x86_64.rpm
    fi

}

# runtime
source linuxtoys-atom.lib
_lang_
source ${langfile}
sleep 1
gsupermenu
