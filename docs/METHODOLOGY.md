# Methodology

This document describes the analytical approach used in the Meta Political Content Policy Analysis.

---

## Research Design Overview

### Discovery-Validation Framework

The analysis employs a **discovery-validation design** suited to the temporal ambiguity of Meta's policy rollout. Since precise implementation dates were never confirmed for specific countries, we:

1. **Discover** structural breakpoints using one group (re-elected MPs)
2. **Validate** these breakpoints across other political actor groups

This approach allows the data to reveal when policy effects actually occurred, rather than assuming they coincided with Meta's announcements.

### Why Re-elected MPs as Discovery Sample?

Re-elected Members of Parliament constitute an optimal discovery sample for three reasons:

1. **Temporal continuity:** These MPs maintained active Facebook pages throughout the entire study period (2021-2025), ensuring uninterrupted time series data

2. **Compositional stability:** Because the sample consists of the same individuals over time, observed variations cannot be attributed to changes in who is posting

3. **Quasi-experimental design:** The policy reversal enables detection of two breakpoints with opposite directional effects (decline at implementation, recovery at reversal), strengthening causal inference

---

## Breakpoint Detection

### Cross-Algorithm Validation

We use a rigorous cross-algorithm validation approach to identify structural breakpoints:

#### Step 1: Detection
Run two complementary algorithms on four engagement metrics:
- **Bai-Perron** structural break detection
- **PELT** (Pruned Exact Linear Time) changepoint detection
- Metrics: views, reactions, shares, comments

This produces up to 8 independent signals per algorithm.

#### Step 2: Clustering
Group detected dates within a 30-day tolerance window:
- Calculate consensus date (cluster median)
- Record detection spread (date range)
- Count number of detections per cluster

#### Step 3: Cross-Validation
Retain only breakpoints detected by **BOTH** algorithms:
- Ensures statistical robustness across methodologies
- Filters out method-specific artifacts
- Results in high-confidence breakpoints

#### Step 4: Model Selection
When ≥3 cross-validated breakpoints exist:
- **T₁:** First chronological (Policy Implementation)
- **T₃:** First after September 2024 OR last chronological (Reversal)
- **T₂:** Among remaining, select strongest evidence (most detections)

### Strength Classification

| Strength | Detection Count | Description |
|----------|-----------------|-------------|
| MODERATE | 3-4 | Detected but limited consensus |
| STRONG | 5-7 | Clear detection by both algorithms |
| VERY STRONG | 8+ | Maximum consensus across methods |

---

## View Imputation

### The Censoring Problem

Meta Content Library API censors view counts ≤100 (returns NA). This censoring affects different groups unequally:
- Extremists: ~9.4% posts censored
- MPs (Reelected): ~5.4% posts censored
- MPs (New): ~4.3% posts censored
- Prominent Politicians: ~1.0% posts censored

### Group-Specific Ratio-Weighted Imputation

Rather than using a single imputation method, we derive group-specific parameters:

1. **Fit power law model** to each group's observed distribution in the 101-500 view range
2. **Extrapolate below threshold** to estimate the 1-100 view distribution
3. **Calculate group-specific ratio** of expected values above vs. below median (50)
4. **Impute using weighted probability** based on the derived distribution

#### Derived Parameters (Italy Study)

| Group | α (slope) | Ratio | Expected Mean | Expected Median |
|-------|-----------|-------|---------------|-----------------|
| Extremists | -0.36 | 1.65 | 44 | 32 |
| MPs_Reelected | 0.14 | 0.82 | 53 | 56 |
| MPs_New | 0.03 | 0.94 | 51 | 52 |
| Prominent Politicians | 0.33 | 0.66 | 56 | 63 |

### Sensitivity Analysis

Maximum difference between group-specific and pooled imputation: **0.002%**

This confirms results are robust to imputation assumptions.

---

## Phase Assignment

### Three-Breakpoint Model

Once breakpoints are detected, the time series is divided into four phases:

| Phase | Label | Description |
|-------|-------|-------------|
| 0 | Pre-Policy | Before T₁: baseline period |
| 1 | Policy-Active | T₁ to T₂: initial implementation |
| 2 | Adjusted-Policy | T₂ to T₃: adjusted/intensified policy |
| 3 | Post-Reversal | After T₃: reversal period |

### Expected Pattern

For mainstream political actors affected by the policy:
```
DOWN → DOWN → UP
(Phase 0→1) (Phase 1→2) (Phase 2→3)
```

Deviation from this pattern (e.g., extremists showing DOWN → DOWN → DOWN) indicates differential algorithmic treatment.

---

## Statistical Testing

### Phase Comparisons

**Kruskal-Wallis test:** Non-parametric test for differences across all phases
- H₀: All phases have the same distribution
- Tests whether detected breakpoints represent genuine structural changes

**Dunn's post-hoc test:** Pairwise phase comparisons with Bonferroni correction
- Identifies which specific phase transitions are significant
- Controls for multiple comparisons

### Validation Criteria

A group validates the discovered breakpoints if:
1. Kruskal-Wallis test is significant (p < 0.05)
2. Phase transitions show the expected directional pattern
3. Key phase comparisons (0→1, 2→3) are significant in pairwise tests

---

## Outcome Measures

### Primary: Average Views per Post

**Why average views:**
- Standardizes for posting frequency differences
- Captures per-post visibility/reach
- Directly reflects algorithmic distribution

**Interpretation:**
- Views = impressions (same post can be viewed multiple times by same user)
- Reshares increment views for BOTH original and reshare
- Higher per-post views = better algorithmic distribution

### Secondary: Total Weekly Reach

**Why total reach (robustness check):**
- Captures aggregate visibility regardless of posting frequency
- Reveals if high-volume posting compensates for per-post reductions
- Important for groups with very different posting behaviors

**Key finding from Italy:**
Extremists showed opposite patterns:
- Per-post reach: DOWN 24%
- Total weekly reach: UP 14%

This suggests high posting volume can compensate for per-post algorithmic reduction.

---

## Election Effects

### Treatment as Transient Fluctuations

Elections are treated as **transient fluctuations** rather than structural breakpoints because:
1. Political activity temporarily increases during campaigns
2. Effects dissipate after election period ends
3. They don't represent permanent algorithmic changes

### Election Window Analysis

For each election:
1. Define campaign window (typically 2-3 months around election day)
2. Compare reach during window vs. surrounding non-election period
3. Calculate "election bounce" percentage
4. Verify return to trend after window closes

---

## Robustness Checks

### 1. Alternative Breakpoint Dates
- Test sensitivity to ±2 week shifts in breakpoint dates
- Results should be qualitatively similar

### 2. Imputation Method Comparison
- Compare group-specific vs. pooled imputation
- Maximum impact should be negligible (<0.01%)

### 3. Total vs. Per-Post Reach
- Verify conclusions hold for both metrics
- Document any divergent patterns

### 4. Group Exclusion
- Re-run analysis excluding each validation group
- Core findings should remain stable

### 5. Weekly vs. Monthly Aggregation
- Compare results at different temporal granularities
- Monthly provides smoother trends but less precise timing

---

## Limitations

### Data Limitations

1. **View count interpretation:** Views are impressions, not unique reach
2. **Censoring:** Cannot observe exact values for low-reach posts
3. **Platform-specific:** Results apply to Facebook; Instagram/Threads may differ
4. **Country-specific:** Effects may vary across political/cultural contexts

### Methodological Limitations

1. **Observational design:** Cannot definitively establish causation
2. **Unknown algorithm details:** Meta's exact implementation is undisclosed
3. **Competing explanations:** Other platform changes may have occurred
4. **Composition effects:** Group membership may change over time

### Interpretation Cautions

1. **Policy timing uncertainty:** Detected breakpoints are estimates
2. **Effect heterogeneity:** Individual accounts may have different experiences
3. **Reverse causality:** Politicians may have changed behavior in response to perceived changes

---

## Replication Requirements

To replicate this methodology:

1. **Data access:** Meta Content Library API (approved researchers)
2. **Minimum sample:** 
   - ≥100 accounts per group
   - ≥10 posts per account per period
   - ≥1 year pre-policy data
3. **Computational:** Standard R environment, ~1 hour runtime for full analysis
4. **Configuration:** Country-specific parameters (elections, groups, timeline)

See [REPLICATION_GUIDE.md](../REPLICATION_GUIDE.md) for detailed instructions.
