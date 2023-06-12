#!/bin/sh
set -xe

# mkdir ~/.config/

# TODO: Installing my dotfiles. Instead of having this part of the code hardcoded, this config param has to be as a plugin config param.
MY_HOME=$HOME # /root/
git clone https://github.com/arnaupv/dotfiles.git ${MY_HOME}/dotfiles
cd ${MY_HOME}/dotfiles
./install.sh
cd -

# TODO: By default the zsh shell is installed inside the dev container. However this is not ideal, as it should be a pluging config param.
sh -c "$(curl -L https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)"

# TODO: such linters could be automatically installed by Neovim Plugins (Mason).
# python packages: formating and linting
pip install black isort
