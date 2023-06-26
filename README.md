🔧 **Current Plugin is under development**

It can be used only for Docker images inheriting from **Ubuntu/Debian**. Example: [Dockerfile](./Dockerfile).

# Devcontainer CLI (Nvim Plugin)

First, which problem is this plugin trying to solve?

**Situation:**

Your favorite editor is **nvim** and you are currently developing a containerized application (using Docker).

**Problem:**

You can definitely use nvim for developing your code, but you quickly face problems with the [LSP](https://microsoft.github.io/language-server-protocol/) and the [DAP](https://microsoft.github.io/debug-adapter-protocol/) (among other plugins), because such plugins do not have access inside the Docker container. True, you can install **nvim** together with all your plugins inside the docker container extending the image. However, this can be cumbersome, and ultimately if you are working in a team, chances are you are the only one is using **nvim**. Also, you do not want to modify your own Docker Target inside your Dockerfile, installing **nvim** etc.

**Solution:**

There are multiple IDEs out there who give you the possibility to execute themself inside the Docker container you are developing, fixing the problems above, but there is nothing which works out-of-the-box for **nvim**. Recently, Microsoft opened the code used in VSCode for attaching the IDE to such containers ([Devconatiner CLI](https://github.com/devcontainers/cli)). The current **nvim** plugin aims to integrate such CLI in a **nvim** plugin for creating your own local development environment on the top of your containerized applications. This plugin allows you use LSP capabilities for external modules (installed inside the Docker container), and also debug your application ([DAP](https://microsoft.github.io/debug-adapter-protocol/)).

**Inspiration:**

This plugin has been inspired by the work previously done by [esensar](https://github.com/esensar/nvim-dev-container) and by [jamestthompson3](https://github.com/jamestthompson3/nvim-remote-containers). The main different is that this plugin benefits from the [Devcontainer CLI](https://github.com/devcontainers/cli) which was opensourced by Microsoft in April 2022.

## Installation

- [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "arnaupv/nvim-devcontainer-cli",
  opts = {}
},
```

### Dependencies

The following dependencies are required for the plugin to work properly:

- [docker](https://docs.docker.com/get-docker/)
- [devcontainer-cli](https://github.com/devcontainers/cli#npm-install)

## How to use?

There are 2 commands: `:DevcontainerUp` and `:DevcontainerConnect`.

1. First you need to have your folder with the devcontainer instructions. This folder is usually called `.devcontainer` and contains a `devcontainer.json` file. This file is used by the [Devcontainer CLI](https://github.com/devcontainers/cli). You can find an example of a `devcontainer.json` file [here](.devcontainer/devcontainer.json). You can also find more information about the `devcontainer.json` file [here](https://code.visualstudio.com/docs/remote/devcontainerjson-reference).

2. Then open a nvim session and execute the first command: `DevcontainerUp`, which will create the image based on your Dockerfile. Once created it will initialize a container with the previously created image, adding nvim and other tools defined in ./bin/devcontainer_setup_scripts/ . Currently the following [dotfiles](https://github.com/arnaupv/dotfiles) are hardcoded [here](./bin/devcontainer_setup_scripts/none_root_setup.sh). The new devcontainer running can be easily checked with the following command: `docker ps -a`.

3. If the process above finish successfully you are prepared for closing the current nvim session and open a new nvim inside the docker container. All this can be done from nvim itself, using the second command: `:DevcontainerConnect`.

4. As an example, you can try to create the first devcontainer using neovim with the current repository, following the instructions above.

## Tests

Tests are executed automatically on each PR using Github Actions.

In case you want to run Github Actions locally, it is recommended to use [act](https://github.com/nektos/act#installation).
And then execute:

```bash
$ act -W .github/workflows/default.yml
```

Another option would be to connect to the devcontainer following the **How to use?** section.
Once connected to the devcontainer, execute:

```bash
$ make test
```

## FEATUREs (in order of priority)

1. [x] Capability to create and run a devcontainer using the [Devconatiner CLI](https://github.com/devcontainers/cli).
1. [x] Capability to attach in a running devcontainer
1. [x] The floating window created during the devcontainer Up process (:DevcontainerUp<cr>) is closed when the process finishes successfully.
1. [ ] Add unit tests using plenary.busted lua module.
1. [ ] The logs printed in the floating window when preparing the Devcontainer are saved and easy to access.
1. [ ] [Give the possibility of defining custom dotfiles when setting up the devcontainer](https://github.com/arnaupv/nvim-devcontainer-cli/issues/1)
1. [ ] Detect the cause/s of the UI issues of neovim when running inside the docker container.
1. [ ] Convert bash scripts in lua code.
1. [ ] Currently bash scripts only support Ubuntu (OS). Once the code is migrated to lua, it has to cover the installation other OS.
1. [ ] Create .devcontainer/devcontainer.json template automatically via a nvim command. Add examples for when the devcontainer is created from docker and also from docker-compose.
