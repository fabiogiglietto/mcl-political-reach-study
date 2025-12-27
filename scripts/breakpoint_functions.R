# =============================================================================
# BREAKPOINT DETECTION FUNCTIONS
# Meta Political Content Policy Analysis
# =============================================================================
# 
# Functions for structural breakpoint detection using Bai-Perron and PELT.
# Source this file for breakpoint analysis notebooks.
#
# Usage: source("scripts/breakpoint_functions.R")
# =============================================================================

# Load required packages
required_packages <- c("strucchange", "changepoint", "tidyverse", "lubridate")
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    # Install using Meta SRE method
    library(fbrir)
    cran <- CRAN$new()
    cran$InstallPackages(pkg)
  }
  library(pkg, character.only = TRUE)
}

# =============================================================================
# BAI-PERRON BREAKPOINT DETECTION
# =============================================================================

#' Run Bai-Perron structural break detection
#' 
#' @param data Data frame with time series
#' @param metric Column name for the metric to analyze
#' @param date_col Column name for date/week
#' @param h Minimum segment length as proportion (default: 0.15)
#' @param breaks Maximum number of breaks (default: 5)
#' @return List with breakpoints and diagnostics
#' @examples
#' bp <- run_bai_perron(weekly_data, "avg_views", "week")
run_bai_perron <- function(data, metric, date_col = "week", h = 0.15, breaks = 5) {
  # Ensure data is sorted by date
  data <- data %>% arrange(.data[[date_col]])
  
  # Extract time series
  ts_data <- data[[metric]]
  
  # Handle any NA values
  if (any(is.na(ts_data))) {
    warning("NA values found in ", metric, ". Removing for analysis.")
    valid_idx <- !is.na(ts_data)
    ts_data <- ts_data[valid_idx]
    dates <- data[[date_col]][valid_idx]
  } else {
    dates <- data[[date_col]]
  }
  
  # Run Bai-Perron
  tryCatch({
    bp <- breakpoints(ts_data ~ 1, h = h, breaks = breaks)
    
    # Extract breakpoint dates
    if (is.na(bp$breakpoints[1])) {
      bp_dates <- NULL
      n_breaks <- 0
    } else {
      bp_dates <- dates[bp$breakpoints]
      n_breaks <- length(bp$breakpoints)
    }
    
    return(list(
      method = "bai_perron",
      metric = metric,
      breakpoint_dates = bp_dates,
      breakpoint_indices = bp$breakpoints,
      n_breaks = n_breaks,
      model = bp,
      BIC = BIC(bp),
      success = TRUE
    ))
    
  }, error = function(e) {
    return(list(
      method = "bai_perron",
      metric = metric,
      breakpoint_dates = NULL,
      n_breaks = 0,
      error = e$message,
      success = FALSE
    ))
  })
}


# =============================================================================
# PELT CHANGEPOINT DETECTION
# =============================================================================

#' Run PELT changepoint detection
#' 
#' @param data Data frame with time series
#' @param metric Column name for the metric to analyze
#' @param date_col Column name for date/week
#' @param penalty Penalty method (default: "MBIC")
#' @param test.stat Test statistic type (default: "Normal")
#' @return List with changepoints and diagnostics
#' @examples
#' cp <- run_pelt(weekly_data, "avg_views", "week")
run_pelt <- function(data, metric, date_col = "week", 
                     penalty = "MBIC", test.stat = "Normal") {
  # Ensure data is sorted by date
  data <- data %>% arrange(.data[[date_col]])
  
  # Extract time series
  ts_data <- data[[metric]]
  
  # Handle any NA values
  if (any(is.na(ts_data))) {
    warning("NA values found in ", metric, ". Removing for analysis.")
    valid_idx <- !is.na(ts_data)
    ts_data <- ts_data[valid_idx]
    dates <- data[[date_col]][valid_idx]
  } else {
    dates <- data[[date_col]]
  }
  
  # Run PELT
  tryCatch({
    cpt <- cpt.mean(
      ts_data, 
      method = "PELT", 
      penalty = penalty,
      test.stat = test.stat
    )
    
    # Extract changepoint positions (excluding end point)
    cpt_pos <- cpts(cpt)
    cpt_pos <- cpt_pos[cpt_pos < length(ts_data)]
    
    if (length(cpt_pos) == 0) {
      cpt_dates <- NULL
      n_cpts <- 0
    } else {
      cpt_dates <- dates[cpt_pos]
      n_cpts <- length(cpt_pos)
    }
    
    return(list(
      method = "pelt",
      metric = metric,
      changepoint_dates = cpt_dates,
      changepoint_indices = cpt_pos,
      n_changepoints = n_cpts,
      model = cpt,
      success = TRUE
    ))
    
  }, error = function(e) {
    return(list(
      method = "pelt",
      metric = metric,
      changepoint_dates = NULL,
      n_changepoints = 0,
      error = e$message,
      success = FALSE
    ))
  })
}


# =============================================================================
# MULTI-METRIC BREAKPOINT DETECTION
# =============================================================================

#' Run breakpoint detection across multiple metrics
#' 
#' @param data Data frame with time series
#' @param metrics Vector of metric column names
#' @param date_col Column name for date/week
#' @param methods Vector of methods to use (default: both)
#' @return Data frame with all detected breakpoints
run_multi_metric_detection <- function(data, 
                                       metrics = c("avg_views", "avg_reactions", 
                                                  "avg_shares", "avg_comments"),
                                       date_col = "week",
                                       methods = c("bai_perron", "pelt")) {
  
  results <- tibble()
  
  for (metric in metrics) {
    if (!metric %in% names(data)) {
      warning("Metric not found: ", metric)
      next
    }
    
    # Bai-Perron
    if ("bai_perron" %in% methods) {
      bp_result <- run_bai_perron(data, metric, date_col)
      
      if (bp_result$success && !is.null(bp_result$breakpoint_dates)) {
        results <- bind_rows(results, tibble(
          method = "bai_perron",
          metric = metric,
          date = bp_result$breakpoint_dates
        ))
      }
    }
    
    # PELT
    if ("pelt" %in% methods) {
      pelt_result <- run_pelt(data, metric, date_col)
      
      if (pelt_result$success && !is.null(pelt_result$changepoint_dates)) {
        results <- bind_rows(results, tibble(
          method = "pelt",
          metric = metric,
          date = pelt_result$changepoint_dates
        ))
      }
    }
  }
  
  return(results)
}


# =============================================================================
# CLUSTERING AND VALIDATION FUNCTIONS
# =============================================================================

#' Cluster detected breakpoints within a tolerance window
#' 
#' @param all_breakpoints Data frame with date, method, metric columns
#' @param tolerance_days Days within which to cluster breakpoints (default: 30)
#' @return Data frame with clustered breakpoints
cluster_breakpoints <- function(all_breakpoints, tolerance_days = 30) {
  if (nrow(all_breakpoints) == 0) {
    return(tibble())
  }
  
  # Sort by date
  all_breakpoints <- all_breakpoints %>%
    arrange(date) %>%
    mutate(cluster = NA_integer_)
  
  # Assign clusters
  current_cluster <- 1
  cluster_end <- all_breakpoints$date[1] + days(tolerance_days)
  all_breakpoints$cluster[1] <- current_cluster
  
  for (i in 2:nrow(all_breakpoints)) {
    if (all_breakpoints$date[i] <= cluster_end) {
      all_breakpoints$cluster[i] <- current_cluster
    } else {
      current_cluster <- current_cluster + 1
      cluster_end <- all_breakpoints$date[i] + days(tolerance_days)
      all_breakpoints$cluster[i] <- current_cluster
    }
  }
  
  # Summarize clusters
  cluster_summary <- all_breakpoints %>%
    group_by(cluster) %>%
    summarise(
      consensus_date = median(date),
      date_min = min(date),
      date_max = max(date),
      date_range = paste(as.character(min(date)), "-", as.character(max(date))),
      n_detections = n(),
      methods = paste(unique(method), collapse = ", "),
      n_methods = n_distinct(method),
      metrics = paste(unique(metric), collapse = ", "),
      n_metrics = n_distinct(metric),
      .groups = "drop"
    ) %>%
    mutate(
      strength = case_when(
        n_detections >= 8 ~ "VERY STRONG",
        n_detections >= 5 ~ "STRONG",
        n_detections >= 3 ~ "MODERATE",
        TRUE ~ "WEAK"
      )
    ) %>%
    arrange(consensus_date)
  
  return(cluster_summary)
}


#' Cross-validate breakpoints (require detection by multiple algorithms)
#' 
#' @param cluster_summary Output from cluster_breakpoints
#' @param min_methods Minimum number of algorithms required (default: 2)
#' @return Filtered data frame with cross-validated breakpoints
cross_validate_breakpoints <- function(cluster_summary, min_methods = 2) {
  cluster_summary %>%
    filter(n_methods >= min_methods) %>%
    mutate(
      validated = TRUE,
      validation_note = paste("Detected by", n_methods, "algorithms")
    )
}


# =============================================================================
# FINAL BREAKPOINT SELECTION
# =============================================================================

#' Select final breakpoints for three-breakpoint model
#' 
#' @param cross_validated Data frame with cross-validated breakpoints
#' @param reversal_cutoff Date after which to search for reversal (default: 2024-09-01)
#' @return Named list with T1, T2, T3 breakpoints
select_final_breakpoints <- function(cross_validated, 
                                     reversal_cutoff = as.Date("2024-09-01")) {
  
  if (nrow(cross_validated) == 0) {
    warning("No cross-validated breakpoints found")
    return(list(T1 = NULL, T2 = NULL, T3 = NULL))
  }
  
  # Sort by date
  cv <- cross_validated %>% arrange(consensus_date)
  
  # T1: First chronological breakpoint (Implementation)
  T1 <- cv$consensus_date[1]
  T1_info <- cv[1, ]
  
  # T3: First breakpoint after reversal cutoff, or last if none after cutoff
  post_cutoff <- cv %>% filter(consensus_date >= reversal_cutoff)
  
  if (nrow(post_cutoff) > 0) {
    T3 <- post_cutoff$consensus_date[1]
    T3_info <- post_cutoff[1, ]
  } else if (nrow(cv) >= 2) {
    T3 <- cv$consensus_date[nrow(cv)]
    T3_info <- cv[nrow(cv), ]
  } else {
    T3 <- NULL
    T3_info <- NULL
  }
  
  # T2: Among remaining intermediate breakpoints, select strongest
  remaining <- cv %>%
    filter(
      consensus_date != T1,
      is.null(T3) | consensus_date != T3
    )
  
  if (nrow(remaining) > 0) {
    # Select by strength (most detections)
    T2_idx <- which.max(remaining$n_detections)
    T2 <- remaining$consensus_date[T2_idx]
    T2_info <- remaining[T2_idx, ]
  } else {
    T2 <- NULL
    T2_info <- NULL
  }
  
  # Build result
  result <- list(
    T1 = list(
      date = T1,
      date_range = T1_info$date_range,
      strength = T1_info$strength,
      methods = T1_info$n_methods,
      detections = T1_info$n_detections,
      label = "Implementation"
    )
  )
  
  if (!is.null(T2)) {
    result$T2 <- list(
      date = T2,
      date_range = T2_info$date_range,
      strength = T2_info$strength,
      methods = T2_info$n_methods,
      detections = T2_info$n_detections,
      label = "Adjustment"
    )
  }
  
  if (!is.null(T3)) {
    result$T3 <- list(
      date = T3,
      date_range = T3_info$date_range,
      strength = T3_info$strength,
      methods = T3_info$n_methods,
      detections = T3_info$n_detections,
      label = "Reversal"
    )
  }
  
  return(result)
}


# =============================================================================
# VALIDATION ACROSS GROUPS
# =============================================================================

#' Validate breakpoints across multiple groups
#' 
#' @param data Data frame with weekly aggregation for all groups
#' @param breakpoints Named list with T1, T2, T3 from select_final_breakpoints
#' @param group_col Column name for group
#' @param metric Column for comparison
#' @return Data frame with validation results
validate_breakpoints_across_groups <- function(data, breakpoints, 
                                               group_col = "main_list",
                                               metric = "avg_views") {
  groups <- unique(data[[group_col]])
  
  # Extract breakpoint dates
  T1 <- breakpoints$T1$date
  T2 <- if (!is.null(breakpoints$T2)) breakpoints$T2$date else as.Date("9999-12-31")
  T3 <- if (!is.null(breakpoints$T3)) breakpoints$T3$date else as.Date("9999-12-31")
  
  # Assign phases to data
  data_phased <- data %>%
    mutate(
      phase = case_when(
        week < T1 ~ "0_Pre-Policy",
        week >= T1 & week < T2 ~ "1_Policy-Active",
        week >= T2 & week < T3 ~ "2_Adjusted-Policy",
        week >= T3 ~ "3_Post-Reversal",
        TRUE ~ NA_character_
      )
    )
  
  results <- tibble()
  
  for (g in groups) {
    group_data <- data_phased %>% filter(.data[[group_col]] == g)
    
    # Calculate phase means
    phase_means <- group_data %>%
      group_by(phase) %>%
      summarise(
        n_weeks = n(),
        mean_val = mean(.data[[metric]], na.rm = TRUE),
        .groups = "drop"
      ) %>%
      arrange(phase)
    
    # Determine directional pattern
    if (nrow(phase_means) >= 3) {
      transitions <- diff(phase_means$mean_val)
      pattern <- paste(ifelse(transitions < 0, "DOWN", "UP"), collapse = " → ")
    } else {
      pattern <- "insufficient phases"
    }
    
    # Run Kruskal-Wallis test
    kw_test <- tryCatch({
      kruskal.test(as.formula(paste(metric, "~ phase")), data = group_data)
    }, error = function(e) {
      list(p.value = NA, statistic = NA)
    })
    
    # Determine if validated
    expected_pattern <- "DOWN → DOWN → UP"
    validated <- pattern == expected_pattern && 
      !is.na(kw_test$p.value) && kw_test$p.value < 0.05
    
    results <- bind_rows(results, tibble(
      group = g,
      pattern = pattern,
      expected_pattern = expected_pattern,
      pattern_matches = pattern == expected_pattern,
      kw_statistic = kw_test$statistic,
      kw_pvalue = kw_test$p.value,
      validated = validated
    ))
  }
  
  return(results)
}


# =============================================================================
# CONVENIENCE WRAPPER
# =============================================================================

#' Run full breakpoint analysis pipeline
#' 
#' @param data Weekly aggregation data frame
#' @param discovery_group Group to use for breakpoint discovery
#' @param group_col Column name for group
#' @param date_col Column name for date
#' @param metrics Metrics to analyze
#' @param tolerance_days Clustering tolerance
#' @return List with all analysis results
run_breakpoint_analysis <- function(data, 
                                    discovery_group,
                                    group_col = "main_list",
                                    date_col = "week",
                                    metrics = c("avg_views", "avg_reactions",
                                               "avg_shares", "avg_comments"),
                                    tolerance_days = 30) {
  
  cat("Running breakpoint analysis...\n")
  cat("Discovery group:", discovery_group, "\n\n")
  
  # Filter to discovery group
  discovery_data <- data %>% 
    filter(.data[[group_col]] == discovery_group)
  
  # Step 1: Run multi-metric detection
  cat("Step 1: Detecting breakpoints...\n")
  all_breakpoints <- run_multi_metric_detection(
    discovery_data, metrics, date_col
  )
  cat("  Found", nrow(all_breakpoints), "raw detections\n\n")
  
  # Step 2: Cluster breakpoints
  cat("Step 2: Clustering breakpoints...\n")
  clustered <- cluster_breakpoints(all_breakpoints, tolerance_days)
  cat("  Found", nrow(clustered), "clusters\n\n")
  
  # Step 3: Cross-validate
  cat("Step 3: Cross-validating...\n")
  cross_validated <- cross_validate_breakpoints(clustered)
  cat("  ", nrow(cross_validated), "cross-validated breakpoints\n\n")
  
  # Step 4: Select final breakpoints
  cat("Step 4: Selecting final breakpoints...\n")
  final_breakpoints <- select_final_breakpoints(cross_validated)
  
  cat("\nFinal breakpoints:\n")
  cat("  T1 (Implementation):", as.character(final_breakpoints$T1$date), "\n")
  if (!is.null(final_breakpoints$T2)) {
    cat("  T2 (Adjustment):", as.character(final_breakpoints$T2$date), "\n")
  }
  if (!is.null(final_breakpoints$T3)) {
    cat("  T3 (Reversal):", as.character(final_breakpoints$T3$date), "\n")
  }
  cat("\n")
  
  # Step 5: Validate across groups
  cat("Step 5: Validating across groups...\n")
  validation <- validate_breakpoints_across_groups(
    data, final_breakpoints, group_col
  )
  
  n_validated <- sum(validation$validated)
  cat("  Validated in", n_validated, "of", nrow(validation), "groups\n\n")
  
  return(list(
    all_breakpoints = all_breakpoints,
    clustered = clustered,
    cross_validated = cross_validated,
    final_breakpoints = final_breakpoints,
    validation = validation,
    discovery_group = discovery_group
  ))
}


# =============================================================================
# VERSION INFO
# =============================================================================

cat("Loaded breakpoint_functions.R - Meta Political Content Policy Analysis\n")
cat("Version: 1.0.0\n")
cat("Available functions:\n")
cat("  - run_bai_perron(): Bai-Perron structural break detection\n")
cat("  - run_pelt(): PELT changepoint detection\n")
cat("  - run_multi_metric_detection(): Multi-metric analysis\n")
cat("  - cluster_breakpoints(): Cluster detected breakpoints\n")
cat("  - cross_validate_breakpoints(): Cross-algorithm validation\n")
cat("  - select_final_breakpoints(): Select final T1/T2/T3\n")
cat("  - validate_breakpoints_across_groups(): Cross-group validation\n")
cat("  - run_breakpoint_analysis(): Full analysis pipeline\n")
cat("\n")
