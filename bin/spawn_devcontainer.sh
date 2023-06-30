#!/bin/sh
set -xe
# Function which provides the folder where the .git folder is located
# In case there is no git initialized it will return an error

# Bash script provides 2 arguments, the first is for removing the existing container (if any), and the secondone the env (dev, pro)
# Default values
remove_existing_container=""
env="pro"

# Handle command-line arguments
while [ $# -gt 0 ]; do
	case $1 in
	-r | --remove-existing-container)
		remove_existing_container="--remove-existing-container"
		shift
		;;
	-e | --env)
		if [ "$2" = "dev" ]; then
			env="dev"
		elif [ "$2" = "pro" ]; then
			env="pro"
		else
			echo "Invalid env. Please specify either 'dev' or 'pro' for -e."
			exit 1
		fi
		shift 2
		;;
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

get_project_root_folder() {
	git rev-parse --show-toplevel
}

workspace=$(get_project_root_folder)
cd "${workspace}"

NVIM_DEVCONTAINER_CLI_FOLDER=$(echo "${HOME}"/.local/share/nvim/lazy/nvim-devcontainer-cli/ | sed "s|^$HOME||")
HOME_IN_DOCKER_CONTAINER="/home/my-app/"
NVIM_DEVCONTAINER_CLI_FOLDER_IN_DOCKER_CONTAINER=${HOME_IN_DOCKER_CONTAINER}"${NVIM_DEVCONTAINER_CLI_FOLDER}"
DEVCONTAINER_OVERRIDE_CONFIG=.devcontainer/devcontainer-override.json

# Check if file .config/github-copilot exists
if [ ! -d "${HOME}"/.config/github-copilot ]; then
	echo "File ${HOME}/.config/github-copilot does not exist"
else
	MOUNT_BIND_COPILOT="--mount type=bind,source=${HOME}/.config/github-copilot,target=/home/my-app/.config/github-copilot"
fi

# Mount the plugin folder only if --env is set to dev:
if [ "$env" = "dev" ]; then
	MOUNT_BIND_PLUGIN="--mount type=bind,source=${HOME}/${NVIM_DEVCONTAINER_CLI_FOLDER},target=${NVIM_DEVCONTAINER_CLI_FOLDER_IN_DOCKER_CONTAINER}"
fi
devcontainer up ${remove_existing_container} \
	${MOUNT_BIND_COPILOT} \
	${MOUNT_BIND_PLUGIN} \
	--workspace-folder "${workspace}"

# Setting Up Devcontainer ()
# TODO: Instead of having 2 different scripts (for root and not root users) we should have a unique script (simplifying the usage of the plugin)
devcontainer exec --override-config ${DEVCONTAINER_OVERRIDE_CONFIG} --workspace-folder "${workspace}" sh "${NVIM_DEVCONTAINER_CLI_FOLDER_IN_DOCKER_CONTAINER}"/bin/devcontainer_setup_scripts/root_setup.sh
# Setting Up Devcontainer (no root permits)
devcontainer exec --workspace-folder "${workspace}" sh "${NVIM_DEVCONTAINER_CLI_FOLDER_IN_DOCKER_CONTAINER}"/bin/devcontainer_setup_scripts/none_root_setup.sh -d "${nvim_dotfiles}" -i "${nvim_dotfiles_install}"
