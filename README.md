# ASC26 UnifoLM Runner（可复现环境搭建指南｜换机快速上手）

本仓库的目的：当我换到一台 **有 NVIDIA GPU 的 Linux 机器**（或远程 GPU 平台）时，可以按照本文档快速完成：
- 拉取 UnifoLM 代码
- 拉取 ASC 官方输入（5 个 scenario）
- 下载 UnifoLM-WMA-0 模型权重
- 设置必要路径（仅修改 data_dir）
- 运行 baseline 推理与 PSNR 评测

本仓库 **不包含** 数据集/模型权重/输出结果（避免仓库过大和误提交）。

---

## 0. 一行配置：统一根目录（强烈推荐）

不要写死 `/home/xxx/...`，统一用一个根目录变量（换机器只改这一行）：

```bash
export ASC26_ROOT="$HOME/asc26"
mkdir -p "$ASC26_ROOT"
```

后续所有路径都基于：
- UnifoLM 代码：`$ASC26_ROOT/unifolm-world-model-action`
- ASC 输入仓库：`$ASC26_ROOT/ASC26-Embodied-World-Model-Optimization`
- 模型权重目录：`$ASC26_ROOT/models/UnifoLM-WMA-0-Dual`

---

## 1. 资源链接（官方文档里的网址，务必收藏）

来自官方 Workflow Tutorial（你提供的截图中出现的链接）：

- UnifoLM 代码仓库（GitHub）  
  https://github.com/unitreerobotics/unifolm-world-model-action

- UnifoLM-WMA-0-Dual 权重（HuggingFace）  
  https://huggingface.co/unitreerobotics/UnifoLM-WMA-0-Dual

- ASC 官方输入/评测仓库（GitHub Repo）  
  https://github.com/ASC-Competition/ASC26-Embodied-World-Model-Optimization.git

- ASC 组织主页（入口）  
  https://github.com/ASC-Competition

---

## 2. 系统前置检查（GPU 必备）

确认 GPU 可见：

```bash
nvidia-smi
```

安装基础工具：

```bash
sudo apt-get update
sudo apt-get install -y git wget curl rsync
```

如需 Git LFS（部分仓库/权重可能用到）：

```bash
sudo apt-get install -y git-lfs
git lfs install
```

---

## 3. Conda 环境（推荐）

```bash
conda create -n asc26 python=3.10 -y
conda activate asc26
```

> PyTorch/CUDA 版本请按你的机器和 UnifoLM 仓库要求安装。  
> 如果你在运行时遇到 `CUDA not available` / `libcuda.so` / `torch` 版本不匹配，优先检查 torch 与驱动版本。

---

## 4. 获取 UnifoLM 代码（必做）

```bash
cd "$ASC26_ROOT"
git clone https://github.com/unitreerobotics/unifolm-world-model-action.git
```

> 重要：只保留这一份代码目录，避免出现“改了 A 跑的是 B”。

安装：

```bash
conda activate asc26
cd "$ASC26_ROOT/unifolm-world-model-action"
pip install .
```

> 如果你希望后续改代码立即生效，可用：
> ```bash
> pip install -e .
> ```

---

## 5. 获取 ASC 官方输入仓库（5 个 scenario + PSNR 脚本）

```bash
cd "$ASC26_ROOT"
git clone https://github.com/ASC-Competition/ASC26-Embodied-World-Model-Optimization.git
```

如发现大文件不完整（大小异常小），尝试：

```bash
cd "$ASC26_ROOT/ASC26-Embodied-World-Model-Optimization"
git lfs pull
```

---

## 6. 获取模型权重（HuggingFace）

目标目录约定为：

`$ASC26_ROOT/models/UnifoLM-WMA-0-Dual`

两种常用下载方式（二选一）：

### 方式 A：git lfs clone（最直观）
```bash
mkdir -p "$ASC26_ROOT/models"
cd "$ASC26_ROOT/models"
git lfs clone https://huggingface.co/unitreerobotics/UnifoLM-WMA-0-Dual
```

### 方式 B：huggingface-cli（可控/可断点）
先安装：
```bash
pip install -U "huggingface_hub[cli]"
```

下载：
```bash
mkdir -p "$ASC26_ROOT/models/UnifoLM-WMA-0-Dual"
huggingface-cli download unitreerobotics/UnifoLM-WMA-0-Dual \
  --local-dir "$ASC26_ROOT/models/UnifoLM-WMA-0-Dual" \
  --local-dir-use-symlinks False
```

验证目录存在文件：
```bash
ls -lah "$ASC26_ROOT/models/UnifoLM-WMA-0-Dual"
```

> 注意：权重很大，不要加入 git；本仓库已用 `.gitignore` 屏蔽大文件目录。

---

## 7. 把 scenario 放到 UnifoLM 仓库根目录（软链接，推荐）

官方/比赛脚本通常希望在 UnifoLM 仓库根目录能看到 `unitree_*` 目录。建议用软链接：

```bash
cd "$ASC26_ROOT/unifolm-world-model-action"

for d in "$ASC26_ROOT/ASC26-Embodied-World-Model-Optimization"/unitree_*; do
  name="$(basename "$d")"
  ln -sfn "$d" "$name"
done
```

检查：
```bash
cd "$ASC26_ROOT/unifolm-world-model-action"
ls -1 | grep '^unitree_'
```

> 我在旧 VM 上见到的目录包括（仅供对照）：  
> `unitree_deploy`、`unitree_g1_pack_camera`、`unitree_z1_dual_arm_cleanup_pencils`、`unitree_z1_dual_arm_stackbox`、`unitree_z1_dual_arm_stackbox_v2`、`unitree_z1_stackbox`  
> 其中 `unitree_deploy` 可能是代码/部署目录，不一定属于 5 个输入 scenario，但出现并不奇怪。

---

## 8. 按比赛要求：只修改 `data_dir`

只改这个文件中的 `data_dir`：

`$ASC26_ROOT/unifolm-world-model-action/configs/inference/world_model_interaction.yaml`

把 `data_dir` 设为 UnifoLM 仓库根目录的绝对路径：

```yaml
data_dir: /abs/path/to/unifolm-world-model-action
```

你可以用命令快速检查：
```bash
grep -n "data_dir" "$ASC26_ROOT/unifolm-world-model-action/configs/inference/world_model_interaction.yaml"
```

---

## 9. 运行推理（例：unitree_g1_pack_camera/case1）

务必从 UnifoLM 仓库根目录运行：

```bash
conda activate asc26
cd "$ASC26_ROOT/unifolm-world-model-action"

bash unitree_g1_pack_camera/case1/run_world_model_interaction.sh
```

查看是否在跑：
```bash
pgrep -af world_model_interaction.py
```

---

## 10. PSNR 评测（官方示例命令）

PSNR 脚本在：
`$ASC26_ROOT/ASC26-Embodied-World-Model-Optimization/psnr_score_for_challenge.py`

查看帮助：
```bash
python "$ASC26_ROOT/ASC26-Embodied-World-Model-Optimization/psnr_score_for_challenge.py" -h
```

官方示例（以 `unitree_g1_pack_camera/case1` 为例）：

```bash
python3 "$ASC26_ROOT/ASC26-Embodied-World-Model-Optimization/psnr_score_for_challenge.py" \
  --gt_video unitree_g1_pack_camera/case1/unitree_g1_pack_camera_case1.mp4 \
  --pred_video unitree_g1_pack_camera/case1/output/inference/0_full_fs6.mp4 \
  --output_file unitree_g1_pack_camera/case1/psnr_result.json
```

---
