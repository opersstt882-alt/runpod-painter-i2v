#!/bin/bash
# PainterI2V Worker - Download models if needed, then start ComfyUI worker
set -e

MODELS_DIR="/comfyui/models"
HF_BASE="https://huggingface.co"
MARKER="$MODELS_DIR/.models_downloaded"

download_if_missing() {
    local url="$1"
    local dest="$2"
    if [ ! -f "$dest" ]; then
        echo "[model-dl] Downloading: $(basename $dest)"
        wget -q --show-progress -O "$dest" "$url"
        echo "[model-dl] Done: $(basename $dest) ($(du -h "$dest" | cut -f1))"
    else
        echo "[model-dl] Already exists: $(basename $dest) ($(du -h "$dest" | cut -f1))"
    fi
}

if [ ! -f "$MARKER" ]; then
    echo "[model-dl] ===== First boot - downloading models (~39GB) ====="

    mkdir -p "$MODELS_DIR/diffusion_models" "$MODELS_DIR/clip" "$MODELS_DIR/vae" "$MODELS_DIR/loras"

    # CLIP text encoder (6.7GB)
    download_if_missing \
        "$HF_BASE/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" \
        "$MODELS_DIR/clip/umt5_xxl_fp8_e4m3fn_scaled.safetensors"

    # VAE (508MB)
    download_if_missing \
        "$HF_BASE/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors" \
        "$MODELS_DIR/vae/wan_2.1_vae.safetensors"

    # LightX2V LoRAs (1.2GB each)
    download_if_missing \
        "$HF_BASE/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors" \
        "$MODELS_DIR/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors"

    download_if_missing \
        "$HF_BASE/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors" \
        "$MODELS_DIR/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors"

    # WAN 2.2 I2V models (15GB each)
    download_if_missing \
        "$HF_BASE/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/I2V/Wan2_2-I2V-A14B-HIGH_fp8_e4m3fn_scaled_KJ.safetensors" \
        "$MODELS_DIR/diffusion_models/Wan2_2-I2V-A14B-HIGH_fp8_e4m3fn_scaled_KJ.safetensors"

    download_if_missing \
        "$HF_BASE/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/I2V/Wan2_2-I2V-A14B-LOW_fp8_e4m3fn_scaled_KJ.safetensors" \
        "$MODELS_DIR/diffusion_models/Wan2_2-I2V-A14B-LOW_fp8_e4m3fn_scaled_KJ.safetensors"

    touch "$MARKER"
    echo "[model-dl] ===== All models downloaded! ====="
    du -sh "$MODELS_DIR"
else
    echo "[model-dl] Models already present, skipping download."
fi

# ===== Start the original ComfyUI worker =====
# Replicate the logic from the base image's /start.sh

# Find and use tcmalloc for better memory management
TCMALLOC="$(ldconfig -p 2>/dev/null | grep -Po "libtcmalloc.so.\d" | head -n 1)"
if [ -n "$TCMALLOC" ]; then
    echo "[start] Using tcmalloc: $TCMALLOC"
    export LD_PRELOAD="$TCMALLOC"
fi

# Set ComfyUI-Manager to offline mode
export COMFYUI_MANAGER_MODE="offline"

# Logging level
COMFY_LOG_LEVEL=${COMFY_LOG_LEVEL:-DEBUG}

echo "[start] Starting ComfyUI worker..."

if [ "${SERVE_API_LOCALLY}" = "true" ]; then
    echo "[start] Local API mode enabled"
    python3 /comfyui/main.py --disable-auto-launch --disable-metadata --listen \
        --log-level "$COMFY_LOG_LEVEL" 2>&1 &

    python3 -u /rp_handler.py --rp_serve_api --rp_api_host=0.0.0.0
else
    python3 /comfyui/main.py --disable-auto-launch --disable-metadata \
        --log-level "$COMFY_LOG_LEVEL" 2>&1 &

    python3 -u /rp_handler.py
fi
