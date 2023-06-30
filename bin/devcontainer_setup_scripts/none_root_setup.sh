#!/bin/sh
set -xe

# Check if I'm connected as root user. If yes, exit.
if [ "$(id -u)" = "0" ]; then
	echo "Sorry, you are not root."
	exit 1
fi

while [ $# -gt 0 ]; do
	case $1 in
	-d | --dotfiles)
		nvim_dotfiles=$2
		shift 2
		;;
	-i | --install_command)
		nvim_dotfiles_install=$2
		shift 2
		;;
	*)
		echo "Invalid option: $1"
		exit 1
		;;
	esac
done

MY_HOME=${HOME} # /root/

# TODO: Installing my dotfiles. Instead of having this part of the code hardcoded, this config param has to be as a plugin config param.
# If dotfiles folder does not exist in MY_HOME directory, clone the repo and run install.sh script.
if [ ! -d "${MY_HOME}"/dotfiles ]; then
	git clone "${nvim_dotfiles}" "${MY_HOME}"/dotfiles
	cd "${MY_HOME}"/
	eval "${nvim_dotfiles_install}"
	cd -
fi

# TODO: By default the zsh shell is installed inside the dev container. However this is not ideal, as the type of SHELL should be a plugin config param.
if [ ! -d "${MY_HOME}"/.oh-my-zsh/ ]; then
	sh -c "$(curl -L https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)"
fi
