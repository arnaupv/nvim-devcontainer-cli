FROM ubuntu:20.04 as builder

# This part of the code is needed for installing nodejs>=14
RUN apt-get update && apt-get install -y \
  curl \
  wget

RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    # Dependencies needed for bulding devcontainers/cli
    nodejs \
    # Dependencies needed for developing in neovim
    lua5.1 \
    luajit \
    luarocks \
    && rm -rf /var/lib/apt/lists/*

# Installing the devcontainers CLI
RUN npm install -g @devcontainers/cli

# Installing Lua Dependencies for testing LUA projects
# RUN luarocks install moonscript
RUN luarocks install busted
# RUN luarocks remove busted --force
# RUN luarocks make

# Create user called my-app in ubuntu and switch to this user
ARG USER=my-app
RUN useradd -ms /bin/bash ${USER}
USER ${USER}

WORKDIR /home/${USER}

# Installing vim-plug
RUN mkdir -p /home/${USER}/.local/share/nvim/lazy/nvim-devcontainer-cli/
COPY ./ /home/${USER}/.local/share/nvim/lazy/nvim-devcontainer-cli/
