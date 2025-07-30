#!/bin/bash
# initialize variables for reboot status
flatpak_run=""

# checklist menu
devmenu () {

    local selection_str
    local search_item
    local selection
    # set up arrays
    declare -a search_item=(
        "VS Code"
        "VSCodium"
        "NeoVim"
        "OhMyBash"
        "GitHub CLI"
        "Node Version Manager"
        "Maven"
        "Python"
        "C# .NET SDK"
        "Java"
        "Android Studio"
        "Unity Hub"
        "Insomnia"
        "Httpie"
        "Postman"
    )

    # checklist
    while true; do
   	    selection_str=$(zenity --list --checklist --title="Developer Menu" \
        	--column="" \
        	--column="Apps" \
        	FALSE "VS Code" \
        	FALSE "VSCodium" \
        	FALSE "NeoVim" \
        	FALSE "OhMyBash" \
        	FALSE "GitHub CLI" \
            FALSE "Node Version Manager" \
        	FALSE "Maven" \
        	FALSE "Python" \
        	FALSE "C# .NET SDK" \
        	FALSE "Java" \
        	FALSE "Android Studio" \
        	FALSE "Unity Hub" \
        	FALSE "Insomnia" \
        	FALSE "Httpie" \
        	FALSE "Postman" \
        	--height=690 --width=300 --separator="|")

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
                        "VS Code") _code="code" ;;
                        "VSCodium") _codium="com.vscodium.codium" ;;
                        "NeoVim") _nvim="neovim" ;;
                        "OhMyBash") _omb="1" ;;
                        "GitHub CLI") _ghcli="gh" ;;
                        "Node Version Manager") _nvm="nodejs" ;;
                        "Maven") _mvn="maven" ;;
                        "Python") _pyenv="pyenv" ;;
                        "C# .NET SDK") _dotnet="dotnet-sdk-9.0" ;;
                        "Java") _java="java" ;;
                        "Android Studio") _droidstd="com.google.AndroidStudio" ;;
                        "Unity Hub") _unity="unityhub" ;;
                        "Insomnia") _insomnia="rest.insomnia.Insomnia" ;;
                        "Httpie") _httpie="io.httpie.Httpie" ;;
                        "Postman") _postman="com.getpostman.Postman" ;;
                    esac
                fi
            done
        done

        # execute selected operations
        install_flatpak
        install_native
        others_t
        if [ -n "$flatpak_run" ]; then
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

	local _packages=($_nvim $_plsr $_nvm $_mvn $_unity $_dotnet $_ghcli)
	if [[ -n "$_pyenv" ]]; then
		_packages+=(make gcc patch zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel libuuid-devel gdbm-libs libnsl2)
	fi
    if [[ -n "$_packages" ]]; then
        if [[ -n "$_unity" ]]; then
            sudo sh -c 'echo -e "[unityhub]\nname=Unity Hub\nbaseurl=https://hub.unity3d.com/linux/repos/rpm/stable\nenabled=1\ngpgcheck=1\ngpgkey=https://hub.unity3d.com/linux/repos/rpm/stable/repodata/repomd.xml.key\nrepo_gpgcheck=1" > /etc/yum.repos.d/unityhub.repo'
        fi
        if [[ -n "$_code" ]]; then
            echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
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
    if [[ -n "$_flatpaks" ]]; then
        if command -v flatpak &> /dev/null; then
            flatpak_in_lib
            _flatpak_
        else
            if whiptail --title "$msg006" --yesno "$msg085" 8 78; then
                flatpak_run="1"
                flatpak_in_lib
                _flatpak_
            else
                zenity --error --title "$msg030" --text "$msg132" --height=300 --width=300
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
			_packages+=(java-1.8.0-openjdk java-1.8.0-openjdk-devel)
            continue
        else
		    _packages+=(java-${jav}-openjdk java-${jav}-openjdk-devel)
        fi
    done
	_install_

}

java_in () {

    local search_java
    local jav
    local chosen_javas
    local chosen_jav
    local javas
    declare -a search_java=(
        "Java 8 LTS"
        "Java 11 LTS"
        "Java 17 LTS"
        "Java 21 LTS"
        "Java 24 Latest"
    )

    while true; do

        chosen_javas=$(zenity --list --checklist --title="Java JDK" \
        	--column="" \
        	--column="$msg277" \
            FALSE "Java 8 LTS" \
            FALSE "Java 11 LTS" \
            FALSE "Java 17 LTS" \
            FALSE "Java 21 LTS" \
            FALSE "Java 24 Latest" \
            --height=410 --width=300 --separator="|")

        if [ $? -ne 0 ]; then
            break
        fi

        IFS='|' read -ra javas <<< "$chosen_javas"

        for jav in "${search_java[@]}"; do
            for chosen_jav in "${javas[@]}"; do
                if [[ "$chosen_jav" == "$jav" ]]; then
                    case $jav in
                        "Java 8 LTS") _jdk8="8" ;;
                        "Java 11 LTS") _jdk11="11" ;;
                        "Java 17 LTS") _jdk17="17" ;;
                        "Java 21 LTS") _jdk21="21" ;;
                        "Java 24 Latest") _jdk24="24" ;;
                    esac
                fi
            done
        done

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
        zenity --info --title "$msg006" --text "$msg136" --height=300 --width=300
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
        zenity --info --title "$msg006" --text "$msg135" --height=300 --width=300
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
source linuxtoys-atom.lib
_lang_
source ${langfile}
sleep 1
devmenu
