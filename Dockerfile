FROM ubuntu:22.04

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Ensure apt is in non-interactive to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies.
RUN apt-get -y update --no-install-recommends \
  && apt-get -y install --no-install-recommends \
  build-essential \
  curl \
  ca-certificates \
  apt-utils \
  dialog \
  git \
  vim \
  zsh \
  wget \
  autojump \
  openssh-client \
  && apt-get autoremove -y \
  && apt-get clean -y

# Create the user.
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

RUN chown -R $USERNAME:$USERNAME /home/vscode

ENV DEBIAN_FRONTEND=dialog

USER $USERNAME

# install oh-my-zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.1/zsh-in-docker.sh)" -- \
  -p git \
  -p ssh-agent \
  -p autojump \
  -p https://github.com/zsh-users/zsh-autosuggestions \
  -p https://github.com/zsh-users/zsh-completions \
  -p https://github.com/zsh-users/zsh-syntax-highlighting

RUN ls -al
ENV NVM_DIR /home/${USERNAME}/.nvm
RUN mkdir /home/${USERNAME}/.nvm
ENV NODE_VERSION 16.15.1

# NVM
## Install nvm
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

## install node and npm
RUN . ${NVM_DIR}/nvm.sh \
  && nvm install $NODE_VERSION \
  && nvm alias default $NODE_VERSION \
  && nvm use $NODE_VERSION

# nvm command
RUN echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"\n[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /home/${USERNAME}/.zshrc

## add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# yarn install
RUN npm install --location=global yarn

# confirm installation
RUN node -v
RUN npm -v
RUN cat ~/.zshrc