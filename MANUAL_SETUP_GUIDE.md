# Manual Setup Guide for Meta Secure Research Environment

## Why This Guide Exists

In Meta's Secure Research Environment (SRE), you **cannot use `git clone`** or directly import code from external repositories due to data protection restrictions. This guide provides step-by-step instructions for manually setting up the analysis pipeline by creating notebooks and copying code from this GitHub repository.

---

## Prerequisites

Before starting, ensure you have:

1. **Access to Meta SRE** with an approved research project
2. **Access to Meta Content Library API** with appropriate permissions
3. **R kernel available** in your Meta SRE Jupyter environment
4. **Required R packages installed** (see main README.md for the package list)
5. **Producer lists created** in the Meta Content Library UI with their list IDs documented

---

## Setup Process Overview

The setup involves three main steps:

1. **Create directory structure** in Meta SRE
2. **Create notebooks** and copy/paste code from this repository
3. **Configure** your study-specific parameters (producer list IDs, dates, etc.)

---

## Step 1: Create Directory Structure

In your Meta SRE terminal or notebook, run these commands:

```bash
# Create main project directory
mkdir -p mcl-political-reach-study
cd mcl-political-reach-study

# Create subdirectories
mkdir -p notebooks
mkdir -p scripts
mkdir -p data/raw
mkdir -p data/processed
mkdir -p data/cleaned
mkdir -p outputs/figures
mkdir -p outputs/tables
mkdir -p config
mkdir -p data_download_output
```

---

## Step 2: Create Helper Scripts

### Script 1: `scripts/utils.R`

1. In Meta SRE, create a new file: `scripts/utils.R`
2. Go to this repository on GitHub: `scripts/utils.R`
3. Copy the entire contents and paste into your Meta SRE file
4. Save the file

### Script 2: `scripts/breakpoint_functions.R`

1. In Meta SRE, create a new file: `scripts/breakpoint_functions.R`
2. Go to this repository on GitHub: `scripts/breakpoint_functions.R`
3. Copy the entire contents and paste into your Meta SRE file
4. Save the file

---

## Step 3: Create and Configure Notebooks

Create each notebook in **numerical order**. For each notebook:

1. **Create** a new R notebook in Meta SRE
2. **Navigate** to the corresponding notebook in this GitHub repository (`notebooks/` directory)
3. **Copy** each code cell from GitHub
4. **Paste** into your Meta SRE notebook
5. **Configure** study-specific parameters (marked with CONFIGURATION sections)

---

### Notebook 00: Data Download (`00_data_download.ipynb`)

**Purpose:** Query Meta Content Library API for posts from your producer lists

**GitHub Location:** `notebooks/00_data_download.ipynb`

**Critical Configuration Required:**

After copying all cells, you **MUST** update the `PRODUCER_LISTS` configuration:

```r
PRODUCER_LISTS <- list(
  list(
    list_id = "YOUR_ACTUAL_LIST_ID_1",  # ← Replace with your real MCL producer list ID
    list_name = "MPs_Legislature_XXI",   # ← Descriptive name for this group
    description = "Members of Parliament from Legislature XXI"
  ),
  list(
    list_id = "YOUR_ACTUAL_LIST_ID_2",
    list_name = "Prominent_Politicians",
    description = "Non-legislative prominent political figures"
  )
  # Add more lists as needed
)

# Also update these parameters:
START_DATE <- "2020-01-01"  # Your study start date
END_DATE <- "2024-12-31"    # Your study end date
PROJECT_NAME <- "Your Project Name"
```

**How to find your producer list IDs:**
1. Log into Meta Content Library UI
2. Navigate to "Producer Lists"
3. Click on each list you created
4. The list ID appears in the URL or list details

**Output:** `data_download_output/posts_with_provenance_YYYY-MM-DD.rds`

---

### Notebook 01: Build Dataset (`01_build_dataset.ipynb`)

**Purpose:** Process raw MCL output, standardize list classifications, apply surface ID fallbacks

**GitHub Location:** `notebooks/01_build_dataset.ipynb`

**Critical Configuration Required:**

```r
# Update input file path to match your Notebook 00 output
INPUT_FILE <- "data_download_output/posts_with_provenance_2024-12-27.rds"  # Update date

# Update list name mappings to match your producer lists
```

**What this notebook does:**
- Processes raw MCL API output
- Handles Stories surface ID fallbacks
- Standardizes list classifications
- Creates analysis-ready dataset

**Output:** `combined_datasets/political_accounts_TIMESTAMP.rds`

---

### Notebook 03: Data Cleaning (`03_data_cleaning.ipynb`)

**Purpose:** Validate data, handle missing values, create aggregated datasets

**GitHub Location:** `notebooks/03_data_cleaning.ipynb`

**Critical Configuration Required:**

```r
# Update input file path
INPUT_FILE <- "combined_datasets/political_accounts_TIMESTAMP.rds"  # From Notebook 01

# Set your study timeframe
STUDY_START_DATE <- as.Date("2021-01-01")
STUDY_END_DATE <- as.Date("2025-01-31")
```

**What this notebook does:**
- Validates merge integrity
- Handles NA views with group-specific imputation
- Removes invalid engagement metrics
- Creates weekly/monthly aggregations
- Produces balanced panel (accounts active in all periods)

**Outputs:**
- `cleaned_data/cleaned_posts_TIMESTAMP.rds`
- `cleaned_data/weekly_aggregation_TIMESTAMP.rds`
- `cleaned_data/monthly_aggregation_TIMESTAMP.rds`
- `cleaned_data/accounts_both_periods_TIMESTAMP.rds`

---

### Notebook 04: Enrich Surface Info (`04_enrich_surface_info.ipynb`)

**Purpose:** Retrieve additional account metadata from MCL API

**GitHub Location:** `notebooks/04_enrich_surface_info.ipynb`

**Note:** This notebook is **optional** but recommended for enriching account metadata.

**Configuration Required:**

```r
# Update input file
INPUT_FILE <- "combined_datasets/political_accounts_TIMESTAMP.rds"
```

**What this notebook does:**
- Queries MCL API for detailed account information
- Adds verification status, follower counts, etc.
- Creates enriched surface info dataset

**Output:** `enriched_data/surface_info_TIMESTAMP.rds`

---

### Notebook 05: Producer List Mapping (`05_producer_list_mapping.ipynb`)

**Purpose:** Verify which accounts belong to which producer lists

**GitHub Location:** `notebooks/05_producer_list_mapping.ipynb`

**Note:** This notebook is **optional** but useful for validation.

**Configuration Required:**

```r
# Update producer list IDs to match your lists
PRODUCER_LIST_IDS <- c(
  "YOUR_LIST_ID_1",
  "YOUR_LIST_ID_2"
)
```

**What this notebook does:**
- Verifies producer list membership
- Creates mapping of accounts to lists
- Validates data provenance

**Output:** `mapping_data/producer_list_mapping_TIMESTAMP.rds`

---

### Notebook 06: Breakpoint Analysis (`06_breakpoint_analysis.ipynb`)

**Purpose:** Main analysis - detect structural breaks in reach time series (RQ1)

**GitHub Location:** `notebooks/06_breakpoint_analysis.ipynb`

**Critical Configuration Required:**

```r
# Update input file
WEEKLY_DATA_FILE <- "cleaned_data/weekly_aggregation_TIMESTAMP.rds"

# Update group names to match your data
DISCOVERY_GROUP <- "MPs_Reelected"  # Group for initial breakpoint discovery
VALIDATION_GROUPS <- c("MPs_New", "Prominent_Politicians")  # Groups for validation

# Set known policy dates for comparison
POLICY_DATES <- list(
  announced = as.Date("2024-02-09"),
  implemented = as.Date("2024-03-XX"),  # Update with actual date
  reversed = as.Date("2025-01-10")
)
```

**What this notebook does:**
- Runs Bai-Perron structural break detection
- Runs PELT changepoint detection
- Cross-validates breakpoints across algorithms
- Assigns phases (pre-policy, policy, post-policy)
- Estimates magnitude of reach reduction
- Validates findings across political actor groups

**Outputs:**
- `outputs/tables/RQ1_breakpoint_results.csv`
- `outputs/tables/RQ1_phase_comparison.csv`
- `outputs/figures/RQ1_breakpoint_visualization.png`
- `RQ1_results_summary.rds`

---

### Notebook 07: Working Paper Outputs (`07_working_paper_outputs.ipynb`)

**Purpose:** Generate publication-ready tables and figures

**GitHub Location:** `notebooks/07_working_paper_outputs.ipynb`

**Configuration Required:**

```r
# Update input files to match your analysis outputs
RQ1_RESULTS <- "RQ1_results_summary.rds"
CLEANED_POSTS <- "cleaned_data/cleaned_posts_TIMESTAMP.rds"
WEEKLY_AGGR <- "cleaned_data/weekly_aggregation_TIMESTAMP.rds"
```

**What this notebook does:**
- Creates formatted tables for paper
- Generates publication-quality figures
- Exports aggregated results summary
- Produces exportable outputs (compliant with Meta data export policies)

**Outputs:**
- `outputs/tables/table_1_descriptive_stats.csv`
- `outputs/tables/table_2_breakpoint_results.csv`
- `outputs/tables/table_3_phase_comparison.csv`
- `outputs/figures/figure_1_time_series.png`
- `outputs/figures/figure_2_breakpoint_plot.png`

---

## Step 4: Execution Workflow

Once all notebooks are created and configured:

1. **Run Notebook 00** - Download data from MCL API
   - ⏱️ Expected time: 30-60 minutes (depends on data size)
   - ⚠️ Consumes API quota - check quota first!

2. **Run Notebook 01** - Build dataset
   - ⏱️ Expected time: 5-10 minutes

3. **Run Notebook 03** - Clean and aggregate data
   - ⏱️ Expected time: 10-20 minutes

4. **(Optional) Run Notebook 04** - Enrich surface info
   - ⏱️ Expected time: 10-30 minutes
   - Requires additional API calls

5. **(Optional) Run Notebook 05** - Verify producer list mapping
   - ⏱️ Expected time: 5-10 minutes

6. **Run Notebook 06** - Main breakpoint analysis
   - ⏱️ Expected time: 15-30 minutes
   - Most computationally intensive

7. **Run Notebook 07** - Generate publication outputs
   - ⏱️ Expected time: 5-10 minutes

---

## Data Export Guidelines

### ✅ What You CAN Export from Meta SRE:

- Aggregated statistics (weekly/monthly totals, means, medians)
- Analysis results (breakpoint dates, phase comparisons, statistical tests)
- Figures and visualizations
- Summary tables without individual post/account identifiers
- Results from Notebook 07 (designed for export compliance)

### ❌ What You CANNOT Export:

- Raw post-level data (`cleaned_posts_*.rds`)
- Individual account identifiers
- Post IDs or surface IDs
- Any data that could re-identify specific content

### Export Process:

1. Complete all analysis within Meta SRE
2. Generate aggregated outputs via Notebook 07
3. Submit export request through Meta's review process
4. Only approved, non-sensitive outputs will be released

---

## Troubleshooting Common Issues

### Issue: "Cannot find file"
**Solution:** Check that file paths match your actual output filenames. Update `INPUT_FILE` variables to match the timestamp in your actual files.

### Issue: "Producer list ID invalid"
**Solution:**
1. Verify list IDs in Meta Content Library UI
2. Ensure list IDs are strings, not numbers
3. Check that lists are properly created and accessible

### Issue: "Package not found"
**Solution:** Install required packages using Meta SRE's package installation method:
```r
library(fbrir)
cran <- CRAN$new()
cran$InstallPackages(c("tidyverse", "lubridate", "strucchange", "changepoint"))
```

### Issue: "API quota exceeded"
**Solution:**
- Check quota status in Notebook 00
- Wait for quota reset (7-day rolling window)
- Reduce date range or number of producers

### Issue: "Breakpoints not detected"
**Solution:**
- Verify you have sufficient time series data (at least 52 weeks)
- Check that your discovery group has consistent posting activity
- Adjust breakpoint detection parameters if needed

---

## Getting Help

If you encounter issues not covered in this guide:

1. **Check the main README.md** for methodology details
2. **Review DATA_DICTIONARY.md** for variable definitions
3. **Consult METHODOLOGY.md** for analytical approach
4. **Open an issue** on GitHub (do not include sensitive data!)
5. **Contact the research team** (see README for contact info)

---

## Configuration Checklist

Before running the pipeline, verify you have:

- [ ] Created all directory structure
- [ ] Copied all 7 notebooks from GitHub
- [ ] Copied helper scripts (`utils.R`, `breakpoint_functions.R`)
- [ ] Updated producer list IDs in Notebook 00
- [ ] Updated start/end dates in Notebook 00
- [ ] Updated project name and description in Notebook 00
- [ ] Created producer lists in MCL UI
- [ ] Documented list IDs
- [ ] Installed all required R packages
- [ ] Verified R kernel is available in Meta SRE
- [ ] Checked API quota availability

---

## Quick Reference: File Paths to Update

When configuring notebooks, you'll need to update these key variables:

| Notebook | Variable | What to Update |
|----------|----------|----------------|
| 00 | `PRODUCER_LISTS` | Your actual MCL producer list IDs |
| 00 | `START_DATE`, `END_DATE` | Your study timeframe |
| 00 | `PROJECT_NAME` | Your research project name |
| 01 | `INPUT_FILE` | Output filename from Notebook 00 |
| 03 | `INPUT_FILE` | Output filename from Notebook 01 |
| 03 | `STUDY_START_DATE`, `STUDY_END_DATE` | Your analysis period |
| 06 | `WEEKLY_DATA_FILE` | Weekly aggregation from Notebook 03 |
| 06 | `DISCOVERY_GROUP`, `VALIDATION_GROUPS` | Your actual group names |
| 07 | `RQ1_RESULTS`, `CLEANED_POSTS`, etc. | Your actual output filenames |

---

## License

This guide and all associated code are released under the MIT License. See LICENSE file for details.

**Data Note:** Raw data from Meta Content Library API cannot be redistributed. Researchers must have their own approved access to MCL.
