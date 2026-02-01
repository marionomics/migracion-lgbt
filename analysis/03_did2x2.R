# ==============================================================================
# Research Project: Legal Equality vs. Structural Immobility
# Script: 2x2 Difference-in-Differences (OLS)
# ==============================================================================

# 1. Setup
library(tidyverse)
library(survey)
library(scales)
library(ggthemes)

# Load Data (Assuming 'endiseg' is loaded)
# endiseg <- read_csv("your_data.csv")

# ==============================================================================
# 2. DEFINITIONS
# ==============================================================================

# "Gold Standard" States (Marriage + CU + Adoption before 2021)
gold_standard_codes <- c("09", "05", "04", "16") # CDMX, Coahuila, Campeche, Michoacán

# State Names Dictionary
state_names <- tibble(
  ENT = sprintf("%02d", 1:32),
  state_name = c("Aguascalientes", "Baja California", "Baja California Sur", "Campeche", 
                 "Coahuila", "Colima", "Chiapas", "Chihuahua", "Ciudad de México", 
                 "Durango", "Guanajuato", "Guerrero", "Hidalgo", "Jalisco", 
                 "Estado de México", "Michoacán", "Morelos", "Nayarit", "Nuevo León", 
                 "Oaxaca", "Puebla", "Querétaro", "Quintana Roo", "San Luis Potosí", 
                 "Sinaloa", "Sonora", "Tabasco", "Tamaulipas", "Tlaxcala", 
                 "Veracruz", "Yucatán", "Zacatecas")
)

# ==============================================================================
# 3. DATA CLEANING
# ==============================================================================

df_analysis <- endiseg %>%
  mutate(
    age = as.numeric(P4_1),
    factor = as.numeric(FACTOR),
    
    # 1. Groups (LGB+ vs Hetero)
    orientation_group = case_when(
      P8_1 %in% c("1", "2", "3", "6") ~ "LGB+",
      P8_1 %in% c("4", "5") ~ "Heterosexual",
      TRUE ~ NA_character_
    ),
    
    # 2. Cohorts (Youth vs Adult) - Excludes 20-24
    mobility_cohort = case_when(
      age >= 15 & age <= 19 ~ "0_Youth_Immobile",
      age >= 25 ~ "1_Adult_Mobile",
      TRUE ~ NA_character_ 
    ),
    
    # 3. Outcome (Living in Gold Standard State)
    ENT = str_pad(as.character(ENT), 2, pad = "0"),
    # We create a numeric 0/1 variable for OLS
    in_gold_standard = ifelse(ENT %in% gold_standard_codes, 1, 0) 
  ) %>%
  filter(!is.na(orientation_group), !is.na(mobility_cohort))

# ==============================================================================
# 4. SURVEY DESIGN
# ==============================================================================
full_design <- svydesign(id = ~1, weights = ~factor, data = df_analysis)

# ==============================================================================
# 5. THE PLOT (Means + Error Bars)
# ==============================================================================

# Calculate percentages and Confidence Intervals
plot_stats <- svyby(
  formula = ~in_gold_standard, 
  by = ~mobility_cohort + orientation_group, 
  design = full_design, 
  FUN = svymean,
  vartype = "ci" # Creates ci_l and ci_u
)

# Prepare for plotting
plot_data <- plot_stats %>%
  mutate(
    # Friendly Labels
    cohort_label = ifelse(mobility_cohort == "0_Youth_Immobile", "Youth (15-19)", "Adults (25+)"),
    cohort_label = factor(cohort_label, levels = c("Youth (15-19)", "Adults (25+)")),
    # Rename for ease
    mean = in_gold_standard,
    low = ci_l,
    high = ci_u
  )

# The Plot
p_did <- ggplot(plot_data, aes(x = cohort_label, y = mean, 
                               group = orientation_group, 
                               shape = orientation_group)) +
  # Error Bars
  geom_errorbar(aes(ymin = low, ymax = high), width = 0.1, size = 0.8, color = "gray30") +
  # Lines
  geom_line(aes(linetype = orientation_group), size = 1, color = "black") +
  # Points
  geom_point(size = 4, color = "black", fill = "white") +
  # Scales
  scale_shape_manual(values = c("Heterosexual" = 1, "LGB+" = 19)) +
  scale_linetype_manual(values = c("Heterosexual" = "dotted", "LGB+" = "solid")) +
  scale_y_continuous(labels = percent, limits = c(0, 0.20)) + 
  # Labels
  labs(
    title = "Migration to 'Gold Standard' States",
    subtitle = "The gap between Youth and Adults is significantly larger for LGB+ people",
    y = "% Living in Gold Standard States",
    x = "Life Stage",
    shape = "Group", linetype = "Group"
  ) +
  theme_hc() +
  theme(legend.position = "top")

print(p_did)
ggsave("img/did_plot.png", p_did, width = 6, height = 4)

# ==============================================================================
# 6. THE STATISTICAL TEST (OLS 2x2 Difference)
# ==============================================================================

# This OLS regression IS the T-test for the 2x2 difference.
# Interaction Term = (LGB_Adult - LGB_Youth) - (Hetero_Adult - Hetero_Youth)

model_ols <- svyglm(
  in_gold_standard ~ mobility_cohort * orientation_group, 
  design = full_design, 
  family = gaussian() # This makes it OLS (Linear Probability Model)
)

print("--- OLS DIFFERENCE-IN-DIFFERENCES RESULTS ---")
summary(model_ols)

# ==============================================================================
# 7. GENERATE THE SIMPLE TABLE (With T-Stats)
# ==============================================================================

# Extract coefficients from the OLS model
coefs <- summary(model_ols)$coefficients

# Build a clean table manually
# 1. Baseline (Hetero Youth)
base <- coefs["(Intercept)", "Estimate"]

# 2. Hetero Gap (Adult - Youth)
hetero_gap <- coefs["mobility_cohort1_Adult_Mobile", "Estimate"]
hetero_pval <- coefs["mobility_cohort1_Adult_Mobile", "Pr(>|t|)"]

# 3. LGB Gap (Adult - Youth)
# In OLS with interaction: LGB_Gap = Hetero_Gap + Interaction_Term
interaction <- coefs["mobility_cohort1_Adult_Mobile:orientation_groupLGB+", "Estimate"]
interaction_pval <- coefs["mobility_cohort1_Adult_Mobile:orientation_groupLGB+", "Pr(>|t|)"]
lgb_gap <- hetero_gap + interaction

# Create the dataframe
results_table <- data.frame(
  Group = c("Heterosexual", "LGB+"),
  Youth_Pct = c(base, base + coefs["orientation_groupLGB+", "Estimate"]),
  Adult_Pct = c(base + hetero_gap, base + coefs["orientation_groupLGB+", "Estimate"] + lgb_gap),
  Migration_Gap = c(hetero_gap, lgb_gap),
  DiD_Premium = c("-", sprintf("+%.1f%% (p=%.3f)", interaction*100, interaction_pval))
)

# Convert to percentages for display
results_table$Youth_Pct <- percent(results_table$Youth_Pct, 0.1)
results_table$Adult_Pct <- percent(results_table$Adult_Pct, 0.1)
results_table$Migration_Gap <- percent(results_table$Migration_Gap, 0.1)

print("--- FINAL 2x2 TABLE ---")
print(results_table)
