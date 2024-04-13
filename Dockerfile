FROM ubuntu:20.04 as builder

ENV USER_NAME=my-app
ARG GROUP_NAME=$USER_NAME
ARG USER_ID=1000
ARG GROUP_ID=$USER_ID

# Create user called my-app in ubuntu
RUN groupadd --gid $GROUP_ID $GROUP_NAME && \
  useradd --uid $USER_ID --gid $GROUP_ID -m $USER_NAME \
  && apt-get update \
  && apt-get install -y --no-install-recommends sudo \
  && echo $USER_NAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER_NAME \
  && chmod 0440 /etc/sudoers.d/$USER_NAME 

# Switch to user
USER $USER_NAME

# Install dependencies needed for building devcontainers/cli and developing in neovim
RUN sudo apt-get update && \
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    apt-utils \
    build-essential \
    curl \
    wget \
    nodejs \
    npm \
    lua5.1 \
    luajit \
    luarocks \
    git \
  # apt clean-up
  && sudo apt-get autoremove -y \
  && sudo rm -rf /var/lib/apt/lists/*

ENV NPM_CONFIG_PREFIX=/home/$USER_NAME/.npm-global

WORKDIR /app

# Installing the devcontainers CLI
RUN npm install -g @devcontainers/cli@0.49.0

# Installing Lua Dependencies for testing LUA projects
RUN sudo luarocks install busted

# this will prevent the .local directory from being owned by root on bind mount
RUN mkdir -p /home/$USER_NAME/.local/share/nvim/lazy
