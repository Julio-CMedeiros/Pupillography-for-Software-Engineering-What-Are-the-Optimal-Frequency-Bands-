# Data Directory Structure

This directory contains placeholders for input data required by the analysis scripts. **No sensitive participant data is included in this repository.**

## Directory Layout

```
data/
├── raw/                    # Raw input data
│   └── rr-data/
│       └── Niazy_aux_dataset/  # ECG/HRV data files
├── processed/              # Intermediate processing outputs
│   └── Study 1/
│       ├── Stage 1/        # Initial pupil processing
│       ├── Stage 2/        # Cleaned pupil data
│       └── Stage 3/        # Final pupil features
└── external/               # Configuration and metadata files
    ├── orders_id_sub_hrv_aux_dataset.mat
    ├── orders_id_sub_0004_aux_dataset.mat
    └── database_pupil_ECG.mat
```

## Required Data Files

### raw/rr-data/Niazy_aux_dataset/
Place ECG data files here with the naming convention:
- `S01_run01_500hz_QRS.mat` through `S30_run01_500hz_QRS.mat`

Each file should contain an `ECG` struct with fields:
- `srate`: Sampling rate
- `data`: ECG signal data
- `times`: Time vector
- `event`: Event markers (QRS complexes, triggers)
- `eventV2.taskEvents`: Task-specific timing information

### external/
Configuration files required by the analysis:

- **orders_id_sub_hrv_aux_dataset.mat**: Contains `orders_id_sub` struct with subject/run order information for HRV analysis
- **orders_id_sub_0004_aux_dataset.mat**: Order information for pupillography analysis  
- **database_pupil_ECG.mat**: Contains `database` cell array with synchronized pupil and ECG data for each subject

### processed/
This directory is automatically populated by the analysis scripts. You may pre-populate it with intermediate results if resuming analysis.

## Data Source

All data files can be obtained from the AI4EU public dataset repository:
**https://ai4eu.dei.uc.pt/base-cognitive-state-monitoring-during-bug-inspection-dataset/**

The dataset includes:
- ECG recordings (sampled at 500 Hz)
- Eye-tracking data with pupillography (sampled at 120 Hz)
- Task event markers and timing information
- Fully anonymized participant data

## Privacy and Ethics

- All participant data has been anonymized according to GDPR requirements
- This repository contains only analysis code; data must be downloaded separately
- Any local data should be stored outside version control
- See the main dataset repository for ethics approval documentation
