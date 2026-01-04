# Scripts Folder

## Purpose

This folder contains reusable R functions designed to be shared across the analysis pipeline notebooks. The scripts provide modular, well-documented functions for common operations.

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
**Status**: Referenced in README but not yet implemented.

## Current Status

⚠️ **IMPORTANT**: These scripts are **NOT currently used** by the analysis notebooks.

### Evidence
- No `source("scripts/...")` calls found in any notebook (00-06)
- Notebooks implement analysis logic **inline** rather than calling these functions
- For example, `notebooks/05_breakpoint_analysis.ipynb` implements Bai-Perron and PELT detection directly instead of using `run_bai_perron()` or `run_pelt()`

### Implications
1. **Code duplication**: Analysis logic is duplicated across notebooks where needed
2. **Maintenance burden**: Changes to methodology require updates in multiple places
3. **Testing difficulty**: Inline code is harder to unit test than isolated functions
4. **Documentation gap**: README describes a modular architecture that doesn't match implementation

## Intended Usage (Not Currently Implemented)

The scripts were designed to be sourced at the beginning of notebooks:

```r
# Load shared utilities
source("scripts/utils.R")
source("scripts/breakpoint_functions.R")

# Use utility functions
config <- load_config("IT")
data <- load_latest_dataset("weekly_aggregation")

# Run breakpoint analysis
results <- run_breakpoint_analysis(
  data = weekly_data,
  discovery_group = "MPs_reelected",
  metrics = c("avg_views", "avg_reactions", "avg_shares", "avg_comments")
)

# Access results
final_breakpoints <- results$final_breakpoints
validation <- results$validation
```

## To Integrate These Scripts

To make the notebooks actually use these functions:

1. **Add source statements** to notebook headers:
   ```r
   source("scripts/utils.R")
   source("scripts/breakpoint_functions.R")
   ```

2. **Replace inline implementations** with function calls:
   - Replace inline Bai-Perron code with `run_bai_perron()`
   - Replace inline PELT code with `run_pelt()`
   - Replace manual clustering with `cluster_breakpoints()`
   - Use `run_breakpoint_analysis()` wrapper for complete pipeline

3. **Verify consistency**: Ensure function implementations match current inline logic

4. **Update documentation**: Update README to reflect actual usage

## Recommendation

Choose one of these paths:

**Option A: Use the scripts**
- Refactor notebooks to source and use these functions
- Gain maintainability, testability, and DRY benefits
- Keep scripts synchronized with notebook needs

**Option B: Remove the scripts**
- Delete unused script files
- Update README to remove references
- Accept inline implementation approach

## Version

- **utils.R**: Version 1.0.0
- **breakpoint_functions.R**: Version 1.0.0
- **Last updated**: 2026-01-04
