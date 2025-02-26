ARG TARGETPLATFORM
FROM --platform=$BUILDPLATFORM python:3.12-slim
USER root
# install curl
RUN apt-get update && apt-get install -y git curl

# install nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y --no-install-recommends nodejs

# install uv with awareness of target architecture
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "arm64" ]; then \
      curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_ARCH=aarch64 sh; \
    else \
      curl -LsSf https://astral.sh/uv/install.sh | sh; \
    fi
ENV PATH=/root/.local/bin:$PATH

COPY pyproject.toml .

## FOR GHCR BUILD PIPELINE
COPY mcp_bridge/__init__.py mcp_bridge/__init__.py
COPY README.md README.md

RUN uv sync

COPY mcp_bridge mcp_bridge

EXPOSE 8000

WORKDIR /mcp_bridge
ENTRYPOINT ["/root/.local/bin/uv", "run", "main.py"]
