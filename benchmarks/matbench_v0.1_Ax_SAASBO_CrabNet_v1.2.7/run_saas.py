#!/usr/bin/env python
import os
import argparse
from utils.matbench import (
    collect_results,
    dummy,
    matbench_fold,
    savepath,
    task,
)

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--mode", choices=["train", "collect"], required=True,
                   help="train: 训练单个 fold；collect: 汇总全部结果")
    p.add_argument("--fold", type=int, default=None,
                   help="在 --mode=train 时指定 fold；若不给则读取 SLURM_ARRAY_TASK_ID")
    args = p.parse_args()

    print(f"[run_saas] dummy={dummy} savepath={savepath}")

    if args.mode == "train":
        fold = args.fold
        if fold is None:
            # 允许用数组作业的索引
            sid = os.getenv("SLURM_ARRAY_TASK_ID")
            if sid is None:
                raise SystemExit("ERROR: --fold 未提供，且未检测到 SLURM_ARRAY_TASK_ID")
            fold = int(sid)

        # 基于 saas_submitit.py 原逻辑：对单个 fold 运行 matbench_fold
        print(f"[run_saas] TRAIN fold={fold}")
        matbench_fold(fold)

    elif args.mode == "collect":
        # 基于 saas_submitit.py：最后执行汇总
        print(f"[run_saas] COLLECT → {savepath}")
        collect_results()

if __name__ == "__main__":
    main()