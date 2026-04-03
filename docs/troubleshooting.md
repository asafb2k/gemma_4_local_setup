# Troubleshooting

Track setup and runtime problems here as you encounter them.

## Ollama

- **Symptom**: `http://localhost:11434/api/tags` not responding.
  - **Checks**:
    - `docker compose logs -f ollama`
    - `docker compose ps ollama` -- ensure status is "Up".
    - Docker Desktop is running with WSL2 backend.

- **Symptom**: Model not available in Open-WebUI or CLI.
  - **Checks**:
    - Pull the model: `docker exec gemma_4_local_setup-ollama-1 ollama pull gemma4:26b`
    - List models: `docker exec gemma_4_local_setup-ollama-1 ollama list`

- **Symptom**: GPU not detected in container.
  - **Checks**:
    - `docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu22.04 nvidia-smi`
    - Docker Desktop WSL integration enabled.
    - Windows NVIDIA driver up to date.

- **Symptom**: Slow inference or CPU-only execution.
  - **Checks**:
    - Confirm GPU is used: `docker exec gemma_4_local_setup-ollama-1 ollama ps`
    - Ensure Docker Compose has GPU reservation (check `docker-compose.yml`).

## LiteLLM / Claude Code

- **Symptom**: Claude Code auth or model errors.
  - **Checks**:
    - `ANTHROPIC_BASE_URL=http://localhost:4000`
    - `ANTHROPIC_AUTH_TOKEN=sk-local-key`
    - LiteLLM running with `configs/litellm_config.yaml`.

- **Symptom**: LiteLLM starts but upstream calls fail.
  - **Checks**:
    - `api_base` points to `http://localhost:11434`
    - Model is pulled and available in Ollama.

## Open-WebUI

- **Symptom**: Web UI is up but cannot generate replies.
  - **Checks**:
    - `ollama` service healthy.
    - `OLLAMA_BASE_URL=http://ollama:11434` set in compose.
    - `docker compose logs -f open-webui`.

## Docker / WSL2

- **Symptom**: Very slow first model pull.
  - **Cause**: `gemma4:26b` is ~18GB download on first run.
  - **Action**: Wait for download; subsequent starts use cached model in `ollama-data` volume.

## Historical: TensorRT-LLM

TensorRT-LLM was the original backend but was replaced due to lack of Gemma 4 support.

- `trtllm-serve` AutoDeploy crashed with tokenizer error: `'list' object has no attribute 'keys'`
- Manual `convert_checkpoint.py` failed with `KeyError: 'gemma4'`
- See `docs/decisions.md` for full rationale.
