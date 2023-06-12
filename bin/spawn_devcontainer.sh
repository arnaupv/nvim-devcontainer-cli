#!/bin/sh
set -xe
# Move to the root_folder
cd $(dirname $0)/..
root_folder="$(pwd)"
cd ${root_folder}

remove_flag=""
if [ "$1" = "true" ]; then
	remove_flag="--remove-existing-container"
	shift
fi
WORKSPACE="./"

cd ${root_folder}

devcontainer up $remove_flag \
	--mount "type=bind,source=$(pwd)/bin/devcontainer_setup_scripts,target=/devcontainer_setup_scripts" \
	--mount type=bind,source=${HOME}/.config/github-copilot,target=/home/my-app/.config/github-copilot \
	--mount type=bind,source=$(pwd),target=/home/my-app/.local/share/nvim/lazy/nvim-devcontainer-cli \
	--workspace-folder ${WORKSPACE}

# TODO: Instead of having 2 different scripts (for root and not root users) we should have a unique script (simplifying the usage of the plugin)

# Setting Up Devcontainer (root permits)
cd ${root_folder}
DEVCONTAINER_OVERRIDE_CONFIG=.devcontainer/devcontainer-override.json
devcontainer exec --override-config ${DEVCONTAINER_OVERRIDE_CONFIG} --workspace-folder ${WORKSPACE} /devcontainer_setup_scripts/root_setup.sh

# Setting Up Devcontainer (no root permits)
devcontainer exec --workspace-folder ${WORKSPACE} /devcontainer_setup_scripts/none_root_setup.sh
