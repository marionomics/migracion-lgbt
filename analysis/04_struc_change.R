# install.packages(c("tidyverse", "strucchange", "fixest", "lmtest", "sandwich"))
library(tidyverse)
library(strucchange)
library(fixest)

# 1. Load Data
df <- read.csv("data/ENOE/final/lgbt_migration.csv")

# 2. Re-create the Legalization Year Mapping (Since we don't have the aux file)
# This allows us to center the time at t=0
em_years <- data.frame(
  ent = 1:32,
  year_em = c(2019, 2017, 2019, 2016, 2014, 2016, 2018, 2015, 2010, 2022, 
              2021, 2022, 2019, 2016, 2022, 2016, 2016, 2015, 2019, 2019, 
              2020, 2021, 2012, 2019, 2021, 2021, 2022, 2022, 2020, 2022, 
              2022, 2021)
)

df <- df %>%
  left_join(em_years, by = "ent") %>%
  mutate(
    # Create a continuous time variable
    time = year + (quarter - 1)/4,
    # Normalize time relative to legalization
    norm_time = time - year_em,
    # Create total migration variable
    total_migration = from_equal + from_non_equal,
    # Treatment Dummy (Post-Reform)
    post_treat = ifelse(norm_time >= 0, 1, 0)
  )

# ==============================================================================
# APPROACH 1: Aggregated Time Series Structural Break (The "Chow Test")
# ==============================================================================
# We aggregate data to one line (like your plot) and test for a break at t=0

df_agg <- df %>%
  group_by(norm_time) %>%
  summarise(avg_migration = mean(total_migration, na.rm = TRUE)) %>%
  filter(norm_time >= -5 & norm_time <= 5) # Focus on a +/- 5 year window

# Run a linear model with an interaction term (Chow Test equivalent)
# If 'post_treat' or the interaction is significant, there is a structural change.
chow_model <- lm(avg_migration ~ norm_time * I(norm_time >= 0), data = df_agg)

print("--- Aggregated Time Series Breakpoint Analysis ---")
summary(chow_model)

# Visualization of the structural breaks
# (This checks if the data suggests a break naturally, without us forcing t=0)
ts_mig <- ts(df_agg$avg_migration, start = -5, frequency = 4)
breakpoints_test <- breakpoints(ts_mig ~ 1)
plot(breakpoints_test)
title("Optimal Breakpoints in Migration Trend")


# ==============================================================================
# APPROACH 2: Panel Event Study (Difference-in-Differences)
# ==============================================================================
# This is the "Gold Standard" for your data structure.
# It checks: Did migration change in a state AFTER it passed the law, 
# compared to states that hadn't passed it yet?

print("--- Panel Event Study Results (DiD) ---")

# We use 'fixest' which is fast and handles fixed effects well
# Model: Migration ~ State FE + Time FE + Dynamic Treatment Effects
did_model <- feols(total_migration ~ i(round(norm_time), ref = -1) | ent + time,
                   cluster = ~ent,
                   data = df)

?feols
# Print concise results
print(did_model)

# Plot the coefficients (The "Event Study Plot")
# If the confidence intervals before 0 cross the line, the "parallel trends" assumption holds.
# If the points after 0 go up/down, that is your structural change effect.
iplot(did_model, 
      main = "Effect of Equal Marriage on Migration (Event Study)",
      xlab = "Years relative to reform",
      ylab = "Change in Migration Inflow")

# Simple DiD (Pre vs Post)
# Just testing the average effect after the law passed
simple_did <- feols(total_migration ~ post_treat | ent + time, 
                    cluster = ~ent, 
                    data = df)
summary(simple_did)
