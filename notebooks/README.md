# Analysis Notebooks

This directory contains the Jupyter notebooks that implement the full analysis pipeline. Run them in numerical order.

> **📖 Prerequisites:** Before running these notebooks, you must have Meta Content Library API access and have collected your data. See the [Meta Content Library API documentation](https://developers.facebook.com/docs/content-library-and-api) for detailed setup instructions.

---

## Pipeline Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            DATA COLLECTION                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  00_data_download.ipynb          Download posts from MCL API (run in SRE)   │
│           │                                                                 │
├───────────┴─────────────────────────────────────────────────────────────────┤
│                            DATA PREPARATION                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│           │                                                                 │
│  01_build_dataset.ipynb          Process MCL output, standardize lists      │
│           │                                                                 │
│           ▼                                                                 │
│  02_data_cleaning.ipynb          Validate, clean, create analysis datasets  │
│           │                                                                 │
│           ├───────────────────────────────────────┐                         │
│           ▼                                       ▼                         │
│  03_enrich_surface_info.ipynb    04_producer_list_mapping.ipynb             │
│  (API enrichment)                (Verify list membership)                   │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                              ANALYSIS                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  05_breakpoint_analysis.ipynb    Detect & validate structural breakpoints   │
│           │                                                                 │
│           ▼                                                                 │
│  06_working_paper_outputs.ipynb  Generate publication-ready outputs         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Notebook Descriptions

### 00_data_download.ipynb
**Purpose:** Download posts from Meta Content Library API with provenance tracking

**Environment:** Must run in Meta Secure Research Environment (SRE) or SOMAR VDE

**Inputs:**
- MCL Producer List IDs (created in MCL UI)
- Date range parameters

**Outputs:**
- `data_download_output/posts_with_provenance_DATE.rds` - Raw posts with list provenance
- `data_download_output/producer_provenance_mapping_DATE.csv` - Surface ID → list mapping
- `data_download_output/posts_by_list_over_time.png` - Quick visualization

**Key Operations:**
- Query multiple producer lists simultaneously
- Smart batching to respect 100K results-per-query limit
- Track which list(s) each producer/post belongs to
- Automatic quota management (500K/7-day rolling window)
- Collection creation for organizing queries

**Configuration Required:**
```r
PRODUCER_LISTS <- list(
  list(list_id = "YOUR_LIST_ID_1", list_name = "MPs", description = "..."),
  list(list_id = "YOUR_LIST_ID_2", list_name = "Prominent Politicians", description = "..."),
  ...
)
START_DATE <- "2020-01-01"
END_DATE <- "2024-12-31"
```

**Note:** See the [Meta Content Library API documentation](https://developers.facebook.com/docs/content-library-and-api) for quota strategies and producer list creation.

---

### 01_build_dataset.ipynb
**Purpose:** Process the raw output from 00_data_download.ipynb into analysis-ready format

**Inputs:**
- `data_download_output/posts_with_provenance_DATE.rds` (from 00_data_download)
- `data_download_output/producer_provenance_mapping_DATE.csv` (from 00_data_download)
- Optional: Re-elected MPs file for experience classification

**Outputs:**
- `combined_datasets/political_posts_TIMESTAMP.rds`

**Key Operations:**
- Load posts with provenance from 00_data_download
- Apply surface ID fallbacks for Stories content
- Standardize list classifications (main_list, sub_list)
- Optionally distinguish re-elected vs newly elected MPs
- Add standardized date/time variables

**Configuration Required:**
```r
# Path to 00_data_download output
DATA_DOWNLOAD_OUTPUT_DIR <- "data_download_output"

# Map your producer list names to standard categories
LIST_MAPPINGS <- list(
  "MPs (Re-elected)" = list(main_list = "MPs_Reelected", sub_list = "MPs_Reelected"),
  "Prominent Politicians" = list(main_list = "Prominent_Politicians", ...),
  ...
)
```

---

### 02_data_cleaning.ipynb
**Purpose:** Validate, clean, and create analysis-ready datasets

**Inputs:**
- Combined dataset from Notebook 01 (`combined_datasets/political_posts_*.rds`)

**Outputs:**
- `cleaned_data/cleaned_posts_TIMESTAMP.rds` - All validated posts
- `cleaned_data/weekly_aggregation_TIMESTAMP.rds` - Weekly time series
- `cleaned_data/monthly_aggregation_TIMESTAMP.rds` - Monthly time series
- `cleaned_data/accounts_summary_TIMESTAMP.rds` - Account-level statistics
- `cleaned_data/accounts_both_periods_TIMESTAMP.rds` - Balanced panel
- `cleaned_data/account_period_TIMESTAMP.rds` - Account × Period data
- `cleaned_data/surface_info_TIMESTAMP.rds` - Account metadata
- `cleaned_data/metadata_TIMESTAMP.rds` - Processing metadata

**Key Operations:**
- Validate merge integrity (one account → one list)
- Handle NA views (group-specific imputation)
- Remove posts with NA engagement metrics
- Filter to study timeframe
- Create aggregated datasets for different analyses

**Configuration:**
- Study dates: 2021-01-01 to 2025-11-30 (adjust in config)
- Min posts per period: 10 (for balanced panel)
- Imputation method: Group-specific ratio-weighted

---

### 03_enrich_surface_info.ipynb
**Purpose:** Query MCL API to enrich account metadata

**Inputs:**
- `cleaned_data/surface_ids_for_api_TIMESTAMP.csv`
- `cleaned_data/surface_info_TIMESTAMP.rds`

**Outputs:**
- `cleaned_data/surface_info_enriched_TIMESTAMP.rds`
- `cleaned_data/entity_type_log_TIMESTAMP.csv`

**Key Operations:**
- Query pages, groups, profiles, events APIs
- Determine entity type for each surface
- Add follower counts, verification status
- Identify invalid or inaccessible accounts

**Note:** Requires MCL API access. Run within Meta's Secure Research Environment.

---

### 04_producer_list_mapping.ipynb
**Purpose:** Verify all surface IDs belong to documented producer lists

**Inputs:**
- `cleaned_data/surface_info_enriched_TIMESTAMP.rds`
- MCL producer list definitions

**Outputs:**
- `cleaned_data/surface_id_producer_list_mapping_TIMESTAMP.csv`
- `cleaned_data/producer_list_summary_TIMESTAMP.csv`
- `cleaned_data/surface_info_with_list_mapping_TIMESTAMP.rds`

**Key Operations:**
- Query each producer list membership
- Create mapping table (surface_id → producer_list)
- Identify any IDs not in any producer list
- Generate coverage statistics

**Note:** Requires MCL API access. Important for data provenance verification.

---

### 05_breakpoint_analysis.ipynb
**Purpose:** Detect and validate structural breakpoints (RQ1)

**Inputs:**
- `cleaned_data/weekly_aggregation_TIMESTAMP.rds`
- `cleaned_data/accounts_summary_TIMESTAMP.rds`

**Outputs:**
- `RQ1_results_summary.rds` - Complete results object
- `RQ1_Table*.csv` - Working paper tables
- `RQ1_Figure*.png` - Working paper figures

**Key Operations:**
- Run Bai-Perron structural break detection
- Run PELT changepoint detection
- Cross-algorithm validation
- Phase assignment
- Validation across political actor groups
- Election period analysis
- Total reach robustness check

**Methodology:**
1. Detect breakpoints on discovery sample (re-elected MPs)
2. Cluster detections within 30-day tolerance
3. Retain only breakpoints detected by BOTH algorithms
4. Validate on other groups

---

### 06_working_paper_outputs.ipynb
**Purpose:** Generate publication-ready tables and figures

**Inputs:**
- `cleaned_data/weekly_aggregation_TIMESTAMP.rds`
- Results from Notebook 05

**Outputs:**
- Tables aligned with working paper numbering (Table 2-10)
- Figures aligned with working paper (Figure 1-3)

**Key Operations:**
- Generate summary statistics tables
- Create time series visualizations
- Format phase comparison results
- Export in publication-ready format

---

## Execution Requirements

### Software
- R ≥ 4.3.0
- Required R packages (see requirements.txt)
- Jupyter with R kernel (IRkernel)

### Data Access
- Meta Content Library API access (Notebooks 03, 04)
- MCL data exports (Notebook 01)

### Configuration
- Country-specific config file in `config/`
- Adjust study dates as needed

---

## Adapting for Other Countries

When replicating for a different country:

1. **Notebook 00:** Update producer list IDs and date range
2. **Notebook 01:** Update LIST_MAPPINGS for your producer list names
3. **Notebook 02:** Usually works without modification (config-driven)
4. **Notebooks 03-04:** Update producer list IDs in config
5. **Notebook 05:** Works without modification (data-driven breakpoint detection)
6. **Notebook 06:** Works without modification

See [REPLICATION_GUIDE.md](../REPLICATION_GUIDE.md) for detailed instructions.

---

## Troubleshooting

### Common Issues

**"No weekly_aggregation files found"**
- Run Notebook 02 first to create cleaned datasets

**"Re-elected MPs file not found"**
- Either create the file or the pipeline will use single "MPs" category
- RQ4 (experience effects) requires the re-elected MP distinction

**"API rate limit exceeded"**
- Add pauses between batch requests
- Reduce batch size in Notebooks 03-04

**Memory issues with large datasets**
- Process in chunks
- Increase R memory limit
- Consider sampling for initial testing

---

## Output File Naming Convention

All output files include timestamps for versioning:
- Format: `{description}_{YYYYMMDD_HHMMSS}.{ext}`
- Example: `weekly_aggregation_20251227_143256.rds`

The pipeline automatically uses the most recent version when multiple files exist.
