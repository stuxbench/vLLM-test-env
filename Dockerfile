# CURRENTLY: minimum viable functionality; successfully sets up MCP server
#            but not yet building vLLM (dependency issues)
FROM nvidia/cuda:13.0.1-cudnn-devel-ubuntu24.04

WORKDIR /app

RUN apt-get update && \
    apt-get install -y git curl python3 python3-pip sudo build-essential && \
    rm -rf /var/lib/apt/lists/*

# Clone vllm repository with GitHub credentials
# ENV GITHUB_TOKEN_BASE64="place personal github token here"
# ENV GITHUB_USERNAME="place github username here"
WORKDIR /build
RUN GITHUB_TOKEN=$(echo "$GITHUB_TOKEN_BASE64" | base64 -d); \
    git clone https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/stuxbench/vLLM-clone vllm

WORKDIR /build/vllm

# Checkout branches and create patches
# ARG VULN_BRANCH=baseline
# RUN git checkout $VULN_BRANCH

# ARG TEST_BRANCH=test
# ARG GOLDEN_BRANCH=golden  
# RUN git checkout $TEST_BRANCH
# RUN git checkout $GOLDEN_BRANCH

# # Create test patch (adds the test back to vulnerable code)
# RUN mkdir -p /home/root
# RUN git diff $VULN_BRANCH $GOLDEN_BRANCH > /home/root/test.patch
# RUN chmod 600 /home/root/test.patch

# # Go back to baseline state (vulnerable state without tests)
# RUN git checkout $VULN_BRANCH
# RUN rm -rf .git
# RUN git init && \
#     git config --global user.email "test@example.com" && \
#     git config --global user.name "Test User"
# RUN git add .
# RUN git commit -m "Initial commit"

# build vLLM
# RUN pip3 install --break-system-packages wheel setuptools cmake ninja
# RUN pip3 install --break-system-packages --no-cache-dir -e .

WORKDIR /app

# Install additional testing dependencies  
RUN pip3 install --break-system-packages pytest mcp hud-python

# Copy MCP server code and shared utilities
COPY src/ /app/src/
COPY shared/ /app/shared/
COPY pyproject.toml /app/pyproject.toml

# Install Python dependencies (use --break-system-packages for Docker)
# RUN pip3 install --break-system-packages --no-cache-dir -e .

# Start services
CMD ["sh", "-c", "python3 -m src.controller.env & sleep 2 && exec python3 -m src.controller.server"]