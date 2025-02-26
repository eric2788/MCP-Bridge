ARG TARGETPLATFORM
FROM --platform=$BUILDPLATFORM python:3.12-bullseye

# install curl, qemu-user-static
RUN apt-get update && apt-get install -y git curl

# install nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y --no-install-recommends nodejs

# install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH=$HOME/.local/bin:$PATH

COPY pyproject.toml .

## FOR GHCR BUILD PIPELINE
COPY mcp_bridge/__init__.py mcp_bridge/__init__.py
COPY README.md README.md

RUN uv sync

COPY mcp_bridge mcp_bridge

EXPOSE 8000

WORKDIR /mcp_bridge
ENTRYPOINT ["uv", "run", "main.py"]
