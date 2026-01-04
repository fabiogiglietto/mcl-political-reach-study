# Config Folder

## Purpose

This folder contains YAML configuration files designed to store country-specific parameters, making the analysis pipeline easily adaptable to different national contexts without modifying code.

## Contents

### `italy_config.yaml`
Reference implementation containing all configuration parameters for the Italian study:

- **Country information**: Code, name, language
- **Study timeframe**: Start/end dates for data collection
- **Meta policy timeline**: Official announcement dates and Italy-specific implementation dates
- **Electoral events**: Major Italian elections (2022 General, 2024 EU) with campaign windows
- **Political actor groups**: Definitions and selection criteria for:
  - MPs (Re-elected): Continuous service across both legislatures
  - MPs (New): Elected only in 2022
  - Prominent Politicians: High-profile non-parliamentary politicians
  - Extremists: Alternative media ecosystem accounts
- **Producer list IDs**: Meta Content Library list identifiers used in the study
- **Data quality parameters**: Imputation methods, censoring thresholds, group-specific parameters
- **Analysis parameters**: Breakpoint detection settings, detected breakpoints (T1/T2/T3)
- **Key findings**: Baseline metrics, decline percentages, validation results
- **Output settings**: Figure formats, colors, table settings
- **File paths**: Data and output directory structure

### `config_template.yaml`
Template for creating configurations for new countries:
- Same structure as `italy_config.yaml`
- Contains placeholder values and inline documentation
- Includes guidance on adapting the methodology to other national contexts
- Designed to be copied and renamed to `[country_code]_config.yaml`

### `policy_timeline.yaml`
**Status**: Referenced in main README (line 46) but **NOT present** in the repository.

## Current Status

⚠️ **IMPORTANT**: These configuration files are **NOT currently used** by the analysis notebooks.

### Evidence
- No `load_config()` calls found in any notebook (00-06)
- No `yaml::read_yaml()` or `read_yaml()` calls found
- No references to `italy_config.yaml`, `config_template.yaml`, or `policy_timeline.yaml`
- Configuration values are **hardcoded directly** in notebook cells instead

### What This Means

**Instead of:**
```r
# Load configuration
config <- load_config("IT")

# Use config values
start_date <- config$study_period$start_date
discovery_group <- config$groups$discovery_sample
producer_lists <- config$producer_lists
```

**Notebooks currently do:**
```r
# Hardcoded values directly in cells
start_date <- as.Date("2021-01-01")
discovery_group <- "MPs_Reelected"
producer_lists <- list(
  mps_all = "2025-09-21-ymub",
  mps_reelected = "2025-12-06-iqbp",
  # etc...
)
```

### Implications

1. **No cross-country portability**: Despite the stated goal of making the pipeline "adaptable to other countries," configuration is embedded in notebook code
2. **Maintenance burden**: Changes to parameters require editing multiple notebook cells
3. **Documentation gap**: The comprehensive YAML files document study design but aren't part of the computational workflow
4. **Template not usable**: `config_template.yaml` cannot actually be used because notebooks don't load configs
5. **README mismatch**: Main README describes using config files (lines 391-412) but this doesn't reflect implementation

## Intended Usage (Not Currently Implemented)

The configuration system was designed to enable:

### 1. Easy Country Adaptation
```bash
# Create config for new country
cp config/config_template.yaml config/de_config.yaml
# Edit de_config.yaml with German-specific parameters
```

### 2. Load Config in Notebooks
```r
# At notebook start
source("scripts/utils.R")
config <- load_config("IT")  # or "DE", "FR", etc.

# Access parameters
study_start <- config$study_period$start_date
study_end <- config$study_period$end_date
groups <- config$groups$definitions
```

### 3. Parameterized Analysis
All country-specific values would be read from config rather than hardcoded, enabling:
- Same notebooks for different countries
- Version-controlled parameter changes
- Clear documentation of study design decisions
- Easier replication and adaptation

## Current Value

Despite not being used computationally, the config files provide:

✅ **Documentation**: Comprehensive record of study design decisions
✅ **Reference**: Clear specification of all parameters used in the Italian study
✅ **Template**: Starting point for researchers planning similar studies
✅ **Reproducibility**: Documents exact values used (even though they're also in notebooks)

## To Integrate Config Files

To make the notebooks actually use these configuration files:

1. **Implement `load_config()` in utils.R** (already present but unused):
   ```r
   source("scripts/utils.R")
   config <- load_config("IT")
   ```

2. **Replace hardcoded values** in notebooks with config references:
   - Study dates: `config$study_period$start_date`
   - Group names: `config$groups$discovery_sample`
   - Producer list IDs: `config$producer_lists$mps_all`
   - Analysis parameters: `config$analysis$breakpoint_detection$cluster_tolerance_days`
   - Colors: `config$output$colors$MPs_Reelected`

3. **Remove duplicate definitions** from notebook cells

4. **Test with multiple configs** to verify portability

## Missing File

The main README references `policy_timeline.yaml` (line 46) which does not exist. The policy timeline information is currently:
- Embedded in `italy_config.yaml` under the `policy_timeline:` key
- Not needed as a separate file given current non-usage

## Recommendation

Choose one of these paths:

**Option A: Use the configs**
- Refactor notebooks to source `utils.R` and load configs
- Replace hardcoded values with config references
- Gain true country portability and maintainability
- Makes the "replication-friendly" design actually work

**Option B: Keep as documentation only**
- Accept configs as documentation artifacts
- Remove references to loading configs from README
- Update README to clarify configs document design but aren't loaded
- Keep hardcoded approach in notebooks

**Option C: Remove the configs**
- Delete YAML files since they're redundant with notebook code
- Update README to remove config references
- Accept single-country, less portable design

**Current state (unused configs)** creates false expectations about portability and duplicates effort (maintaining both configs and hardcoded values).

## Version

- **italy_config.yaml**: Contains parameters for the published Italian study
- **config_template.yaml**: Template for country adaptation
- **Last updated**: 2026-01-04
