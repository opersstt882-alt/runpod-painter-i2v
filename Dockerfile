# PainterI2V + LightX2V Worker for RunPod Serverless
# Models baked into image (~39GB) - no Network Volume needed
FROM runpod/worker-comfyui:latest-base

# Install custom nodes via ComfyUI registry
RUN comfy-node-install comfyui-kjnodes comfyui-videohelpersuite

# Install PainterI2V (not in registry, clone from GitHub)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/princepainter/ComfyUI-PainterI2V.git

# Install pip dependencies for PainterI2V if needed
RUN cd /comfyui/custom_nodes/ComfyUI-PainterI2V && \
    if [ -f requirements.txt ]; then pip install -r requirements.txt; fi

# Download models (~39GB total)
# CLIP text encoder (6.7GB)
RUN comfy model download --url "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" --relative-path "models/clip/"

# VAE (508MB)
RUN comfy model download --url "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors" --relative-path "models/vae/"

# LightX2V LoRAs (1.2GB each)
RUN comfy model download --url "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors" --relative-path "models/loras/"
RUN comfy model download --url "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors" --relative-path "models/loras/"

# WAN 2.2 I2V models - HIGH noise (15GB)
RUN comfy model download --url "https://huggingface.co/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/I2V/Wan2_2-I2V-A14B-HIGH_fp8_e4m3fn_scaled_KJ.safetensors" --relative-path "models/diffusion_models/"

# WAN 2.2 I2V models - LOW noise (15GB)
RUN comfy model download --url "https://huggingface.co/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/I2V/Wan2_2-I2V-A14B-LOW_fp8_e4m3fn_scaled_KJ.safetensors" --relative-path "models/diffusion_models/"
