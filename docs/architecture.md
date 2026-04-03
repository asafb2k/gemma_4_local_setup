# Architecture

## Overview

This project runs Ollama as the inference backend for Gemma 4 models and exposes it to three clients:

- Open-WebUI (browser chat)
- `cli/chat.py` (terminal chat)
- Claude Code (through LiteLLM Anthropic-compatible bridge)

## Component Diagram

```mermaid
flowchart LR
    subgraph wsl2Docker [WSL2 + Docker]
        OLLAMA["Ollama (port 11434)"]
        MODEL["Gemma 4 model"]
        WEBUI["Open-WebUI (port 3000)"]
        OLLAMA --- MODEL
        WEBUI --> OLLAMA
    end

    subgraph windowsHost [Windows host]
        CLI["cli/chat.py"]
        LLM["LiteLLM proxy (port 4000)"]
        CC["Claude Code"]
    end

    CLI --> OLLAMA
    LLM --> OLLAMA
    CC --> LLM
```

## Ports and Interfaces

- `11434`: Ollama API (native + OpenAI-compatible at `/v1/`)
- `3000`: Open-WebUI web app
- `4000`: LiteLLM endpoint for Anthropic-compatible clients

## Runtime Layout

- Docker/WSL2:
  - `ollama` service (GPU-enabled)
  - `open-webui` service
- Windows host:
  - Python environment (`gemma_4_env`)
  - LiteLLM process
  - CLI and Claude Code

## Request Flow

1. User sends a prompt from UI/CLI/Claude Code.
2. Claude Code requests route through LiteLLM; UI/CLI call Ollama directly.
3. Ollama performs inference on GPU via llama.cpp and streams response tokens.
4. Client receives and renders the response.
