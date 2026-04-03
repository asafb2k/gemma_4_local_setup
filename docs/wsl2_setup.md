# WSL2 + Docker + GPU Setup

This project runs TensorRT-LLM in Docker with WSL2 backend.

## 1) Install and update WSL2

```powershell
wsl --install
wsl --update
```

Reboot if requested.

## 2) Install Docker Desktop

- Enable WSL2 backend during install.
- In Docker Desktop settings:
  - Enable WSL integration for your distro.
  - Enable GPU support.

## 3) Configure `.wslconfig` on Windows host

Copy `configs/.wslconfig` to:

`C:\Users\<your-user>\.wslconfig`

Then restart WSL:

```powershell
wsl --shutdown
```

## 4) Verify GPU passthrough

```powershell
docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu22.04 nvidia-smi
```

Expected result: NVIDIA device (RTX 4090) appears inside container.

## 5) Verify project stack access

From project root:

```powershell
docker compose up -d trtllm
```

When ready, this should return model metadata:

```powershell
Invoke-RestMethod http://localhost:8000/v1/models
```
