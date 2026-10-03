```{r} 
  > library(tidyverse)
── Attaching core tidyverse packages ────── tidyverse 2.0.0 ──
✔ dplyr     1.1.4     ✔ readr     2.1.5
✔ forcats   1.0.0     ✔ stringr   1.5.1
✔ ggplot2   3.5.2     ✔ tibble    3.2.1
✔ lubridate 1.9.5     ✔ tidyr     1.3.1
✔ purrr     1.0.4     
── Conflicts ──────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
ℹ Use the conflicted package to force all conflicts to become errors
Warning message:
  package ‘lubridate’ was built under R version 4.4.3 
> library(lubridate)
> 
  > rats_raw <- read_csv(
    +     file.choose(),
    +     na = c("", "NA", "N/A"),
    +     show_col_types = FALSE
    + )
>                                                             
  > rats_clean <- rats_raw %>%
  +     rename(
    +         created_date = `Created Date`,
    +         borough = Borough
    +     ) %>%
  +     mutate(
    +         created_date = mdy_hms(created_date),
    +         sighting_year = year(created_date),
    +         sighting_month = month(created_date),
    +         borough = str_to_title(borough)
    +     ) %>%
  +     filter(
    +         borough %in% c(
      +             "Bronx",
      +             "Brooklyn",
      +             "Manhattan",
      +             "Queens",
      +             "Staten Island"
      +         )
    +     )
> 
  > stopifnot(!any(is.na(rats_clean$created_date)))
> 
  > rats_2021_2025 <- rats_clean %>%
  +     filter(
    +         sighting_year >= 2021,
    +         sighting_year <= 2025
    +     )
> 
  > seasonal_reports <- rats_2021_2025 %>%
  +     group_by(sighting_month) %>%
  +     summarise(
    +         average_reports = n() / 5,
    +         .groups = "drop"
    +     )
> 
  > bar_plot <- ggplot(
    +     seasonal_reports,
    +     aes(
      +         x = factor(
        +             sighting_month,
        +             levels = 1:12,
        +             labels = month.abb
        +         ),
      +         y = average_reports
      +     )
    + ) +
  +     geom_col(
    +         fill = "#0072B2",
    +         width = 0.7
    +     ) +
  +     scale_y_continuous(
    +         labels = scales::label_comma(),
    +         expand = expansion(mult = c(0, 0.05))
    +     ) +
  +     labs(
    +         title = "Monthly Pattern in NYC Rat-Sighting Reports",
    +         subtitle = "Average reports by month, 2021–2025",
    +         x = "Month",
    +         y = "Average Number of Reports",
    +         caption = "Source: NYC 311 rat-sightings data."
    +     ) +
  +     theme_minimal(base_size = 12) +
  +     theme(
    +         panel.grid.minor = element_blank(),
    +         panel.grid.major.x = element_blank(),
    +         plot.title = element_text(face = "bold"),
    +         plot.caption = element_text(hjust = 0)
    +     )
> 
  > bar_plot
```
