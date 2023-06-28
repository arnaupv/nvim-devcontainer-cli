#!/bin/bash
# The following code creates a new terminal (using gnome-terminal) and it
# connects to the container using the devcontainer built in command.
# TODO: Add a check to see if the container is running.
# TODO: Give the possibility of using multiple terminals, not only gnome-terminal
# TODO: Give the possibility of opening a new tmux page instead of opening a new container
WORKSPACE="./"
SHELL="zsh"
REPOSTORY_NAME=$(basename "$(pwd)")
TERMINAL_TITLE="Devcontainer [${REPOSTORY_NAME}] - You are inside a Docker Container now...!"

if [ -x "$(command -v alacritty)" ]; then
	# Try to execute the command in a new alacritty terminal in case it is installed
	alacritty --working-directory ${WORKSPACE} --title "${TERMINAL_TITLE}" -e devcontainer exec --workspace-folder ${WORKSPACE} ${SHELL} &
else
	gnome-terminal -- bash -c "devcontainer exec --workspace-folder ${WORKSPACE} ${SHELL}"
fi
