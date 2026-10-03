# 1. Load and clean data
library(tidyverse)
library(lubridate)
library(scales)

# Source utility script
source("utils.R")

# 1. Load and clean data
rats <- clean_rats(load_rats("data/Rat_sightings.csv"))

# Filter for 2010 through 2025 (avoiding 2026 partial-year truncation)
rats_time_series <- rats %>%
  filter(sighting_year >= 2010, sighting_year <= 2025)

# Aggregate to daily counts per borough and compute a 30-day rolling average for smooth trend-lines
daily_borough_data <- rats_time_series %>%
  group_by(created_date = floor_date(parsed_date, "day"), borough) %>%
  summarize(daily_sightings = n(), .groups = "drop") %>%
  group_by(borough) %>%
  arrange(created_date) %>%
  mutate(smoothed_sightings = zoo::rollmean(daily_sightings, k = 30, fill = NA, align = "right")) %>%
  ungroup()

# 2. Plot 1: Detailed Daily Time Series with 30-Day Smoothing (2010–2025)
p1 <- ggplot(daily_borough_data, aes(x = created_date, y = smoothed_sightings, color = borough)) +
  geom_line(linewidth = 0.8, alpha = 0.9) +
  scale_y_continuous(labels = label_comma()) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  theme_minimal(base_size = 12) +
  labs(
    title = "Daily Trajectory of NYC Rat Sightings by Borough (30-Day Moving Average)",
    subtitle = "Tracking longitudinal growth and seasonal oscillations (2010–2025)",
    x = "Year",
    y = "Daily Sightings (Smoothed)",
    color = "Borough",
    caption = "Source: NYC 311 rat-sightings data."
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

print(p1)

# 3. Additional Plot: Year-over-Year Percentage Change in Annual Sightings (The Rate of Change)
annual_totals <- rats_time_series %>%
  group_by(sighting_year, borough) %>%
  summarize(total_sightings = n(), .groups = "drop") %>%
  group_by(borough) %>%
  arrange(sighting_year) %>%
  mutate(pct_change = (total_sightings - lag(total_sightings)) / lag(total_sightings) * 100) %>%
  ungroup()

p3 <- ggplot(annual_totals %>% filter(sighting_year > 2010), aes(x = sighting_year, y = pct_change, fill = borough)) +
  geom_col(position = "dodge", width = 0.7) +
  geom_hline(yintercept = 0, color = "black", linewidth = 0.5) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  scale_x_continuous(breaks = seq(2011, 2025, 2)) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Year-over-Year Percentage Change in Rat Sightings by Borough",
    subtitle = "Isolating annual acceleration and deceleration phases leading up to the 2023 intervention",
    x = "Year",
    y = "YoY Change (%)",
    fill = "Borough",
    caption = "Source: NYC 311 rat-sightings data."
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

print(p3)

# Save plots for memo inclusion
ggsave(filename = "rat_daily_timeseries.png", plot = p1, width = 10, height = 6, dpi = 300)
ggsave(filename = "rat_yoy_change.png", plot = p3, width = 10, height = 6, dpi = 300)

# 3. Plot 2: Monthly Seasonality (Averaged across 2021–2025)
seasonal_data <- summarize_by_month_seasonality(rats, start_year = 2021, end_year = 2025)

p2 <- ggplot(
  seasonal_data,
  aes(
    x = factor(
      sighting_month,
      levels = 1:12,
      labels = month.abb
    ),
    y = average_reports
  )
) +
  geom_col(
    width = 0.7
  ) +
  scale_y_continuous(
    labels = label_comma(),
    expand = expansion(mult = c(0, 0.05))
  ) +
  labs(
    title = "Monthly Pattern in NYC Rat-Sighting Reports",
    subtitle = "Average reports by month, 2021–2025",
    x = "Month",
    y = "Average Number of Reports",
    caption = "Source: NYC 311 rat-sightings data."
  ) +
  theme_bw() +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    plot.title = element_text(face = "bold")
  )

print(p2)
