# This script contains modular functions for cleaning and wrangling the NYC 311
# data on rodent sightings

# Package imports
library(tidyverse)
library(lubridate)

load_rats <- function(file_path = "data/Rat_sightings.csv") {
  return(read_csv(file_path, na = c("", "NA", "N/A")))
}

# This function will conduct a basic processing as provided in the starter code.
clean_rats <- function(rats) {
  rats_clean <- rats %>%
    rename(
      created_date = `Created Date`,
      location_type = `Location Type`,
      borough = Borough
    ) %>%
    mutate(
      parsed_date = mdy_hms(created_date),
      # Fallback for formats without seconds if necessary
      parsed_date = if_else(is.na(parsed_date), mdy_hm(created_date), parsed_date)
    ) %>%
    filter(!is.na(parsed_date)) %>%
    mutate(
      sighting_year = year(parsed_date),
      sighting_month = month(parsed_date),
      sighting_day = day(parsed_date),
      sighting_weekday = wday(parsed_date, label = TRUE, abbr = FALSE),
      sighting_year_month = floor_date(parsed_date, "month")
    ) %>%
    filter(borough != "Unspecified", !is.na(borough))
  return(rats_clean)
}

summarize_by_year_borough <- function(df) {
  df %>%
    group_by(sighting_year, borough) %>%
    summarize(total_sightings = n(), .groups = "drop")
}
summarize_by_month_seasonality <- function(df) {
  df %>%
    group_by(sighting_month) %>%
    summarize(total_sightings = n(), .groups = "drop")
}