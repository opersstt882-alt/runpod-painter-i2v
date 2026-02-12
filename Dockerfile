# PainterI2V + LightX2V Worker for RunPod Serverless
# Small image - models download at first boot, then cached by Flash Boot
FROM runpod/worker-comfyui:latest-base

# Install custom nodes via ComfyUI registry
RUN comfy-node-install comfyui-kjnodes comfyui-videohelpersuite

# Install PainterI2V (not in registry, clone from GitHub)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/princepainter/ComfyUI-PainterI2V.git

# Install pip dependencies for PainterI2V if needed
RUN cd /comfyui/custom_nodes/ComfyUI-PainterI2V && \
    if [ -f requirements.txt ]; then pip install -r requirements.txt; fi

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
