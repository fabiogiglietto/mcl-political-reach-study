# Replication Guide: Adapting This Study to Other Countries

This guide provides detailed instructions for replicating the Meta political content policy analysis in countries other than Italy. The pipeline is designed to be country-agnostic, with all country-specific parameters isolated in configuration files.

---

## Prerequisites

### 1. Meta Content Library API Access
- You must be an approved researcher with access to the Meta Content Library (MCL)
- **Apply for access**: [Meta Content Library - Get Access](https://developers.facebook.com/docs/content-library-and-api/get-access)
- **Official documentation**: [Meta Content Library and API Docs](https://developers.facebook.com/docs/content-library-and-api)
- Data queries must be executed within the secure computing environment (Meta SRE or approved platforms)
- Ensure your research proposal covers comparative political content analysis

### 2. Political Actor Identification
Before starting, you need to identify:
- **Elected representatives** with active Facebook pages/profiles
- **Prominent politicians** (high-profile but non-legislative)
- **Comparison groups** (optional, e.g., extremist accounts, activists)

### 3. Technical Requirements
- R ≥ 4.3.0
- Python 3.8+ (for MCL API queries)
- ~50GB storage for large datasets

---

## Step-by-Step Replication

### Step 1: Define Your Political Actor Groups

#### A. Elected Representatives (Required)
Your primary group should be legislators with:
- Official Facebook pages
- Continuous activity during the study period
- Public, verifiable political affiliation

**Example structures by country:**

| Country | Group Definition |
|---------|-----------------|
| Italy | Members of Parliament (Camera + Senato) |
| Germany | Bundestag members |
| France | Assemblée Nationale + Sénat members |
| UK | House of Commons members |
| USA | House of Representatives + Senate members |
| Brazil | Câmara dos Deputados + Senado members |

#### B. Experience-Based Subgroups (Recommended)
If possible, distinguish:
- **Re-elected/Experienced**: Served multiple terms spanning the policy period
- **Newly elected**: First-time legislators during policy period

This enables RQ4-style analysis of experience effects.

**How to identify re-elected MPs:**
1. Obtain official lists of legislators for relevant legislative terms
2. Cross-reference to identify those serving in both pre- and post-policy legislatures
3. Create separate MCL producer lists for each subgroup

#### C. Prominent Politicians (Recommended)
Non-legislative political actors with significant Facebook reach:
- Party leaders not in legislature
- Regional governors/premiers
- Former national leaders
- High-profile political commentators

#### D. Comparison Groups (Optional)
Groups potentially subject to different algorithmic treatment:
- Political extremist accounts
- Grassroots activists
- Political media outlets

---

### Step 2: Create MCL Producer Lists

Producer lists are essential for filtering MCL data to your specific accounts of interest. See the [Meta Content Library documentation](https://developers.facebook.com/docs/content-library-and-api) for detailed instructions on creating and managing producer lists.

For each political actor group:

1. **Collect Facebook identifiers:**
   - Page IDs (preferred) - numeric identifiers
   - Profile IDs - for individual politician profiles
   - Page/Profile URLs (can be converted to IDs in MCL UI)

2. **Create producer lists in MCL UI:**
   ```
   # In Meta Content Library interface:
   # Navigate to Producer Lists → Create New List
   # Options:
   #   - Search accounts by name and add individually
   #   - Bulk upload via CSV with URLs or IDs
   #   - Import from existing list
   
   # Note the generated list ID (format: YYYY-MM-DD-xxxx)
   # Example: 2025-01-15-abcd
   ```

3. **Verify list contents:**
   - Confirm all accounts are found
   - Check accounts meet MCL inclusion criteria (public, follower thresholds)
   - Note any missing accounts and investigate

4. **Document your lists thoroughly:**
   ```yaml
   # In your config file
   producer_lists:
     mps_reelected: 
       id: "2025-01-15-abcd"
       created: "2025-01-15"
       n_accounts: 280
       description: "MPs serving 2021 AND 2022 legislatures"
     mps_new: 
       id: "2025-01-15-efgh"
       created: "2025-01-15"
       n_accounts: 270
       description: "MPs elected only in 2022"
     prominent_politicians:
       id: "2025-01-16-ijkl"
       created: "2025-01-16"
       n_accounts: 200
       description: "Non-legislative prominent politicians"
     extremists:  # optional comparison group
       id: "2025-01-16-mnop"
       created: "2025-01-16"
       n_accounts: 150
       description: "Accounts flagged for extreme content"
   ```

5. **Share lists with collaborators:**
   - MCL allows sharing editable producer lists between researchers
   - Useful for multi-country comparative studies

---

### Step 3: Configure Your Country Settings

Copy and modify the configuration template:

```bash
cp config/config_template.yaml config/[country_code]_config.yaml
```

#### Essential Configuration Parameters

```yaml
# config/germany_config.yaml (example)

country:
  code: "DE"
  name: "Germany"
  language: "de"

# Study timeframe
study_period:
  start_date: "2021-01-01"
  end_date: "2025-11-30"
  
# Policy dates (use Meta's announcements + expected local timing)
policy_timeline:
  # When do you expect the policy reached your country?
  expected_implementation: "2021-10-01"  # October 2021 expansion
  global_announcement: "2022-07-19"
  reversal_announcement: "2025-01-07"
  
# Key elections during study period
elections:
  - name: "Bundestag Election 2021"
    date: "2021-09-26"
    window_start: "2021-08-01"
    window_end: "2021-10-31"
  - name: "EU Parliamentary Election 2024"
    date: "2024-06-09"
    window_start: "2024-05-01"
    window_end: "2024-06-30"

# Political actor groups
groups:
  discovery_sample: "MPs_Reelected"
  validation_samples:
    - "MPs_New"
    - "Prominent_Politicians"
    - "Extremists"

# MCL Producer List IDs
producer_lists:
  mps_all: "YYYY-MM-DD-xxxx"
  mps_reelected: "YYYY-MM-DD-xxxx"
  prominent_politicians: "YYYY-MM-DD-xxxx"
  
# Data collection parameters
data_collection:
  min_posts_per_period: 10  # Minimum posts to be included in balanced panel
  view_censoring_threshold: 100  # MCL censors views ≤ this value
```

---

### Step 4: Query Data from MCL

Execute queries within your secure computing environment (Meta SRE or SOMAR VDE). For comprehensive API guidance, see the [Meta Content Library API documentation](https://developers.facebook.com/docs/content-library-and-api).

#### Query Structure (Python)

```python
# Example MCL query structure (Python in secure environment)
from metacontentlibrary import ContentLibraryAPI
import pandas as pd

# Initialize API client
api = ContentLibraryAPI()

# Define query parameters
query_params = {
    "producer_list_id": "your-producer-list-id",  # From Step 2
    "start_date": "2021-01-01",
    "end_date": "2025-11-30",
    "fields": [
        "id",
        "creation_time",
        "content_type",
        "message",
        "surface.id",
        "surface.name",
        "statistics.view_count",      # CRITICAL for this study
        "statistics.reaction_count",
        "statistics.share_count", 
        "statistics.comment_count"
    ]
}

# Execute paginated search
all_results = []
for batch in api.search_fb_posts(**query_params):
    all_results.extend(batch)
    print(f"Collected {len(all_results)} posts...")

# Convert to DataFrame and save
df = pd.DataFrame(all_results)
df.to_parquet("mps_posts_raw.parquet", index=False)
```

#### Query Structure (R)

```r
# R equivalent using reticulate or native R interface
library(reticulate)
library(tidyverse)

# Load Python MCL module
mcl <- import("metacontentlibrary")
api <- mcl$ContentLibraryAPI()

# Query and convert to R dataframe
results <- api$search_fb_posts(
  producer_list_id = "your-producer-list-id",
  start_date = "2021-01-01",
  end_date = "2025-11-30",
  fields = list("id", "creation_time", "statistics.view_count", ...)
)

posts_df <- py_to_r(results)
saveRDS(posts_df, "mps_posts_raw.rds")
```

#### Rate Limit Planning

**Standard weekly limit**: 500,000 results (combined UI + API queries)

For large-scale studies (>500k posts), you have three strategies to accelerate data collection:

| Strategy | How It Works | Timeline Impact |
|----------|--------------|-----------------|
| **Extended Quota** | Request 1M limit from Meta | Cuts collection time ~50% |
| **Team Quotas** | Each collaborator has own 500k quota | Multiply capacity by team size |
| **Combined** | Extended quota + multiple team members | Fastest possible collection |

**📖 For information on quota management and extended quotas, see the [Meta Content Library API documentation](https://developers.facebook.com/docs/content-library-and-api).**

**Standard 5-week collection plan** (500k quota, single researcher):
```
Week 1: MPs_Reelected posts (~500k)
Week 2: MPs_New posts (~400k)
Week 3: Prominent_Politicians (~300k)
Week 4: Extremists + buffer (~300k)
Week 5: Re-queries for any failures
```

**Accelerated 2-week plan** (1M quota + 2 collaborators):
```
Week 1: 
  Lead (1M quota): MPs_Reelected (~600k) + MPs_New (~400k)
  Collaborator 1 (500k): Prominent_Politicians (~450k)
  Collaborator 2 (500k): Extremists (~400k)
Week 2: Validation, re-queries, merge datasets
```

#### Using Async Queries for Large Jobs

For producer lists with >100,000 posts:
```python
# Submit async job
job_id = api.async_search_fb_posts(
    producer_list_id="large-list-id",
    start_date="2021-01-01",
    end_date="2025-11-30"
)

# Monitor status
while True:
    status = api.get_async_job_status(job_id)
    if status == "completed":
        break
    time.sleep(60)  # Check every minute

# Retrieve results
results = api.get_async_job_results(job_id)
```

#### Data Validation Checklist

Before proceeding to analysis, verify:
- [ ] All producer lists queried successfully
- [ ] View counts available for most posts
- [ ] Date range covers full study period
- [ ] No unexpected gaps in time series
- [ ] File sizes match expected post counts

**Export data as RDS/parquet files** for use in the R pipeline.

---

### Step 5: Adapt Data Processing Code

#### Notebook 01: Build Dataset

Key modifications needed:
1. Update file paths to your raw data
2. Modify group classification logic if your structure differs

```r
# Example modification for Germany
mps_data <- mps_data %>%
  mutate(
    # Adapt to your re-election logic
    is_reelected = surface.id %in% bundestag_2017_and_2021_members,
    main_list = if_else(is_reelected, "MPs_Reelected", "MPs_New")
  )
```

#### Notebook 03: Data Cleaning

Usually requires minimal changes if configuration is correct:
- Study dates pulled from config
- Group names pulled from config
- Imputation parameters are data-driven

---

### Step 6: Run Breakpoint Analysis

The breakpoint detection code is country-agnostic. However, interpret results in your context:

#### Expected Patterns
Based on Meta's policy rollout:
- **October 2021**: Expansion to "more countries around the world"
- **July 2022**: "Global implementation" announced
- **January 2025**: Reversal announced, gradual rollout

Your detected breakpoints should roughly align with this timeline, though:
- Exact timing may vary by country
- Effects might appear earlier/later than announcements
- Magnitude may differ based on political culture

#### Validation
The cross-algorithm validation will work the same way:
1. Bai-Perron detects structural breaks
2. PELT detects changepoints
3. Only breakpoints confirmed by both algorithms are retained
4. Discovery sample breakpoints are validated across other groups

---

### Step 7: Document Your Findings

Create a country-specific results summary:

```yaml
# outputs/results_summary_[country].yaml
country: "Germany"
analysis_date: "2025-XX-XX"

breakpoints_detected:
  T1_implementation:
    date: "2021-XX-XX"
    uncertainty_range: "±2 weeks"
  T2_adjustment:
    date: "2023-XX-XX"
    uncertainty_range: "±3 weeks"
  T3_reversal:
    date: "2025-XX-XX"
    uncertainty_range: "±1 week"

key_findings:
  baseline_mean_views: XXXXX
  trough_mean_views: XXXXX
  decline_percentage: XX.X%
  post_reversal_recovery: XX.X%

validation:
  groups_validated: X of Y
  pattern_matches: "DOWN → DOWN → UP"
  divergent_groups: ["list any"]
```

---

## Country-Specific Considerations

### Parliamentary Systems (UK, Germany, Italy, etc.)
- Legislature membership is well-defined
- Re-election tracking straightforward via official records
- Coalition dynamics may affect posting behavior

### Presidential Systems (USA, Brazil, France)
- Consider both legislative AND executive branches
- President/cabinet have high visibility, may skew averages
- Mid-term elections vs. general elections matter

### Federal Systems (Germany, USA, Brazil)
- Consider including state/regional legislators
- Federal vs. state-level effects may differ

### Non-Western Democracies
- Verify Facebook is a primary political platform
- Consider alternative platforms (WhatsApp, local alternatives)
- Political culture differences in online communication

---

## Common Issues and Solutions

### Issue: Too Few Re-elected MPs
**Cause:** High legislative turnover
**Solution:** Extend "experienced" definition to include previous legislative experience at any level, or combine with local/regional legislators

### Issue: Breakpoints Don't Match Expected Timing
**Cause:** Policy rollout timing varied by country
**Solution:** 
- Use data-driven breakpoint detection (don't force expected dates)
- Report discrepancy as a finding
- Consider country-specific factors

### Issue: One Group Shows Different Pattern
**Cause:** Potentially differential algorithmic treatment
**Solution:**
- Report as finding (e.g., extremists showed different trajectory)
- Consider robustness check with total reach vs. per-post reach
- Investigate group-specific factors

### Issue: Insufficient Pre-Policy Data
**Cause:** Study started after initial policy tests
**Solution:**
- Document limitation
- Consider relative analysis (policy vs. reversal only)
- Compare with other countries that have complete pre-policy data

---

## Checklist for Replication

- [ ] Obtained MCL access approval
- [ ] Identified political actor groups for your country
- [ ] Created MCL producer lists for each group
- [ ] Documented list IDs and membership criteria
- [ ] Created country configuration file
- [ ] Queried and exported raw data from MCL
- [ ] Adapted Notebook 01 for your data structure
- [ ] Verified data cleaning produces expected outputs
- [ ] Ran breakpoint analysis
- [ ] Validated findings across groups
- [ ] Documented country-specific considerations
- [ ] Created results summary

---

## Contributing Your Findings

We encourage researchers to contribute their country-specific findings:

1. **Fork the repository**
2. **Add your country configuration and results**
3. **Submit a pull request with:**
   - Configuration file (`config/[country]_config.yaml`)
   - Results summary (`outputs/results_summary_[country].yaml`)
   - Brief methodology notes in PR description

This enables comparative analysis across countries and strengthens the overall findings about Meta's policy effects.

---

## Support

For questions about replication:
1. **Open a GitHub Issue** with your country and specific question
2. **Email the corresponding author** for methodology discussions
3. **Join the discussion** in the repository's Discussions tab

---

## Comparative Analysis Framework

Once multiple countries have been analyzed, consider:

1. **Timing comparison:** Did policy effects appear simultaneously?
2. **Magnitude comparison:** Were reach reductions similar across countries?
3. **Recovery comparison:** Did all countries experience similar recovery patterns?
4. **Group comparison:** Did extremist/non-mainstream accounts show consistent divergent patterns?

This comparative framework can help identify whether Meta's policy was implemented uniformly or adapted to local contexts.
