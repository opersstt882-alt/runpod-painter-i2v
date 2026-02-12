#!/usr/bin/env bash
# PainterI2V Worker - Download models if needed, then start ComfyUI worker

MODELS_DIR="/comfyui/models"
HF_BASE="https://huggingface.co"
MARKER="$MODELS_DIR/.models_downloaded"

download_if_missing() {
    local url="$1"
    local dest="$2"
    if [ ! -f "$dest" ]; then
        echo "[model-dl] Downloading: $(basename $dest)"
        wget -q --show-progress -O "$dest" "$url"
        if [ $? -ne 0 ]; then
            echo "[model-dl] ERROR downloading $(basename $dest), retrying..."
            rm -f "$dest"
            wget -q --show-progress -O "$dest" "$url"
        fi
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

# ===== Start the ComfyUI worker (matching base image logic) =====

# Use libtcmalloc for better memory management
TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
export LD_PRELOAD="${TCMALLOC}"

# Ensure ComfyUI-Manager runs in offline network mode
comfy-manager-set-mode offline || echo "worker-comfyui - Could not set ComfyUI-Manager network_mode" >&2

echo "worker-comfyui: Starting ComfyUI"

: "${COMFY_LOG_LEVEL:=DEBUG}"

if [ "$SERVE_API_LOCALLY" == "true" ]; then
    python -u /comfyui/main.py --disable-auto-launch --disable-metadata --listen --verbose "${COMFY_LOG_LEVEL}" --log-stdout &

    echo "worker-comfyui: Starting RunPod Handler"
    python -u /handler.py --rp_serve_api --rp_api_host=0.0.0.0
else
    python -u /comfyui/main.py --disable-auto-launch --disable-metadata --verbose "${COMFY_LOG_LEVEL}" --log-stdout &

    echo "worker-comfyui: Starting RunPod Handler"
    python -u /handler.py
fi
