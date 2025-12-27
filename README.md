# Meta Political Content Policy: Empirical Analysis Pipeline

[![R Version](https://img.shields.io/badge/R-%3E%3D4.3-blue)](https://www.r-project.org/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![DOI](https://img.shields.io/badge/DOI-pending-lightgrey)]()

## Overview

This repository contains the complete analytical pipeline for studying Meta's political content reduction policy (2021-2025) using data from the **Meta Content Library API**. The analysis examines how platform algorithmic changes affected political actors' reach on Facebook.

**Primary Research Question (RQ1):** *When and to what extent did Meta's political content reduction policy—and its subsequent reversal—affect political actors' reach on Facebook?*

### Reference Study

This pipeline was developed for the study:

> **"A Pretty Blunt Approach": Meta's Political Content Reduction Policy and Italian Parliamentarians' Facebook Visibility**

The methodology is designed to be **fully reproducible** and **adaptable to other countries** where researchers have access to the Meta Content Library.

---

## Key Findings (Italy Case Study)

- **Timing:** Policy effects detected ~10 months before Meta's announced global implementation
- **Magnitude:** ~72% reduction in average reach during the policy period
- **Recovery:** Partial recovery to ~65% of pre-policy levels following January 2025 reversal
- **Validation:** Pattern confirmed across mainstream political actors (MPs, prominent politicians)

---

## Repository Structure

```
mcl-political-reach-study/
├── README.md                    # This file
├── REPLICATION_GUIDE.md         # Guide for adapting to other countries
├── LICENSE                      # MIT License
├── requirements.txt             # R package dependencies
│
├── config/
│   ├── italy_config.yaml        # Italy-specific configuration
│   ├── config_template.yaml     # Template for new countries
│   └── policy_timeline.yaml     # Meta policy announcement dates
│
├── notebooks/
│   ├── 00_data_download.ipynb           # Download posts from MCL API
│   ├── 01_build_dataset.ipynb           # Process MCL output, standardize lists
│   ├── 03_data_cleaning.ipynb           # Validation, cleaning, aggregation
│   ├── 04_enrich_surface_info.ipynb     # API enrichment of account metadata
│   ├── 05_producer_list_mapping.ipynb   # Verify account list membership
│   ├── 06_breakpoint_analysis.ipynb     # RQ1: Main breakpoint detection
│   └── 07_working_paper_outputs.ipynb   # Generate tables/figures for paper
│
├── scripts/
│   ├── utils.R                  # Shared utility functions
│   ├── breakpoint_functions.R   # Bai-Perron & PELT implementations
│   └── visualization.R          # Plotting functions
│
├── docs/
│   ├── DATA_DICTIONARY.md       # Variable definitions
│   ├── METHODOLOGY.md           # Analytical approach explanation
│   └── DATASET_GUIDE.md         # Which dataset for which analysis
│
├── data/
│   ├── raw/                     # Original MCL API exports (not included)
│   ├── processed/               # Intermediate processed files
│   └── cleaned/                 # Analysis-ready datasets
│
└── outputs/
    ├── figures/                 # Generated plots
    └── tables/                  # Generated CSV tables
```

---

## Pipeline Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         DATA COLLECTION LAYER                          │
│  (Meta Content Library API - requires approved researcher access)       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐         │
│  │ MPs Posts Data  │  │ Prominent Pols  │  │ Extremists Data │         │
│  │ (Legislature)   │  │ Posts Data      │  │ (Comparison)    │         │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘         │
│           │                    │                    │                   │
│           └────────────────────┼────────────────────┘                   │
│                                │                                        │
│                                ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │        NOTEBOOK 00: DATA DOWNLOAD (Run in Meta SRE)             │   │
│  │  • Query MCL API for producer lists                             │   │
│  │  • Smart batching (respect 100K limit)                          │   │
│  │  • Track provenance (which list each post came from)            │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                │                                        │
│                                ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │        NOTEBOOK 01: BUILD DATASET                               │   │
│  │  • Process MCL download output                                  │   │
│  │  • Apply surface ID fallbacks for Stories                       │   │
│  │  • Standardize list classifications                             │   │
│  │  • Optionally classify MPs (re-elected vs. new)                 │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                │                                        │
│                                ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │        NOTEBOOK 03: DATA CLEANING & PREPARATION                 │   │
│  │  • Validate merge integrity (one account → one list)            │   │
│  │  • Handle NA views (group-specific imputation)                  │   │
│  │  • Remove NA engagement metrics                                 │   │
│  │  • Filter to study timeframe                                    │   │
│  │  • Create aggregated datasets (weekly, monthly, account-level)  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                │                                        │
│           ┌────────────────────┼────────────────────┐                   │
│           ▼                    ▼                    ▼                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐         │
│  │ cleaned_posts   │  │ weekly_aggr     │  │ accounts_both   │         │
│  │ (2.5M posts)    │  │ (time series)   │  │ (balanced panel)│         │
│  └─────────────────┘  └────────┬────────┘  └─────────────────┘         │
│                                │                                        │
├────────────────────────────────┼────────────────────────────────────────┤
│                         ANALYSIS LAYER                                  │
│                                │                                        │
│                                ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │        NOTEBOOK 06: BREAKPOINT ANALYSIS (RQ1)                   │   │
│  │  • Bai-Perron structural break detection                        │   │
│  │  • PELT changepoint detection                                   │   │
│  │  • Cross-algorithm validation                                   │   │
│  │  • Phase assignment & magnitude estimation                      │   │
│  │  • Validation across political actor groups                     │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                │                                        │
│                                ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │        NOTEBOOK 07: WORKING PAPER OUTPUTS                       │   │
│  │  • Generate publication-ready tables                            │   │
│  │  • Create figures aligned with paper sections                   │   │
│  │  • Export results summary                                       │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Quick Start

### Prerequisites

1. **Meta Content Library API Access**
   - Must be an approved researcher with access to the Meta Content Library
   - **Apply for access**: [Meta Content Library - Get Access](https://developers.facebook.com/docs/content-library-and-api/get-access)
   - **Documentation**: [Meta Content Library and API Official Docs](https://developers.facebook.com/docs/content-library-and-api)
   - Data must be queried within the secure computing environment (Meta SRE or approved platforms)

2. **R Environment** (R ≥ 4.3)
   ```r
   # Install required packages using Meta SRE method
   library(fbrir)
   cran <- CRAN$new()
   cran$InstallPackages(c(
     "tidyverse", "lubridate", "strucchange", "changepoint",
     "zoo", "segmented", "patchwork", "scales", "moments",
     "lme4", "emmeans", "knitr"
   ))
   ```

3. **Producer Lists Setup**
   - Create producer lists in MCL UI for your target accounts
   - Configure list IDs in `config/[country]_config.yaml`
   - Document list contents for reproducibility

### Running the Pipeline

**⚠️ IMPORTANT: All data querying and analysis must be performed within Meta's secure computing environment.**

The Meta Content Library API enforces strict data protection policies. Raw post-level data **cannot be downloaded** for local analysis. You must run the entire pipeline within one of these approved environments:

- **Meta Secure Research Environment (SRE)** - Meta's cloud-based analysis platform
- **SOMAR Virtual Data Enclave (VDE)** - Social Media Archive computing environment
- **Other approved secure platforms** with MCL API access

#### Setup Within Secure Environment

```bash
# 1. Access your approved secure computing environment (e.g., Meta SRE)

# 2. Clone this repository within the secure environment
git clone https://github.com/[username]/mcl-political-reach-study.git
cd mcl-political-reach-study

# 3. Install R dependencies (if not already available)
# See Prerequisites section above for required packages

# 4. Create your MCL producer lists through the MCL UI
# - Navigate to Meta Content Library web interface
# - Create producer lists for your political actor groups
# - Document list IDs in config/[country]_config.yaml
```

#### Execution Workflow

Run notebooks **in numerical order** within the secure environment:

```r
# NOTEBOOK 00: Data Download (Queries MCL API)
# - Queries posts from your producer lists
# - Tracks provenance (which list each post came from)
# - Smart batching for large datasets
# Output: data_download_output/posts_with_provenance_DATE.rds

# NOTEBOOK 01: Build Dataset (Data preparation)
# - Processes raw MCL query output
# - Standardizes list classifications
# - Applies surface ID fallbacks
# Output: combined_datasets/political_accounts_TIMESTAMP.rds

# NOTEBOOK 03: Data Cleaning (Creates analysis datasets)
# - Validates and cleans data
# - Handles NA values with group-specific imputation
# - Creates aggregated datasets (weekly, monthly, account-level)
# Outputs: cleaned_data/*.rds files

# NOTEBOOKS 04-05: Enrichment & Validation (Optional, requires API calls)
# - 04: Enrich account metadata via MCL API
# - 05: Verify producer list membership
# Outputs: enriched surface info, mapping files

# NOTEBOOK 06: Breakpoint Analysis (RQ1 - Main analysis)
# - Detects structural breaks using Bai-Perron and PELT
# - Validates across political actor groups
# Outputs: RQ1_results_summary.rds, tables, figures

# NOTEBOOK 07: Publication Outputs (Generate final results)
# - Creates publication-ready tables and figures
# Outputs: formatted tables and visualizations
```

#### Data Export Policy

⚠️ **You cannot export raw post-level data** from the secure environment.

**What you CAN export:**
- ✅ Aggregated statistics (weekly/monthly totals, means)
- ✅ Analysis results (breakpoint dates, phase comparisons)
- ✅ Figures and visualization files
- ✅ Summary tables (no individual posts/accounts)

**What you CANNOT export:**
- ❌ Raw post-level data (`cleaned_posts_*.rds`)
- ❌ Individual account identifiers or metrics
- ❌ Any file containing post IDs or surface IDs
- ❌ Data that could re-identify specific content or accounts

**Export review process:**
1. Complete all analysis within the secure environment
2. Generate aggregated outputs via Notebook 07
3. Submit export requests through your platform's review process
4. Only approved, non-sensitive outputs will be released

#### Local Repository Use

This GitHub repository serves as:
- **Code distribution:** Share analysis scripts and notebooks
- **Methodology documentation:** Explain analytical approach
- **Results publication:** Host approved aggregated outputs
- **Collaboration:** Enable reproducibility across secure environments

Researchers replicate the study by:
1. Cloning this repo **into their own secure environment**
2. Running the pipeline on their own MCL data access
3. Comparing results across countries/contexts

---

## Configuration for Your Country

To replicate this study for a different country:

1. **Copy the configuration template:**
   ```bash
   cp config/config_template.yaml config/[your_country]_config.yaml
   ```

2. **Define your political actor groups:**
   - Elected representatives (e.g., MPs, Congress members)
   - Prominent politicians (non-legislative)
   - Comparison groups (optional)

3. **Set your country-specific parameters:**
   - Election dates
   - Policy implementation expectations
   - Study timeframe

4. **Create MCL producer lists** for each group

See **[REPLICATION_GUIDE.md](REPLICATION_GUIDE.md)** for detailed instructions.

---

## Output Datasets

The pipeline produces multiple analysis-ready datasets:

| Dataset | Description | Primary Use |
|---------|-------------|-------------|
| `cleaned_posts_*.rds` | All posts with engagement metrics | Post-level analysis (RQ2) |
| `weekly_aggregation_*.rds` | Weekly time series by group | Breakpoint detection (RQ1) |
| `monthly_aggregation_*.rds` | Monthly time series by group | Trend visualization |
| `accounts_both_periods_*.rds` | Accounts active pre & post policy | Balanced panel analysis (RQ3) |
| `account_period_*.rds` | Account-level by period | Policy impact by account |
| `surface_info_*.rds` | Account metadata | Enrichment and verification |

---

## Key Methodological Notes

### View Imputation
- Views ≤100 are censored in MCL API (returned as NA)
- We use **group-specific ratio-weighted imputation** based on power law extrapolation
- Sensitivity analysis shows <0.002% impact on results

### Breakpoint Detection
- **Discovery sample:** Re-elected MPs (continuous activity 2021-2025)
- **Validation groups:** New MPs, Prominent Politicians, Extremists
- **Cross-validation:** Only breakpoints detected by BOTH Bai-Perron AND PELT are retained
- **Three-breakpoint model:** T₁ (Implementation), T₂ (Adjustment), T₃ (Reversal)

### Outcome Measure
- Primary: **Views** (impressions, not unique reach)
- Views count reshare appearances on both original and reshared post
- Engagement metrics (reactions, shares, comments) used for secondary analysis

---

## Citation

If you use this code or methodology, please cite:

```bibtex
@unpublished{giglietto2026meta,
  author = {Giglietto, Fabio},
  title = {A Pretty Blunt Approach: Meta's Political Content Reduction 
           Policy and Italian Parliamentarians' Facebook Visibility},
  year = {2026},
  note = {Working Paper}
}
```

---

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

**Data Note:** Raw data from the Meta Content Library API cannot be redistributed. Researchers must have their own approved access to MCL.

---

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

For questions about replicating this study in other countries, please open an issue.

---

## Acknowledgments

- This research was conducted using the Meta Content Library API
- Thanks to [institutional affiliations]
- [Funding acknowledgments if applicable]

---

## Contact

**Fabio Giglietto**  
University of Urbino  
[Email] | [ORCID]
