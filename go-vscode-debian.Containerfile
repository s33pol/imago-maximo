# Go; Debian builder for VSCode
FROM golang
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
LABEL description="VSCode builder for Go 1 + 'gopls'"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y \
    sudo git openssh-client gcc \
    && rm -rf /var/lib/apt/lists/*
# VSCode user
RUN groupadd --gid $USER_GID $USERNAME \
    && adduser --disabled-password --gecos "" --uid $USER_UID --gid $USER_GID $USERNAME \
    && adduser vscode sudo \
    && echo "vscode ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
USER $USERNAME
# Go language server 'gopls'
RUN GO111MODULE=on go get -x golang.org/x/tools/gopls@latest