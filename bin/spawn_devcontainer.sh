#!/bin/sh
set -ex

help() {
	echo "Usage: $0 [OPTIONS]"
	echo "Options:"
	echo "  -r, --remove-existing-container"
	echo "  Description: Remove existing devcontainer before creating a new one."
	echo "  -d, --root_directory"
	echo "  Description: root_dir where the .devcontainer folder is located"
	echo "  -s, --setup-environment-repo"
	echo "  Description: Repository with the instructions needed for installing the dependencies in the devcontainer."
	echo "  -i, --setup-environment-install-command"
	echo "  Description: Command to install the setup environment."
	echo "  -D, --nvim-dotfiles-repo"
	echo "  Description: Repository with the nvim dotfiles."
	echo "  -B, --nvim-dotfiles-branch"
	echo "  Description: Branch to use for the dotfiles repository."
	echo "  -F, --nvim-dotfiles-directory"
	echo "  Description: Directory to use for the dotfiles repository."
	echo "  -I, --nvim-dotfiles-install-command"
	echo "  Description: Command to install the nvim dotfiles."
	echo "  -h, --help"
	echo "  Description: Show help."
	echo ""
	echo "Example:"
	echo "  $0 -r -s https://www.github.com/username/setup-environment -i './install.sh -p nvim zsh stow' -D https://github.com/LazyVim/starter -I 'mv ~/dotfiles ~/.config/nvim'"
	echo ""
}

# Default values
remove_existing_container=""

# Handle command-line arguments
while [ $# -gt 0 ]; do
	case $1 in
	-r | --remove-existing-container)
		remove_existing_container="--remove-existing-container"
		shift
		;;
	-d | --root_directory)
		root_dir=$2
		shift 2
		;;
	-s | --setup-environment-repo)
		setup_environment_repo=$2
		shift 2
		;;
	-S | --setup-environment-dir)
		setup_environment_dir=$2
		shift 2
		;;
	-i | --setup-environment-install-command)
		setup_environment_install_command=$2
		shift 2
		;;
	-D | --nvim-dotfiles-repo)
		nvim_dotfiles_repo=$2
		shift 2
		;;
	-B | --nvim-dotfiles-branch)
		nvim_dotfiles_branch=$2
		shift 2
		;;
	-F | --nvim-dotfiles-directory)
		nvim_dotfiles_dir=$2
		shift 2
		;;
	-I | --nvim-dotfiles-install-command)
		nvim_dotfiles_install_command=$2
		shift 2
		;;
	-h | --help)
		help
		exit 0
		;;
	*)
		echo "Invalid option: $1"
		exit 1
		;;
	esac
done
workspace=${root_dir}
cd "${workspace}"

REMOTE_USER=$(devcontainer read-configuration --include-merged-configuration --workspace-folder . | jq '.configuration.remoteUser' | tr -d '"')
WORKSPACE_FOLDER=$(devcontainer read-configuration --include-merged-configuration --workspace-folder . | jq '.workspace.workspaceFolder' | tr -d '"')

NVIM_DEVCONTAINER_CLI_FOLDER=$(echo "${HOME}"/.local/share/nvim/lazy/nvim-devcontainer-cli/ | sed "s|^$HOME||")
echo "REMOTE_USER: $REMOTE_USER"

if [ "${REMOTE_USER}" = "root" ]; then
    REMOTE_HOME="/root"
else
    REMOTE_HOME="/home/${REMOTE_USER}"
fi
echo REMOTE_HOME: $REMOTE_HOME

NVIM_DEVCONTAINER_CLI_FOLDER_IN_DOCKER_CONTAINER=${REMOTE_HOME}"${NVIM_DEVCONTAINER_CLI_FOLDER}"
DOTFILES_DIR="${REMOTE_HOME}/$nvim_dotfiles_dir"
SETUP_ENVIRONMENT_DIR="${REMOTE_HOME}/$setup_environment_dir"

devcontainer up ${remove_existing_container} \
	--dotfiles-repository "${setup_environment_repo}" \
	--dotfiles-target-path "${SETUP_ENVIRONMENT_DIR}" \
	--workspace-folder "${workspace}" \
	--update-remote-user-uid-default off
# Only the clonation is needed, the installation does nothing. This is done in the next commands (with ROOT user)
# --dotfiles-install-command "${nvim_dotfiles_install}" \

# Setting Up Devcontainer
# Installing dependencies as root (nvim package)
DEVCONTAINER_ROOT_CONFIG=.devcontainer/autogenerated-devcontainer-root.json

jq -n --arg workspaceFolder "$WORKSPACE_FOLDER" '{ "remoteUser": "root", "workspaceFolder": $workspaceFolder, "remoteEnv": { "HOME": "" }}' >${DEVCONTAINER_ROOT_CONFIG}
# jq -n '{ "remoteUser": "root", "remoteEnv": { "HOME": "" }}' >${DEVCONTAINER_ROOT_CONFIG}
# devcontainer up --dotfiles-repository clones the dotfiles by default in this path /home/${REMOTE_USER}/dotfiles
devcontainer exec --override-config ${DEVCONTAINER_ROOT_CONFIG} --workspace-folder "${workspace}" sh -c "cd ${SETUP_ENVIRONMENT_DIR} && ${setup_environment_install_command}"
rm "${DEVCONTAINER_ROOT_CONFIG}"

# Configuring NVIM dotfiles
devcontainer exec --workspace-folder "${workspace}" \
  sh -c "git clone -b '${nvim_dotfiles_branch}' '${nvim_dotfiles_repo}' '${DOTFILES_DIR}' && cd '${DOTFILES_DIR}' && ${nvim_dotfiles_install_command}"
