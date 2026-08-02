# MatBench Reproducibility Study

[![GitHub Actions](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF?logo=githubactions&logoColor=white)](../../actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Paper](https://img.shields.io/badge/Paper-DOI%20pending-lightgrey)](#citation)

This repository accompanies the study:

> **When Code Does Not Run: Reproducibility Challenges in Materials Machine Learning Benchmarks**

It contains the continuous-integration workflows, reconstructed Python environments, and selected re-execution outputs used to evaluate the practical reproducibility of public [MatBench](https://github.com/materialsproject/matbench) submissions.

> [!IMPORTANT]
> This is a research fork of the MatBench repository and is **not** the official MatBench distribution.  
> The original benchmark framework, datasets, and submission protocol were developed by the MatBench authors. The main additions in this fork are reproducibility-testing workflows and study-specific artifacts.

## Study scope

We assessed reproducibility at three distinct levels:

1. **Environment reconstruction** — whether a runnable Python environment can be established from the dependency information supplied with a submission.
2. **Code executability** — whether the submitted source code can complete a selected benchmark task and generate benchmark outputs in the reconstructed environment.
3. **Numerical result reproducibility** — whether the regenerated evaluation metrics agree with the originally reported values.

The reconstructed environments in this repository are intended to be **functionally compatible with the submitted code**.

## Main findings

| Outcome | Number of submissions |
|---|---:|
| Environment reconstructed directly from the original metadata | 2 / 28 |
| Environment reconstructed after rule-based automatic remediation | 15 / 28 |
| Environment reconstructed with human-supervised intervention | 9 / 28 |
| Environment not reconstructed after substantial effort | 2 / 28 |
| Selected benchmark task completed and output regenerated | 13 / 28 |

For the 13 submissions that completed re-execution on the selected representative tasks, the regenerated five-fold mean RMSE values were close to the originally reported values; the largest absolute relative difference was 7.2%.

The representative tasks used in this study were:

- `matbench_steels` for composition-based models;
- `matbench_jdft2d` for structure-based models.

## What was added to the upstream MatBench repository

The principal study-specific additions are:

- GitHub Actions workflows for sandboxed environment reconstruction;
  - Installation and import checks for submitted scripts and notebooks (**Check Single Model Env**);
  - Error-guided relaxation of dependency constraints (**Auto Fix Single Model Env**);
  - Export reconstructed Conda environment files (**Lock and Pack Single Model Env**);
- Archived environments for selected cases;
- Re-executed benchmark outputs for submissions that completed the selected task.

The original MatBench source code remains available from the [official repository](https://github.com/materialsproject/matbench).

## Running the GitHub Actions workflow

1. Fork the repository.
2. Open the Actions tab in the fork.
3. Enable workflows if prompted.
4. Select `Check Single Model Env`/`Auto Fix Single Model Env`/`Lock and Pack Single Model Env`.
5. Choose **Run workflow**.
6. Enter the submission name and Python versions.
7. Run the workflow and download the exported environment artifact.

Example command-line invocation with the GitHub CLI:

```bash
gh workflow run auto_fix_single_model_env.yml \
  -f model=TPOT \
  -f python_versions='["3.8","3.9","3.10"]'
```

## Citation

When using the reproducibility workflows, reconstructed environments, or re-execution results from this repository, cite the accompanying study:

```bibtex
@article{lyu_matbench_reproducibility,
  title   = {When Code Does Not Run: Reproducibility Challenges in Materials Machine Learning Benchmarks},
  author  = {Lyu, Bohui and Bonini, John and Zhang, Mao and Sadeghi, Amin and Jaberi, Ali and Hattrick-Simpers, Jason and Choudhary, Kamal and Wines, Daniel and Li, Kangming},
  journal = {<journal>},
  year    = {<year>},
  doi     = {<doi>}
}
```

Please also cite the original MatBench paper:

```bibtex
@article{dunn2020matbench,
  title   = {Benchmarking Materials Property Prediction Methods: The Matbench Test Set and Automatminer Reference Algorithm},
  author  = {Dunn, Alexander and Wang, Qi and Ganose, Alex and Dopp, Daniel and Jain, Anubhav},
  journal = {npj Computational Materials},
  volume  = {6},
  pages   = {138},
  year    = {2020},
  doi     = {10.1038/s41524-020-00406-3}
}
```

## License and attribution

This repository retains the upstream MatBench MIT license. The original MatBench project and its contributors should be credited for the benchmark framework and source code.

Before publication, review third-party submission files and model assets and add a `THIRD_PARTY_NOTICES.md` file for any components governed by separate licenses or attribution requirements.

## Contact

For questions about this reproducibility study, open a GitHub issue or contact the corresponding author listed in the accompanying paper.
