# Producer Lists for Italian Study

This document provides the specific Meta Content Library producer lists used in the original Italian study. These lists are publicly accessible to any researcher with Meta Content Library API access and can be imported directly into new research projects for exact replication.

---

## Overview

All producer lists below are available in the Meta Content Library interface. Researchers with approved MCL access can import these lists directly using the provided URLs, enabling exact replication of the sample used in the working paper.

---

## Producer Lists

### 1. MPs (Re-elected)
**Description:** Members of Parliament elected in both the 2018 and 2022 Italian legislatures

**URL:** https://www.facebook.com/transparency-tools/content-library/producer-lists/1508867967036191/

**Purpose:** Primary discovery sample for breakpoint detection (RQ1). These MPs served continuously across the policy implementation period, providing stable time series for structural break analysis.

**Usage in pipeline:**
- Notebook 00: Query this list for posts
- Notebook 01: Classify as `main_list = "MPs_Reelected"`
- Notebook 06: Use as discovery sample for breakpoint detection

---

### 2. Parlamentari ITA Leg XIX
**Description:** All members of the XIX Italian legislature (2022–present)

**URL:** https://www.facebook.com/transparency-tools/content-library/producer-lists/1079401170932761/

**Purpose:** Validation sample for cross-group verification. Includes both re-elected and newly elected MPs.

**Usage in pipeline:**
- Notebook 00: Query this list for posts
- Notebook 01: Classify as `main_list = "MPs_All"` or use for distinguishing newly elected MPs
- Notebook 06: Validation group for detected breakpoints

---

### 3. Prominent Politicians
**Description:** Most-followed Italian politicians not holding parliamentary seats

**URL:** https://www.facebook.com/transparency-tools/content-library/producer-lists/2018160402336859/

**Purpose:** Validation sample to test whether policy effects extended beyond elected legislators to prominent political figures.

**Usage in pipeline:**
- Notebook 00: Query this list for posts
- Notebook 01: Classify as `main_list = "Prominent_Politicians"`
- Notebook 06: Validation group for detected breakpoints

---

### 4. Extremists (Cluster 1)
**Description:** Italian pages and public figures in the alternative media ecosystem

**URL:** https://www.facebook.com/transparency-tools/content-library/producer-lists/1546733040084559/

**Purpose:** Comparison group to examine whether policy effects differed for accounts potentially subject to different content moderation rules.

**Usage in pipeline:**
- Notebook 00: Query this list for posts
- Notebook 01: Classify as `main_list = "Extremists"`, `sub_list = "Cluster_1"`
- Notebook 06: Comparison group analysis

---

### 5. Extremists (Cluster 2)
**Description:** Additional Italian pages and public figures in the alternative media ecosystem

**URL:** https://www.facebook.com/transparency-tools/content-library/producer-lists/25433097262993192/

**Purpose:** Second cluster of alternative media accounts for robustness of comparison group analysis.

**Usage in pipeline:**
- Notebook 00: Query this list for posts
- Notebook 01: Classify as `main_list = "Extremists"`, `sub_list = "Cluster_2"`
- Notebook 06: Comparison group analysis

---

## Importing Producer Lists

To import these lists into your own MCL project:

1. **Access Meta Content Library:** Navigate to https://www.facebook.com/transparency-tools/content-library/
2. **Navigate to Producer Lists:** Click on "Producer Lists" in the left sidebar
3. **Import from URL:** Click "Import" and paste one of the URLs above
4. **Note the List ID:** Once imported, note the new list ID assigned in your workspace
5. **Update Configuration:** Add the list ID to your `config/italy_config.yaml` or Notebook 00 configuration

**Example:**
```r
# In Notebook 00_data_download.ipynb
PRODUCER_LISTS <- list(
  list(
    list_id = "1508867967036191",  # Your imported list ID
    list_name = "MPs_Reelected",
    description = "MPs elected in 2018 AND 2022"
  ),
  # ... add other lists
)
```

---

## List Membership Criteria

### MPs (Re-elected) - Selection Criteria
- Served in both XVIII Legislature (2018-2022) AND XIX Legislature (2022-present)
- Active Facebook page or profile during study period (2021-01-01 to 2025-11-30)
- Verifiable membership in Italian Parliament (Camera dei Deputati or Senato della Repubblica)

### Parlamentari ITA Leg XIX - Selection Criteria
- Current members of XIX Legislature (2022-present)
- Includes both re-elected and newly elected MPs
- Active Facebook page or profile

### Prominent Politicians - Selection Criteria
- High-profile political figures not currently holding parliamentary seats
- Examples: party leaders, regional governors, former ministers
- Facebook follower count above threshold (top percentile of political figures)
- Active posting during study period

### Extremists (Cluster 1 & 2) - Selection Criteria
- Pages and public figures identified as part of Italian alternative media ecosystem
- Classification based on previous research and content analysis
- Represents accounts potentially subject to different content moderation policies
- Note: "Extremists" is an analytical category for comparison purposes, not a value judgment

---

## Data Collection Timeline

| List | Posts Collected | Time Period | Quota Used |
|------|----------------|-------------|------------|
| MPs (Re-elected) | ~500,000 | 2021-01-01 to 2025-11-30 | ~500K |
| Parlamentari ITA Leg XIX | ~400,000 | 2021-01-01 to 2025-11-30 | ~400K |
| Prominent Politicians | ~300,000 | 2021-01-01 to 2025-11-30 | ~300K |
| Extremists (Cluster 1) | ~250,000 | 2021-01-01 to 2025-11-30 | ~250K |
| Extremists (Cluster 2) | ~200,000 | 2021-01-01 to 2025-11-30 | ~200K |

**Total:** ~1.65 million posts collected over 4 weeks using standard 500K/week quota

---

## Verification

To verify your data collection matches the original study:

1. **Post Count Check:**
   ```r
   # After running Notebook 01
   combined_data %>%
     group_by(main_list) %>%
     summarize(
       n_posts = n(),
       n_accounts = n_distinct(surface.id),
       date_range = paste(min(date), "to", max(date))
     )
   ```

2. **Expected Account Counts:**
   - MPs (Re-elected): ~280 accounts
   - Parlamentari ITA Leg XIX: ~550 accounts
   - Prominent Politicians: ~200 accounts
   - Extremists (Cluster 1): ~150 accounts
   - Extremists (Cluster 2): ~100 accounts

3. **Temporal Coverage:**
   - All lists should have posts from 2021-01-01 to 2025-11-30
   - Gaps during holiday periods (December, August) are normal
   - No systematic gaps should appear

---

## Replicating with Your Own Lists

If you're adapting this study to another country, you'll create your own producer lists. See [REPLICATION_GUIDE.md](REPLICATION_GUIDE.md) for detailed instructions on:

1. Identifying political actors in your country
2. Creating producer lists in MCL interface
3. Mapping your lists to the pipeline's expected structure
4. Validating data collection

---

## Contact

For questions about the Italian producer lists or list composition:

**Fabio Giglietto**
University of Urbino
fabio.giglietto@uniurb.it
ORCID: 0000-0001-8019-1035

---

## Data Access Note

⚠️ **Important:** While the producer lists are publicly accessible through Meta's Content Library interface, the underlying post-level data cannot be shared outside Meta's secure computing environment. Replication requires:

1. Approved researcher access to Meta Content Library API
2. Independent data collection by importing these producer lists
3. Analysis conducted within Meta's Secure Research Environment (SRE) or approved platforms

See [README.md](README.md#quick-start) for information on obtaining MCL access.
