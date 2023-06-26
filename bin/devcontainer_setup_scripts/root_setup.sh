#!/bin/sh
set -e
if ! type nvim >/dev/null 2>&1; then
	# Updating libraries to ensure nodejs >= 14 is being installed.
	apt-get update
	apt-get install -y curl wget
	curl -sL https://deb.nodesource.com/setup_18.x | bash -

	# Installing neovim dependencies
	apt-get update
	apt-get install -y \
		git \
		zsh \
		nodejs \
		zip \
		libluajit-5.1-dev \
		ripgrep \
		fd-find \
		python3 \
		python3-pip

	# Installing lazy git
	LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
	tar xf lazygit.tar.gz lazygit
	install lazygit /usr/local/bin
	rm lazygit.tar.gz lazygit

	# Installing neovim via .deb
	# curl -LO https://github.com/neovim/neovim/releases/download/v0.9.1/nvim-linux64.deb
	# apt install ./nvim-linux64.deb
	# rm ./nvim-linux64.deb

	# .deb is not supported for 0.9.0 version upwards. More info: https://github.com/neovim/neovim/issues/22684
	# Another options for installing neovim:
	# https://github.com/MordechaiHadad/bob

	# Installing neovim via appimage. Recommended approach: https://github.com/neovim/neovim/releases/download/v0.9.1/nvim-linux64.deb
	# curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
	curl -LO https://github.com/neovim/neovim/releases/download/v0.8.3/nvim.appimage
	chmod u+x nvim.appimage
	./nvim.appimage --appimage-extract
	./squashfs-root/AppRun --version
	rm nvim.appimage

	# Exposing nvim globally
	if [ ! -d /squashfs-root ]; then
		mv squashfs-root /
	fi
	ln -s /squashfs-root/AppRun /usr/bin/nvim

	# Forcing ~/.config/ accessible by my-app user
	if [ ! -d /home/my-app/.config ]; then
		mkdir /home/my-app/.config
	fi

	# Forcing ~/.local/ accessible by my-app user
	if [ ! -d /home/my-app/.local ]; then
		mkdir /home/my-app/.local
	fi

	chown -R my-app:my-app /home/my-app/.config
	chown -R my-app:my-app /home/my-app/.local
fi
