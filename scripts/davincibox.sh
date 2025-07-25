#!/bin/bash

# install dependencies
davinciboxdeps () {

    local _packages=(podman lshw distrobox)
    local amdGPU=$(lspci | grep -Ei 'vga|3d' | grep -Ei 'amd|ati|radeon|amdgpu')
    local nvGPU=$(lspci | grep -iE 'vga|3d' | grep -i nvidia)
    local intelGPU=$(lspci | grep -Ei 'vga|3d' | grep -Ei 'intel|iris|xe')
    if [[ -n "$nvGPU" ]]; then
        # add repository and install nvidia container toolkit
        curl -O https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo
        sudo install -o 0 -g 0 nvidia-container-toolkit.repo /etc/yum.repos.d/nvidia-container-toolkit.repo
        rm nvidia-container-toolkit.repo
        NVIDIA_CONTAINER_TOOLKIT_VERSION=1.17.8-1
        _packages+=("nvidia-container-toolkit-${NVIDIA_CONTAINER_TOOLKIT_VERSION} nvidia-container-toolkit-base-${NVIDIA_CONTAINER_TOOLKIT_VERSION} libnvidia-container-tools-${NVIDIA_CONTAINER_TOOLKIT_VERSION} libnvidia-container1-${NVIDIA_CONTAINER_TOOLKIT_VERSION}")
    elif [[ -n "$amdGPU" ]]; then
        # select ROCm or Rusticl
        while :; do
            CHOICE=$(whiptail --title "AMD Drivers" --menu "$msg254" 25 78 16 \
            "ROCm" "$msg255" \
            "RustiCL" "$msg256" \
            3>&1 1>&2 2>&3)

            exitstatus=$?
            if [ $exitstatus != 0 ]; then
                # Exit the script if the user presses Esc
                return 1
            fi

            case $CHOICE in
            ROCm) _packages+=("rocm-comgr rocm-runtime rccl rocalution rocblas rocfft rocm-smi rocsolver rocsparse rocm-device-libs rocminfo rocm-hip hiprand rocm-opencl ocl-icd clinfo") ;;
            RustiCL) _packages+=("mesa-libOpenCL clinfo") ;;
            *) echo "Invalid Option" ;;
            esac
        done
    elif [[ -n "$intelGPU" ]]; then
        # install intel compute runtime
        _packages+=("intel-compute-runtime")
    fi
    _install_
    if [[ $? -eq 1 ]]; then
        echo "No packages to install."
    else
        if [[ "${_to_install[*]}" =~ "rocm" ]]; then
            sudo usermod -aG render,video $USER
        elif [[ "${_to_install[*]}" =~ "mesa-libOpenCL" ]]; then
            curl -sL https://raw.githubusercontent.com/psygreg/linuxtoys-atom/main/src/patches/rusticl-amd \
                | sudo tee -a /etc/environment > /dev/null
        fi
    fi

}

#create JSON, user agent and download Resolve
getresolve () {

  	local pkgname="$_upkgname"
  	local major_version="20.0"
  	local minor_version="1"
  	pkgver="${major_version}.${minor_version}"
	  runver="20.0.1"
  	local _product=""
  	local _referid=""
  	local _siteurl=""
  	local sha256sum=""
  	_archive_name=""
  	_archive_run_name=""

  	if [ "$pkgname" == "davinci-resolve" ]; then
    		_product="DaVinci Resolve"
    		_referid='dfd43085ef224766b06b579ce8a6d097'
    		_siteurl="https://www.blackmagicdesign.com/api/support/latest-stable-version/davinci-resolve/linux"
    		sha256sum='40bf13b7745b420ed9add11c545545c2ba2174429b6c8eafe8fceb94aa258766'
    		_archive_name="DaVinci_Resolve_${pkgver}_Linux"
    		_archive_run_name="DaVinci_Resolve_${runver}_Linux"
  	elif [ "$pkgname" == "davinci-resolve-studio" ]; then
    		_product="DaVinci Resolve Studio"
    		_referid='0978e9d6e191491da9f4e6eeeb722351'
    		_siteurl="https://www.blackmagicdesign.com/api/support/latest-stable-version/davinci-resolve-studio/linux"
    		sha256sum='5fb4614834c5a9f990afa977b7d5dcd2675c26529bc09a468e7cd287bbaf5097'
    		_archive_name="DaVinci_Resolve_Studio_${pkgver}_Linux"
    		_archive_run_name="DaVinci_Resolve_Studio_${runver}_Linux"
  	fi

  	local _useragent="User-Agent: Mozilla/5.0 (X11; Linux ${CARCH}) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.75 Safari/537.36"
  	local _releaseinfo
  	_releaseinfo=$(curl -Ls "$_siteurl")

  	local _downloadId
  	_downloadId=$(printf "%s" "$_releaseinfo" | sed -n 's/.*"downloadId":"\([^"]*\).*/\1/p')
  	local _pkgver
  	_pkgver=$(printf "%s" "$_releaseinfo" | awk -F'[,:]' '{for(i=1;i<=NF;i++){if($i~/"major"/){print $(i+1)} if($i~/"minor"/){print $(i+1)} if($i~/"releaseNum"/){print $(i+1)}}}' | sed 'N;s/\n/./;N;s/\n/./')

  	if [[ $pkgver != "$_pkgver" ]]; then
    		echo "Version mismatch"
    		return 1
  	fi

  	local _reqjson
  	_reqjson="{\"firstname\": \"Arch\", \"lastname\": \"Linux\", \"email\": \"someone@archlinux.org\", \"phone\": \"202-555-0194\", \"country\": \"us\", \"street\": \"Bowery 146\", \"state\": \"New York\", \"city\": \"AUR\", \"product\": \"$_product\"}"
  	_reqjson=$(printf '%s' "$_reqjson" | sed 's/[[:space:]]\+/ /g')
  	_useragent=$(printf '%s' "$_useragent" | sed 's/[[:space:]]\+/ /g')
  	local _useragent_escaped="${_useragent// /\\ }"

  	_siteurl="https://www.blackmagicdesign.com/api/register/us/download/${_downloadId}"
  	local _srcurl
  	_srcurl=$(curl -s \
    		-H 'Host: www.blackmagicdesign.com' \
    		-H 'Accept: application/json, text/plain, */*' \
    		-H 'Origin: https://www.blackmagicdesign.com' \
    		-H "$_useragent" \
    		-H 'Content-Type: application/json;charset=UTF-8' \
    		-H "Referer: https://www.blackmagicdesign.com/support/download/${_referid}/Linux" \
    		-H 'Accept-Encoding: gzip, deflate, br' \
    		-H 'Accept-Language: en-US,en;q=0.9' \
    		-H 'Authority: www.blackmagicdesign.com' \
    		-H 'Cookie: _ga=GA1.2.1849503966.1518103294; _gid=GA1.2.953840595.1518103294' \
    		--data-ascii "$_reqjson" \
    		--compressed \
    		"$_siteurl")

  	curl -L -o "${_archive_name}.zip" "$_srcurl"

}

# installation
inresolve () {

    davinciboxdeps
    cd $HOME
    git clone https://github.com/zelikos/davincibox.git
    sleep 1
    cd davincibox
    getresolve
    unzip ${_archive_name}.zip
    chmod +x setup.sh
    ./setup.sh ${_archive_run_name}.run
    whiptail --title "AutoDaVinciBox" --msgbox "Installation succesful." 8 78
    cd ..
    rm -rf davincibox

}

# runtime start
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/linuxtoys-atom.lib)
# menu
while :; do
	CHOICE=$(whiptail --title "AutoDaVinciBox" --menu "Which version do you want to install?" 25 78 16 \
	"0" "Free" \
	"1" "Studio" \
	"2" "Cancel" 3>&1 1>&2 2>&3)

	exitstatus=$?
	if [ $exitstatus != 0 ]; then
    	# Exit the script if the user presses Esc
    	break
	fi

	case $CHOICE in
	0) 	_upkgname='davinci-resolve'
    inresolve
		exit 0 ;;
	1) 	_upkgname='davinci-resolve-studio'
	  inresolve
    exit 0 ;;
	2 | q) break ;;
	*) echo "Invalid Option" ;;
	esac
done
