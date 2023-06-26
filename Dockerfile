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
RUN luarocks install busted

# Create user called my-app in ubuntu
ARG USER=my-app
RUN useradd -ms /bin/bash ${USER}

# Install nvim
COPY --chmod=0755 ./bin/devcontainer_setup_scripts/root_setup.sh .
RUN ./root_setup.sh

# Switch to user
WORKDIR /home/${USER}
USER ${USER}

# Installing vim-plug
RUN mkdir -p /home/${USER}/.local/share/nvim/lazy/nvim-devcontainer-cli/
COPY ./ /home/${USER}/.local/share/nvim/lazy/nvim-devcontainer-cli/
