# PainterI2V + LightX2V Worker for RunPod Serverless
# Uses Network Volume for model storage (~39GB models)
FROM runpod/worker-comfyui:latest-base

# Install custom nodes via ComfyUI registry
RUN comfy-node-install comfyui-kjnodes comfyui-videohelpersuite

# Install PainterI2V (not in registry, clone from GitHub)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/princepainter/ComfyUI-PainterI2V.git

# Install pip dependencies for PainterI2V if needed
RUN cd /comfyui/custom_nodes/ComfyUI-PainterI2V && \
    if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
