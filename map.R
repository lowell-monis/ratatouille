library(tidyverse)
library(sf)
library(tigris)
library(scales)

# Source your utility script
source("utils.R")

# 1. Load and clean rat data & NYC boundaries
rats_raw <- load_rats("data/Rat_sightings.csv")
rats <- clean_rats(rats_raw)
nyc_boroughs <- load_nyc_boroughs()

# 2. Select target years (e.g., 2021–2025)
target_years <- 2021:2025

# 3. Assign months to meteorological seasons and aggregate rat sightings by Borough, Year, and Season
borough_sightings_seasons <- rats %>%
  filter(sighting_year %in% target_years) %>%
  mutate(
    season = case_when(
      sighting_month %in% c(12, 1, 2)  ~ "Winter",
      sighting_month %in% c(3, 4, 5)   ~ "Spring",
      sighting_month %in% c(6, 7, 8)   ~ "Summer",
      sighting_month %in% c(9, 10, 11) ~ "Autumn"
    ),
    # Ensure correct chronological ordering of seasons in plots
    season = factor(season, levels = c("Spring", "Summer", "Autumn", "Winter"))
  ) %>%
  group_by(sighting_year, season, borough) %>%
  summarize(total_sightings = n(), .groups = "drop")

# 4. Expand grid to ensure every combination of year, season, and borough exists
all_combinations <- expand_grid(
  sighting_year = target_years,
  season = factor(c("Spring", "Summer", "Autumn", "Winter"), levels = c("Spring", "Summer", "Autumn", "Winter")),
  borough = unique(nyc_boroughs$borough)
)

map_data_seasons <- all_combinations %>%
  left_join(borough_sightings_seasons, by = c("sighting_year", "season", "borough")) %>%
  mutate(total_sightings = replace_na(total_sightings, 0)) %>%
  left_join(nyc_boroughs, by = "borough") %>%
  st_as_sf() %>%
  mutate(
    area_km2 = as.numeric(st_area(.)) / 1e6,
    sightings_per_km2 = total_sightings / area_km2
  )

# 5. Create Faceted Choropleth Map (Seasons across columns, Years down rows)
p_faceted_seasons <- ggplot(map_data_seasons) +
  geom_sf(aes(fill = sightings_per_km2), color = "white", linewidth = 0.3) +
  scale_fill_viridis_c(
    option = "plasma", 
    labels = label_comma(),
    name = "Sightings / km²"
  ) +
  facet_grid(sighting_year ~ season) +
  theme_minimal(base_size = 11) +
  labs(
    title = "Seasonal Evolution of Rat Density Across NYC Boroughs (2021–2025)",
    subtitle = "Faceted by Year (Rows) and Meteorological Season (Columns)",
    caption = "Source: NYC 311 & US Census Bureau (Tigris)"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    legend.position = "right",
    strip.text = element_text(face = "bold", size = 10)
  )

print(p_faceted_seasons)

# 6. Save the plot for your memo
ggsave(
  filename = "nyc_rats_seasons_faceted.png",
  plot = p_faceted_seasons,
  width = 11,
  height = 9,
  dpi = 300
)