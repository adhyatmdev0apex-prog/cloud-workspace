FROM codercom/code-server:latest

USER root

# ------------------------------------------------------------
# Base development tools
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
    && git lfs install \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Workspace
# ------------------------------------------------------------
RUN mkdir -p /home/coder/project && \
    mkdir -p /home/coder/.config/code-server && \
    mkdir -p /home/coder/entrypoint.d && \
    chown -R coder:coder /home/coder

# ------------------------------------------------------------
# Startup script
# ------------------------------------------------------------
COPY start.sh /start.sh

RUN chmod +x /start.sh && \
    chown coder:coder /start.sh

USER coder

WORKDIR /home/coder/project

# Render normally provides PORT.
# 10000 is the fallback.
EXPOSE 10000

# Our wrapper handles:
#   - repository checkout
#   - code-server configuration
#   - Render PORT
#   - launching the official code-server entrypoint
ENTRYPOINT ["/start.sh"]
