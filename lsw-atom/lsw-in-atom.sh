#!/bin/bash

# docker installation
docker_install () {

		curl -O https://download.docker.com/linux/fedora/docker-ce.repo
		sudo install -o 0 -g 0 -m644 docker-ce.repo /etc/yum.repos.d/docker-ce.repo
		local _packages=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)
		_install_
		sudo usermod -aG docker $USER
		sudo systemctl enable --now docker || echo "Error: failed to start docker service" && exit 1
		sudo systemctl enable --now docker.socket || echo "Error: failed to start docker socket" && exit 2

}

# windows docker container setup
win_install () {

		local _packages=(dialog netcat freerdp iproute libnotify)
		_install_
		cd $HOME/.config/winapps
		wget -nc https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/lsw-atom/winapps/compose.yaml
		wget -nc https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/lsw-atom/winapps/winapps.conf
		# make necessary adjustments to compose file
    # Cap at 16GB
    if (( _cram > 16 )); then
        _winram=16
    else
        _winram=$_cram
    fi
    # get cpu threads
    _wincpu="$_ccpu"
    # get C size
    _csize=$(whiptail --inputbox "Enter Windows disk (C:) size in GB. Leave empty to use 50GB." 10 30 3>&1 1>&2 2>&3)
    local available_gb=$(df -BG "/" | awk 'NR==2 { gsub("G","",$4); print $4 }')
    if [ -z "$_csize" ]; then
        _winsize="50"
    else
        # stop if input size is not a number
				if [[ -n "$_csize" && ! "$_csize" =~ ^[0-9]+$ ]]; then
            local title="Error"
            local msg="Invalid number for disk size."
            _msgbox_
            return 10
        fi
        _winsize="$_csize"
    fi
    if (( _winsize < 40 )); then
        local title="Error"
        local msg="Not enough space to install Windows, minimum 40GB."
        _msgbox_
        return 11
    fi
    if (( available_gb < _winsize )); then
        local title="Error"
        local msg="Not enough disk space: ${_winsize} GB required, ${available_gb} GB available."
        _msgbox_
        exit 3
    fi
    sed -i "s|^\(\s*RAM_SIZE:\s*\).*|\1\"${_winram}G\"|" compose.yaml
    sed -i "s|^\(\s*CPU_CORES:\s*\).*|\1\"${_wincpu}\"|" compose.yaml
    sed -i "s|^\(\s*DISK_SIZE:\s*\).*|\1\"${_winsize}\"|" compose.yaml
		if command -v konsole &> /dev/null; then
        setsid konsole --noclose -e  "sudo docker compose --file ./compose.yaml up" >/dev/null 2>&1 < /dev/null &
		elif command -v ptyxis &> /dev/null; then
				setsid ptyxis bash -c "sudo docker compose --file ./compose.yaml up; exec bash" >/dev/null 2>&1 < /dev/null &
    elif command -v gnome-terminal &> /dev/null; then
        setsid gnome-terminal -- bash -c "sudo docker compose --file ./compose.yaml up; exec bash" >/dev/null 2>&1 < /dev/null &
    else
        local title="Error"
        local msg="No compatible terminal emulator found to launch Docker Compose."
        _msgbox_
        exit 4
    fi

}

# lsw shortcuts installation
lsw_install () {

		if whiptail --title "Setup" --yesno "Is the Windows installation finished?" 8 78; then
				wget https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/lsw-atom/rpmbuild/RPMS/x86_64/lsw-atom-shortcuts-1.0-1.x86_64.rpm
				rpm-ostree install -yA lsw-atom-shortcuts-1.0-1.x86_64.rpm
				exit 0
		else
				if whiptail --title "Setup" --yesno "Do you want to revert all changes? WARNING: This will ERASE all Docker Compose data!" 8 78; then
          	sudo docker compose down --rmi=all --volumes
            exit 7
        fi
		fi

}

# hardware requirements check
hwcheck () {

	# Enforce minimum RAM check
    	local total_kb=$(grep MemTotal /proc/meminfo | awk '{ print $2 }')
    	local available_kb=$(grep MemAvailable /proc/meminfo | awk '{ print $2 }')
    	local total_gb=$(( total_kb / 1024 / 1024 ))
    	local available_gb=$(( available_kb / 1024 / 1024 ))
    	_cram=$(( total_gb / 3 ))
    	if (( _cram < 4 )); then
        	local title="Error"
        	ocal msg="System RAM too low. At least 12GB total is required to continue."
        	_msgbox_
        	exit 5
    	fi
    	# Enforce availability with 1GB buffer (to avoid rounding issues)
    	if (( available_gb < (_cram + 1) )); then
        	local title="Error"
        	local msg="Not enough free RAM. Close some applications and try again."
        	_msgbox_
        	exit 5
    	fi
    	# CPU thread check
    	local _total_threads=$(nproc)
    	_ccpu=$(( _total_threads / 2 ))
    	if (( _ccpu < 2 )); then
        	local title="Error"
        	local msg="Not enough CPU threads to install Windows hypervisor, minimum 4."
        	_msgbox_
        	exit 6
    	fi

}

# runtime
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/linuxtoys-atom.lib)
hwcheck
if command -v docker &> /dev/null; then
		win_install
		lsw_install
else
		docker_install
		win_install
		lsw_install
fi
