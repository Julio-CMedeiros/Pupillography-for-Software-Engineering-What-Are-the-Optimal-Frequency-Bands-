# Optimal frequency bands for pupillography for maximal correlation with HRV - MATLAB Supplementary

This repository contains the MATLAB scripts that supported the preprocessing and analyzing pupillography and HRV data published in:  
**"Pupillography for Software Engineering: What Are the Optimal Frequency Bands?"**  
*Scientific Reports* (Nature Portfolio). [Read paper](https://www.nature.com/articles/s41598-025-85663-2)

## Overview

- Pipeline scripts perform ECG/HRV feature extraction, pupillography preprocessing, and frequency band correlation analysis.
- Supplemental utilities assist with band selection and statistical analysis.
- The supplied files omit participant data; all sensitive inputs should be placed in appropriate data directories for privacy.

## Dependencies

| Tool | Notes |
| --- | --- |
| MATLAB | Tested with R2021b or newer |
| [EEGLAB](https://sccn.ucsd.edu/eeglab/index.php) | Required for pupil data processing |

## Repository Layout

- `project_config.m`: Centralized path configuration used by every script to avoid hard-coded personal paths.
- `src/`: Main MATLAB scripts for analysis.
  - `extract_hrv_features.m`: Preprocessing and HRV feature extraction from ECG data.
  - `extract_pupil_features.m`: Preprocessing and feature extraction from pupillography data.
  - `analyze_frequency_bands.m`: Frequency band correlation analysis and selection.
- `data/`: Placeholder directories for inputs.
  - `raw/`: Raw ECG and eye-tracking data.
  - `processed/`: Intermediate processing outputs.
  - `external/`: Configuration files and metadata.
- `results/`: Directory where processed results and features are saved.
  - `Extracted_Features_Structs/`: HRV features.
  - `Extracted_PUPfeatures_Structs/`: Pupillography features.
  - `Correlations_Files/`: Correlation analysis results.
  - `figures/`: Generated plots and figures.
- `logs/`: Optional log outputs.

## Configuration Helper and Environment Variables

All scripts depend on `project_config.m`. The helper exposes a `cfg` struct with configurable paths:

| Env Variable | Default directory | Description |
| --- | --- | --- |
| `PUP_PROJECT_SCRIPTS` | `src` | Main analysis scripts location |
| `PUP_DATA_RAW` | `data/raw` | Raw ECG and eye-tracking data |
| `PUP_DATA_PROCESSED` | `data/processed` | Intermediate processing outputs |
| `PUP_DATA_EXTERNAL` | `data/external` | Configuration files and metadata |

`project_config` automatically creates placeholder directories if they are missing, but you should populate them with actual data files before running. The helper keeps scripts portable by avoiding any hard-coded paths.

## Data Placeholders and Privacy

Sensitive ECG or eye-tracking data never appears in this repository. All associated data are publicly accessible via the AI4EU project:  
[AI4EU Dataset repository](https://ai4eu.dei.uc.pt/base-cognitive-state-monitoring-during-bug-inspection-dataset/)

Download the datasets and place them in the appropriate directories under `data/` before running the scripts.

## Typical Processing Order

1. **HRV Analysis** (`src/extract_hrv_features.m`): Processes ECG data, extracts R-peaks, computes HRV features in frequency and time domains.
2. **Pupillography Analysis** (`src/extract_pupil_features.m`): Preprocesses pupil diameter signals, removes artifacts, extracts frequency-domain features across multiple bands.
3. **Band Selection** (`src/analyze_frequency_bands.m`): Correlates pupillography bands with HRV metrics, identifies optimal frequency bands, generates visualizations.

Each script reads from the paths exposed by `project_config` and writes results to the appropriate folders.

## Running the Scripts

1. Install or configure dependencies (MATLAB, EEGLAB).
2. Populate the placeholder directories under `data/` with your actual `.mat` files, or set the corresponding environment variables.
3. Run `project_config` from MATLAB to confirm paths and ensure all directories exist.
4. Execute the scripts in the desired order. Scripts should be run from the repository root.

## Output and Verification

- HRV features land under `results/Extracted_Features_Structs/`.
- Pupillography features go to `results/Extracted_PUPfeatures_Structs/`.
- Correlation results are stored in `results/Correlations_Files/`.
- Figures are saved to `results/figures/`.
- Optional logs can be written to `logs/`.

## Citation

If you use this code, please cite:
```
[Citation details for the Scientific Reports paper]
```

## Contact

For further information, please contact the corresponding author: Julio Medeiros (julio.medeiros@dei.uc.pt)
