# Troubleshooting

Track setup and runtime problems here as you encounter them.

## TensorRT-LLM

- **Symptom**: `http://localhost:8000/v1/models` not responding after startup.
  - **Checks**:
    - `docker compose logs -f trtllm`
    - Verify first boot is still compiling engine (can take 10-30+ minutes).
    - Ensure `HF_TOKEN` is set if model access is gated.

- **Symptom**: GPU not detected in container.
  - **Checks**:
    - `docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu22.04 nvidia-smi`
    - Docker Desktop WSL integration enabled.
    - Windows NVIDIA driver up to date.

## LiteLLM / Claude Code

- **Symptom**: Claude Code auth or model errors.
  - **Checks**:
    - `ANTHROPIC_BASE_URL=http://localhost:4000`
    - `ANTHROPIC_AUTH_TOKEN=sk-local-key`
    - LiteLLM running with `configs/litellm_config.yaml`.

- **Symptom**: LiteLLM starts but upstream calls fail.
  - **Checks**:
    - `api_base` points to `http://localhost:8000/v1`
    - Local model is visible from `/v1/models`.

## Open-WebUI

- **Symptom**: Web UI is up but cannot generate replies.
  - **Checks**:
    - `trtllm` service healthy.
    - `OPENAI_API_BASE_URL=http://trtllm:8000/v1` inside compose.
    - `docker compose logs -f open-webui`.

## Docker / WSL2

- **Symptom**: Very slow first request.
  - **Cause**: Initial TensorRT engine build and model download.
  - **Action**: Wait for build completion; subsequent startup is faster due to cache.
