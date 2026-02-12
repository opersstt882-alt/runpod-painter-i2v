#!/bin/bash
# Download all models to RunPod Network Volume
# Run this inside a RunPod GPU Pod with the network volume mounted at /runpod-volume/
# Total download: ~39GB

set -e

MODELS_DIR="/runpod-volume/models"
HF_BASE="https://huggingface.co"

mkdir -p "$MODELS_DIR/diffusion_models"
mkdir -p "$MODELS_DIR/clip"
mkdir -p "$MODELS_DIR/vae"
mkdir -p "$MODELS_DIR/loras"

echo "=== Downloading WAN 2.2 I2V HIGH noise model (15GB) ==="
wget -c -O "$MODELS_DIR/diffusion_models/Wan2_2-I2V-A14B-HIGH_fp8_e4m3fn_scaled_KJ.safetensors" \
  "$HF_BASE/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/I2V/Wan2_2-I2V-A14B-HIGH_fp8_e4m3fn_scaled_KJ.safetensors"

echo "=== Downloading WAN 2.2 I2V LOW noise model (15GB) ==="
wget -c -O "$MODELS_DIR/diffusion_models/Wan2_2-I2V-A14B-LOW_fp8_e4m3fn_scaled_KJ.safetensors" \
  "$HF_BASE/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/I2V/Wan2_2-I2V-A14B-LOW_fp8_e4m3fn_scaled_KJ.safetensors"

echo "=== Downloading CLIP text encoder (6.7GB) ==="
wget -c -O "$MODELS_DIR/clip/umt5_xxl_fp8_e4m3fn_scaled.safetensors" \
  "$HF_BASE/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"

echo "=== Downloading VAE (508MB) ==="
wget -c -O "$MODELS_DIR/vae/wan_2.1_vae.safetensors" \
  "$HF_BASE/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"

echo "=== Downloading LightX2V LoRA HIGH noise (1.2GB) ==="
wget -c -O "$MODELS_DIR/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors" \
  "$HF_BASE/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors"

echo "=== Downloading LightX2V LoRA LOW noise (1.2GB) ==="
wget -c -O "$MODELS_DIR/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors" \
  "$HF_BASE/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors"

echo "=== All models downloaded! ==="
echo "Total size:"
du -sh "$MODELS_DIR"
echo ""
echo "Directory structure:"
find "$MODELS_DIR" -type f -exec ls -lh {} \;
