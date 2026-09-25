FROM codercom/code-server:latest

USER root

RUN apt-get update && \
    apt-get install -y \
        git \
        curl \
        wget \
        ca-certificates \
        python3 \
        python3-pip \
        nodejs \
        npm \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/coder/project && \
    chown -R coder:coder /home/coder

USER coder

WORKDIR /home/coder/project

EXPOSE 10000

CMD ["sh", "-c", "exec code-server /home/coder/project --bind-addr 0.0.0.0:${PORT:-10000} --auth password --disable-telemetry --log debug"]
