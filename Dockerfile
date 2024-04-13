FROM ubuntu:20.04 as builder

ARG USER_NAME
ARG GROUP_NAME
ARG USER_ID
ARG GROUP_ID

# Create user called my-app in ubuntu
RUN groupadd --gid $GROUP_ID $GROUP_NAME && \
  useradd --uid $USER_ID --gid $GROUP_ID -m $USER_NAME

# This part of the code is needed for installing nodejs>=14
RUN apt-get update && apt-get install -y \
  build-essential \
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
  git \
  && rm -rf /var/lib/apt/lists/*

# Installing the devcontainers CLI
RUN npm install -g @devcontainers/cli@0.49.0

# Installing Lua Dependencies for testing LUA projects
RUN luarocks install busted

# Switch to user
USER ${USER_NAME}

# Installing vim-plug
COPY ./ /home/${USER}/.local/share/nvim/lazy/nvim-devcontainer-cli/
RUN mkdir -p /home/${USER}/.local/share/nvim/lazy/nvim-devcontainer-cli/
