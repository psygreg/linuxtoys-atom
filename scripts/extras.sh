#!/bin/bash

# set up firewall (firewall-config)
ufw_in () {

    if zenity --question --title "$msg006" --text "$msg007" --height=300 --width=300; then
        local _packages=(firewall-config)
        _install_
        zenity --info --title "$msg006" --text "$msg008" --height=300 --width=300
    fi

}

# better font settings for people with reduced eyesight for Linux
lucidglyph_in () {

    local tag=$(curl -s "https://api.github.com/repos/maximilionus/lucidglyph/releases/latest" | grep -oP '"tag_name": "\K(.*)(?=")')
    local ver="${tag#v}"
    if zenity --question --title "$msg019" --text "$msg020" --height=300 --width=300; then
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
        zenity --info --title "$msg021" --text "$msg022" --height=300 --width=300
    fi

}

# enable signing of kernel modules (akmods) like Nvidia and VirtualBox
akmod_sb () {

    if ! rpm -qi "akmods-keys" &>/dev/null; then
        if zenity --question --title "$msg006" --text "$msg267" --height=300 --width=300; then
            _packages=(rpmdevtools akmods)
            _install_
            sudo kmodgenca
            sudo mokutil --import /etc/pki/akmods/certs/public_key.der
            git clone https://github.com/CheariX/silverblue-akmods-keys
            cd silverblue-akmods-keys
            sudo bash setup.sh
            rpm-ostree install akmods-keys-0.0.2-8.fc$(rpm -E %fedora).noarch.rpm
            zenity --info --title "$msg006" --text "$msg268" --height=300 --width=300
            exit 0
        fi
    else
        nonfatal "$msg234"
    fi

}

# Nvidia driver installer for Fedora/SUSE/Debian - it is a montrosity, but it works, trust me bro
nvidia_in () {

    local GPU=$(lspci | grep -iE 'vga|3d' | grep -i nvidia)
    if [[ -n "$GPU" ]]; then
        while true; do

            CHOICE=$(zenity --list --title="Nvidia Drivers" \
                --column="$msg067" \
                "$msg269" \
                "$msg068" \
                "$msg069" \
                "$msg070" \
                --width=320 --height=360)

            if [ $? -ne 0 ]; then
                break
            fi

            case $CHOICE in
            "$msg068" | "$msg269") if ! rpm -qi "rpmfusion-free-release" &>/dev/null; then
                    sudo rpm-ostree install -yA https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
                fi
                if ! rpm -qi "rpmfusion-nonfree-release" &>/dev/null; then
                    sudo rpm-ostree install -yA https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
                fi
                if sudo mokutil --sb-state | grep -q "SecureBoot enabled"; then
                    if ! rpm -qi "akmods-keys" &>/dev/null; then
                        _packages=(rpmdevtools akmods)
                        _install_
                        sudo kmodgenca
                        sudo mokutil --import /etc/pki/akmods/certs/public_key.der
                        git clone https://github.com/CheariX/silverblue-akmods-keys
                        cd silverblue-akmods-keys
                        sudo bash setup.sh
                        rpm-ostree install -yA akmods-keys-0.0.2-8.fc$(rpm -E %fedora).noarch.rpm
                    fi
                fi
                rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia-cuda
                sudo rpm-ostree kargs --append=rd.driver.blacklist=nouveau,nova_core --append=modprobe.blacklist=nouveau --append=nvidia-drm.modeset=1
                zenity --info --title "Nvidia Drivers" --text "$msg036" --width 300 --height 300
                exit 0 ;;
            "$msg069") if ! rpm -qi "rpmfusion-free-release" &>/dev/null; then
                    sudo rpm-ostree install -yA https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
                fi
                if ! rpm -qi "rpmfusion-nonfree-release" &>/dev/null; then
                    sudo rpm-ostree install -yA https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
                fi
                if sudo mokutil --sb-state | grep -q "SecureBoot enabled"; then
                    if ! rpm -qi "akmods-keys" &>/dev/null; then
                        _packages=(rpmdevtools akmods)
                        _install_
                        sudo kmodgenca
                        sudo mokutil --import /etc/pki/akmods/certs/public_key.der
                        git clone https://github.com/CheariX/silverblue-akmods-keys
                        cd silverblue-akmods-keys
                        sudo bash setup.sh
                        rpm-ostree install -yA akmods-keys-0.0.2-8.fc$(rpm -E %fedora).noarch.rpm
                    fi
                fi
                rpm-ostree install xorg-x11-drv-nvidia-470xx akmod-nvidia-470xx xorg-x11-drv-nvidia-470xx-cuda
                sudo rpm-ostree kargs --append=rd.driver.blacklist=nouveau,nova_core --append=modprobe.blacklist=nouveau --append=nvidia-drm.modeset=1
                zenity --info --title "Nvidia Drivers" --text "$msg036" --width 300 --height 300
                exit 0;;
            "$msg070") break ;;
            *) echo "Invalid Option" ;;
            esac

        done

    else
        nonfatal "$msg077"
    fi

}

# install proper codec support
codecfixes () {

    if [ ! -f /.autopatch.state ]; then
        if zenity --question --title "$msg006" --text "$msg080" --height=300 --width=300; then
            _packages=("libavcodec-freeworld")
            _install_
        fi
    else
        nonfatal "$msg234"
    fi

}

# linux kernel power saving optimized settings when on battery
psaver () {

    if [ ! -f /.autopatch.state ]; then
        if zenity --question --title "$msg006" --text "$msg176" --height=300 --width=300; then
            psave_lib
        fi
    else
        nonfatal "$msg234"
    fi

}

# enable rpm-ostree automatic updating
ostree_autoupd () {

    if [ ! -f /.autopatch.state ]; then
        if zenity --question --title "OSTree Auto-Update" --text "$msg263" --height=300 --width=300; then
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
        nonfatal "$msg234"
    fi

}

# optimized systemd configuration files from CachyOS
optimizer_ () {

    if [ ! -f /.autopatch.state ]; then
        if zenity --question --title "$msg006" --text "$msg257" --height=300 --width=300; then
            wget https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/linuxtoys-cfg-atom/rpmbuild/RPMS/x86_64/linuxtoys-cfg-atom-1.0-1.x86_64.rpm
            rpm-ostree install -yA linuxtoys-cfg-atom-1.0-1.x86_64.rpm
            rm linuxtoys-cfg-atom-1.0-1.x86_64.rpm
            zenity --info --title "$msg006" --text "$msg036" --height=300 --width=300
        fi
    else
        nonfatal "$msg234"
    fi

}

# inet wireless daemon installer
iwd_summon () {

    if zenity --question --title "iNet Wireless Daemon" --text "$msg244" --height=300 --width=300; then
        zenity --warning --title "iNet Wireless Daemon" --text "$msg243" --height=300 --width=300
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

    zenity --text-info \
       --title="LSW" \
       --filename=txtbox \
       --checkbox="$msg276" \
       --width=400 --height=360
    
    if zenity --question --title "LSW" --text "$msg217" --height=300 --width=300; then
        cd $HOME
        bash <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/lsw-atom/lsw-in-atom.sh)
        sleep 1
        rm txtbox
    fi

}

# install RPMFusion
rpmfusion_in () {

    if [ ! -f /.autopatch.state ]; then
        if zenity --question --title "RPMFusion" --text "$msg266" --height=300 --width=300; then
            local rpmfusion_status="$(rpm-ostree status | grep rpmfusion)"
            if [ -n "$rpmfusion_status" ]; then
                sudo rpm-ostree install -yA https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
            fi
        fi
    else
        nonfatal "$msg234"
    fi

}

# photogimp - for those who already have GIMP installed
photogimp_in () {

    if zenity --question --title "PhotoGIMP" --text "$msg271" --height=300 --width=300; then
        if flatpak list --app | grep -q org.gimp.GIMP; then
            zenity --info --title "PhotoGIMP" --text "$msg272" --height=300 --width=300
            flatpak run org.gimp.GIMP & sleep 1
            PID=($(pgrep -f "gimp"))
            if [ -z "$PID" ]; then
                echo "Failed to find Flatpak process."
                return 1
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
        else
            nonfatal "$msg273"
        fi
    fi

}

# runtime
. /etc/os-release
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/linuxtoys-atom.lib)
_lang_
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/src/lang/${langfile})
sleep 1
# extras menu
while :; do

    CHOICE=$(zenity --list --title="Extras" \
        --column="" \
        "$msg044" \
        "$msg048" \
        "PhotoGIMP" \
        "$msg258" \
        "$msg177" \
        "iNet Wireless Daemon" \
        "$msg265" \
        "$msg260" \
        "$msg264" \
        "$msg270" \
        "$msg078" \
        "$msg209" \
        "$msg059" \
        --width=500 --height=550)

    if [ $? -ne 0 ]; then
        break
    fi

    case $CHOICE in
        "$msg044") ufw_in ;;
        "$msg048") lucidglyph_in ;;
        "PhotoGIMP") photogimp_in ;;
        "$msg258") optimizer_ ;;
        "$msg177") psaver ;;
        "iNet Wireless Daemon") iwd_summon ;;
        "$msg265") rpmfusion_in ;;
        "$msg260") codecfixes ;;
        "$msg264") ostree_autoupd ;;
        "$msg270") akmod_sb ;;
        "$msg078") nvidia_in ;;
        "$msg209") lsw_in ;;
        "$msg059") break ;;
        *) echo "Invalid Option" ;;
    esac
done
