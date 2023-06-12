#!/bin/bash
# The following code creates a new terminal (using gnome-terminal) and it
# connects to the container using the devcontainer built in command.
# TODO: Add a check to see if the container is running.
# TODO: Give the possibility of using multiple terminals, not only gnome-terminal
# TODO: Give the possibility of opening a new tmux page instead of opening a new container
WORKSPACE="./"
gnome-terminal -- bash -c "devcontainer exec --workspace-folder ${WORKSPACE} zsh"
