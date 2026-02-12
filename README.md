# PainterI2V Custom RunPod Worker

## 概述
自建 ComfyUI Worker，使用 PainterI2V 节点增强 WAN 2.2 I2V 的动作幅度（比标准端点提升 30-50%）。

## 前置条件
1. GitHub 仓库（用于 RunPod GitHub 集成自动构建 Docker 镜像）
2. RunPod 账号已连接 GitHub
3. RunPod Network Volume（存放模型，~50GB）

## 模型清单（共 ~39GB）

| 文件 | 大小 | 下载源 | 目标目录 |
|---|---|---|---|
| Wan2_2-I2V-A14B-HIGH_fp8_e4m3fn_scaled_KJ.safetensors | 15 GB | [Kijai/WanVideo_comfy_fp8_scaled](https://huggingface.co/Kijai/WanVideo_comfy_fp8_scaled/blob/main/I2V/Wan2_2-I2V-A14B-HIGH_fp8_e4m3fn_scaled_KJ.safetensors) | models/diffusion_models/ |
| Wan2_2-I2V-A14B-LOW_fp8_e4m3fn_scaled_KJ.safetensors | 15 GB | [同上](https://huggingface.co/Kijai/WanVideo_comfy_fp8_scaled/blob/main/I2V/Wan2_2-I2V-A14B-LOW_fp8_e4m3fn_scaled_KJ.safetensors) | models/diffusion_models/ |
| umt5_xxl_fp8_e4m3fn_scaled.safetensors | 6.7 GB | [Comfy-Org](https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/blob/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors) | models/clip/ |
| wan_2.1_vae.safetensors | 508 MB | [Comfy-Org](https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/blob/main/split_files/vae/wan_2.1_vae.safetensors) | models/vae/ |
| wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors | 1.2 GB | [Comfy-Org](https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/blob/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors) | models/loras/ |
| wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors | 1.2 GB | [Comfy-Org](https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/blob/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors) | models/loras/ |

## 部署步骤

### 1. 创建 GitHub 仓库
将本目录（`Dockerfile` + `workflow_api.json`）推送到 GitHub。

### 2. 在 RunPod 创建 Network Volume
- 区域: US-KS-2（已验证 A100 SXM 可用）
- 大小: 50GB
- 需要配置 SSH 公钥后 SSH 进 Pod 下载模型

### 3. 下载模型到 Network Volume
```bash
# 在 RunPod GPU Pod 中执行
bash /tmp/setup-volume.sh
```

### 4. 创建 Serverless Endpoint
- RunPod 控制台 → Serverless → New Endpoint → Start from GitHub Repo
- GPU: NVIDIA A100 SXM 80GB（推理需要 ~40GB VRAM）
- 挂载 Network Volume
- Active Workers: 0（按需缩放）
- Max Workers: 1
- Flash Boot: 启用

### 5. 更新后端代码
`VideoGenService.php` 中新增 `submitComfyUIJob()` 方法调用新端点。

## 核心参数
- `motion_amplitude`: 1.3（NSFW 场景推荐 1.3-1.5，越高动作越大但可能有色偏）
- 采样步数: 4（LightX2V 4-step LoRA）
- 分辨率: 720x1280（竖屏）
- 帧数: 81 帧 @ 24fps = ~3.4 秒

## 预估成本
- A100 SXM Serverless Flex: $0.00076/秒
- 预计生成时间: 60-120秒
- 单次成本: ~$0.05-0.10
- Network Volume: $3.50/月 (50GB × $0.07/GB)

## RunPod 凭据
- API Key: 见 `memory/runpod-credentials.md`
- SSH Key: `/root/.ssh/runpod_key`（已配置到 RunPod 账号）
