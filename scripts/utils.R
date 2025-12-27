# =============================================================================
# UTILITY FUNCTIONS
# Meta Political Content Policy Analysis
# =============================================================================
# 
# Shared utility functions used across the analysis pipeline.
# Source this file at the beginning of each notebook.
#
# Usage: source("scripts/utils.R")
# =============================================================================

# Load required packages
required_packages <- c("tidyverse", "lubridate", "yaml")
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg)
  }
  library(pkg, character.only = TRUE)
}

# =============================================================================
# CONFIGURATION FUNCTIONS
# =============================================================================

#' Load country configuration file
#' 
#' @param country_code ISO 3166-1 alpha-2 country code (e.g., "IT", "DE")
#' @param config_dir Directory containing config files (default: "config/")
#' @return List containing configuration parameters
#' @examples
#' config <- load_config("IT")
load_config <- function(country_code, config_dir = "config/") {
  config_file <- file.path(config_dir, paste0(tolower(country_code), "_config.yaml"))
  
  if (!file.exists(config_file)) {
    stop(
      "Configuration file not found: ", config_file, "\n",
      "Please create a config file for your country.\n",
      "See config/config_template.yaml for the required format."
    )
  }
  
  config <- yaml::read_yaml(config_file)
  
  # Validate required fields
  required_fields <- c("country", "study_period", "groups")
  missing_fields <- setdiff(required_fields, names(config))
  
  if (length(missing_fields) > 0) {
    stop("Missing required config fields: ", paste(missing_fields, collapse = ", "))
  }
  
  # Convert date strings to Date objects
  config$study_period$start_date <- as.Date(config$study_period$start_date)
  config$study_period$end_date <- as.Date(config$study_period$end_date)
  
  # Convert election dates
  if (!is.null(config$elections)) {
    config$elections <- lapply(config$elections, function(e) {
      e$date <- as.Date(e$date)
      e$window_start <- as.Date(e$window_start)
      e$window_end <- as.Date(e$window_end)
      e
    })
  }
  
  return(config)
}


# =============================================================================
# FILE MANAGEMENT FUNCTIONS
# =============================================================================

#' Find the most recent file matching a pattern
#' 
#' @param directory Directory to search
#' @param pattern File name pattern (regex)
#' @return Full path to most recent file, or NULL if none found
find_most_recent_file <- function(directory, pattern) {
  files <- list.files(
    path = directory,
    pattern = pattern,
    full.names = TRUE
  )
  
  if (length(files) == 0) {
    return(NULL)
  }
  
  # Sort by modification time
  file_info <- file.info(files)
  most_recent <- rownames(file_info)[which.max(file_info$mtime)]
  
  return(most_recent)
}


#' Generate timestamped output filename
#' 
#' @param prefix File name prefix
#' @param extension File extension (without dot)
#' @param directory Output directory
#' @return Full path with timestamp
generate_output_filename <- function(prefix, extension, directory = ".") {
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  filename <- paste0(prefix, "_", timestamp, ".", extension)
  return(file.path(directory, filename))
}


#' Load most recent dataset of a type
#' 
#' @param data_type Type of dataset (e.g., "weekly_aggregation", "cleaned_posts")
#' @param data_dir Directory containing datasets (default: "cleaned_data/")
#' @return Loaded dataset
load_latest_dataset <- function(data_type, data_dir = "cleaned_data/") {
  pattern <- paste0("^", data_type, "_.*\\.rds$")
  file_path <- find_most_recent_file(data_dir, pattern)
  
  if (is.null(file_path)) {
    stop("No ", data_type, " files found in ", data_dir)
  }
  
  cat("Loading:", basename(file_path), "\n")
  return(readRDS(file_path))
}


# =============================================================================
# DATA VALIDATION FUNCTIONS
# =============================================================================

#' Validate dataset structure
#' 
#' @param data Data frame to validate
#' @param required_cols Vector of required column names
#' @param dataset_name Name for error messages
#' @return TRUE if valid, stops with error if not
validate_dataset <- function(data, required_cols, dataset_name = "dataset") {
  if (!is.data.frame(data)) {
    stop(dataset_name, " is not a data frame")
  }
  
  missing_cols <- setdiff(required_cols, names(data))
  
  if (length(missing_cols) > 0) {
    stop(
      "Missing required columns in ", dataset_name, ":\n",
      "  ", paste(missing_cols, collapse = ", ")
    )
  }
  
  return(TRUE)
}


#' Check for data integrity issues
#' 
#' @param data Data frame with surface.id and main_list columns
#' @return List with integrity check results
check_data_integrity <- function(data) {
  results <- list()
  
  # Check 1: Each surface.id should have exactly one main_list
  multi_list <- data %>%
    group_by(surface.id) %>%
    summarise(n_lists = n_distinct(main_list), .groups = "drop") %>%
    filter(n_lists > 1)
  
  results$multi_list_accounts <- multi_list
  results$n_multi_list <- nrow(multi_list)
  
  # Check 2: Duplicate post IDs
  if ("id" %in% names(data)) {
    duplicate_posts <- data %>%
      group_by(id) %>%
      filter(n() > 1)
    
    results$duplicate_posts <- duplicate_posts
    results$n_duplicates <- nrow(duplicate_posts)
  }
  
  # Summary
  results$has_issues <- results$n_multi_list > 0 || 
    (!is.null(results$n_duplicates) && results$n_duplicates > 0)
  
  return(results)
}


# =============================================================================
# DATA TRANSFORMATION FUNCTIONS
# =============================================================================

#' Add policy phase variable based on breakpoints
#' 
#' @param data Data frame with a date/week column
#' @param breakpoints Named list of breakpoint dates (T1, T2, T3)
#' @param date_col Name of the date column
#' @return Data frame with phase column added
add_policy_phase <- function(data, breakpoints, date_col = "week") {
  T1 <- breakpoints$T1
  T2 <- if (!is.null(breakpoints$T2)) breakpoints$T2 else as.Date("9999-12-31")
  T3 <- if (!is.null(breakpoints$T3)) breakpoints$T3 else as.Date("9999-12-31")
  
  data %>%
    mutate(
      phase = case_when(
        .data[[date_col]] < T1 ~ "0_Pre-Policy",
        .data[[date_col]] >= T1 & .data[[date_col]] < T2 ~ "1_Policy-Active",
        .data[[date_col]] >= T2 & .data[[date_col]] < T3 ~ "2_Adjusted-Policy",
        .data[[date_col]] >= T3 ~ "3_Post-Reversal",
        TRUE ~ NA_character_
      ),
      phase = factor(phase, levels = c(
        "0_Pre-Policy", "1_Policy-Active", 
        "2_Adjusted-Policy", "3_Post-Reversal"
      ))
    )
}


#' Calculate reach change statistics
#' 
#' @param data Data frame with pre/post reach columns
#' @param group_col Column name for grouping
#' @return Summary statistics by group
calculate_reach_change <- function(data, group_col = "main_list") {
  data %>%
    group_by(.data[[group_col]]) %>%
    summarise(
      n_accounts = n(),
      mean_change = mean(reach_change, na.rm = TRUE),
      median_change = median(reach_change, na.rm = TRUE),
      mean_change_pct = mean(reach_change_pct, na.rm = TRUE),
      median_change_pct = median(reach_change_pct, na.rm = TRUE),
      sd_change_pct = sd(reach_change_pct, na.rm = TRUE),
      .groups = "drop"
    )
}


# =============================================================================
# IMPUTATION FUNCTIONS
# =============================================================================

#' Calculate group-specific imputation parameters
#' 
#' @param data Data frame with views column
#' @param group_col Column name for grouping
#' @param bin_width Width of bins for power law fit
#' @param max_view Maximum view value for fitting
#' @return List of parameters by group
calculate_imputation_params <- function(data, group_col = "main_list",
                                        bin_width = 100, max_view = 500) {
  groups <- unique(data[[group_col]])
  params <- list()
  
  for (g in groups) {
    group_data <- data %>%
      filter(.data[[group_col]] == g, !is.na(statistics.views))
    
    # Bin the near-threshold data
    bins <- group_data %>%
      filter(statistics.views > 100, statistics.views <= max_view) %>%
      mutate(bin = cut(statistics.views, 
                       breaks = seq(100, max_view, by = bin_width),
                       include.lowest = TRUE)) %>%
      count(bin)
    
    if (nrow(bins) < 3) {
      # Not enough data for reliable fit - use fallback
      params[[g]] <- list(
        alpha = NA,
        ratio = 1.0,  # Neutral fallback
        expected_mean = 50,
        expected_median = 50,
        method = "fallback"
      )
    } else {
      # Fit power law (simplified)
      bins$x <- seq_len(nrow(bins))
      fit <- lm(log(n) ~ x, data = bins)
      alpha <- coef(fit)["x"]
      
      # Calculate ratio (expected value above vs below 50)
      ratio <- exp(-alpha * 2)  # Approximate
      
      params[[g]] <- list(
        alpha = alpha,
        ratio = ratio,
        expected_mean = round(50 * (1 + ratio) / 2),
        expected_median = if (ratio > 1) 32 else if (ratio < 0.7) 63 else 50,
        method = "power_law_fit"
      )
    }
  }
  
  return(params)
}


#' Impute censored view values
#' 
#' @param views Vector of view counts (NA for censored)
#' @param group Vector of group labels
#' @param params Imputation parameters from calculate_imputation_params
#' @param seed Random seed for reproducibility
#' @return Vector with imputed values
impute_views <- function(views, group, params, seed = 42) {
  set.seed(seed)
  
  imputed <- views
  na_idx <- which(is.na(views))
  
  for (i in na_idx) {
    g <- as.character(group[i])
    if (!g %in% names(params)) {
      g <- names(params)[1]  # Fallback to first group
    }
    
    p <- params[[g]]
    ratio <- p$ratio
    
    # Generate imputed value based on ratio-weighted distribution
    if (runif(1) < ratio / (1 + ratio)) {
      imputed[i] <- sample(1:50, 1)
    } else {
      imputed[i] <- sample(51:100, 1)
    }
  }
  
  return(imputed)
}


# =============================================================================
# SUMMARY STATISTICS FUNCTIONS
# =============================================================================

#' Calculate summary statistics for engagement metrics
#' 
#' @param data Data frame with engagement columns
#' @param group_col Column name for grouping
#' @return Summary statistics table
calculate_engagement_stats <- function(data, group_col = "main_list") {
  data %>%
    group_by(.data[[group_col]]) %>%
    summarise(
      # Views
      views_mean = mean(avg_views, na.rm = TRUE),
      views_sd = sd(avg_views, na.rm = TRUE),
      views_median = median(avg_views, na.rm = TRUE),
      views_min = min(avg_views, na.rm = TRUE),
      views_max = max(avg_views, na.rm = TRUE),
      
      # Reactions
      reactions_mean = mean(avg_reactions, na.rm = TRUE),
      reactions_sd = sd(avg_reactions, na.rm = TRUE),
      reactions_median = median(avg_reactions, na.rm = TRUE),
      
      # Shares
      shares_mean = mean(avg_shares, na.rm = TRUE),
      shares_sd = sd(avg_shares, na.rm = TRUE),
      shares_median = median(avg_shares, na.rm = TRUE),
      
      # Comments
      comments_mean = mean(avg_comments, na.rm = TRUE),
      comments_sd = sd(avg_comments, na.rm = TRUE),
      comments_median = median(avg_comments, na.rm = TRUE),
      
      .groups = "drop"
    )
}


# =============================================================================
# PRINTING AND REPORTING FUNCTIONS
# =============================================================================

#' Print a formatted section header
#' 
#' @param title Section title
#' @param width Character width (default: 80)
#' @param char Character to use for border (default: "=")
print_header <- function(title, width = 80, char = "=") {
  border <- paste(rep(char, width), collapse = "")
  cat("\n", border, "\n", sep = "")
  cat(title, "\n")
  cat(border, "\n\n", sep = "")
}


#' Print a formatted sub-header
#' 
#' @param title Sub-section title
#' @param width Character width (default: 60)
print_subheader <- function(title, width = 60) {
  border <- paste(rep("-", width), collapse = "")
  cat("\n", title, "\n", sep = "")
  cat(border, "\n\n", sep = "")
}


#' Print dataset summary
#' 
#' @param data Data frame to summarize
#' @param name Dataset name for header
print_dataset_summary <- function(data, name = "Dataset") {
  cat(name, "Summary:\n")
  cat("  Rows:", format(nrow(data), big.mark = ","), "\n")
  cat("  Columns:", ncol(data), "\n")
  
  if ("date" %in% names(data) || "week" %in% names(data)) {
    date_col <- if ("date" %in% names(data)) "date" else "week"
    cat("  Date range:", 
        as.character(min(data[[date_col]], na.rm = TRUE)), "to",
        as.character(max(data[[date_col]], na.rm = TRUE)), "\n")
  }
  
  if ("main_list" %in% names(data)) {
    cat("  Groups:", paste(unique(data$main_list), collapse = ", "), "\n")
  }
  
  cat("\n")
}


# =============================================================================
# VERSION INFO
# =============================================================================

cat("Loaded utils.R - Meta Political Content Policy Analysis\n")
cat("Version: 1.0.0\n")
cat("Available functions:\n")
cat("  - load_config(): Load country configuration\n")
cat("  - find_most_recent_file(): Find latest file by pattern\n")
cat("  - load_latest_dataset(): Load most recent dataset of type\n")
cat("  - validate_dataset(): Validate dataset structure\n")
cat("  - check_data_integrity(): Check for data issues\n")
cat("  - add_policy_phase(): Add phase variable\n")
cat("  - calculate_reach_change(): Calculate reach change stats\n")
cat("  - calculate_imputation_params(): Get imputation parameters\n")
cat("  - impute_views(): Impute censored view values\n")
cat("  - calculate_engagement_stats(): Engagement summary statistics\n")
cat("  - print_header(), print_subheader(): Formatted output\n")
cat("\n")
