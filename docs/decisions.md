# Decisions

This file records architecture decisions in an ADR-style format.

## 2026-04-03 - Use TensorRT-LLM as sole backend (superseded)

- **Context**: Need a local, performant inference stack for Gemma 4 on RTX 4090.
- **Decision**: Use TensorRT-LLM (`trtllm-serve`) only; no fallback backend.
- **Rationale**: NVIDIA-optimized stack, OpenAI-compatible API, and strong GPU utilization.
- **Alternatives considered**: Ollama, vLLM.
- **Status**: **Superseded** -- see 2026-04-03 entry below.

## 2026-04-03 - Switch from TensorRT-LLM to Ollama

- **Context**: TensorRT-LLM `1.3.0rc10` does not support Gemma 4. AutoDeploy crashes with `KeyError: 'gemma4'` in the config parser, and the manual `convert_checkpoint.py` script also fails with the same error. NVIDIA's own Gemma 4 launch blogs recommend Ollama and llama.cpp for RTX GPU deployment -- TensorRT-LLM is not mentioned.
- **Decision**: Replace TensorRT-LLM with Ollama as the inference backend.
- **Rationale**:
  - NVIDIA-recommended for RTX GPUs with Gemma 4.
  - `gemma4:26b` (Q4_K_M, 18GB) fits comfortably on 24GB RTX 4090.
  - Best single-user throughput via llama.cpp backend.
  - OpenAI-compatible API at `/v1/` requires minimal changes to existing CLI, Open-WebUI, and LiteLLM configs.
- **Alternatives considered**:
  - TensorRT-LLM: no Gemma 4 support in current release.
  - vLLM: Day 0 Gemma 4 support, but 26B model requires 80GB in BF16; quantized path less documented for consumer GPUs.
  - llama.cpp directly: viable, but Ollama wraps it with simpler model management and Docker integration.
- **Evidence**:
  - TRT-LLM crash: `KeyError: 'gemma4'` in `tensorrt_llm/models/gemma/config.py`
  - NVIDIA blog: https://blogs.nvidia.com/blog/rtx-ai-garage-open-models-google-gemma-4/
  - Ollama model page: https://ollama.com/library/gemma4:26b

## 2026-04-03 - Run inference in Docker with WSL2

- **Context**: Primary host OS is Windows.
- **Decision**: Run Ollama in Docker Desktop with WSL2 backend and GPU passthrough.
- **Rationale**: Most reliable support path for NVIDIA containers on Windows hosts.
- **Alternatives considered**: Native Windows runtime.

## 2026-04-03 - Bridge Claude Code through LiteLLM (superseded)

- **Context**: Claude Code expects Anthropic-compatible endpoints.
- **Decision**: Add LiteLLM proxy mapping Claude model names to local Gemma via Ollama API.
- **Rationale**: Avoid custom protocol adapter code and keep a standard local bridge.
- **Alternatives considered**: Custom translation service.
- **Status**: **Superseded** -- see direct Ollama entry below.

## 2026-04-03 - Connect Claude Code directly to Ollama

- **Context**: LiteLLM's Anthropic-to-OpenAI translation layer drops `tool_use` blocks, so Claude Code cannot execute tools (Bash, Read, Write, etc.) through the proxy. Ollama v0.14+ added native Anthropic API compatibility at `/v1/messages`, including structured `tool_use` responses, streaming, and vision.
- **Decision**: Point Claude Code directly at Ollama (`http://localhost:11434`) using the native Anthropic API. Use `claude-launcher` to remap all role models to the local Ollama model.
- **Rationale**:
  - Eliminates the LiteLLM translation layer and its tool-call parsing bugs.
  - Ollama v0.20.0 fully supports `tool_use` content blocks in Anthropic format.
  - `claude-launcher` prevents background role-model requests from leaking to Anthropic cloud.
- **Alternatives considered**:
  - LiteLLM with `ollama_chat/` prefix and `supports_function_calling`: partial fix, still has known parsing issues ([litellm#24091](https://github.com/BerriAI/litellm/issues/24091)).
  - Custom middleware to transform tool responses: unnecessary given Ollama's native support.
- **LiteLLM retained as optional**: Still useful for OpenAI-compatible clients that are not Claude Code.

## 2026-04-03 - Default model target

- **Context**: Need a practical quality/speed model for 24 GB VRAM.
- **Decision**: Default to `gemma4:26b` (Q4_K_M quantization via Ollama).
- **Rationale**: 18GB download, 25.8B total params with only 3.8B active (MoE), balanced speed and quality.
- **Alternatives considered**: `gemma4:31b`, `gemma4:e4b`, `gemma4:e2b`.
