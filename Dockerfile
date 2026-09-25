FROM codercom/code-server:latest

USER root

RUN apt-get update && \
    apt-get install -y \
        git \
        git-lfs \
        curl \
        wget \
        ca-certificates \
        python3 \
        python3-pip \
        python3-venv \
        nodejs \
        npm \
        build-essential \
        procps \
        htop \
        nano \
        vim-tiny \
        openssh-client \
        tmux \
    && git lfs install \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/coder/repo && \
    chown -R coder:coder /home/coder/repo

COPY start.sh /start.sh

RUN chmod +x /start.sh && \
    chown coder:coder /start.sh

USER coder

WORKDIR /home/coder/repo

EXPOSE 10000

ENTRYPOINT ["/start.sh"]
