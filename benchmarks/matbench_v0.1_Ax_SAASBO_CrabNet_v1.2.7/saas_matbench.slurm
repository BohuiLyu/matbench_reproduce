#!/bin/bash
#SBATCH --job-name=saas
#SBATCH --partition=gpu               # 如不需要分区可删
#SBATCH --gres=gpu:1                  # 训练一般要 GPU；汇总时可在提交时改为 --gres=gpu:0
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G                     # 只使用一种内存模式，避免互斥
#SBATCH --time=48:00:00               # 提交时可用 --time 覆盖
#SBATCH --output=slurm-%A_%a.out      # 训练用数组时含 %a；汇总不会展开
#SBATCH --error=slurm-%A_%a.err

# ====== 环境激活（按你机器修改）======
cd "$SLURM_SUBMIT_DIR"
module load cuda                       # 如需
source /ibex/user/lyub/miniconda3/etc/profile.d/conda.sh
conda activate /ibex/user/lyub/miniconda3/envs/Ax_SAASBO_CrabNet_v1.2.7
# =====================================

# 线程与绑定（避免你之前遇到的 CPU 绑定冲突）
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export MKL_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export SLURM_CPU_BIND=cores           # 如仍冲突可改为 none

# 防御：清理任何遗留的互斥内存变量（有时环境里会带）
unset SLURM_MEM_PER_CPU SLURM_MEM_PER_GPU SLURM_MEM_PER_NODE

# MODE=train / collect
MODE="${MODE:-train}"

if [[ "$MODE" == "train" ]]; then
  echo "[SLURM] MODE=train  fold=${SLURM_ARRAY_TASK_ID:-<single>}"
  srun --ntasks=1 --cpu-bind=cores \
      python run_saas.py --mode train ${SLURM_ARRAY_TASK_ID:+--fold $SLURM_ARRAY_TASK_ID}

elif [[ "$MODE" == "collect" ]]; then
  echo "[SLURM] MODE=collect"
  # 汇总通常不需要 GPU，可以在提交时用 --gres=gpu:0 覆盖
  srun --ntasks=1 --cpu-bind=cores \
      python run_saas.py --mode collect

else
  echo "ERROR: 未知 MODE='$MODE'，请用 MODE=train 或 MODE=collect"
  exit 2
fi