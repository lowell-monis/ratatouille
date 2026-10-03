source("utils.R")

rats <- clean_rats(load_rats())
typeof(rats$parsed_date)
annual_borough_data <- summarize_by_year_borough(rats)

max_month <- 8 # August is the cutoff in this dataset update
comparable_annual_data <- rats %>%
  filter(sighting_month <= max_month, sighting_year >= 2010, sighting_year <= 2025) %>%
  group_by(sighting_year, borough) %>%
  summarize(total_sightings = n(), .groups = "drop")

p1 <- ggplot(comparable_annual_data, aes(x = sighting_year, y = total_sightings, color = borough)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.5) +
  theme_minimal(base_size = 12) +
  labs(
    title = "NYC Rat Sightings by Borough (Jan–Aug, 2010–2025)",
    subtitle = "Controlling for partial-year truncation in 2026",
    x = "Year",
    y = "Number of Sightings",
    color = "Borough"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  )

print(p1)

monthly_data <- rats %>%
  filter(sighting_year >= 2015, sighting_year <= 2025) %>%
  group_by(sighting_month) %>%
  summarize(avg_monthly_sightings = n() / n_distinct(sighting_year), .groups = "drop")

p2 <- ggplot(monthly_data, aes(x = factor(sighting_month, labels = month.abb), y = avg_monthly_sightings)) +
  geom_col(fill = "#2c3e50", width = 0.7) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Average Rat Sightings by Month (2015–2025)",
    subtitle = "Demonstrating peak activity during summer months",
    x = "Month",
    y = "Average Sightings"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank()
  )

print(p2)