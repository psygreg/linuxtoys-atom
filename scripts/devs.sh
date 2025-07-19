#!/bin/bash

# initialize variables for reboot status
flatpak_run=""

# supermenu checklist
dsupermenu () {

    local codium_status=$([ "$_codium" = "com.vscodium.codium" ] && echo "ON" || echo "OFF")
		local plsr_status=$([ "$_plsr" = "pulsar" ] && echo "ON" || echo "OFF")
    local nvim_status=$([ "$_nvim" = "neovim" ] && echo "ON" || echo "OFF")
    local nvm_status=$([ "$_nvm" = "nodejs" ] && echo "ON" || echo "OFF")
    local mvn_status=$([ "$_mvn" = "maven" ] && echo "ON" || echo "OFF")
    local pyenv_status=$([ "$_pyenv" = "pyenv" ] && echo "ON" || echo "OFF")
    local unity_status=$([ "$_unity" = "unityhub" ] && echo "ON" || echo "OFF")
    local dotnet_status=$([ "$_dotnet" = "dotnet-sdk-9.0" ] && echo "ON" || echo "OFF")
    local java_status=$([ "$_java" = "java" ] && echo "ON" || echo "OFF")
    local droidstd_status=$([ "$_droidstd" = "com.google.AndroidStudio" ] && echo "ON" || echo "OFF")
    local omb_status=$([ "$_omb" = "1" ] && echo "ON" || echo "OFF")
    local insomnia_status=$([ "$_insomnia" = "rest.insomnia.Insomnia" ] && echo "ON" || echo "OFF")
    local httpie_status=$([ "$_httpie" = "io.httpie.Httpie" ] && echo "ON" || echo "OFF")
    local postman_status=$([ "$_postman" = "com.getpostman.Postman" ] && echo "ON" || echo "OFF")
		local ghcli_status=$([ "$_ghcli" = "gh" ] && echo "ON" || echo "OFF")

    while :; do

        local selection
        selection=$(whiptail --title "$msg131" --checklist \
            "$msg131" 20 78 15 \
						"Pulsar" "$msg261" $code_status \
            "VSCodium" "$msg142" $codium_status \
            "NeoVim" "$msg140" $nvim_status \
            "OhMyBash" "$msg226" $omb_status \
						"GitHub CLI" "$msg262" $ghcli_status \
            "NodeJS" "+ Node Version Manager" $nvm_status \
            "Maven" "$msg178" $mvn_status \
            "Python" "$msg134" $pyenv_status \
            "C#" "Microsoft .NET SDK" $dotnet_status \
            "Java" "OpenJDK/JRE" $java_status \
            "Android Studio" "$msg206" $droidstd_status \
            "Unity Hub" "$msg137" $unity_status \
            "Insomnia" "$msg245" $insomnia_status \
            "Httpie" "$msg246" $httpie_status \
            "Postman" "$msg247" $postman_status \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ $exitstatus != 0 ]; then
        # Exit the script if the user presses Esc
            break
        fi

        [[ "$selection" == *"VSCodium"* ]] && _codium="com.vscodium.codium" || _codium=""
				[[ "$selection" == *"Pulsar"* ]] && _plsr="pulsar" || _plsr=""
        [[ "$selection" == *"NeoVim"* ]] && _nvim="neovim" || _nvim=""
        [[ "$selection" == *"NodeJS"* ]] && _nvm="nodejs" || _nvm=""
        [[ "$selection" == *"Maven"* ]] && _mvn="maven" || _mvn=""
        [[ "$selection" == *"Python"* ]] && _pyenv="pyenv" || _pyenv=""
        [[ "$selection" == *"Unity Hub"* ]] && _unity="unityhub" || _unity=""
        [[ "$selection" == *"C#"* ]] && _dotnet="dotnet-sdk-9.0" || _dotnet=""
        [[ "$selection" == *"Java"* ]] && _java="java" || _java=""
        [[ "$selection" == *"Android Studio"* ]] && _droidstd="droidstd" || _droidstd=""
        [[ "$selection" == *"OhMyBash"* ]] && _omb="1" || _omb=""
        [[ "$selection" == *"Insomnia"* ]] && _insomnia="rest.insomnia.Insomnia" || _insomnia=""
        [[ "$selection" == *"Httpie"* ]] && _httpie="io.httpie.Httpie" || _httpie=""
        [[ "$selection" == *"Postman"* ]] && _postman="com.getpostman.Postman" || _postman=""
				[[ "$selection" == *"GitHub CLI"* ]] && _ghcli="gh" || _ghcli=""

        install_flatpak
        install_native
        others_t
        # adjust if rebooting is required for any software
        if [[ -n "$flatpak_run" || -n "$_pyenv" || -n "$_nvm" ]]; then
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

		local _packages=($_nvim $_plsr $_nvm $_mvn $_unity $_dotnet $_ghcli)
		if [[ -n "$_pyenv" ]]; then
				_packages+=("make gcc patch zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel libuuid-devel gdbm-libs libnsl2")
		fi
    if [[ -n "$_packages" ]]; then
        if [[ -n "$_unity" ]]; then
            sudo sh -c 'echo -e "[unityhub]\nname=Unity Hub\nbaseurl=https://hub.unity3d.com/linux/repos/rpm/stable\nenabled=1\ngpgcheck=1\ngpgkey=https://hub.unity3d.com/linux/repos/rpm/stable/repodata/repomd.xml.key\nrepo_gpgcheck=1" > /etc/yum.repos.d/unityhub.repo'
        fi
				if [[ -n "$_ghcli" ]]; then
						curl https://cli.github.com/packages/rpm/gh-cli.repo | sudo tee > /etc/yum.repos.d/gh-cli.repo
				fi
        _install_
    fi

}

# flatpak packages
install_flatpak () {

    local _flatpaks=($_codium $_insomnia $_httpie $_postman $_droidstd)
    if [[ -n "$_flatpaks" ]] || [[ -n "$_steam" ]]; then
        if command -v flatpak &> /dev/null; then
            flatpak_in_lib
            _flatpak_
        else
            if whiptail --title "$msg006" --yesno "$msg085" 8 78; then
                flatpak_run="1"
                flatpak_in_lib
                _flatpak_
            else
                local title="$msg030"
                local msg="$msg132"
                _msgbox_
            fi
        fi
    fi

}

# java JDK + JRE installation
jdk_install () {

		local _packages=()
    local javas=($_jdk8 $_jdk11 $_jdk17 $_jdk21 $_jdk24)
    for jav in "${javas[@]}"; do
        if [ $jav == "8" ]; then
						_packages+=("java-1.8.0-openjdk java-1.8.0-openjdk-devel")
            continue
        fi
				_packages+=("java-${jav}-openjdk java-${jav}-openjdk-devel")
    done
		_install_

}

java_in () {

    local jdk8_status=$([ "$_jdk8" = "8" ] && echo "ON" || echo "OFF")
    local jdk11_status=$([ "$_jdk11" = "11" ] && echo "ON" || echo "OFF")
    local jdk17_status=$([ "$_jdk17" = "17" ] && echo "ON" || echo "OFF")
    local jdk21_status=$([ "$_jdk21" = "21" ] && echo "ON" || echo "OFF")
    local jdk24_status=$([ "$_jdk24" = "24" ] && echo "ON" || echo "OFF")

    while :; do

        local selection
        selection=$(whiptail --title "$msg131" --checklist \
            "$msg131" 20 78 15 \
            "Java 8" "LTS" $jdk8_status \
            "Java 11" "LTS" $jdk11_status \
            "Java 17" "LTS" $jdk17_status \
            "Java 21" "LTS" $jdk21_status \
            "Java 24" "Latest" $jdk24_status \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ $exitstatus != 0 ]; then
        # Exit the script if the user presses Esc
            return
        fi

        [[ "$selection" == *"Java 8"* ]] && _jdk8="8" || _jdk8=""
        [[ "$selection" == *"Java 11"* ]] && _jdk11="11" || _jdk11=""
        [[ "$selection" == *"Java 17"* ]] && _jdk17="17" || _jdk17=""
        [[ "$selection" == *"Java 21"* ]] && _jdk21="21" || _jdk21=""
        [[ "$selection" == *"Java 24"* ]] && _jdk24="24" || _jdk24=""

        jdk_install

    done

}

# triggers for OS-agnostic installers
others_t () {

    if [[ -n "$_nvm" ]]; then
				_packages=(npm)
				_install_
        wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
        rm install.sh
        npm i --global yarn
        # basic usage instruction prompt
        local title="$msg006"
        local msg="$msg136"
        _msgbox_
        xdg-open https://github.com/nvm-sh/nvm?tab=readme-ov-file#usage
    fi
    if [[ -n "$_pyenv" ]]; then
        # pyenv and python build requirements installation
        curl -fsSL https://pyenv.run | bash
        if [[ -f "${HOME}/.bash_profile" ]]; then
            echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
            echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
            echo 'eval "$(pyenv init - bash)"' >> ~/.bash_profile
        elif [[ -f "$HOME/.profile" ]]; then
            echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
            echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
            echo 'eval "$(pyenv init - bash)"' >> ~/.profile
        fi
        if [[ -f "$HOME/.zshrc" ]]; then
            echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
            echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
            echo 'eval "$(pyenv init - zsh)"' >> ~/.zshrc
        fi
        git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
        echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
        # basic usage instruction prompt
        local title="$msg006"
        local msg="$msg135"
        _msgbox_
        xdg-open https://github.com/pyenv/pyenv?tab=readme-ov-file#usage
        xdg-open https://github.com/pyenv/pyenv-virtualenv?tab=readme-ov-file#usage
    fi
    if [[ -n "$_java" ]]; then
        java_in
    fi
    if [[ -n "$_omb" ]]; then
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
    fi

}

# runtime
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/linuxtoys-atom.lib)
_lang_
source <(curl -s https://raw.githubusercontent.com/psygreg/linuxtoys-atom/refs/heads/main/src/lang/${langfile})
dsupermenu
