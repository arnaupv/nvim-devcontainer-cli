#!/bin/bash
# This executable file has been isolated from ./bin/connect_to_devcontainer.sh so it
# can be executed in MAC Terminals (Termina.app/iTerm.app)

set -e

WORKSPACE="$(pwd)"
SHELL="zsh"

workspace_folder=$(devcontainer read-configuration --include-merged-configuration --log-format json --workspace-folder . 2>/dev/null | jq .workspace.workspaceFolder | sed 's/"//g')
docker_id=$(docker ps -q -a --filter label=devcontainer.local_folder="${WORKSPACE}" --filter label=devcontainer.config_file="${WORKSPACE}"/.devcontainer/devcontainer.json)
docker exec -it "${docker_id}" bash -c "cd ${workspace_folder} && ${SHELL}"
# docker exec -it "${docker_id}" ${SHELL}

# TODO: It would be great to use th devcontainer exec command as long as we know how to fix the visualization issue inside the docker container!
# If you want to give a try, just comment the docker exect -it ... above and uncommend the line below. Then execute the :DevcontainerConnect and open vim.
# There you will see visualzation issues which do not occur when connectint to docker via docker exec

# devcontainer exec --workspace-folder ${WORKSPACE} ${SHELL}
