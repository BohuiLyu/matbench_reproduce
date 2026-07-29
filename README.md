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

The reconstructed environments in this repository are intended to be **functionally compatible with the submitted code**. They should not be interpreted as exact copies of the environments originally used by the submission authors.

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
- Python-version testing across Python 3.6-3.12;
- dependency extraction from each submission's `info.json`;
- installation and import checks for submitted scripts and notebooks;
- deterministic, error-guided relaxation of dependency constraints;
- exported reconstructed Conda environment files;
- archived environments for selected cases;
- re-executed benchmark outputs for submissions that completed the selected task.

The original MatBench source code remains available from the [official repository](https://github.com/materialsproject/matbench).

## Environment reconstruction workflow

The automated remediation workflow follows this procedure:

1. Create a clean Conda environment for a selected Python version.
2. Parse the Python dependencies recorded in `info.json`.
3. Attempt installation without modifying the submitted requirements.
4. If installation fails, classify the error from the installation log.
5. Apply predefined remediation rules:
   - remove a local build suffix from an unavailable exact pin;
   - remove the version pin from an unavailable package;
   - remove version pins only from packages identified in a dependency conflict;
   - remove all version constraints as a final fallback.
6. Retry installation, with a maximum of five attempts.
7. Install MatBench separately when it is not already present.
8. convert notebooks to Python scripts, collect top-level imports, and run an import-based sanity check.
9. Export the successful Conda environment as a workflow artifact.

These automatic rules correspond to the **Stage 2** procedure described in the paper. Environments requiring missing-package identification, explicit version selection, installation-order changes, mixed `pip`/`conda` installation, source modification, or other human interpretation are classified as **Stage 3**.

## Reusing a reconstructed environment

Choose a submission folder containing an exported environment file:

```bash
git clone https://github.com/BohuiLyu/matbench_reproduce.git
cd matbench_reproduce

conda env create -f benchmarks/matbench_v0.1_<submission>/<environment-file>.yml
conda env list
```

Activate the environment name recorded in the YAML file:

```bash
conda activate <environment-name>
```

Then run the submission script from its benchmark folder, following the submission-specific command documented in the manifest or its local reproduction notes:

```bash
cd benchmarks/matbench_v0.1_<submission>
python <execution-script>.py
```

A successful environment reconstruction does not guarantee successful code execution. Some submissions still fail at runtime because of renamed APIs, relocated modules, changed command-line entry points, missing external resources, or incomplete submitted source files.

## Running the GitHub Actions workflow

For public reuse, the top-level workflow should expose the submission name and Python versions through `workflow_dispatch` inputs. After this interface is enabled:

1. Open the repository's **Actions** tab.
2. Select **Auto Fix Single Model Env**.
3. Choose **Run workflow**.
4. Enter the MatBench submission name and Python versions.
5. Download the exported environment artifact from the completed workflow run.

Example command-line invocation with the GitHub CLI:

```bash
gh workflow run auto_fix_single_model_env.yml \
  -f model=TPOT \
  -f python_versions='["3.8","3.9","3.10"]'
```

## Interpreting the artifacts

The repository contains several kinds of files with different meanings:

| Artifact | Interpretation |
|---|---|
| Original `info.json` | Dependency metadata supplied with the MatBench submission |
| Reconstructed `*.yml` | Environment exported after successful reconstruction and import validation |
| Archived environment | Snapshot of an installed environment for more direct reuse |
| Regenerated result file | Output produced by re-executing one selected representative task |
| Original result file | Benchmark output distributed with the original MatBench submission |

A reconstructed environment may differ from the submission author's original environment because unavailable or conflicting version constraints were sometimes relaxed. Therefore, each environment should be interpreted together with its reconstruction category, Python version, remediation stage, and execution status.

## Reproducibility status

The full per-submission status is reported in the paper and should also be maintained in a machine-readable repository manifest.

The four environment categories are:

- **Category 1:** environment reconstructed directly;
- **Category 2:** environment reconstructed by deterministic automatic remediation;
- **Category 3:** environment reconstructed with human-supervised intervention;
- **Category 4:** environment not reconstructed despite substantial effort.

For traceability, each manifest entry should link to:

- the submission folder;
- the reconstructed environment artifact;
- the re-executed result file, when available;
- the relevant workflow run or commit;
- a short note describing any manual intervention.

## Limitations

This repository evaluates practical reproducibility under the software and hardware conditions described in the accompanying paper. It does not establish bitwise reproducibility or guarantee identical behavior across operating systems, CPU/GPU architectures, CUDA versions, drivers, or future package repositories.

The reconstructed environments were validated for importability and, where reported, for execution of one selected representative MatBench task. They were not necessarily tested on all 13 MatBench tasks.

External APIs, remote datasets, authentication tokens, and resources that are no longer available may prevent re-execution even when the local Python environment is valid.

## Recommended archival record

For the published version of the study, create a tagged GitHub release and archive that exact release on Zenodo. Record the following in both the paper and this README:

- repository release tag;
- Git commit SHA;
- Zenodo DOI;
- date of archival;
- operating system and runner image;
- selected Python versions;
- HPC/CUDA configuration used for code re-execution.

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
