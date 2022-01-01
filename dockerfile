FROM ubuntu:20.04 as ubuntu
    ARG USER
    # make a non-root user to run things within the container
    #  RUN echo "pain"
    RUN if [ $(getent group $USER) ]; then echo ''; else groupadd -r $USER; fi && \
        if [ $(getent passwd $USER) ]; then echo ''; else useradd --no-log-init -r -g $USER $USER; fi && \
        usermod -u 1000 $USER && \
        groupmod -g 1000 $USER && \
        # if [ $(id -g) -eq 0 ]; then id -g; else groupmod -g 1000 $USER; fi && \
        mkdir -p /home/$USER && chown -R $USER:$USER /home/$USER/

    ENV TZ=Etc/UTC
    RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

    # dependencies:
    # gcc, make and python are required for erlpack and zlib-sync
    RUN apt-get update && apt-get -y upgrade && apt-get -y install git curl gcc g++ make python3 build-essential

FROM ubuntu as node
    ARG USER
    WORKDIR /home/$USER
    ENV NVM_DIR /home/$USER/.nvm
    USER root
    RUN mkdir -p /home/$USER/.nvm && touch /home/$USER/.bashrc && \
        git clone https://github.com/nvm-sh/nvm.git $NVM_DIR && \
        cd $NVM_DIR && \
        git -c advice.detachedHead=false checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)` && \
        . $NVM_DIR/nvm.sh && \
        nvm install 16 && \
        nvm use 16 && \
        chown -R $USER:$USER /home/$USER/
    # WORKDIR /home/$USER/app/passcontrol
    # COPY .bashrc /home/$USER/.bashrc
    # RUN 
    # RUN npm i -g npm && npm i -g yarn && yarn set version latest
    # RUN yarn install

FROM node AS devcontainer
    ARG USER
    USER root
    RUN mkdir -p /home/$USER/.vscode-server/extensions && \
        mkdir -p /home/$USER/.gnupg && \
        chown -R $USER:$USER /home/$USER/

FROM devcontainer AS completed
    ARG USER
    USER $USER
    WORKDIR /home/$USER/app/passcontrol
    ENV SHELL /bin/bash
