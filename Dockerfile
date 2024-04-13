FROM ubuntu:20.04 as builder

ARG USER_NAME
ARG GROUP_NAME
ARG USER_ID
ARG GROUP_ID

# Create user called my-app in ubuntu
RUN groupadd --gid $GROUP_ID $GROUP_NAME && \
  useradd --uid $USER_ID --gid $GROUP_ID -m $USER_NAME \
  && apt-get update \
  && apt-get install -y --no-install-recommends sudo \
  && echo $USER_NAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER_NAME \
  && chmod 0440 /etc/sudoers.d/$USER_NAME 

# Switch to user
USER ${USER_NAME}

FROM builder as dev

# This part of the code is needed for installing nodejs>=14
RUN sudo apt-get update && \
  sudo apt-get install -y --no-install-recommends \
    apt-utils \
    build-essential \
    curl \
    wget \
  # apt clean-up
  && sudo apt-get autoremove -y \
  && sudo rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -

RUN sudo apt-get update && \
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    # Dependencies needed for bulding devcontainers/cli
    nodejs \
    npm \
    # Dependencies needed for developing in neovim
    lua5.1 \
    luajit \
    luarocks \
    git \
  && sudo apt-get autoremove -y \
  && sudo rm -rf /var/lib/apt/lists/*

ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

WORKDIR /app
# Installing the devcontainers CLI
RUN npm install -g @devcontainers/cli@0.49.0

# Installing Lua Dependencies for testing LUA projects
RUN sudo luarocks install busted

# Installing vim-plug
COPY ./ /home/${USER}/.local/share/nvim/lazy/nvim-devcontainer-cli/
RUN mkdir -p /home/${USER}/.local/share/nvim/lazy/nvim-devcontainer-cli/
RUN chown -R ${USER_NAME}:${GROUP_NAME} /home/${USER_NAME}/.local 
