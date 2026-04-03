# Decisions

This file records architecture decisions in an ADR-style format.

## 2026-04-03 - Use TensorRT-LLM as sole backend

- **Context**: Need a local, performant inference stack for Gemma 4 on RTX 4090.
- **Decision**: Use TensorRT-LLM (`trtllm-serve`) only; no fallback backend.
- **Rationale**: NVIDIA-optimized stack, OpenAI-compatible API, and strong GPU utilization.
- **Alternatives considered**: Ollama, vLLM.

## 2026-04-03 - Run inference in Docker with WSL2

- **Context**: Primary host OS is Windows.
- **Decision**: Run TensorRT-LLM in Docker Desktop with WSL2 backend and GPU passthrough.
- **Rationale**: Most reliable support path for NVIDIA containers on Windows hosts.
- **Alternatives considered**: Native Windows runtime.

## 2026-04-03 - Bridge Claude Code through LiteLLM

- **Context**: Claude Code expects Anthropic-compatible endpoints.
- **Decision**: Add LiteLLM proxy mapping Claude model names to local Gemma via OpenAI API.
- **Rationale**: Avoid custom protocol adapter code and keep a standard local bridge.
- **Alternatives considered**: Custom translation service.

## 2026-04-03 - Default model target

- **Context**: Need a practical quality/speed model for 24 GB VRAM.
- **Decision**: Default to `google/gemma-4-26B-A4B-it`.
- **Rationale**: Balanced speed and quality for development and daily usage.
- **Alternatives considered**: `google/gemma-4-31B-it`, `google/gemma-4-E4B-it`.
