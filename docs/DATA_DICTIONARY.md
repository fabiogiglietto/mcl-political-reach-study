# Data Dictionary

This document defines all variables used in the Meta Political Content Policy Analysis pipeline.

---

## Source Data (Meta Content Library API)

### Post-Level Variables (from MCL)

| Variable | Type | Description | Notes |
|----------|------|-------------|-------|
| `id` | character | Unique post identifier | MCL internal ID |
| `creation_time` | datetime | Post publication timestamp | UTC timezone |
| `content_type` | character | Type of post content | "photo", "video", "link", "status", "stories" |
| `surface.id` | character | ID of the page/profile where post appeared | May be NA for stories |
| `surface.name` | character | Display name of page/profile | |
| `surface.username` | character | Handle/username of page/profile | |
| `post_owner.id` | character | ID of the account that created the post | Differs from surface for reshares |
| `post_owner.name` | character | Name of post creator | |
| `statistics.views` | numeric | Number of times post appeared on screen | Censored ≤100 |
| `statistics.reaction_count` | numeric | Total reactions (like, love, etc.) | |
| `statistics.share_count` | numeric | Number of times post was shared | |
| `statistics.comment_count` | numeric | Number of comments | |

### View Count Details

- **Measurement:** Views count appearances on screen for ≥250ms, excluding owner's views
- **Reshare mechanics:** When a reshare appears, views increment for BOTH original and reshare
- **Censoring threshold:** Views ≤100 return as NA in MCL API
- **Imputation:** Group-specific ratio-weighted method based on power law extrapolation

---

## Derived Variables

### Classification Variables

| Variable | Type | Description | Values |
|----------|------|-------------|--------|
| `main_list` | character | Primary political actor category | "MPs_Reelected", "MPs_New", "Prominent_Politicians", "Extremists" |
| `sub_list` | character | Sub-category within main list | Dataset-specific |
| `list_description` | character | Human-readable description | |
| `source_file` | character | Original data file | For provenance tracking |
| `date_collected` | date | When data was queried from MCL | |

### Temporal Variables

| Variable | Type | Description | Format |
|----------|------|-------------|--------|
| `date` | date | Post date (derived from creation_time) | YYYY-MM-DD |
| `year` | integer | Year of post | 2021-2025 |
| `month` | integer | Month of post | 1-12 |
| `week` | date | Week start date (Sunday) | YYYY-MM-DD |
| `year_month` | date | First of month | YYYY-MM-01 |

### Policy Phase Variables

| Variable | Type | Description | Values |
|----------|------|-------------|--------|
| `post_policy` | logical | Whether post is after policy implementation | TRUE/FALSE |
| `phase` | factor | Policy phase assignment | "0_Pre-Policy", "1_Policy-Active", "2_Adjusted-Policy", "3_Post-Reversal" |

### Data Quality Flags

| Variable | Type | Description | Notes |
|----------|------|-------------|-------|
| `views_imputed` | logical | Whether view count was imputed | TRUE for original NA |
| `views_pre_2017` | logical | Whether views unavailable (pre-2017 post) | MCL limitation |
| `views_na_reason` | character | Reason for NA views | "censored", "pre_2017", "unknown" |

---

## Aggregated Datasets

### Weekly Aggregation (`weekly_aggregation_*.rds`)

| Variable | Type | Description |
|----------|------|-------------|
| `week` | date | Week start date (Sunday) |
| `main_list` | character | Political actor category |
| `n_posts` | integer | Number of posts that week |
| `n_accounts` | integer | Number of unique accounts posting |
| `total_views` | numeric | Sum of all post views |
| `avg_views` | numeric | Mean views per post |
| `median_views` | numeric | Median views per post |
| `sd_views` | numeric | Standard deviation of views |
| `total_reactions` | numeric | Sum of reactions |
| `avg_reactions` | numeric | Mean reactions per post |
| `total_shares` | numeric | Sum of shares |
| `avg_shares` | numeric | Mean shares per post |
| `total_comments` | numeric | Sum of comments |
| `avg_comments` | numeric | Mean comments per post |

**Note:** Only complete weeks (Sunday-Saturday) are included in weekly aggregation.

### Monthly Aggregation (`monthly_aggregation_*.rds`)

Same structure as weekly, with `month` (date) instead of `week`.

### Accounts Summary (`accounts_summary_*.rds`)

| Variable | Type | Description |
|----------|------|-------------|
| `surface.id` | character | Unique account identifier |
| `surface.name` | character | Account display name |
| `main_list` | character | Political actor category |
| `n_posts` | integer | Total posts in study period |
| `first_post` | date | Date of earliest post |
| `last_post` | date | Date of most recent post |
| `total_views` | numeric | Sum of all views |
| `avg_views` | numeric | Mean views per post |
| `total_reactions` | numeric | Sum of all reactions |
| `total_shares` | numeric | Sum of all shares |
| `total_comments` | numeric | Sum of all comments |

### Accounts Both Periods (`accounts_both_periods_*.rds`)

Balanced panel of accounts with ≥10 posts in BOTH pre- and post-policy periods.

| Variable | Type | Description |
|----------|------|-------------|
| `surface.id` | character | Account identifier |
| `surface.name` | character | Account name |
| `main_list` | character | Political actor category |
| `posts_pre` | integer | Posts in pre-policy period |
| `posts_post` | integer | Posts in post-policy period |
| `reach_pre` | numeric | Total views pre-policy |
| `reach_post` | numeric | Total views post-policy |
| `reach_change` | numeric | reach_post - reach_pre |
| `reach_change_pct` | numeric | 100 × (reach_post - reach_pre) / reach_pre |
| `avg_views_pre` | numeric | Mean views per post pre-policy |
| `avg_views_post` | numeric | Mean views per post post-policy |

### Account Period (`account_period_*.rds`)

Account-level statistics by period (includes all accounts, not just balanced panel).

| Variable | Type | Description |
|----------|------|-------------|
| `surface.id` | character | Account identifier |
| `main_list` | character | Political actor category |
| `period` | character | "pre" or "post" |
| `n_posts` | integer | Posts in period |
| `total_views` | numeric | Total views in period |
| `avg_views` | numeric | Mean views in period |

---

## Surface Info (`surface_info_*.rds`)

Comprehensive account metadata extracted from posts and MCL API queries.

| Variable | Type | Description |
|----------|------|-------------|
| `surface.id` | character | Account identifier |
| `surface.name` | character | Display name |
| `surface.username` | character | Handle/username |
| `main_list` | character | Political actor category |
| `sub_list` | character | Sub-category |
| `entity_type` | character | "page", "profile", "group" |
| `n_posts` | integer | Total posts in dataset |
| `first_post` | date | Earliest post date |
| `last_post` | date | Most recent post date |
| `api_follower_count` | integer | Followers (from API enrichment) |
| `api_verification_status` | character | Verification status |

---

## Analysis Outputs

### Breakpoint Results

| Variable | Type | Description |
|----------|------|-------------|
| `breakpoint_id` | character | "T1", "T2", or "T3" |
| `date` | date | Estimated breakpoint date |
| `detection_range` | character | Earliest-latest detection in cluster |
| `methods` | integer | Number of algorithm-metric detections |
| `strength` | character | "MODERATE", "STRONG", "VERY STRONG" |
| `algorithms` | character | Which algorithms detected it |

### Phase Statistics

| Variable | Type | Description |
|----------|------|-------------|
| `main_list` | character | Political actor category |
| `phase` | character | Policy phase |
| `n_weeks` | integer | Weeks in phase |
| `mean_views` | numeric | Mean of weekly average views |
| `median_views` | numeric | Median of weekly average views |
| `sd_views` | numeric | Standard deviation |
| `change_from_baseline` | numeric | Percentage change from Phase 0 |

---

## Missing Data Codes

| Code | Meaning | Handling |
|------|---------|----------|
| `NA` (views) | Censored (≤100) or unavailable | Imputed with group-specific method |
| `NA` (engagement) | Missing engagement data | Row removed from analysis |
| `NA` (surface.id) | Missing for stories content type | Fallback to post_owner.id |

---

## Dataset Version Compatibility

The pipeline automatically detects dataset version:

| Version | Groups | Notes |
|---------|--------|-------|
| v2/v3.1 | 3 groups | MPs, Prominent_Politicians, Extremists |
| v3.2 | 4 groups | MPs_Reelected, MPs_New, Prominent_Politicians, Extremists |
| v3.2 fallback | 3 groups | If re-elected MP file unavailable |

All analysis code works with both 3-group and 4-group datasets automatically.
