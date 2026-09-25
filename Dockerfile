FROM codercom/code-server:latest

USER root

RUN apt-get update && \
    apt-get install -y \
        git \
        curl \
        python3 \
        python3-pip \
        nodejs \
        npm \
    && rm -rf /var/lib/apt/lists/*

USER coder

EXPOSE 10000

CMD ["code-server", "--bind-addr", "0.0.0.0:10000", "--auth", "password", "/home/coder/project"]
