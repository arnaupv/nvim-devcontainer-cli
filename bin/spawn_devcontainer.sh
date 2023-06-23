#!/bin/sh
set -xe
# Function which provides the folder where the .git folder is located
# In case there is no git initialized it will return an error

get_project_root_folder() {
	git rev-parse --show-toplevel
}

workspace=$(get_project_root_folder)
cd ${workspace}

remove_flag=""
if [ "$1" = "true" ]; then
	remove_flag="--remove-existing-container"
	shift
fi

NVIM_DEVCONTAINER_CLI_FOLDER=$(echo ${HOME}/.local/share/nvim/lazy/nvim-devcontainer-cli/ | sed "s|^$HOME||")
HOME_IN_DOCKER_CONTAINER="/home/my-app/"
NVIM_DEVCONTAINER_CLI_FOLDER_IN_DOCKER_CONTAINER=${HOME_IN_DOCKER_CONTAINER}${NVIM_DEVCONTAINER_CLI_FOLDER}
DEVCONTAINER_OVERRIDE_CONFIG=.devcontainer/devcontainer-override.json

devcontainer up $remove_flag \
	--mount type=bind,source=${HOME}/.config/github-copilot,target=/home/my-app/.config/github-copilot \
	--mount type=bind,source=${HOME}/${NVIM_DEVCONTAINER_CLI_FOLDER},target=${NVIM_DEVCONTAINER_CLI_FOLDER_IN_DOCKER_CONTAINER} \
	--workspace-folder ${workspace}

# Setting Up Devcontainer ()
# TODO: Instead of having 2 different scripts (for root and not root users) we should have a unique script (simplifying the usage of the plugin)
devcontainer exec --override-config ${DEVCONTAINER_OVERRIDE_CONFIG} --workspace-folder ${workspace} ${NVIM_DEVCONTAINER_CLI_FOLDER_IN_DOCKER_CONTAINER}/bin/devcontainer_setup_scripts/root_setup.sh
# Setting Up Devcontainer (no root permits)
devcontainer exec --workspace-folder ${workspace} ${NVIM_DEVCONTAINER_CLI_FOLDER_IN_DOCKER_CONTAINER}/bin/devcontainer_setup_scripts/none_root_setup.sh
