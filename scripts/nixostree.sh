#!/bin/bash
# functions
prep_point () {

sudo tee /etc/ostree/prepare-root.conf <<'EOL'
[composefs]
enabled = yes
[root]
transient = true
EOL
    echo "NIXOSTREE_STATUS=1" > $HOME/.nixostree
    zenity --info --text "Initial mountpoint setup complete. Run this installer again after the reboot to finish installing NixPKGs. Your system will reboot now." --width 360 --height 300
    systemctl reboot

}

selinux_prep () {

    # add SELinux rules for nixpkgs
    sudo semanage fcontext -a -t etc_t '/nix/store/[^/]+/etc(/.*)?'
    sudo semanage fcontext -a -t lib_t '/nix/store/[^/]+/lib(/.*)?'
    sudo semanage fcontext -a -t systemd_unit_file_t '/nix/store/[^/]+/lib/systemd/system(/.*)?'
    sudo semanage fcontext -a -t man_t '/nix/store/[^/]+/man(/.*)?'
    sudo semanage fcontext -a -t bin_t '/nix/store/[^/]+/s?bin(/.*)?'
    sudo semanage fcontext -a -t usr_t '/nix/store/[^/]+/share(/.*)?'
    sudo semanage fcontext -a -t var_run_t '/nix/var/nix/daemon-socket(/.*)?'
    sudo semanage fcontext -a -t usr_t '/nix/var/nix/profiles(/per-user/[^/]+)?/[^/]+'
    # also for /var/lib/nix
    sudo semanage fcontext -a -t etc_t '/var/lib/nix/store/[^/]+/etc(/.*)?' 
    sudo semanage fcontext -a -t lib_t '/var/lib/nix/store/[^/]+/lib(/.*)?'
    sudo semanage fcontext -a -t systemd_unit_file_t '/var/lib/nix/store/[^/]+/lib/systemd/system(/.*)?'
    sudo semanage fcontext -a -t man_t '/var/lib/nix/store/[^/]+/man(/.*)?'
    sudo semanage fcontext -a -t bin_t '/var/lib/nix/store/[^/]+/s?bin(/.*)?'
    sudo semanage fcontext -a -t usr_t '/var/lib/nix/store/[^/]+/share(/.*)?'
    sudo semanage fcontext -a -t var_run_t '/var/lib/nix/var/nix/daemon-socket(/.*)?'
    sudo semanage fcontext -a -t usr_t '/var/lib/nix/var/nix/profiles(/per-user/[^/]+)?/[^/]+'

}

dir_prep () {

    sudo chattr -i /
    sleep 1
    sudo mkdir -p /nix
    sleep 1
    sudo chattr +i /
    sleep 1
    sudo mkdir -p /var/lib/nix
    # set SSL certificate for Nix
    wget https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/src/patches/override.conf
    sudo mkdir -p /etc/systemd/system/nix-daemon.service.d
    sudo mv -f override.conf /etc/systemd/system/nix-daemon.service.d/
    # set up systemd services for ostree
    wget https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/src/patches/mkdir-rootfs@.service
    wget https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/src/patches/nix.mount
    sudo mv -f mkdir-rootfs@.service /etc/systemd/system/
    sudo mv -f nix.mount /etc/systemd/system/
    # refresh and enable new services
    sleep 1
    sudo systemctl daemon-reload
    sleep 4
    sudo systemctl enable nix.mount
    sudo systemctl start nix.mount
    sudo restorecon -RF /nix

}

# protection against user stupidity
fix_mount () {

    sudo awk '
    BEGIN { has_after = 0; has_bindsto = 0 }
    /^After=.*nix\.mount/ { has_after = 1 }
    /^BindsTo=.*nix\.mount/ { has_bindsto = 1 }
    /^\[Unit\]$/ { in_unit = 1 }
    /^\[/ && !/^\[Unit\]$/ { 
        if (in_unit && (!has_after || !has_bindsto)) {
            if (!has_after) print "After=nix.mount"
            if (!has_bindsto) print "BindsTo=nix.mount"
            in_unit = 0
        }
    }
    { print }
    END {
        if (in_unit && (!has_after || !has_bindsto)) {
            if (!has_after) print "After=nix.mount"
            if (!has_bindsto) print "BindsTo=nix.mount"
        }
    }' /etc/systemd/system/nix-daemon.service > /tmp/nix-daemon.service && \
    sudo mv /tmp/nix-daemon.service /etc/systemd/system/nix-daemon.service

}


nix_install () {

    # temporarily set SELinux to permissive
    sudo setenforce Permissive
    # install nixpkgs
    sh <(curl -L https://nixos.org/nix/install) --daemon
    # fix services
    sudo rm -f /etc/systemd/system/nix-daemon.{service,socket}
    sudo cp /nix/var/nix/profiles/default/lib/systemd/system/nix-daemon.{service,socket} /etc/systemd/system/
    sudo systemctl daemon-reload
    sleep 4
    sudo systemctl enable --now nix-daemon.socket
    sleep 1
    # setting SELinux back to enforcing
    sudo setenforce Enforcing

}

nix_icons () {

    local LINE='XDG_DATA_DIRS="$HOME/.nix-profile/share:/nix/var/nix/profiles/default/share:$XDG_DATA_DIRS"'
    if ! grep -qF "$LINE" ~/.bashrc; then
        echo "$LINE" >> ~/.bashrc
    fi

}


# runtime
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/linuxtoys-atom.lib)
_lang_
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/src/lang/${langfile})
if zenity --question --text "$msg282" --width 360 --height 300; then
    if [ ! -f "$HOME/.nixostree" ]; then
        prep_point
    else
        source $HOME/.nixostree
        if [ "$NIXOSTREE_STATUS" = "1" ]; then
            cd $HOME
            selinux_prep
            dir_prep
            nix_install
            fix_mount
            nix_icons
            echo "NIXOSTREE_STATUS=2" > $HOME/.nixostree
        elif [ "$NIXOSTREE_STATUS" = "2" ]; then
            zenity --info --text "$msg281" --width 300 --height 300
            exit 0
        fi
    fi
fi
