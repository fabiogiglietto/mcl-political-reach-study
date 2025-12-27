# 📚 Meta Content Library (MCL) & Secure Research Environment Guide

This guide provides detailed instructions for researchers seeking to replicate this study using Meta's Content Library and API. It covers the application process, platform options, data collection strategies, and compliance requirements.

---

## Table of Contents

1. [Overview of Meta Content Library](#overview-of-meta-content-library)
2. [Access Requirements and Eligibility](#access-requirements-and-eligibility)
3. [Application Process](#application-process)
4. [Platform Options: SRE vs SOMAR VDE](#platform-options-sre-vs-somar-vde)
5. [Content Library UI vs API](#content-library-ui-vs-api)
6. [Data Scope and Coverage](#data-scope-and-coverage)
7. [Producer Lists: Key to Political Research](#producer-lists-key-to-political-research)
8. [API Endpoints and Query Syntax](#api-endpoints-and-query-syntax)
9. [Rate Limits and Quotas](#rate-limits-and-quotas)
10. [Data Retention and Deletion Requirements](#data-retention-and-deletion-requirements)
11. [Output Export and Publication](#output-export-and-publication)
12. [Step-by-Step Workflow for This Study](#step-by-step-workflow-for-this-study)
13. [Troubleshooting Common Issues](#troubleshooting-common-issues)
14. [Additional Resources](#additional-resources)

---

## Overview of Meta Content Library

Meta Content Library (MCL) provides researchers comprehensive access to public content from Facebook, Instagram, and Threads. It was launched in 2023 as a replacement for CrowdTangle and offers:

- **Near real-time data**: Content is available shortly after posting
- **Historical archive**: Access to years of historical public posts
- **Engagement metrics**: Reactions, shares, comments, and crucially for this study, **view counts**
- **100+ searchable data fields**: Comprehensive metadata on posts and accounts

### Two Access Methods

| Method | Description | Best For |
|--------|-------------|----------|
| **Content Library UI** | Web-based graphical interface | Exploratory research, testing queries, non-coders |
| **Content Library API** | Programmatic access via Python/R | Large-scale data collection, computational research |

**For this study**: The API is essential due to the scale of data collection (~2.3 million posts) and the need for systematic querying by producer lists.

---

## Access Requirements and Eligibility

### Who Can Apply?

✅ **Eligible:**
- Academic researchers at universities
- Researchers at non-profit organizations
- Fact-checking organizations
- Civil society organizations pursuing public interest research

❌ **Not Eligible:**
- For-profit or commercial organizations
- Researchers in sanctioned jurisdictions (US, UK, EU, UN sanctions)

### Requirements

1. **Institutional Affiliation**: Must be affiliated with an academic or non-profit institution
2. **Research Agenda**: Clear description of research questions and methodology
3. **PhD Not Required**: Terminal degree not mandatory, but institution may require PI with PhD for data use agreements
4. **Programming Skills (API)**: R or Python proficiency recommended for API access

### Application Timeline

- **Review Period**: 2-6 weeks typically
- **Application Portal**: Through ICPSR/SOMAR or Meta's application system
- **Contact**: metaresearchapplications@meta.com

---

## Application Process

### Step 1: Prepare Your Research Proposal

Your application should include:

```
1. Research Questions
   - What are you trying to study?
   - Why is this public interest research?

2. Methodology
   - How will you collect data?
   - What analyses will you perform?
   - What is your study period?

3. Data Needs
   - Which platforms (Facebook, Instagram, Threads)?
   - What content types (posts, comments, pages)?
   - Estimated data volume

4. Team Members
   - Lead Researcher information
   - Collaborator details
```

### Step 2: Complete the Application

1. Visit the [Meta Content Library application portal](https://socialmediaarchive.org/)
2. Select access type:
   - UI only
   - UI + API (recommended for this study)
3. Provide institutional information
4. Submit research agenda

### Step 3: Sign Data Use Agreements

For API access, you'll need:
- **Restricted Data Use Agreement (RDUA)**: Signed by Lead Researcher and institutional signatory
- **VDE/SRE Terms of Use**: Platform-specific agreements

### Step 4: Complete Required Training

- ICPSR VDE security training (if using SOMAR VDE)
- Platform-specific onboarding materials

### Step 5: Access Granted

- Receive credentials for UI and/or API
- Set up secure computing environment
- Begin data collection

---

## Platform Options: SRE vs SOMAR VDE

As of late 2024, researchers can choose between two secure computing platforms for API access:

### Meta Secure Research Environment (SRE)

| Feature | Details |
|---------|---------|
| **Operated By** | Meta Platforms |
| **Cost** | Free computation |
| **Access Method** | Amazon WorkSpaces Secure Browser |
| **Storage** | Up to 330 GB per team |
| **Languages** | Python, R |
| **Environment** | JupyterLab |

**Advantages:**
- No fees
- Direct Meta support
- Larger storage allocation

### SOMAR Virtual Data Enclave (VDE)

| Feature | Details |
|---------|---------|
| **Operated By** | ICPSR at University of Michigan |
| **Cost** | Starting January 2026: $371/month + $1,000 setup for new teams |
| **Access Method** | ICPSR secure environment |
| **Languages** | Python, R, Stata (upon request) |
| **Output Review** | ICPSR staff review required |

**Advantages:**
- Established academic infrastructure
- Additional ICPSR data resources
- Familiar to many researchers

### Comparison Table

| Feature | Meta SRE | SOMAR VDE |
|---------|----------|-----------|
| **Cost** | Free | $371/month (from Jan 2026) |
| **Storage** | 330 GB | Varies |
| **Output Export** | Meta review | ICPSR staff review |
| **Support** | Meta tickets | somar-help@umich.edu |
| **ML Model Upload** | Yes (with approval) | Yes (with approval) |

### Recommendation for This Study

**Meta SRE** is recommended due to:
1. No cost
2. Larger storage for multi-year data
3. Direct integration with MCL API

---

## Content Library UI vs API

### Content Library UI

**Best for:**
- Testing search queries before API implementation
- Exploratory data analysis
- Creating and managing producer lists
- Visualizing trends with dashboards

**Key Features:**
- Keyword search with exact phrase matching
- Text-in-image search (OCR)
- Real-time dashboards
- Producer list management
- CSV export for widely-known accounts

**Limitations:**
- 500,000 results per 7-day rolling period (combined with API)
- Manual process for large-scale data collection

### Content Library API

**Best for:**
- Large-scale systematic data collection
- Programmatic analysis
- Research requiring millions of posts
- Reproducible workflows

**Key Features:**
- 100+ data fields
- Multiple endpoints (posts, pages, groups, events, comments)
- Asynchronous queries for large jobs
- Up to 100,000 results per query

**Requirements:**
- Python or R proficiency
- Access to SRE or SOMAR VDE
- Understanding of API pagination

---

## Data Scope and Coverage

### Facebook Content

| Content Type | Included | Notes |
|--------------|----------|-------|
| **Pages** | ✅ | Public pages |
| **Posts** | ✅ | Posts to pages, groups, events |
| **Groups** | ✅ | Public groups only |
| **Events** | ✅ | Public events |
| **Profiles** | ✅ | Verified OR 100+ followers |
| **Comments** | ✅ | On public posts |
| **Marketplace** | ✅ | Public listings |
| **Fundraisers** | ✅ | Public fundraisers |

### Instagram Content

| Content Type | Included | Notes |
|--------------|----------|-------|
| **Accounts** | ✅ | Business, creator, and qualifying personal |
| **Posts** | ✅ | Public posts, reels, albums |
| **Comments** | ✅ | Via API |
| **Channels** | ✅ | Public channels |
| **Fundraisers** | ✅ | Public fundraisers |

### Threads Content

| Content Type | Included | Notes |
|--------------|----------|-------|
| **Posts** | ✅ | 1,000+ follower accounts |
| **CSV Export** | ❌ | UI viewing only |

### Downloadable Data (CSV Export)

CSV exports are available for **"widely-known" accounts** only:

| Platform | Threshold |
|----------|-----------|
| **Facebook Pages** | 15,000+ likes OR followers |
| **Facebook Profiles** | Verified OR 25,000+ followers |
| **Instagram Accounts** | Verified OR 25,000+ followers |

**Important for This Study**: Italian parliamentarians may not all meet these thresholds, making API access essential.

### Key Data Fields for Political Research

```
Post-Level Fields:
- id: Unique post identifier
- creation_time: Post timestamp
- message: Text content
- statistics.view_count: Number of views (KEY FOR RQ1)
- statistics.reaction_count: Total reactions
- statistics.share_count: Shares
- statistics.comment_count: Comments
- content_type: Video, photo, text, link, etc.

Account-Level Fields:
- surface.id: Account identifier
- surface.name: Display name
- surface.follower_count: Number of followers
- surface.verification_status: Verified badge
- surface.page_category: Category (politician, etc.)
```

---

## Producer Lists: Key to Political Research

Producer lists are **essential** for this study. They allow you to:

1. Define specific accounts to track (MPs, prominent politicians, etc.)
2. Filter search results to only those accounts
3. Share lists with collaborators
4. Apply lists across multiple queries

### Creating Producer Lists

**In the UI:**
1. Navigate to Producer Lists section
2. Click "Create New List"
3. Add accounts by:
   - Searching by name
   - Entering Facebook/Instagram URLs
   - Bulk upload via CSV

**Via API:**
```python
# Producer lists are referenced by their unique ID
# Example: "2025-09-21-ymub"

# Query posts from a specific producer list
from metacontentlibrary import ContentLibraryAPI

api = ContentLibraryAPI()

results = api.search_fb_posts(
    producer_list_id="YOUR_PRODUCER_LIST_ID",
    start_date="2021-01-01",
    end_date="2025-11-30",
    fields=["id", "creation_time", "statistics", "message"]
)
```

### Producer List Strategy for This Study

We recommend creating **separate producer lists** for each group:

| List Name | Contents | Approximate Size |
|-----------|----------|------------------|
| `italy_mps_reelected` | MPs serving 2021 AND 2022+ | ~280 accounts |
| `italy_mps_new` | MPs elected only in 2022 | ~270 accounts |
| `italy_prominent_politicians` | Ministers, party leaders, etc. | ~200 accounts |
| `italy_extremists` | Accounts flagged for extreme content | ~150 accounts |

**Tips:**
- Document list creation date and contents
- Export list contents for reproducibility
- Update lists as needed (new MPs, etc.)

---

## API Endpoints and Query Syntax

### Primary Endpoints for This Study

| Endpoint | Function | Use Case |
|----------|----------|----------|
| `search_fb_posts()` | Search Facebook posts | Main data collection |
| `search_fb_pages()` | Search Facebook pages | Account metadata |
| `search_ig_posts()` | Search Instagram posts | If including Instagram |
| `search_ig_accounts()` | Search Instagram accounts | Account metadata |

### Example: Collecting Posts from Italian MPs

```python
from metacontentlibrary import ContentLibraryAPI
import pandas as pd

# Initialize API
api = ContentLibraryAPI()

# Define query parameters
query_params = {
    "producer_list_id": "YOUR_MP_LIST_ID",
    "start_date": "2021-01-01",
    "end_date": "2025-11-30",
    "fields": [
        "id",
        "creation_time", 
        "message",
        "content_type",
        "statistics.view_count",
        "statistics.reaction_count",
        "statistics.share_count",
        "statistics.comment_count",
        "surface.id",
        "surface.name"
    ]
}

# Execute search (paginated)
all_results = []
for batch in api.search_fb_posts(**query_params):
    all_results.extend(batch)
    print(f"Collected {len(all_results)} posts...")

# Convert to DataFrame
df = pd.DataFrame(all_results)
df.to_csv("italian_mp_posts.csv", index=False)
```

### Asynchronous Queries for Large Jobs

For queries expecting >100,000 results, use async search:

```python
# Submit async job
job_id = api.async_search_fb_posts(
    producer_list_id="YOUR_LIST_ID",
    start_date="2021-01-01",
    end_date="2025-11-30"
)

# Check status
status = api.get_async_job_status(job_id)
print(f"Job status: {status}")

# Retrieve results when complete
if status == "completed":
    results = api.get_async_job_results(job_id)
```

---

## Rate Limits and Quotas

### Standard Weekly Query Limit

| Limit | Value | Notes |
|-------|-------|-------|
| **Total Results** | 500,000 per 7-day rolling period | Combined UI + API |
| **Sync Searches** | 60 per minute | Standard queries |
| **Async Jobs** | 1 per minute | Large queries |
| **Results per Query** | 100,000 max | Per single query |

### The Challenge for Large-Scale Political Research

For studies like this one (~2.3 million posts), the standard 500k weekly quota presents a significant bottleneck:

```
Standard scenario:
- Total posts needed: ~2,300,000
- Weekly limit: 500,000
- Minimum collection time: ~5 weeks (sequential)
- With buffer for errors: 6-7 weeks
```

**This is often impractical** for time-sensitive research or when secure environment access is limited.

---

### 🚀 Strategy 1: Request Extended Quota (1 Million)

Meta may grant extended quotas for legitimate large-scale research projects. 

#### How to Request

1. **Document your data needs** in your research application:
   ```
   Estimated data volume: 2.3 million posts
   Justification: Longitudinal study of political actors across 4+ years
   Standard quota impact: Would require 5+ weeks of sequential collection
   Requested quota: 1,000,000 results per 7-day period
   ```

2. **Submit request through Direct Support:**
   
   👉 **https://developers.facebook.com/docs/content-library-and-api/support/get-help**
   
   This is the official channel for limit increase requests. In your support ticket, include:
   - Your approved research agenda reference
   - Specific data volume estimates with methodology
   - Timeline constraints and research deadlines
   - Technical justification for increased quota

3. **Provide technical justification:**
   ```
   Our study requires:
   - 4 producer lists covering ~900 political accounts
   - 5-year study period (2021-2025)
   - All posts with engagement metrics
   - Estimated 2.3M total posts
   
   With 1M weekly quota:
   - Collection time reduced to 3 weeks
   - Allows time for validation and re-queries
   - Enables timely research outputs
   ```

#### What to Expect

- **Response time**: 1-2 weeks typically
- **Approval likelihood**: Generally favorable for well-justified academic research
- **Quota granted**: Often 1M, occasionally higher for exceptional cases
- **Duration**: Usually for the duration of your approved research agenda

#### Tips for Approval

✅ **Do:**
- Provide precise estimates with methodology
- Explain research significance and timeline
- Reference your approved ICPSR application
- Offer to provide progress updates

❌ **Don't:**
- Request without justification
- Significantly overestimate needs
- Request before your application is approved

---

### 👥 Strategy 2: Leverage Team Member Quotas

Each approved researcher on your team has their own independent quota. Strategic coordination can dramatically accelerate data collection.

#### How Team Quotas Work

```
Lead Researcher quota:     500,000/week
Collaborator 1 quota:      500,000/week
Collaborator 2 quota:      500,000/week
─────────────────────────────────────────
Combined team capacity:  1,500,000/week
```

#### Implementation Strategy

**Step 1: Plan data partitioning**

Divide your data collection by non-overlapping segments:

```
Option A: By Producer List
──────────────────────────
Lead Researcher:   MPs_Reelected list (~600k posts)
Collaborator 1:    MPs_New list (~500k posts)
Collaborator 2:    Prominent_Politicians + Extremists (~1.2M posts)

Option B: By Time Period
────────────────────────
Lead Researcher:   2021-01-01 to 2022-06-30
Collaborator 1:    2022-07-01 to 2023-12-31
Collaborator 2:    2024-01-01 to 2025-11-30

Option C: Hybrid Approach (Recommended)
───────────────────────────────────────
Lead Researcher:   MPs_Reelected (all dates)
Collaborator 1:    MPs_New (all dates)
Collaborator 2:    Other groups (all dates)
```

**Step 2: Coordinate collection schedule**

Create a shared tracking document:

| Researcher | Assignment | Est. Posts | Week 1 | Week 2 | Status |
|------------|------------|------------|--------|--------|--------|
| Lead | MPs_Reelected | 600k | 500k | 100k | ✅ Complete |
| Collab 1 | MPs_New | 500k | 500k | — | ✅ Complete |
| Collab 2 | Prominent + Extremists | 1.2M | 500k | 500k | 🔄 Week 2 |

**Step 3: Merge datasets**

After collection, combine in the secure environment:

```python
# Each researcher saves to their workspace
# Lead: mps_reelected_posts.parquet
# Collab1: mps_new_posts.parquet
# Collab2: other_groups_posts.parquet

# Merge in shared project space (if available)
# Or export to common format and combine

import pandas as pd

# Combine all datasets
all_posts = pd.concat([
    pd.read_parquet("mps_reelected_posts.parquet"),
    pd.read_parquet("mps_new_posts.parquet"),
    pd.read_parquet("other_groups_posts.parquet")
])

# Deduplicate (in case of any overlap)
all_posts = all_posts.drop_duplicates(subset=['id'])

# Save combined dataset
all_posts.to_parquet("combined_political_posts.parquet")
```

#### Adding Collaborators to Your Project

1. Lead Researcher submits Collaborator Addition Request via ICPSR/Meta
2. Collaborator completes their own application
3. Collaborator signs data use agreements
4. Collaborator completes required training
5. Collaborator receives access credentials

**Timeline**: Allow 2-3 weeks for collaborator onboarding

#### Best Practices for Team Collection

1. **Use consistent query parameters**: All team members should use identical field lists
2. **Document everything**: Track who collected what, when
3. **Validate overlaps**: If using time-based splits, ensure no gaps/overlaps at boundaries
4. **Coordinate timing**: Start collection in same week to ensure data consistency
5. **Establish merge protocol**: Agree on file naming and combination procedure

---

### 📅 Strategy 3: Multi-Week Collection Planning

Even with standard quotas, careful planning ensures efficient data collection.

#### Sample 6-Week Collection Plan

```
WEEK 1: Foundation
├── Day 1-2: Test queries with small date ranges
├── Day 3-4: Validate field availability (especially view counts)
├── Day 5-7: Collect MPs_Reelected (Q1-Q2 2021)
└── Posts collected: ~200,000

WEEK 2: MPs Reelected (continued)
├── Complete MPs_Reelected (Q3 2021 - Q4 2022)
└── Posts collected: ~400,000 (running total: 600k)

WEEK 3: MPs New
├── Collect all MPs_New posts
└── Posts collected: ~500,000 (running total: 1.1M)

WEEK 4: Prominent Politicians
├── Collect Prominent_Politicians list
└── Posts collected: ~450,000 (running total: 1.55M)

WEEK 5: Extremists + Validation
├── Day 1-4: Collect Extremists list (~400k)
├── Day 5-7: Re-query any failed batches
└── Posts collected: ~450,000 (running total: 2.0M)

WEEK 6: Buffer + Quality Check
├── Re-query missing date ranges
├── Validate completeness
├── Begin data cleaning pipeline
└── Posts collected: ~300,000 (final total: 2.3M)
```

#### Handling Quota Resets

The 500k limit is a **rolling 7-day window**, not a calendar week:

```
Example timeline:
─────────────────
Day 1 (Mon): Query 100k posts → 400k remaining
Day 3 (Wed): Query 200k posts → 200k remaining
Day 5 (Fri): Query 200k posts → 0 remaining (limit hit)
Day 8 (Mon): Day 1 queries "expire" → 100k available again
Day 10 (Wed): Day 3 queries "expire" → 300k available
```

**Tip**: Front-load your weekly queries early in the window to maximize flexibility.

#### Monitoring Your Quota

Check remaining quota in the MCL UI:
1. Navigate to Settings or Dashboard
2. Look for "Query Budget" or "Usage" section
3. Note: UI and API queries share the same pool

---

### Combined Strategy: Maximum Efficiency

For the fastest possible data collection, combine all strategies:

```
OPTIMIZED APPROACH
══════════════════

1. Request 1M extended quota (2 weeks before collection)
2. Onboard 2 collaborators (during quota request period)
3. Plan partitioned collection strategy

Result:
- Team capacity: 3 researchers × 1M quota = 3M/week potential
- Actual need: 2.3M posts
- Collection time: 1 WEEK (vs. 5+ weeks baseline)
- Buffer: Entire second week for validation/re-queries
```

#### Decision Matrix

| Scenario | Posts Needed | Recommended Strategy |
|----------|--------------|---------------------|
| <500k | Standard quota, single researcher | No special action needed |
| 500k - 1M | Request 1M quota OR add 1 collaborator | Choose based on timeline |
| 1M - 2M | Request 1M quota AND add 1-2 collaborators | Combine strategies |
| >2M | Request 1M+ quota AND full team coordination | All strategies essential |

---

### Strategies to Maximize Efficiency

1. **Use producer lists** instead of keyword searches (more precise, fewer wasted results)
2. **Request only needed fields** to reduce data transfer overhead
3. **Use async queries** for batches >50k (more reliable)
4. **Monitor weekly usage** in the UI dashboard (avoid surprises)
5. **Plan collection timeline** with 20% buffer for issues
6. **Partition by non-overlapping criteria** when using team quotas
7. **Document everything** for reproducibility and troubleshooting

---

## Data Retention and Deletion Requirements

### 180-Day Deletion Requirement

**Critical Compliance Issue:**

Every 180 days, researchers must:
1. Receive list of content IDs no longer in MCL (deleted posts)
2. Delete those IDs from their workspace within 30 days
3. Certify deletion to ICPSR/Meta

### Exemption for EU Systemic Risk Research

Researchers studying systemic risks in the EU may be exempt. This study's focus on democratic accountability and platform governance may qualify.

**To request exemption:**
- Document EU systemic risk focus in application
- Contact metaresearchapplications@meta.com

### Data Preservation Strategy

Since raw data cannot be exported, preserve your research by:

1. **Save aggregated statistics**: Group-level means, medians, etc.
2. **Export figures and charts**: All visualizations
3. **Document methodology**: Exact queries used
4. **Save analysis code**: For reproducibility
5. **Export regression outputs**: Tables, coefficients

---

## Output Export and Publication

### What Can Be Exported?

| Output Type | Exportable? | Notes |
|-------------|-------------|-------|
| **Aggregate statistics** | ✅ | Means, counts, etc. |
| **Figures and charts** | ✅ | Visualizations |
| **Regression tables** | ✅ | Statistical outputs |
| **Code/scripts** | ✅ | Your analysis code |
| **Raw data** | ❌ | Never exportable |
| **Individual posts** | ❌ | Never exportable |
| **Identifiable quotes** | ⚠️ | Requires careful handling |

### Export Review Process

**SOMAR VDE:**
1. Self-vet for disclosure risk
2. Submit export request to SOMAR
3. ICPSR staff review (allow 10+ business days)
4. Receive approved outputs

**Meta SRE:**
1. Follow Meta's export guidelines
2. Submit through SRE export system
3. Meta review
4. Receive approved outputs

### Publication Guidelines

Meta allows publication without prior review, but:

1. **Follow attribution guidelines**: Cite Meta Content Library appropriately
2. **Notify upon publication**: Email metaresearchapplications@meta.com
3. **No raw data in publications**: Only aggregates
4. **Respect privacy**: Avoid identifying individuals inappropriately

### Suggested Citation

```
Data collected via Meta Content Library API, accessed through 
[Meta Secure Research Environment / SOMAR Virtual Data Enclave] 
between [dates]. Meta Content Library provides programmatic access 
to public content from Facebook and Instagram for qualified researchers.
```

---

## Step-by-Step Workflow for This Study

### Phase 1: Application & Team Setup (Weeks 1-8)

```
Week 1-2: Prepare application materials
├── Write research proposal with data volume estimates
├── Identify institutional signatory
├── Plan team composition (consider adding collaborators for quota)
└── Document estimated posts needed (~2.3M for this study)

Week 3: Submit application
├── Apply through ICPSR portal
├── Select UI + API access
├── Choose platform (SRE recommended - free)
├── Include data volume justification for quota extension
└── List planned collaborators

Week 4-6: Review period
├── Respond to any reviewer questions
├── Complete required training
└── Sign data use agreements

Week 7-8: Quota & Team Preparation
├── Request extended quota (1M) via Direct Support portal
├── Submit collaborator addition requests (if using team strategy)
├── Collaborators complete their applications
└── Await quota extension approval
```

### Phase 2: Setup & Preparation (Weeks 9-10)

```
Week 9: Access granted
├── Receive login credentials (Lead + Collaborators)
├── All team members access UI and familiarize
├── Confirm quota extension is active (check in UI dashboard)
└── Access SRE/VDE environment

Week 10: Prepare infrastructure
├── Create producer lists in UI
├── Share lists with collaborators (if team collection)
├── Test API queries with small samples (~1000 posts)
├── Validate view count field availability
├── Finalize data partitioning strategy (who collects what)
└── Create shared tracking spreadsheet
```

### Phase 3: Data Collection (Weeks 11-13)

**With Extended Quota + Team (Accelerated Timeline):**

```
Week 11: Primary Collection
├── Lead: MPs_Reelected list (all dates) → ~600k posts
├── Collaborator 1: MPs_New list (all dates) → ~500k posts
├── Collaborator 2: Prominent_Politicians → ~450k posts
├── Monitor progress in shared tracker
└── Daily coordination check-ins

Week 12: Complete Collection + Validation
├── Collaborator 2: Extremists list → ~400k posts
├── All: Re-query any failed batches
├── Validate data completeness per group
├── Check for date range gaps
└── Merge datasets in shared project space

Week 13: Quality Assurance
├── Deduplicate combined dataset
├── Validate view count coverage
├── Cross-check surface IDs against producer lists
├── Export to analysis format (.rds/.parquet)
└── Document collection metadata
```

**With Standard Quota (Extended Timeline - Weeks 11-17):**

```
Week 11-12: MPs Collection
├── Week 11: MPs_Reelected (partial) → 500k posts
├── Week 12: MPs_Reelected (complete) + MPs_New (start)

Week 13-14: Continue MPs + Start Others
├── Week 13: MPs_New (complete) + Prominent (start)
├── Week 14: Prominent_Politicians (complete)

Week 15-16: Extremists + Validation
├── Week 15: Extremists list
├── Week 16: Re-queries and validation

Week 17: Quality Assurance
├── Combine all datasets
├── Export to analysis format
```

### Phase 4: Analysis (Weeks 14-20 or 18-24)

```
Weeks 14-15 (or 18-19): Data cleaning
├── Run validation scripts (Notebook 03)
├── Impute missing view counts
├── Create aggregated datasets
└── Generate cleaned outputs

Weeks 16-18 (or 20-22): Main analyses
├── Breakpoint detection (RQ1) - Notebook 06
├── Moderation analysis (RQ2)
├── Group comparisons (RQ3)
├── Experience effects (RQ4)
└── Sensitivity analyses

Weeks 19-20 (or 23-24): Output preparation
├── Generate figures and tables (Notebook 07)
├── Self-vet all outputs for disclosure risk
├── Submit export requests (allow 10+ business days)
└── Prepare methodology documentation
```

### Phase 5: Publication (Weeks 21+ or 25+)

```
├── Receive exported outputs from SOMAR/Meta
├── Finalize manuscript with exported figures/tables
├── Notify Meta of publication (required)
├── Archive code and documentation
└── Consider sharing replication materials
```

### Timeline Comparison

| Strategy | Total Weeks | Data Collection | Notes |
|----------|-------------|-----------------|-------|
| Standard quota, solo | 24-26 | 6-7 weeks | Slowest, lowest coordination |
| Extended quota (1M), solo | 20-22 | 3-4 weeks | Moderate speed, simple |
| Team quotas (3 researchers) | 18-20 | 2-3 weeks | Fast, requires coordination |
| Extended + Team (optimal) | 16-18 | 1-2 weeks | Fastest, most complex |

---

## Troubleshooting Common Issues

### Issue: View counts missing for some posts

**Cause**: View counts not available for all content types or time periods.

**Solution**: 
- Document missing data patterns
- Use imputation (see our methodology)
- Focus on posts with available view data for primary analyses

### Issue: Rate limit exceeded

**Cause**: Exceeded 500k results in 7-day period.

**Solution**:
- Wait for quota reset
- Plan collection timeline more carefully
- Use more specific queries

### Issue: Producer list accounts not found

**Cause**: Account may be deleted, private, or below follower threshold.

**Solution**:
- Verify account is public
- Check follower count meets MCL threshold
- Try searching by exact URL

### Issue: Results inconsistent between queries

**Cause**: Data in MCL updates in near real-time; posts may be deleted.

**Solution**:
- Collect data within short time window
- Document collection timestamps
- Accept some data volatility as inherent limitation

### Issue: Cannot export raw data for peer review

**Cause**: MCL terms prohibit raw data export.

**Solution**:
- Export aggregate statistics only
- Provide detailed methodology documentation
- Offer to run additional analyses if requested by reviewers
- Note limitation in methods section

---

## Additional Resources

### Official Documentation

- **Meta Content Library**: https://transparency.meta.com/researchtools/meta-content-library/
- **Developer Documentation**: https://developers.facebook.com/docs/content-library-and-api
- **SOMAR FAQs**: https://socialmediaarchive.org/pages/?page=Meta+Content+Library+FAQs

### Application Portal

- **ICPSR Application**: https://socialmediaarchive.org/
- **Meta Application Portal**: Check Meta documentation for current URL

### Support Contacts

| Platform | Contact |
|----------|---------|
| **Direct Support (API issues, quota requests)** | https://developers.facebook.com/docs/content-library-and-api/support/get-help |
| **General MCL inquiries** | metaresearchapplications@meta.com |
| **SOMAR VDE** | somar-help@umich.edu |
| **Meta SRE** | Submit ticket through SRE interface |

### Training and Webinars

- SOMAR hosts periodic webinars on MCL
- Check SOMAR website for upcoming sessions
- Review ICPSR VDE training materials

---

## Version History

| Date | Version | Changes |
|------|---------|---------|
| 2025-12 | 1.0 | Initial comprehensive guide |

---

## Acknowledgments

This guide was created based on publicly available documentation from Meta, ICPSR/SOMAR, and the academic research community. We thank Meta for providing research tools and the broader academic community for sharing experiences with these platforms.

---

*Last updated: December 2025*
