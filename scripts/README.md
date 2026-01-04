# Scripts Folder

## Purpose

This folder contains reusable R functions that are shared across the analysis pipeline notebooks. The scripts provide modular, well-documented functions for common operations, enabling code reuse and maintainability.

## Contents

### `utils.R`
General-purpose utility functions for the analysis pipeline:
- **Configuration management**: `load_config()` - Load country-specific YAML configurations
- **File operations**: `find_most_recent_file()`, `generate_output_filename()`, `load_latest_dataset()`
- **Data validation**: `validate_dataset()`, `check_data_integrity()`
- **Data transformation**: `add_policy_phase()`, `calculate_reach_change()`
- **Imputation**: `calculate_imputation_params()`, `impute_views()` - Group-specific view imputation
- **Summary statistics**: `calculate_engagement_stats()`
- **Output formatting**: `print_header()`, `print_subheader()`, `print_dataset_summary()`

### `breakpoint_functions.R`
Specialized statistical functions for breakpoint detection (RQ1 analysis):
- **Bai-Perron detection**: `run_bai_perron()` - Structural break detection
- **PELT detection**: `run_pelt()` - Changepoint detection
- **Multi-metric analysis**: `run_multi_metric_detection()` - Run detection across multiple metrics
- **Clustering**: `cluster_breakpoints()` - Group nearby breakpoints within tolerance window
- **Validation**: `cross_validate_breakpoints()` - Require detection by multiple algorithms
- **Selection**: `select_final_breakpoints()` - Select T1/T2/T3 for three-breakpoint model
- **Cross-group validation**: `validate_breakpoints_across_groups()` - Verify patterns across groups
- **Full pipeline**: `run_breakpoint_analysis()` - Convenience wrapper for complete analysis

### `visualization.R`
**Status**: Referenced in main README (line 60) but not yet implemented. Planned for future development.

## Usage in Notebooks

All notebooks (00-06) now source these scripts and use their functions:

```r
# Standard pattern at the beginning of each notebook
source("scripts/utils.R")
source("scripts/breakpoint_functions.R")  # For breakpoint analysis notebooks
config <- load_config("IT")
```

### Notebook-Specific Usage

| Notebook | utils.R Functions | breakpoint_functions.R | Primary Use Case |
|----------|------------------|------------------------|------------------|
| 00 | `load_config()` | - | Config-driven data download |
| 01 | `load_config()`, `find_most_recent_file()` | - | Dataset construction |
| 02 | `load_config()`, `find_most_recent_file()` | - | Data cleaning with config dates |
| 03 | `load_config()`, `find_most_recent_file()` | - | Surface info enrichment |
| 04 | `load_config()`, `find_most_recent_file()` | - | Producer list mapping |
| 05 | `load_config()`, `load_latest_dataset()`, `add_policy_phase()` | `run_breakpoint_analysis()` | Full breakpoint detection pipeline |
| 06 | `load_config()`, `load_latest_dataset()` | - | Paper outputs with config colors/settings |

## Key Benefits

✅ **Code Reuse**: Functions written once, used across multiple notebooks
✅ **Maintainability**: Changes to methodology made in one place
✅ **Consistency**: All notebooks use the same logic for common operations
✅ **Testability**: Functions can be unit tested independently
✅ **Documentation**: Centralized documentation of analytical methods
✅ **Reproducibility**: Clear separation between methods and application

## Example Usage Patterns

### Loading Configuration
```r
source("scripts/utils.R")
config <- load_config("IT")

# Access configuration values
start_date <- config$study_period$start_date
producer_lists <- config$producer_lists
group_colors <- config$output$colors
```

### File Management
```r
# Find and load most recent dataset
latest_file <- find_most_recent_file("cleaned_data", "weekly_aggregation_.*\\.rds$")
data <- readRDS(latest_file)

# Or use the convenience function
data <- load_latest_dataset("weekly_aggregation", "cleaned_data")
```

### Breakpoint Analysis
```r
source("scripts/breakpoint_functions.R")

# Run complete breakpoint analysis pipeline
results <- run_breakpoint_analysis(
  data = weekly_data,
  discovery_group = config$groups$discovery_sample,
  metrics = c("avg_views", "avg_reactions", "avg_shares", "avg_comments"),
  tolerance_days = 30
)

# Access results
final_breakpoints <- results$final_breakpoints
validation <- results$validation
```

### Data Transformation
```r
# Add policy phases based on detected breakpoints
data_phased <- add_policy_phase(
  data = weekly_data,
  breakpoints = final_breakpoints,
  date_col = "week"
)
```

## Version

- **utils.R**: Version 1.0.0
- **breakpoint_functions.R**: Version 1.0.0
- **Last updated**: 2026-01-04
- **Status**: ✅ Actively used in all notebooks (00-06)
