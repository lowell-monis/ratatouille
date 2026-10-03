# This script contains modular functions for cleaning and wrangling the NYC 311
# data on rodent sightings

# Package imports
library(tidyverse)
library(lubridate)
library(sf)
library(tigris)

load_rats <- function(file_path = "data/Rat_sightings.csv") {
  read_csv(file_path, na = c("", "NA", "N/A"), show_col_types = FALSE)
}

clean_rats <- function(rats) {
  rats %>%
    rename(
      created_date = `Created Date`,
      location_type = `Location Type`,
      borough = Borough
    ) %>%
    mutate(
      parsed_date = mdy_hms(created_date),
      parsed_date = if_else(is.na(parsed_date), mdy_hm(created_date), parsed_date)
    ) %>%
    filter(!is.na(parsed_date)) %>%
    mutate(
      sighting_year = year(parsed_date),
      sighting_month = month(parsed_date),
      sighting_day = day(parsed_date),
      sighting_weekday = wday(parsed_date, label = TRUE, abbr = FALSE),
      sighting_year_month = floor_date(parsed_date, "month"),
      borough = str_to_title(borough)
    ) %>%
    filter(
      borough %in% c("Bronx", "Brooklyn", "Manhattan", "Queens", "Staten Island"),
      !is.na(borough)
    )
}

summarize_by_year_borough <- function(df, start_year = NULL, end_year = NULL) {
  data <- df
  if (!is.null(start_year)) data <- data %>% filter(sighting_year >= start_year)
  if (!is.null(end_year)) data <- data %>% filter(sighting_year <= end_year)
  
  data %>%
    group_by(sighting_year, borough) %>%
    summarize(total_sightings = n(), .groups = "drop")
}

summarize_by_month_seasonality <- function(df, start_year = NULL, end_year = NULL) {
  data <- df
  if (!is.null(start_year)) data <- data %>% filter(sighting_year >= start_year)
  if (!is.null(end_year)) data <- data %>% filter(sighting_year <= end_year)
  
  n_years <- n_distinct(data$sighting_year)
  
  data %>%
    group_by(sighting_month) %>%
    summarize(
      total_sightings = n(),
      average_reports = n() / n_years,
      .groups = "drop"
    )
}

load_nyc_boroughs <- function() {
  tigris::counties(state = "NY", cb = TRUE, progress_bar = FALSE) %>%
    filter(COUNTYFP %in% c("005", "047", "061", "081", "085")) %>%
    mutate(
      borough = case_when(
        COUNTYFP == "005" ~ "Bronx",
        COUNTYFP == "047" ~ "Brooklyn",
        COUNTYFP == "061" ~ "Manhattan",
        COUNTYFP == "081" ~ "Queens",
        COUNTYFP == "085" ~ "Staten Island"
      )
    )
}

make_rat_spatial <- function(rats_clean) {
  rats_clean %>%
    filter(!is.na(Latitude), !is.na(Longitude)) %>%
    st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326)
}