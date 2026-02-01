# ==============================================================================
# Research Project: LGB+ Migration and Well-being in Mexico (ENDISEG 2021)
# ==============================================================================
# Objective: Explore if Marriage Equality laws act as a "pull factor" for 
#            LGB+ migration by comparing age cohorts (Synthetic Cohort DiD)
#            and analyzing well-being outcomes (Discrimination/Depression).
#
# Data Source: INEGI - Encuesta Nacional sobre Diversidad Sexual y de Género (2021)
# ==============================================================================

# 1. Setup and Libraries
# ------------------------------------------------------------------------------
library(tidyverse)
library(survey)   # Essential for handling ENDISEG expansion factors (weights)
library(scales)   # For percentage formatting in plots

# Load Data (Assuming dataset is loaded as 'conjunto_de_datos_tmodulo_endiseg_2021')
endiseg <- read.csv("data/conjunto_de_datos_endiseg_2021_csv/conjunto_de_datos_tmodulo_endiseg_2021/conjunto_de_datos/conjunto_de_datos_tmodulo_endiseg_2021.csv")


# ==============================================================================
# 2. Data Cleaning & Variable Definition
# ==============================================================================

# Define "Early Adopter" States (Treatment Group)
# These states legalized Same-Sex Marriage (SSM) well before the 2021 survey,
# allowing time for potential migration.
# Codes: 09(CDMX), 05(Coahuila), 18(Nayarit), 14(Jalisco), etc.
early_adopters_codes <- c(
  "09", "23", "05", "08", "18", "04", "14", "16", "17", 
  "07", "21", "01", "24", "19", "03", "20"
)

df_analysis <- endiseg %>%
  mutate(
    # --- A. Demographic Variables ---
    age = as.numeric(P4_1),
    factor = as.numeric(FACTOR),
    
    # --- B. Define Target Population (LGB+) vs Control (Heterosexual) ---
    # P8_1: 1-3,6 = LGB+; 4-5 = Heterosexual
    orientation_group = case_when(
      P8_1 %in% c("1", "2", "3", "6") ~ "LGB+",
      P8_1 %in% c("4", "5") ~ "Heterosexual",
      TRUE ~ NA_character_
    ),
    
    # --- C. Define Mobility Cohorts (The "Time" Dimension) ---
    # Hypothesis: Youth (<20) are immobile (live where parents live).
    #             Adults (25+) are mobile (can vote with their feet).
    mobility_cohort = case_when(
      age >= 15 & age <= 19 ~ "0_Youth_Immobile",
      age >= 25 ~ "1_Adult_Mobile",
      TRUE ~ NA_character_ # Exclude 20-24 (transition years)
    ),
    
    # --- D. Define Treatment Status (Geographic Dimension) ---
    ENT = str_pad(as.character(ENT), 2, pad = "0"), 
    state_type = ifelse(ENT %in% early_adopters_codes, "Treatment_State", "Control_State"),
    
    # --- E. Outcome Variables (Well-being) ---
    # Depression (P10_1_3): 1=Yes, 2=No
    has_depression = ifelse(P10_1_3 == "1", 1, 0),
    # Discrimination (P8_5): 1=Yes, 2=No (Past 12 months)
    suffered_discrimination = ifelse(P8_5 == "1", 1, 0)
  ) %>%
  # Filter for analysis: valid orientation and age groups
  filter(!is.na(orientation_group), !is.na(mobility_cohort))

# Create a specific subset for LGB+ analysis only
df_lgb <- df_analysis %>% filter(orientation_group == "LGB+")

# ==============================================================================
# 3. Survey Design Object
# ==============================================================================
# Important: All subsequent stats must use this design to account for weights.
lgb_design <- svydesign(
  id = ~1, 
  weights = ~factor, 
  data = df_lgb
)

# ==============================================================================
# 4. Analysis 1: The Migration Hypothesis (Null Result)
# ==============================================================================
# Question: Do LGB+ Adults live in Treatment States at higher rates than Youth?

# Calculate weighted proportions with 95% Confidence Intervals
migration_stats <- svyby(
  formula = ~state_type, 
  by = ~mobility_cohort, 
  design = lgb_design, 
  FUN = svymean,
  vartype = "ci"
)

print("Migration Stats (Proportion living in Treatment/Control by Age):")
print(migration_stats)

# Result Interpretation:
# If CI overlap between Youth and Adults for 'Treatment_State', 
# migration is not statistically significant.

# ==============================================================================
# 5. Analysis 2: Robustness Check (Excluding CDMX)
# ==============================================================================
# CDMX (09) is a massive economic outlier. We check if results hold without it.

df_no_cdmx <- df_lgb %>% filter(ENT != "09")
design_no_cdmx <- svydesign(id = ~1, weights = ~factor, data = df_no_cdmx)

migration_stats_no_cdmx <- svyby(
  formula = ~state_type, 
  by = ~mobility_cohort, 
  design = design_no_cdmx, 
  FUN = svymean,
  vartype = "ci"
)

print("Robustness Check (No CDMX):")
print(migration_stats_no_cdmx)

# ==============================================================================
# 6. Analysis 3: The "Control Group" Comparison (Descriptive)
# ==============================================================================
# Compare LGB+ migration trends vs Heterosexual migration trends.
# If slopes are parallel, movement is likely economic, not rights-based.

comparison_summary <- df_analysis %>%
  group_by(orientation_group, mobility_cohort, state_type) %>%
  summarise(total_pop = sum(factor, na.rm = TRUE)) %>%
  ungroup() %>%
  group_by(orientation_group, mobility_cohort) %>%
  mutate(share_in_state = total_pop / sum(total_pop)) %>%
  filter(state_type == "Treatment_State")

ggplot(comparison_summary, aes(x = mobility_cohort, y = share_in_state, 
                               group = orientation_group, color = orientation_group)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  geom_text(aes(label = percent(share_in_state, accuracy = 0.1)), vjust = -1) +
  scale_y_continuous(labels = percent, limits = c(0.4, 0.6)) +
  labs(title = "Migration Patterns: LGB+ vs Heterosexuals",
       subtitle = "Similar slopes suggest economic factors outweigh legal factors",
       y = "% Living in Inclusive States", x = "Cohort") +
  theme_minimal()

# ==============================================================================
# 7. Analysis 4: Well-being Outcomes (Depression & Discrimination)
# ==============================================================================
# Question: Does living in a 'Treatment State' reduce negative outcomes?

# Model A: Discrimination
# Controlling for age, does State Type predict discrimination?
model_discrim <- svyglm(suffered_discrimination ~ state_type + age, 
                        design = lgb_design, 
                        family = quasibinomial())

print("Model: Discrimination Risks")
summary(model_discrim) 
# Look for 'state_typeTreatment_State' p-value. >0.05 indicates no protection effect.

# Model B: Depression
model_depression <- svyglm(has_depression ~ state_type + age, 
                           design = lgb_design, 
                           family = quasibinomial())

print("Model: Depression Risks")
summary(model_depression)

# ==============================================================================
# 8. Final Visualization (The "Descriptive Stability" Plot)
# ==============================================================================
# This is the key visual for the paper showing the overlap (Null Result).

# Extract the relevant rows for plotting (Treatment State proportions)
plot_data <- migration_stats %>%
  # Filter is tricky with svyby output, usually easier to rebuild or index carefully.
  # Here we manually extract the "Treatment_State" columns for clarity
  transmute(
    cohort = mobility_cohort,
    prop = state_typeTreatment_State,
    ci_l = ci_l.state_typeTreatment_State,
    ci_u = ci_u.state_typeTreatment_State
  )

ggplot(plot_data, aes(x = cohort, y = prop, fill = cohort)) +
  geom_col(alpha = 0.7, width = 0.5) +
  geom_errorbar(aes(ymin = ci_l, ymax = ci_u), width = 0.1, size = 1) +
  scale_y_continuous(labels = percent, limits = c(0, 0.6)) +
  labs(
    title = "Regional Distribution of LGB+ Population",
    subtitle = "Overlapping Confidence Intervals indicate descriptive stability across generations",
    y = "Proportion residing in Marriage-Equality States",
    x = "Age Cohort",
    caption = "Source: ENDISEG 2021. Error bars represent 95% CI."
  ) +
  theme_minimal() +
  theme(legend.position = "none")

