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
│   ├── 01_build_dataset.ipynb           # Combine raw data sources
│   ├── 02_append_new_data.ipynb         # Add incremental data updates
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
│   ├── DATASET_GUIDE.md         # Which dataset for which analysis
│   ├── MCL_ACCESS_GUIDE.md      # Meta Content Library & SRE guide
│   └── PIPELINE_DIAGRAM.md      # Visual workflow diagram
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
│  │        NOTEBOOK 01: BUILD DATASET                               │   │
│  │  • Combine multiple data sources                                │   │
│  │  • Apply surface ID fallbacks for Stories                       │   │
│  │  • Classify MPs (re-elected vs. new)                            │   │
│  │  • Tag main_list and sub_list categories                        │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                │                                        │
│                                ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │        NOTEBOOK 02: APPEND NEW DATA (Optional)                  │   │
│  │  • Add incremental data updates                                 │   │
│  │  • Verify consistency with existing dataset                     │   │
│  │  • Deduplicate posts                                            │   │
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
   - Must be an approved researcher with access to MCL
   - Apply through ICPSR: https://socialmediaarchive.org/
   - Choose platform: Meta Secure Research Environment (free) or SOMAR VDE
   - Data must be queried within the secure computing environment
   - **See [docs/MCL_ACCESS_GUIDE.md](docs/MCL_ACCESS_GUIDE.md) for detailed application and setup instructions**

2. **R Environment** (R ≥ 4.3)
   ```r
   # Install required packages
   install.packages(c(
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

```bash
# Clone repository
git clone https://github.com/[username]/mcl-political-reach-study.git
cd mcl-political-reach-study

# Copy your raw data exports to data/raw/
# (These must be exported from Meta's Secure Research Environment)

# Run notebooks in order (1-7)
# Each notebook documents its inputs and outputs
```

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
