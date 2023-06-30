#!/bin/bash
# This executable file has been isolated from ./bin/connect_to_devcontainer.sh so it
# can be executed in MAC Terminals (Termina.app/iTerm.app)

set -e

WORKSPACE="./"
SHELL="zsh"

devcontainer exec --workspace-folder ${WORKSPACE} ${SHELL}
