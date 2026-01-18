# ASC26 UnifoLM Runner

本仓库用于记录我在 VM 上跑 ASC26 baseline（UnifoLM world model interaction）的**可复现流程**：从零开始搭环境、准备代码/输入/模型、按 case 脚本运行、以及 PSNR 评测。

本仓库 **不包含** 数据集/模型权重/输出结果（避免仓库过大和误提交）。

---

## 0. 目录规划

我在 VM 上固定使用以下目录结构（后续命令全部基于此路径）：

- Runner 仓库（本仓库，仅脚本/文档）  
  `/home/bohao-fang/asc26/asc26-unifolm-runner`

- 代码仓库（UnifoLM）  
  `/home/bohao-fang/asc26/unifolm-world-model-action`

- 输入数据仓库（官方 5 个 scenario + PSNR 脚本）  
  `/home/bohao-fang/asc26/ASC26-Embodied-World-Model-Optimization`

- 模型权重目录（你本地自行准备，别提交到 GitHub）  
  `/home/bohao-fang/asc26/models/UnifoLM-WMA-0-Dual`

> 如果你换机器/用户名：把本文所有 `/home/bohao-fang` 替换成你的实际 home 路径即可。

---

## 1. 系统前置依赖

推荐 Ubuntu 20.04/22.04 + NVIDIA GPU 环境，确保下面命令可用：

```bash
nvidia-smi
```

安装基础工具：

```bash
sudo apt-get update
sudo apt-get install -y git wget curl rsync
```

---

## 2. Conda 环境（推荐）

创建并进入环境（环境名用 `asc26`）：

```bash
conda create -n asc26 python=3.10 -y
conda activate asc26
```

---

## 3. Clone 代码仓库（UnifoLM）

在固定目录下 clone（已存在可跳过）：

```bash
mkdir -p /home/bohao-fang/asc26
cd /home/bohao-fang/asc26
git clone <UnifoLM代码仓库地址> unifolm-world-model-action
```

**重要提醒：不要在别的地方再 clone 第二份**（例如 `~/unifolm-world-model-action`），否则很容易出现“改了 A 跑的是 B”。

---

## 4. 安装 UnifoLM 依赖

进入代码仓库：

```bash
conda activate asc26
cd /home/bohao-fang/asc26/unifolm-world-model-action
```

```bash
pip install .
```

> 说明：如果你希望之后改代码能立即生效，通常更推荐：
> ```bash
> pip install -e .
> ```
> 但“只跑 baseline”场景下，`pip install .` 也完全可以。

---

## 5. Clone 官方输入仓库（scenario 数据）

官方仓库地址：

- https://github.com/ASC-Competition/ASC26-Embodied-World-Model-Optimization.git

clone：

```bash
cd /home/bohao-fang/asc26
git clone https://github.com/ASC-Competition/ASC26-Embodied-World-Model-Optimization.git
```

检查结构：

```bash
cd /home/bohao-fang/asc26/ASC26-Embodied-World-Model-Optimization
ls -1
```

如果大文件下载不完整（文件大小异常小），尝试：

```bash
sudo apt-get install -y git-lfs
git lfs install
git lfs pull
```

---

## 6. 将 scenario 目录放到 UnifoLM 仓库根目录（推荐：软链接）

比赛/官方示例通常要求：在 `unifolm-world-model-action` 仓库根目录下能直接看到 `unitree_*` 目录。

推荐用软链接（不重复占空间、数据仓库保持原样）：

```bash
cd /home/bohao-fang/asc26/unifolm-world-model-action

for d in /home/bohao-fang/asc26/ASC26-Embodied-World-Model-Optimization/unitree_*; do
  name="$(basename "$d")"
  ln -sfn "$d" "$name"
done
```

### 6.1 验证：当前应能看到这些目录
我这台 VM 当前 `unifolm-world-model-action` 根目录下能看到（你贴出来的真实结果）：

- `unitree_deploy`
- `unitree_g1_pack_camera`
- `unitree_z1_dual_arm_cleanup_pencils`
- `unitree_z1_dual_arm_stackbox`
- `unitree_z1_dual_arm_stackbox_v2`
- `unitree_z1_stackbox`

检查命令：

```bash
cd /home/bohao-fang/asc26/unifolm-world-model-action
ls -1 | grep '^unitree_'
```

> 说明：`unitree_deploy` 可能是代码/部署相关目录，不一定属于 5 个官方 scenario 输入；但它在仓库根目录出现是正常的。

---

## 7. 准备模型权重（不要提交到 GitHub）

请把权重放到：

`/home/bohao-fang/asc26/models/UnifoLM-WMA-0-Dual`

并确认权重文件确实存在：

```bash
ls -lah /home/bohao-fang/asc26/models/UnifoLM-WMA-0-Dual
```

---

## 8. 按要求：只修改 `data_dir`

比赛要求通常限制：只能改 `configs/inference/world_model_interaction.yaml` 里的 `data_dir`。

在我当前环境中，`data_dir` 已经是（你贴出来的真实值，约在第 225 行）：

`/home/bohao-fang/asc26/unifolm-world-model-action`

检查命令：

```bash
grep -n "data_dir" /home/bohao-fang/asc26/unifolm-world-model-action/configs/inference/world_model_interaction.yaml
```

如果需要修改，把它改成：

```yaml
data_dir: /home/bohao-fang/asc26/unifolm-world-model-action
```

---

## 9. 运行推理（以 case1 为例）

务必从 **UnifoLM 仓库根目录** 执行脚本（避免相对路径错乱）：

```bash
conda activate asc26
cd /home/bohao-fang/asc26/unifolm-world-model-action

bash unitree_g1_pack_camera/case1/run_world_model_interaction.sh
```

查看是否在跑：

```bash
pgrep -af world_model_interaction.py
```

---

## 10. PSNR 评测

PSNR 脚本位于官方输入仓库根目录：

`/home/bohao-fang/asc26/ASC26-Embodied-World-Model-Optimization/psnr_score_for_challenge.py`

先看帮助：

```bash
python /home/bohao-fang/asc26/ASC26-Embodied-World-Model-Optimization/psnr_score_for_challenge.py -h
```

然后按脚本要求传入你的输出目录/GT 目录（不同 case 可能不同，以官方脚本说明为准）。

---
