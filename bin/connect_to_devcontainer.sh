#!/bin/bash

set -e
# The following code creates a new terminal (using gnome-terminal) and it
# connects to the container using the devcontainer built in command.
# TODO: Add a check to see if the container is running.
# TODO: Give the possibility of using multiple terminals, not only gnome-terminal
# TODO: Give the possibility of opening a new tmux page instead of opening a new container

# Get the folder of the current file
function get_script_dir {
	# SOURCE: https://stackoverflow.com/a/246128/10491337
	local SOURCE="${BASH_SOURCE[0]}"
	local DIR=""
	while [ -h "${SOURCE}" ]; do
		DIR="$(cd -P "$(dirname "${SOURCE}")" >/dev/null 2>&1 && pwd)"
		SOURCE="$(readlink "${SOURCE}")"
		[[ "${SOURCE}" != /* ]] && SOURCE="${DIR}/${SOURCE}"
	done
	cd -P "$(dirname "${SOURCE}")" >/dev/null 2>&1 && pwd
}

SCRIPT_DIR=$(get_script_dir)
# Execute the command for opening the devcontainer in the following terminal:
if [ -x "$(command -v alacritty)" ]; then
	# ALACRITTY TERMINAL EMULATOR
	REPOSTORY_NAME=$(basename "$(pwd)")
	TERMINAL_TITLE="Devcontainer [${REPOSTORY_NAME}] - You are inside a Docker Container now...!"
	alacritty --working-directory . --title "${TERMINAL_TITLE}" -e "${SCRIPT_DIR}"/open_shell_in_devcontainer.sh &
elif [ -x "$(command -v gnome-terminal)" ]; then
	# GNOME TERMINAL
	gnome-terminal -- bash -c "${SCRIPT_DIR}"/open_shell_in_devcontainer.sh
elif [ "$(uname)" == "Darwin" ] && [ -x "$(command -v iTerm)" ]; then
	# MAC ITERM2 TERMINAL EMULATOR
	open -a iTerm.app "${SCRIPT_DIR}"/open_shell_in_devcontainer.sh
elif [ "$(uname)" == "Darwin" ] && [ -x "$(command -v Terminal)" ]; then
	# MAC TERMINAL
	open -a Terminal.app "${SCRIPT_DIR}"/open_shell_in_devcontainer.sh
else
	# TERMINAL NO DEFINED
	echo "ERROR: No compatible emulators found!"
fi
