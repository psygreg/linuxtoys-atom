#!/bin/bash

DEST_FILE=${HOME}/.bash_profile

# patch for Nvidia GPUs
patch_nv () {

    cd $HOME
    wget -O patch-nvidia https://raw.githubusercontent.com/psygreg/shader-booster/refs/heads/main/patch-nvidia;
    cat "${HOME}/patch-nvidia" >> "${DEST_FILE}"
    whiptail --title "Shader Booster" --msgbox "Success! Reboot to apply." 8 78
    cat "1" > "${HOME}/.booster"
    rm ${HOME}/patch-nvidia
    exit 0

}

# patch for Mesa-driven GPUs
patch_mesa () {

    cd $HOME
    wget -O patch-mesa https://raw.githubusercontent.com/psygreg/shader-booster/refs/heads/main/patch-mesa;
    cat "${HOME}/patch-mesa" >> "${DEST_FILE}"
    whiptail --title "Shader Booster" --msgbox "Success! Reboot to apply." 8 78
    cat "1" > "${HOME}/.booster"
    rm ${HOME}/patch-mesa
    exit 0

}

GPU=$(lspci | grep -i '.* vga .* nvidia .*')
if [ ! -f ${HOME}/.booster ]; then
	if [[ $GPU == *' nvidia '* ]]; then
		patch_nv
	else
		patch_mesa
	fi
else
	whiptail --title "Shader Booster" --msgbox "System already patched." 8 78
    	exit 0
fi
