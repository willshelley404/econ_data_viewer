# utils.R
# Utility functions for the FRED Housing Market Dashboard

# Format values based on units
format_value <- function(value, units) {
  if (is.na(value)) return("N/A")
  
  # Handle different unit types
  if (grepl("percent|rate", units, ignore.case = TRUE)) {
    return(paste0(round(value, 2), "%"))
  } else if (grepl("dollars|price", units, ignore.case = TRUE)) {
    return(paste0("$", format(round(value, 0), big.mark = ",")))
  } else if (grepl("thousands", units, ignore.case = TRUE)) {
    return(paste0(format(round(value, 1), big.mark = ","), "K"))
  } else if (grepl("millions", units, ignore.case = TRUE)) {
    return(paste0("$", format(round(value, 0), big.mark = ","), "M"))
  } else if (grepl("index", units, ignore.case = TRUE)) {
    return(round(value, 2))
  } else {
    return(format(round(value, 2), big.mark = ","))
  }
}

# Calculate percentage change
calculate_change <- function(data, periods = 1) {
  if (nrow(data) < periods + 1) return(NA)
  
  current_value <- tail(data$value, 1)
  previous_value <- tail(data$value, periods + 1)[1]
  
  if (is.na(current_value) || is.na(previous_value) || previous_value == 0) {
    return(NA)
  }
  
  ((current_value - previous_value) / previous_value) * 100
}

# Create summary statistics table
create_summary_stats <- function(values, units) {
  if (length(values) == 0 || all(is.na(values))) {
    return(data.frame(
      Statistic = "No data available",
      Value = ""
    ))
  }
  
  # Remove NA values for calculations
  clean_values <- values[!is.na(values)]
  
  if (length(clean_values) == 0) {
    return(data.frame(
      Statistic = "No valid data points",
      Value = ""
    ))
  }
  
  stats <- data.frame(
    Statistic = c(
      "Count",
      "Mean",
      "Median", 
      "Standard Deviation",
      "Minimum",
      "Maximum",
      "First Quartile",
      "Third Quartile"
    ),
    Value = c(
      length(clean_values),
      format_value(mean(clean_values), units),
      format_value(median(clean_values), units),
      format_value(sd(clean_values), units),
      format_value(min(clean_values), units),
      format_value(max(clean_values), units),
      format_value(quantile(clean_values, 0.25), units),
      format_value(quantile(clean_values, 0.75), units)
    )
  )
  
  return(stats)
}

# Validate API key format
validate_api_key <- function(api_key) {
  # FRED API keys are typically 32 character alphanumeric strings
  if (is.null(api_key) || api_key == "") {
    return(FALSE)
  }
  
  if (nchar(api_key) != 32) {
    return(FALSE)
  }
  
  if (!grepl("^[a-f0-9]{32}$", api_key, ignore.case = TRUE)) {
    return(FALSE)
  }
  
  return(TRUE)
}

# Create date sequence for missing data visualization
create_date_sequence <- function(start_date, end_date, frequency = "monthly") {
  start <- as.Date(start_date)
  end <- as.Date(end_date)
  
  if (frequency == "monthly") {
    seq(from = start, to = end, by = "month")
  } else if (frequency == "quarterly") {
    seq(from = start, to = end, by = "quarter")  
  } else if (frequency == "annual") {
    seq(from = start, to = end, by = "year")
  } else {
    seq(from = start, to = end, by = "month")
  }
}

# Safe division function
safe_divide <- function(x, y) {
  ifelse(y == 0 | is.na(y), NA, x / y)
}

# Format large numbers
format_large_number <- function(x) {
  if (is.na(x)) return("N/A")
  
  if (abs(x) >= 1e9) {
    paste0(round(x / 1e9, 1), "B")
  } else if (abs(x) >= 1e6) {
    paste0(round(x / 1e6, 1), "M")
  } else if (abs(x) >= 1e3) {
    paste0(round(x / 1e3, 1), "K")
  } else {
    as.character(round(x, 1))
  }
}