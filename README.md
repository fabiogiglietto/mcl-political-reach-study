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
>
> **Preprint:** https://osf.io/preprints/socarxiv/8dqag_v2/

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
│   ├── 02_data_cleaning.ipynb           # Validation, cleaning, aggregation
│   ├── 03_enrich_surface_info.ipynb     # API enrichment of account metadata
│   ├── 04_producer_list_mapping.ipynb   # Verify account list membership
│   ├── 05_breakpoint_analysis.ipynb     # RQ1: Main breakpoint detection
│   └── 06_working_paper_outputs.ipynb   # Generate tables/figures for paper
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
│  │        NOTEBOOK 02: DATA CLEANING & PREPARATION                 │   │
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
│  │        NOTEBOOK 05: BREAKPOINT ANALYSIS (RQ1)                   │   │
│  │  • Bai-Perron structural break detection                        │   │
│  │  • PELT changepoint detection                                   │   │
│  │  • Cross-algorithm validation                                   │   │
│  │  • Phase assignment & magnitude estimation                      │   │
│  │  • Validation across political actor groups                     │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                │                                        │
│                                ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │        NOTEBOOK 06: WORKING PAPER OUTPUTS                       │   │
│  │  • Generate publication-ready tables                            │   │
│  │  • Create figures aligned with paper sections                   │   │
│  │  • Export results summary                                       │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Replication Materials

To facilitate replication and extension of this study, all analysis code and documentation are publicly available in this repository. The complete analytical pipeline—from data download through breakpoint detection—is provided as a series of documented notebooks that can be executed within the Meta Secure Research Environment (SRE) or other approved platforms with Meta Content Library API access.

### Code Availability

The repository includes seven core notebooks:
- **00_data_download.ipynb:** Data download from MCL API
- **01_build_dataset.ipynb:** Dataset construction and standardization
- **02_data_cleaning.ipynb:** Data cleaning and validation
- **03_enrich_surface_info.ipynb:** Account metadata enrichment
- **04_producer_list_mapping.ipynb:** Producer list verification
- **05_breakpoint_analysis.ipynb:** Breakpoint analysis (RQ1)
- **06_working_paper_outputs.ipynb:** Publication outputs

Each notebook contains detailed documentation and is designed to run sequentially within the secure computing environment. The repository also provides configuration templates for adapting the methodology to other country contexts.

### Data Access Requirements

Replication requires approved researcher access to the **Meta Content Library API**. The Meta Content Library provides comprehensive access to publicly available content from Facebook and Instagram, including post-level engagement metrics and view counts.

**To obtain access:**
- Apply through Meta's official application process: [Meta Content Library - Get Access](https://developers.facebook.com/docs/content-library-and-api/get-access)
- All data querying and analysis must be conducted within Meta's secure computing environment
- Raw post-level data cannot be downloaded for local analysis due to Meta's data protection policies

**Documentation:**
- Official API docs: [Meta Content Library and API Documentation](https://developers.facebook.com/docs/content-library-and-api)

### Producer Lists

The original producer lists used in this study are publicly accessible to any researcher with Meta Content Library API access. These lists can be imported directly into new research projects, enabling exact replication of the sample.

**Italian Study Producer Lists:**

1. **MPs (Re-elected):** Members of Parliament elected in both 2018 and 2022 legislatures
   https://www.facebook.com/transparency-tools/content-library/producer-lists/1508867967036191/

2. **Parlamentari ITA Leg XIX:** All members of the XIX Italian legislature (2022–present)
   https://www.facebook.com/transparency-tools/content-library/producer-lists/1079401170932761/

3. **Prominent Politicians:** Most-followed Italian politicians not holding parliamentary seats
   https://www.facebook.com/transparency-tools/content-library/producer-lists/2018160402336859/

4. **Extremists (Cluster 1):** Italian pages and public figures in the alternative media ecosystem
   https://www.facebook.com/transparency-tools/content-library/producer-lists/1546733040084559/

5. **Extremists (Cluster 2):** Additional Italian pages and public figures in the alternative media ecosystem
   https://www.facebook.com/transparency-tools/content-library/producer-lists/25433097262993192/

**For detailed information on list composition, membership criteria, and import instructions, see [PRODUCER_LISTS.md](PRODUCER_LISTS.md).**

### Cross-Country Replication

The repository includes a detailed replication guide ([REPLICATION_GUIDE.md](REPLICATION_GUIDE.md)) for adapting the methodology to other national contexts.

**To examine Meta's political content policy in other countries:**

1. **Identify analogous political actor categories:**
   - Elected representatives (e.g., MPs, Congress members, Parliament members)
   - Prominent non-elected politicians (party leaders, governors, etc.)
   - Comparison groups (optional: extremist accounts, alternative media)

2. **Create producer lists** in the MCL interface for each category

3. **Adapt configuration files** to specify country-specific parameters:
   - Election dates
   - Policy timeline expectations
   - Study timeframe

4. **Execute pipeline notebooks** in sequence (00 → 07)

The modular design allows researchers to modify individual components while maintaining methodological consistency with the original study.

**Important Note:** While code and producer lists are publicly available, raw post-level data cannot be shared outside the secure environment. Replication therefore requires independent data collection through the MCL API. Aggregated results and statistical outputs can be exported following Meta's review process for non-sensitive materials.

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

**⚠️ IMPORTANT:** In Meta's Secure Research Environment (SRE), you **cannot** use `git clone` because external repository access is restricted for data protection. You must manually create notebooks and copy code from this repository.

**Step-by-Step Setup Process:**

```bash
# 1. Access your approved secure computing environment (e.g., Meta SRE)

# 2. Create project directory structure
mkdir -p mcl-political-reach-study/notebooks
mkdir -p mcl-political-reach-study/scripts
mkdir -p mcl-political-reach-study/data/raw
mkdir -p mcl-political-reach-study/data/processed
mkdir -p mcl-political-reach-study/data/cleaned
mkdir -p mcl-political-reach-study/outputs/figures
mkdir -p mcl-political-reach-study/outputs/tables
mkdir -p mcl-political-reach-study/config

# 3. Install R dependencies (if not already available)
# See Prerequisites section above for required packages

# 4. Create your MCL producer lists through the MCL UI
# - Navigate to Meta Content Library web interface
# - Create producer lists for your political actor groups
# - Document the list IDs (you'll paste them into notebook 00)
```

**For each notebook (00-07), you need to:**

1. **In Meta SRE:** Create a new R notebook with the corresponding name
   - Notebook 00: `00_data_download.ipynb`
   - Notebook 01: `01_build_dataset.ipynb`
   - Notebook 02: `02_data_cleaning.ipynb`
   - Notebook 03: `03_enrich_surface_info.ipynb`
   - Notebook 04: `04_producer_list_mapping.ipynb`
   - Notebook 05: `05_breakpoint_analysis.ipynb`
   - Notebook 06: `06_working_paper_outputs.ipynb`

2. **From this GitHub repository:** Navigate to the `notebooks/` directory and open each `.ipynb` file

3. **Copy & Paste:** Copy all code cells from the GitHub notebook into your Meta SRE notebook

4. **Configure:** Update configuration values (producer list IDs, dates, etc.) in the appropriate cells

**See [MANUAL_SETUP_GUIDE.md](MANUAL_SETUP_GUIDE.md) for detailed copy/paste instructions for each notebook.**

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

# NOTEBOOK 02: Data Cleaning (Creates analysis datasets)
# - Validates and cleans data
# - Handles NA values with group-specific imputation
# - Creates aggregated datasets (weekly, monthly, account-level)
# Outputs: cleaned_data/*.rds files

# NOTEBOOKS 03-04: Enrichment & Validation (Optional, requires API calls)
# - 03: Enrich account metadata via MCL API
# - 04: Verify producer list membership
# Outputs: enriched surface info, mapping files

# NOTEBOOK 05: Breakpoint Analysis (RQ1 - Main analysis)
# - Detects structural breaks using Bai-Perron and PELT
# - Validates across political actor groups
# Outputs: RQ1_results_summary.rds, tables, figures

# NOTEBOOK 06: Publication Outputs (Generate final results)
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

This research was conducted using the Meta Content Library API. We thank Research Partnerships at Meta for providing access to the Meta Content Library and supporting academic research on platform governance.

We are grateful to Giada Marino and Massimo Terenzi (University of Urbino) for valuable feedback and contributions to the development of this research project.

Anthropic Claude was used to assist with coding, designing and developing the GitHub repository infrastructure, improving the English language in the paper, and supporting various aspects of the research project development.

---

## Contact

Fabio Giglietto
University of Urbino
fabio.giglietto@uniurb.it | 0000-0001-8019-1035
