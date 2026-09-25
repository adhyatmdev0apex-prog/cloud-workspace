FROM codercom/code-server:latest

USER root

# ------------------------------------------------------------
# Development environment
# ------------------------------------------------------------

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

# ------------------------------------------------------------
# Repository workspace
# ------------------------------------------------------------

RUN mkdir -p /home/coder/repo && \
    mkdir -p /home/coder/.config/code-server && \
    chown -R coder:coder /home/coder

# ------------------------------------------------------------
# Startup script
# ------------------------------------------------------------

COPY start.sh /start.sh

RUN chmod +x /start.sh && \
    chown coder:coder /start.sh

USER coder

WORKDIR /home/coder/repo

EXPOSE 10000

ENTRYPOINT ["/start.sh"]
