#!/bin/bash
# consolidated installation
optimizer () {

    if [ ! -f /.autopatch.state ]; then
        # filtered cachyos systemd configs
        wget https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/linuxtoys-cfg-atom/rpmbuild/RPMS/x86_64/linuxtoys-cfg-atom-1.0-1.x86_64.rpm
        rpm-ostree install -yA linuxtoys-cfg-atom-1.0-1.x86_64.rpm
        # shader booster
        local script="shader-patcher-atom" && _invoke_
        # automatic updating
        local AUTOPOLICY="stage"
        sudo cp /etc/rpm-ostreed.conf /etc/rpm-ostreed.conf.bak
        if grep -q "^AutomaticUpdatePolicy=" /etc/rpm-ostreed.conf; then
            sudo sed -i "s/^AutomaticUpdatePolicy=.*/AutomaticUpdatePolicy=${AUTOPOLICY}/" /etc/rpm-ostreed.conf
        else
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
        sudo systemctl enable rpm-ostreed-automatic.timer --now
        # install rpmfusion if absent
        local rpmfusion_status="$(rpm-ostree status | grep rpmfusion)"
        if [ -n "$rpmfusion_status" ]; then
            sudo rpm-ostree install -yA https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        fi
        # save autopatch state
        wget https://raw.githubusercontent.com/psygreg/linuxtoys/refs/heads/main/src/resources/other/autopatch.state
        sudo mv autopatch.state /.autopatch.state
    else
        local title="AutoPatcher"
        local msg="$msg234"
        _msgbox_
    fi

}

# end messagebox
end_msg () {

    local title="$msg006"
    local msg="$msg036"
    _msgbox_

}

# runtime
. /etc/os-release
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys/refs/heads/main/src/linuxtoys.lib)
# language
_lang_
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys/refs/heads/main/src/lang/${langfile})
# menu
while :; do

    CHOICE=$(whiptail --title "Power Optimizer" --menu "$msg229" 25 78 16 \
        "0" "Desktop" \
        "1" "Laptop" \
        "2" "Cancel" 3>&1 1>&2 2>&3)

    exitstatus=$?
    if [ $exitstatus != 0 ]; then
        # Exit the script if the user presses Esc
        break
    fi

    case $CHOICE in
    0) optimizer && end_msg && break ;;
    1) optimizer && psave_lib && end_msg && break ;;
    2 | q) break ;;
    *) echo "Invalid Option" ;;
    esac
done
