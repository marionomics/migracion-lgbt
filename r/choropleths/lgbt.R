library(tidyverse)
library(mxmaps)

lgbt <- read.csv("data/ENDISEG_WEB/final/lgbt.csv")

data(mxstate.map)
mxstate.map$ent <- as.integer(mxstate.map$region)
map_df <- mxstate.map %>% left_join(lgbt, by = "ent")

# Polygon mean centroids for label placement
cents <- mxstate.map %>%
    group_by(region) %>%
    summarise(long = mean(long), lat = mean(lat), .groups = "drop") %>%
    mutate(ent = as.integer(region)) %>%
    left_join(lgbt, by = "ent")

# External anchor points for small states whose labels go outside the Republic
# Colima → Pacific Ocean SW; CDMX → Gulf of Mexico E; Querétaro → Gulf of California NW
ext <- tribble(
    ~ent, ~ext_lon, ~ext_lat,
       6,  -109.5,    17.5,
       9,   -89.5,    20.0,
      22,  -112.5,    23.5
)

labels_df <- cents %>%
    left_join(ext, by = "ent") %>%
    mutate(
        is_small = ent %in% c(6, 9, 22),
        lbl_lon  = coalesce(ext_lon, long),
        lbl_lat  = coalesce(ext_lat, lat),
        label    = format(round(percentage_lgbt, 1), nsmall = 1)
    )

p <- ggplot() +
    geom_polygon(
        data = map_df,
        aes(x = long, y = lat, group = group, fill = percentage_lgbt),
        color = "white", size = 0.2
    ) +
    scale_fill_gradient(
        low    = "#d0d0d0",
        high   = "#1a1a1a",
        name   = "Percentage",
        limits = c(3.1, 8.5),
        breaks = c(3.1, 8.5),
        labels = c("3.1", "8.5"),
        guide  = guide_colorbar(
            direction      = "horizontal",
            title.position = "top",
            title.hjust    = 0.5,
            barwidth       = 5,
            barheight      = 0.5
        )
    ) +
    # Leader lines from state centroid to external label
    geom_segment(
        data = filter(labels_df, is_small),
        aes(x = long, y = lat, xend = ext_lon, yend = ext_lat),
        color = "black", size = 0.35
    ) +
    # In-state labels
    geom_text(
        data = filter(labels_df, !is_small),
        aes(x = lbl_lon, y = lbl_lat, label = label),
        size = 2.5, color = "white"
    ) +
    # External labels for the three small states
    geom_text(
        data = filter(labels_df, is_small),
        aes(x = lbl_lon, y = lbl_lat, label = label),
        size = 2.5, color = "black"
    ) +
    coord_map("mercator", xlim = c(-118, -86.5), ylim = c(13.0, 33.0)) +
    theme_void() +
    theme(
        legend.position = "top",
        legend.title    = element_text(size = 9),
        legend.text     = element_text(size = 8),
        plot.background = element_rect(fill = "white", color = NA),
        plot.margin     = margin(10, 10, 10, 10)
    )

ggsave("img/lgbt_choropleth.png", p, width = 8, height = 6, dpi = 300, bg = "white")
cat("Saved: img/lgbt_choropleth.png\n")
