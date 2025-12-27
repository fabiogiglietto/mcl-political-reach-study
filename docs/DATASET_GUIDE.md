# âš¡ QUICK ANSWER: Which Datasets for Which RQs

**NOTE:** Dataset version affects the number of groups:
- **v2/v3.1**: 3 groups (MPs, Prominent_Politicians, Extremists)
- **v3.2 with re-elected MPs**: 4 groups (MPs_Reelected, MPs_New, Prominent_Politicians, Extremists)
- **v3.2 fallback**: 3 groups (MPs, Prominent_Politicians, Extremists)

The validation script auto-detects which version you have. All analyses work with either version!

---

## TL;DR

| RQ | Use This Dataset | Why |
|----|-----------------|-----|
| **RQ1: When/Extent?** | `weekly_aggregation` | Time series for breakpoint detection |
| **RQ2: Engagement moderation?** | `cleaned_posts` | Need post-level variation for moderation |
| **RQ3: Equal effects?** | `accounts_both_periods` | Balanced panel for fair comparison |
| **RQ4: Experience effect? (v3.2 only)** | `accounts_both_periods` | Compare MPs_Reelected vs MPs_New |

---

## RQ1: When and to what extent does Meta's reduction affect reach?

### Use: `weekly_aggregation` (or `monthly_aggregation`)

**Why:**
- âœ… Shows temporal trends
- âœ… Can detect WHEN changes occurred (breakpoints)
- âœ… Measures extent of change over time
- âœ… Visual inspection of gradual vs. sudden changes

**Analysis:**
```r
weekly <- readRDS("cleaned_data/weekly_aggregation_TIMESTAMP.rds")

# Plot trends
ggplot(weekly, aes(x = week, y = avg_views, color = main_list)) +
  geom_line() +
  geom_vline(xintercept = as.Date("2022-07-19"))

# Breakpoint detection
library(strucchange)
bp_model <- breakpoints(avg_views ~ 1, 
                        data = weekly %>% filter(main_list == "Extremists"))
```

---

## RQ2: How did de-emphasis of engagement signals moderate the engagement-reach relationship?

### Use: `cleaned_posts`

**Why:**
- âœ… Need individual posts to model: views ~ reactions Ã— policy
- âœ… Aggregation destroys the variation you need
- âœ… Can test if reaction-reach correlation weakened post-policy

**Analysis:**
```r
posts <- readRDS("cleaned_data/cleaned_posts_TIMESTAMP.rds")

posts <- posts %>%
  mutate(
    post_policy = date >= as.Date("2022-07-19"),
    log_views = log1p(statistics.views),
    log_reactions = log1p(statistics.reaction_count)
  )

# Moderation model
library(lme4)
mod <- lmer(log_views ~ 
              log_reactions * post_policy +  # KEY: interaction
              log_shares * post_policy +
              log_comments * post_policy +
              (1 | surface.id),
            data = posts)
```

**Key insight:** Negative coefficients on interactions = de-emphasis working

---

## RQ3: Did the policy affect politicians across the spectrum equally?

### Use: `accounts_both_periods`

**Why:**
- âœ… Same accounts pre AND post (â‰¥10 posts each period)
- âœ… Within-account comparison controls confounds
- âœ… Fair comparison (not biased by account entry/exit)
- âœ… Has pre-calculated reach_change for each account

**Number of Groups:**
- v2/v3.1: 3 groups (MPs, Prominent_Politicians, Extremists)
- v3.2 with MP split: 4 groups (MPs_Reelected, MPs_New, Prominent_Politicians, Extremists)

**Analysis:**
```r
accounts_both <- readRDS("cleaned_data/accounts_both_periods_TIMESTAMP.rds")

# Compare groups (automatic - works with 3 or 4 groups)
accounts_both %>%
  group_by(main_list) %>%
  summarise(
    n = n(),
    mean_change_pct = mean(reach_change_pct),
    median_change_pct = median(reach_change_pct)
  )

# Statistical test
anova_model <- aov(reach_change_pct ~ main_list, data = accounts_both)
summary(anova_model)

# Post-hoc
library(emmeans)
emmeans(anova_model, pairwise ~ main_list)
```

**Key insight:** Different mean change % across groups = differential impact

**If MPs are split (v3.2):** You'll get 4-way comparison including experience effects. See RQ4 below for MP-specific analysis.

---

## RQ4: Did the policy affect experienced vs new MPs differently? (v3.2 only)

### Use: `accounts_both_periods` (filtered for MPs)

**Available if:** You used `combine_datasets_v3_reelected_mps.R` with the re-elected MPs file

**Why:**
- âœ… Compares MPs_Reelected (served 2021+2022) vs MPs_New (elected only 2022)
- âœ… Tests if parliamentary experience buffers against algorithmic changes
- âœ… Controls for other factors (both are MPs, similar institutional position)

**Analysis:**
```r
accounts_both <- readRDS("cleaned_data/accounts_both_periods_TIMESTAMP.rds")

# Check if MPs are split
mp_groups <- unique(accounts_both$main_list[grepl("^MPs", accounts_both$main_list)])

if (length(mp_groups) > 1) {
  # Filter for MPs only
  mp_data <- accounts_both %>% filter(grepl("^MPs", main_list))
  
  # Descriptive comparison
  mp_data %>%
    group_by(main_list) %>%
    summarise(
      n = n(),
      mean_change = mean(reach_change_pct),
      median_change = median(reach_change_pct),
      sd_change = sd(reach_change_pct)
    )
  
  # T-test
  t.test(reach_change_pct ~ main_list, data = mp_data)
  
  # With controls
  mp_model <- lm(reach_change_pct ~ main_list + log(reach_pre) + log(posts_pre),
                 data = mp_data)
  summary(mp_model)
  
  # Visualization
  ggplot(mp_data, aes(x = main_list, y = reach_change_pct, fill = main_list)) +
    geom_boxplot() +
    geom_hline(yintercept = 0, linetype = "dashed") +
    labs(title = "Reach Change: Re-elected vs New MPs",
         y = "% Change in Reach")
} else {
  cat("MPs not split - using v2/v3.1 data or v3.2 without re-elected file\n")
}
```

**Key insight:** If new MPs show larger reach reduction â†’ algorithmic barrier to entry for newcomers

**Combine MPs if needed:**
```r
# Treat all MPs as one group for other analyses
data %>%
  mutate(group_combined = if_else(grepl("^MPs", main_list), "MPs", main_list))
```

---

## Why NOT These Datasets?

### âŒ `cleaned_posts` for RQ1?
- Too granular (2.28M posts)
- Need aggregation to see trends
- Use weekly/monthly instead

### âŒ `weekly_aggregation` for RQ2?
- Aggregation destroys post-level variation
- Can't model engagement â†’ reach at weekly level
- Need individual posts

### âŒ `cleaned_posts` for RQ3?
- Unbalanced (some accounts only pre or post)
- Confounds composition with policy effects
- Use balanced panel instead

---

## Other Datasets - When to Use

### `posts_both_periods`
- Post-level detail BUT only for balanced accounts
- Good for: Detailed analysis with composition control

### `account_period`
- Account stats by period, includes ALL accounts
- Good for: Overall trends including new accounts

### `accounts_summary`
- Overall account characteristics
- Good for: Descriptives, but not for pre/post comparison

### `monthly_aggregation`
- Alternative to weekly (smoother, less noise)
- Good for: If weekly is too volatile

---

## Quick Start

```r
# Load the 3 key datasets
weekly <- readRDS("cleaned_data/weekly_aggregation_TIMESTAMP.rds")
posts <- readRDS("cleaned_data/cleaned_posts_TIMESTAMP.rds")
accounts_both <- readRDS("cleaned_data/accounts_both_periods_TIMESTAMP.rds")

# Quick visual check
library(ggplot2)

# RQ1 visual
ggplot(weekly, aes(x = week, y = avg_views, color = main_list)) +
  geom_line() +
  labs(title = "RQ1: Reach Over Time")

# RQ3 visual
ggplot(accounts_both, aes(x = main_list, y = reach_change_pct, fill = main_list)) +
  geom_boxplot() +
  labs(title = "RQ3: Reach Change by Group")
```

---

## Bottom Line

**3-4 Research Questions = 3 Datasets**

1. **Timing question** â†’ Time series data (`weekly_aggregation`)
2. **Relationship question** â†’ Individual posts (`cleaned_posts`)
3. **Group comparison** â†’ Balanced panel (`accounts_both_periods`)
4. **Experience comparison (v3.2 only)** â†’ Balanced panel, filtered for MPs

**Each dataset is optimized for its specific research question!**

**Note on group structure:**
- All analyses work with **3 or 4 groups** automatically
- v3.2 with MP split enables RQ4 (experience effects)
- Use `grepl("^MPs", main_list)` to combine MPs when needed

---

See `DATASET_RECOMMENDATIONS_FOR_RQS.md` for detailed explanations, code examples, and methodological rationale.
