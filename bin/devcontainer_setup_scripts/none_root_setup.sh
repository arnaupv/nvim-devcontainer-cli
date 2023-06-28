#!/bin/sh
set -xe

MY_HOME=${HOME} # /root/

# TODO: Installing my dotfiles. Instead of having this part of the code hardcoded, this config param has to be as a plugin config param.
# If dotfiles folder does not exist in MY_HOME directory, clone the repo and run install.sh script.
if [ ! -d "${MY_HOME}"/dotfiles ]; then
	git clone https://github.com/arnaupv/dotfiles.git "${MY_HOME}"/dotfiles
	cd "${MY_HOME}"/dotfiles
	./install.sh
	cd -
fi

# TODO: By default the zsh shell is installed inside the dev container. However this is not ideal, as the type of SHELL should be a plugin config param.
if [ ! -d "${MY_HOME}"/.oh-my-zsh/ ]; then
	sh -c "$(curl -L https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)"
fi
