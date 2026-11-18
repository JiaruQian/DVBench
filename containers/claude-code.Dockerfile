FROM node:22-bookworm-slim
ARG CLAUDE_CODE_VERSION
RUN test -n "$CLAUDE_CODE_VERSION" && apt-get update && apt-get install -y --no-install-recommends bash ca-certificates git python3 ripgrep && rm -rf /var/lib/apt/lists/* && npm install -g "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}"
RUN useradd --create-home --uid 1000 agent
ENV HOME=/home/agent
USER agent
WORKDIR /submission
ENTRYPOINT ["claude"]
