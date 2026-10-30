FROM node:22-bookworm

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/node \
    CODEX_HOME=/home/node/.codex \
    PING_INTERVAL_SECONDS=18000

RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    ca-certificates \
    openssh-client \
    build-essential \
    python3 \
    python3-pip \
    jq \
    vim \
    nano \
    less \
    ripgrep \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Install Codex CLI
RUN npm install -g @openai/codex@0.166.0

# Install the internal scheduler
COPY --chmod=755 cron-ping.sh /usr/local/bin/cron-ping

# Prepare directories
RUN mkdir -p \
    /workspace \
    /home/node/.codex \
    /home/node/logs \
    && chown -R node:node \
    /workspace \
    /home/node/.codex \
    /home/node/logs

USER node

WORKDIR /workspace

# Start scheduler automatically
CMD ["/usr/local/bin/cron-ping"]