#!/bin/bash
# This executable file has been isolated from ./bin/connect_to_devcontainer.sh so it
# can be executed in MAC Terminals (Termina.app/iTerm.app)

tmux-split-cmd() (tmux split-window -h -t "$TMUX_PANE" "bash --rcfile <(echo '. ~/.bashrc;$*')")
tmux-new-cmd() (tmux new-window -n Devcontainer "bash --rcfile <(echo '. ~/.bashrc;$*')")

set -e

WORKSPACE="$(pwd)"
SHELL="zsh"

config_json=$(devcontainer read-configuration --include-merged-configuration --log-format json --workspace-folder . 2>/dev/null)
workspace_folder=$(echo "$config_json" | jq -r '.workspace.workspaceFolder')
remote_user=$(echo "$config_json" | jq -r '.configuration.remoteUser // .remoteUser')

docker_id=$(docker ps -q -a --filter label=devcontainer.local_folder="${WORKSPACE}" --filter label=devcontainer.config_file="${WORKSPACE}"/.devcontainer/devcontainer.json)

if [ -n "$remote_user" ] && [ "$remote_user" != "null" ]; then
    open_shell_in_devcontainer_command="docker exec -it --user ${remote_user} ${docker_id} bash -c \"cd ${workspace_folder} && ${SHELL}\""
else
    open_shell_in_devcontainer_command="docker exec -it ${docker_id} bash -c \"cd ${workspace_folder} && ${SHELL}\""
fi

# Check if we are inside a tmux session
# If so, create a new pane and execute the open_shell_in_devcontainer_command
# If not, just execute the open_shell_in_devcontainer_command

if [ -n "$TMUX" ]; then
	# Replace by tmux-split-cmd if you want to split the current pane horizontally
	tmux-new-cmd "${open_shell_in_devcontainer_command}"
else
	eval "${open_shell_in_devcontainer_command}"
fi
# docker exec -it "${docker_id}" ${SHELL}

# TODO: It would be great to use th devcontainer exec command as long as we know how to fix the visualization issue inside the docker container!
# If you want to give a try, just comment the docker exec -it ... above and uncommend the line below. Then execute the :DevcontainerConnect and open vim.
# There you will see visualzation issues which do not occur when connectint to docker via docker exec

# devcontainer exec --workspace-folder ${WORKSPACE} ${SHELL}
