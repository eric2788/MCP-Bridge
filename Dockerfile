ARG TARGETPLATFORM
FROM --platform=$BUILDPLATFORM python:3.12-slim
USER root
# install curl
RUN apt-get update && apt-get install -y git curl

# install nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y --no-install-recommends nodejs

# install uv
RUN case "$(uname -m)" in \
        aarch64) ARCH="aarch64" ;; \
        arm64) ARCH="aarch64" ;; \
        x86_64) ARCH="x86_64" ;; \
        *) echo "Unsupported architecture" && exit 1 ;; \
    esac && \
    curl -LsSf https://github.com/astral-sh/uv/releases/download/0.5.20/uv-${ARCH}-unknown-linux-gnu.tar.gz | tar -xz && \
    mv uv /usr/local/bin/uv && \
    chmod +x /usr/local/bin/uv

COPY pyproject.toml .

## FOR GHCR BUILD PIPELINE
COPY mcp_bridge/__init__.py mcp_bridge/__init__.py
COPY README.md README.md

RUN uv sync

COPY mcp_bridge mcp_bridge

EXPOSE 8000

WORKDIR /mcp_bridge
ENTRYPOINT ["uv", "run", "main.py"]
