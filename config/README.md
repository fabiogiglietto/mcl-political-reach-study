# Config Folder

## Purpose

This folder contains YAML configuration files that store country-specific parameters, making the analysis pipeline easily adaptable to different national contexts without modifying code. All notebooks (00-06) load configuration from these files using the `load_config()` function from `scripts/utils.R`.

## Contents

### `italy_config.yaml`
Complete configuration for the Italian study containing:

- **Country information**: Code (IT), name, language
- **Study timeframe**: Start/end dates (2021-01-01 to 2025-11-30)
- **Meta policy timeline**: Official announcement dates and Italy-specific implementation dates
- **Electoral events**: Major Italian elections with campaign windows
  - 2022 General Election (2022-09-25)
  - 2024 EU Parliamentary Election (2024-06-09)
- **Political actor groups**: Definitions and selection criteria
  - MPs_Reelected: Continuous service across both legislatures (~280 accounts)
  - MPs_New: Elected only in 2022 (~270 accounts)
  - Prominent_Politicians: High-profile non-parliamentary politicians (~200 accounts)
  - Extremists: Alternative media ecosystem accounts (~150 accounts)
- **Producer list IDs**: Meta Content Library list identifiers
  - `mps_all: "2025-09-21-ymub"`
  - `mps_reelected: "2025-12-06-iqbp"`
  - `prominent_politicians: "2025-12-24-vpry"`
  - `extremists_cluster1: "2025-11-29-vpjr"`
  - `extremists_cluster2: "2025-11-29-qkqw"`
- **Data quality parameters**: Imputation methods, censoring thresholds, group-specific parameters
- **Analysis parameters**: Breakpoint detection settings, detected breakpoints (T1/T2/T3)
- **Key findings**: Baseline metrics (53,368 views), decline (-72.1%), recovery (+65.4% of baseline)
- **Output settings**: Figure formats (PNG, 300 DPI, 12x6), group colors, table formats
- **File paths**: Data and output directory structure

### `config_template.yaml`
Template for creating configurations for new countries:
- Same structure as `italy_config.yaml`
- Contains placeholder values with inline documentation
- Includes guidance on adapting the methodology to other contexts
- **Usage**: Copy to `[country_code]_config.yaml` and customize

### `policy_timeline.yaml`
**Status**: Referenced in main README (line 46) but not present as a separate file. Policy timeline information is included within `italy_config.yaml` under the `policy_timeline:` key.

## Usage in Notebooks

All notebooks now load configuration at startup:

```r
# Standard pattern in all notebooks
source("scripts/utils.R")
config <- load_config("IT")
```

### Configuration Access Patterns

**Study Period:**
```r
study_start <- config$study_period$start_date
study_end <- config$study_period$end_date
```

**Producer Lists:**
```r
mps_list_id <- config$producer_lists$mps_reelected
prominent_list_id <- config$producer_lists$prominent_politicians
```

**Policy Timeline:**
```r
policy_start <- config$policy_timeline$initial_tests
global_implementation <- config$policy_timeline$global_implementation
reversal_date <- config$policy_timeline$reversal_announcement
```

**Elections:**
```r
italian_election <- config$elections[[1]]$date
election_window_start <- config$elections[[1]]$window_start
election_window_end <- config$elections[[1]]$window_end
```

**Groups:**
```r
discovery_group <- config$groups$discovery_sample  # "MPs_Reelected"
group_definitions <- config$groups$definitions
```

**Output Settings:**
```r
figure_width <- config$output$figures$width
figure_dpi <- config$output$figures$dpi
group_colors <- config$output$colors
```

**File Paths:**
```r
data_dir <- config$paths$cleaned_data
figures_dir <- config$paths$figures
tables_dir <- config$paths$tables
```

## Notebook-Specific Usage

| Notebook | Primary Config Values Used |
|----------|---------------------------|
| 00 | `producer_lists.*`, `study_period.*` |
| 01 | `paths.*`, `groups.definitions` |
| 02 | `study_period.*`, `policy_timeline.*`, `data_quality.*` |
| 03 | `paths.cleaned_data` |
| 04 | `paths.*`, `producer_lists.*` |
| 05 | `groups.*`, `policy_timeline.*`, `elections.*`, `paths.*` |
| 06 | `output.*`, `paths.*` |

## Benefits of Config-Driven Approach

✅ **Cross-Country Portability**: Create new config files for different countries without changing code
✅ **Single Source of Truth**: All parameters defined once, used everywhere
✅ **Version Control**: Changes to study parameters are tracked in git
✅ **Documentation**: Config files serve as comprehensive documentation of study design
✅ **Consistency**: All notebooks use identical values for dates, groups, colors, etc.
✅ **Maintainability**: Update parameters in one place, affects all notebooks
✅ **Reproducibility**: Clear specification of all study parameters

## Creating Configuration for a New Country

To replicate this study for another country:

### 1. Copy Template
```bash
cp config/config_template.yaml config/de_config.yaml  # For Germany
```

### 2. Customize Parameters
Edit `de_config.yaml` to specify:
- Country code, name, language
- Study timeframe
- Electoral events and dates
- Political actor group definitions
- Producer list IDs (after creating lists in MCL)
- Expected policy implementation dates

### 3. Load in Notebooks
```r
config <- load_config("DE")  # Instead of "IT"
```

### 4. Run Pipeline
Execute notebooks 00-06 in sequence. All country-specific parameters will be loaded from the config file automatically.

## Config File Structure

The config file is organized into logical sections:

```yaml
country:           # Basic country metadata
study_period:      # Temporal boundaries
policy_timeline:   # Meta policy announcement dates
elections:         # Electoral events (array)
groups:           # Political actor definitions
producer_lists:    # MCL list IDs
data_quality:     # Data processing parameters
analysis:         # Breakpoint detection settings
findings:         # Results (for reference)
output:           # Figure/table settings
paths:            # Directory structure
```

## Implementation Notes

### load_config() Function
Located in `scripts/utils.R` (lines 35-71), this function:
- Reads YAML files from `config/` directory
- Validates required fields
- Converts date strings to R Date objects
- Processes election dates into proper format
- Returns a nested list structure

### Config Validation
The function checks for required fields:
- `country`
- `study_period`
- `groups`

Missing fields will stop execution with a clear error message.

### Date Handling
All dates in the config file are stored as strings (`"YYYY-MM-DD"`) and automatically converted to R `Date` objects by `load_config()`.

## Version

- **italy_config.yaml**: Contains parameters for the published Italian study
- **config_template.yaml**: Template for country adaptation
- **Last updated**: 2026-01-04
- **Status**: ✅ Actively loaded by all notebooks (00-06)

## Migration from Hardcoded Values

The refactoring from hardcoded values to config-driven approach involved:
- **Notebook 00**: 2 date values + 5 producer list IDs → config
- **Notebook 01**: File paths → config
- **Notebook 02**: 20+ policy/study dates → config
- **Notebook 03**: Data paths → config
- **Notebook 04**: 5 producer list IDs + paths → config
- **Notebook 05**: 15+ dates + groups + elections → config
- **Notebook 06**: Output settings + colors → config

This centralization eliminated duplication and created a true country-portable pipeline.
