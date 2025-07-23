#!/bin/bash

# set up firewall (firewall-config)
ufw_in () {

    if whiptail --title "$msg006" --yesno "$msg007" 8 78; then
        local _packages=(firewall-config)
        _install_
        local title="$msg006"
        local msg="$msg008"
        _msgbox_
    fi

}

# better font settings for people with reduced eyesight for Linux
lucidglyph_in () {

    local tag=$(curl -s "https://api.github.com/repos/maximilionus/lucidglyph/releases/latest" | grep -oP '"tag_name": "\K(.*)(?=")')
    local ver="${tag#v}"
    if whiptail --title "$msg019" --yesno "$msg020" 8 78; then
        cd $HOME
        [ -f "${tag}.tar.gz" ] && rm -f "${tag}.tar.gz"
        wget -O "${tag}.tar.gz" "https://github.com/maximilionus/lucidglyph/archive/refs/tags/${tag}.tar.gz"
        tar -xvzf "${tag}.tar.gz"
        cd lucidglyph-${ver}
        chmod +x lucidglyph.sh
        ./lucidglyph.sh --user
        cd ..
        sleep 1
        rm -rf lucidglyph-${ver}
        local title="$msg021"
        local msg="$msg022"
        _msgbox_
    fi

}

# Nvidia driver installer for Fedora/SUSE/Debian - it is a montrosity, but it works, trust me bro
## TODO make compatible with secure boot
nvidia_in () {

    local title="$msg006"
    local msg="$msg259"
    _msgbox_
    local GPU=$(lspci | grep -iE 'vga|3d' | grep -i nvidia)
    if [[ -n "$GPU" ]]; then
        while :; do

            CHOICE=$(whiptail --title "$msg006" --menu "$msg067" 25 78 16 \
            "0" "$msg068" \
            "1" "$msg069" \
            "2" "$msg070" 3>&1 1>&2 2>&3)

            exitstatus=$?
            if [ $exitstatus != 0 ]; then
                # Exit the script if the user presses Esc
                return
            fi

            case $CHOICE in
            0) local rpmfusion_status="$(rpm-ostree status | grep rpmfusion)"
                if [ -n "$rpmfusion_status" ]; then
                    sudo rpm-ostree install -yA https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
                fi
                rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia-cuda
                sudo rpm-ostree kargs --append=rd.driver.blacklist=nouveau,nova_core --append=modprobe.blacklist=nouveau --append=nvidia-drm.modeset=1 ;;
            1) local rpmfusion_status="$(rpm-ostree status | grep rpmfusion)"
                if [ -n "$rpmfusion_status" ]; then
                    sudo rpm-ostree install -yA https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
                fi
                rpm-ostree install xorg-x11-drv-nvidia-470xx akmod-nvidia-470xx xorg-x11-drv-nvidia-470xx-cuda
                sudo rpm-ostree kargs --append=rd.driver.blacklist=nouveau,nova_core --append=modprobe.blacklist=nouveau --append=nvidia-drm.modeset=1 ;;
            2 | q) break ;;
            *) echo "Invalid Option" ;;
            esac

        done

    else
        local title="$msg039"
        local msg="$msg077"
        _msgbox_
    fi

}

# install proper codec support
codecfixes () {

    if whiptail --title "$msg006" --yesno "$msg080" 8 78; then
        _packages=("libavcodec-freeworld")
        _install_
    fi

}

# linux kernel power saving optimized settings when on battery
psaver () {

    if [ ! -f /.autopatch.state ]; then
        if whiptail --title "$msg006" --yesno "$msg176" 12 78; then
            psave_lib
        fi
    else
        local title="AutoPatcher"
        local msg="$msg234"
        _msgbox_
    fi

}

# enable rpm-ostree automatic updating
ostree_autoupd () {

    if [ ! -f /.autopatch.state ]; then
        if whiptail --title "OSTree Auto-Update" --yesno "$msg263" 12 78; then
            AUTOPOLICY="stage"
            # backup original config
            sudo cp /etc/rpm-ostreed.conf /etc/rpm-ostreed.conf.bak
            # update or insert the AutomaticUpdatePolicy line using sudo tee
            if grep -q "^AutomaticUpdatePolicy=" /etc/rpm-ostreed.conf; then
                # Replace existing line
                sudo sed -i "s/^AutomaticUpdatePolicy=.*/AutomaticUpdatePolicy=${AUTOPOLICY}/" /etc/rpm-ostreed.conf
            else
                # Append under the [Daemon] section
                sudo awk -v policy="$AUTOPOLICY" '
                /^\[Daemon\]/ {
                    print
                    print "AutomaticUpdatePolicy=" policy
                    next
                }
                { print }
                ' /etc/rpm-ostreed.conf | sudo tee /etc/rpm-ostreed.conf > /dev/null
            fi
            echo "AutomaticUpdatePolicy set to: $AUTOPOLICY"
            # enable timer service
            sudo systemctl enable rpm-ostreed-automatic.timer --now
        fi
    else
        local title="AutoPatcher"
        local msg="$msg234"
        _msgbox_
    fi

}

# optimized systemd configuration files from CachyOS
optimizer_ () {

    if [ ! -f /.autopatch.state ]; then
        if whiptail --title "$msg006" --yesno "$msg257" 8 78; then
            wget https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/linuxtoys-cfg-atom/rpmbuild/RPMS/x86_64/linuxtoys-cfg-atom-1.0-1.x86_64.rpm
            rpm-ostree install -yA linuxtoys-cfg-atom-1.0-1.x86_64.rpm
            local title="$msg006"
            local msg="$msg036"
            _msgbox_
        fi
    else
        local title="AutoPatcher"
        local msg="$msg234"
        _msgbox_
    fi

}

# inet wireless daemon installer
iwd_summon () {

    if whiptail --title "iNet Wireless Daemon" --yesno "$msg244" 12 78; then
        local title="iNet Wireless Daemon"
        local msg="$msg243"
        _msgbox_
        local script="iwdwifi" && _invoke_
    fi

}

# install linux subsystem for windows
lsw_in () {

    {
        echo "$msg209"
        echo "$msg210"
        echo "$msg211"
        echo "$msg212"
        echo "$msg213"
        echo "$msg214"
        echo "$msg215"
        echo "$msg216"
    } > txtbox
    whiptail --textbox txtbox 12 80
    if whiptail --title "LSW" --yesno "$msg217" 12 78; then
        cd $HOME
        bash <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/lsw-atom/lsw-in-atom.sh)
        sleep 1
        rm txtbox
    fi

}

# install lsfg-vk

lsfg_vk_in () {

    local title="LSFG-VK"
    local msg="$msg251"
    _msgbox_
    if whiptail --title "LSFG-VK" --yesno "$msg250" 12 78; then
        # add check for DLL location
        DLL_FIND="$(find / -name Lossless.dll 2>/dev/null | head -n 1)"
        if [ -z "$DLL_FIND" ]; then
            local title="LSFG-VK"
            local msg="Lossless.dll not found. Did you install Lossless Scaling?"
            _msgbox_
            return 1
        fi
        curl -sSf https://pancake.gay/lsfg-vk.sh | sh
        if [ $? -eq 0 ]; then
            # check flatpaks
            if command -v flatpak &> /dev/null; then
                curl -fsSL https://raw.githubusercontent.com/psygreg/lsfg-vk-flatpak/main/flatpak-enabler.sh | bash
            fi
            local title="LSFG-VK"
            local msg="$msg249"
            _msgbox_
            xdg-open https://github.com/PancakeTAS/lsfg-vk/wiki/Configuring-lsfg%E2%80%90vk
        fi
    fi

}

# install RPMFusion
rpmfusion_in () {

    if [ ! -f /.autopatch.state ]; then
        if whiptail --title "RPMFusion" --yesno "$msg266" 12 78; then
            local rpmfusion_status="$(rpm-ostree status | grep rpmfusion)"
            if [ -n "$rpmfusion_status" ]; then
                sudo rpm-ostree install -yA https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
            fi
        fi
    else
        local title="AutoPatcher"
        local msg="$msg234"
        _msgbox_
    fi

}

# runtime
. /etc/os-release
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/linuxtoys-atom.lib)
_lang_
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/src/lang/${langfile})
# extras menu
while :; do

    CHOICE=$(whiptail --title "Extras Supermenu" --menu "LinuxToys ${current_ltver}" 25 78 16 \
        "0" "$msg044" \
        "1" "$msg048" \
        "2" "$msg248" \
        "3" "$msg258" \
        "4" "$msg177" \
        "5" "iNet Wireless Daemon" \
        "6" "$msg265" \
        "7" "$msg260" \
        "8" "$msg264" \
        "9" "$msg078" \
        "10" "$msg209" \
        "11" "$msg059" 3>&1 1>&2 2>&3)

    exitstatus=$?
    if [ $exitstatus != 0 ]; then
        # Exit the script if the user presses Esc
        break
    fi

    case $CHOICE in
    0) ufw_in ;;
    1) lucidglyph_in ;;
    2) lsfg_vk_in ;;
    3) optimizer_ ;;
    4) psaver ;;
    5) iwd_summon ;;
    6) rpmfusion_in ;;
    7) codecfixes ;;
    8) ostree_autoupd ;;
    9) nvidia_in ;;
    10) lsw_in ;;
    11 | q) break ;;
    *) echo "Invalid Option" ;;
    esac
done
