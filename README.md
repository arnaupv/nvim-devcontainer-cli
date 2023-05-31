**Current Plugin is under development**

# Devcontainer CLI (Nvim Plugin)

First, which problem is this plugin trying to solve?

**Situation:**

Your favorite editor is **nvim** and you are currently developing a containerized application (using Docker).

**Problem:**

You can definitely use nvim for developing your code, but you quickly face problems with the [LSP](https://microsoft.github.io/language-server-protocol/) and the [DAP](https://microsoft.github.io/debug-adapter-protocol/) (among other plugins), because such plugins do not have access inside the Docker container. True, you can install **nvim** together with all your plugins inside the docker container extending the image. However, this can be cumbersome, and ultimately if you are working in a team, chances are you are the only one is using **nvim**. Also, you do not want to modify your own Docker Target inside your Dockerfile, installing **nvim** etc.

**Solution:**

There are multiple IDEs out there who give you the possibility to execute themself inside the Docker container you are developing, fixing the problems above, but there is nothing which works out-of-the-box for **nvim**. Recently, Microsoft opened the code used in VSCode for attaching the IDE to such containers ([Devconatiner CLI](https://github.com/devcontainers/cli)). The current **nvim** plugin aims to integrate such CLI in a **nvim** plugin for creating your own local development environment on the top of your containerized applications. This plugin allows you use LSP capabilities for external modules (installed inside the Docker container), and also debug your application ([DAP](https://microsoft.github.io/debug-adapter-protocol/)).

## Installation

- [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "arnaupv/nvim-devcontainer-cli",
  opts = {}
},
```
