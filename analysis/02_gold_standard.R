# ==============================================================================
# Research Project: Legal Equality vs. Structural Immobility
# Paper Title: "Rights without Resources: Structural Immobility of the LGBT+ Population in Mexico"
# Data Source: INEGI - ENDISEG 2021
# ==============================================================================

# 1. Setup and Libraries
# ------------------------------------------------------------------------------
library(tidyverse)
library(survey)   # Essential for INEGI expansion factors
library(scales)   # For percentage formatting
library(ggthemes) # For clean academic plot styles

# Load Data
# Note: Replace 'conjunto_de_datos...' with your actual dataframe name
# endiseg <- read_csv("data/ENDISEG_WEB/conjunto_de_datos_tmodulo_endiseg_2021.csv")
# Assuming it is already loaded in your environment as 'endiseg'

# ==============================================================================
# 2. DEFINING THE "GOLD STANDARD" TREATMENT
# ==============================================================================
# Hypothesis: Migration only occurs to states with COMPREHENSIVE rights 
# (Marriage + Civil Unions + Adoption) enacted well before 2021.

# 09 - Ciudad de México (Pioneer: 2010)
# 05 - Coahuila (Early: 2014)
# 04 - Campeche (Early: 2016)
# 16 - Michoacán (Early: 2016)

gold_standard_codes <- c("09", "05", "04", "16")

# State Dictionary
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
# 3. FEATURE ENGINEERING
# ==============================================================================

df_analysis <- endiseg %>%
  mutate(
    # --- A. Demographics ---
    age = as.numeric(P4_1),
    factor = as.numeric(FACTOR),
    
    # --- B. Orientation Groups ---
    # P8_1: 1-3,6 = LGB+; 4-5 = Heterosexual
    orientation_group = case_when(
      P8_1 %in% c("1", "2", "3", "6") ~ "LGB+",
      P8_1 %in% c("4", "5") ~ "Heterosexual",
      TRUE ~ NA_character_
    ),
    
    # --- C. Mobility Cohorts (The "Time" Proxy) ---
    # Youth (<20) = Immobile Control (Anchored by parents)
    # Adults (25+) = Mobile Treatment (Can theoretically migrate)
    mobility_cohort = case_when(
      age >= 15 & age <= 19 ~ "0_Youth_Immobile",
      age >= 25 ~ "1_Adult_Mobile",
      TRUE ~ NA_character_ 
    ),
    
    # --- D. Treatment Status (Geography) ---
    ENT = str_pad(as.character(ENT), 2, pad = "0"), 
    
    # The Pivot: Comparing "Gold Standard" vs "The Rest"
    state_type = ifelse(ENT %in% gold_standard_codes, "Gold_Standard_State", "Rest_of_Mexico"),
    
    # --- E. Structural Rigidities ---
    # Education (Economic Capital Proxy)
    # NIV 5+ = College/Technical (High Capital)
    education_level = case_when(
      as.numeric(NIV) >= 5 ~ "High (College+)",
      as.numeric(NIV) >= 2 & as.numeric(NIV) < 5 ~ "Medium (Basic)",
      TRUE ~ "Low/None"
    ),
    
    # Family Support (Social Capital Proxy)
    # P8_4_1: 1=Accepted, 2/3=Rejected/Forced to change
    family_support = case_when(
      P8_4_1 == "1" ~ "Accepted",
      P8_4_1 %in% c("2", "3") ~ "Rejected",
      TRUE ~ "Not_Disclosed/NA"
    ),
    
    # --- F. Outcomes (Well-being) ---
    has_depression = ifelse(P10_1_3 == "1", 1, 0),
    suffered_discrimination = ifelse(P8_5 == "1", 1, 0)
  ) %>%
  left_join(state_names, by = "ENT") %>%
  filter(!is.na(orientation_group), !is.na(mobility_cohort))

# Create LGB+ Subset
df_lgb <- df_analysis %>% filter(orientation_group == "LGB+")

# ==============================================================================
# 4. SURVEY DESIGN OBJECT
# ==============================================================================
# This is crucial for correct standard errors and p-values
lgb_design <- svydesign(id = ~1, weights = ~factor, data = df_lgb)
full_design <- svydesign(id = ~1, weights = ~factor, data = df_analysis)

# ==============================================================================
# 5. ANALYSIS 1: THE GOLD STANDARD EFFECT (The "Positive" Result)
# ==============================================================================

# Calculate proportions
gold_stats <- svyby(
  formula = ~state_type, 
  by = ~mobility_cohort, 
  design = lgb_design, 
  FUN = svymean,
  vartype = "ci"
)

# Plotting the "Gold Standard" Pull Factor
plot_gold <- gold_stats %>%
  mutate(
    prop = state_typeGold_Standard_State,
    low = ci_l.state_typeGold_Standard_State,
    high = ci_u.state_typeGold_Standard_State,
    cohort_label_text = ifelse(mobility_cohort == "0_Youth_Immobile", "Youth (15-19)", "Adults (25+)"),
    cohort_label = factor(cohort_label_text, levels = c("Youth (15-19)", "Adults (25+)"))
  )

p_gold <- ggplot(plot_gold, aes(x = cohort_label, y = prop, group = 1)) +
  geom_errorbar(aes(ymin = low, ymax = high), width = 0.1, size = .7, color = "black") +
  geom_line(color = "#2c3e50", size = .7) + 
  geom_point(size = 3, color = "#2c3e50") +
  geom_text(aes(label = percent(prop, accuracy = 0.1)), vjust = -1.5, fontface = "bold", size = 3) +
  scale_y_continuous(labels = percent, limits = c(0, 0.25)) + 
  labs(
    #title = "Migration to 'Gold Standard' States",
    #subtitle = "Adults are significantly more concentrated in states with Full Rights (Marriage+CU+Adoption)",
    y = "Proportion Residing in states with equal rights",
    x = "Life Stage"
  ) +
  theme_hc()

print(p_gold)
ggsave("img/figure_gold_standard.png", p_gold, width = 6, height = 4)

# Statistical Test
print("--- MODEL 1: GOLD STANDARD MIGRATION ---")
model_gold <- svyglm(
  state_type == "Gold_Standard_State" ~ mobility_cohort, 
  design = lgb_design, 
  family = quasibinomial()
)
summary(model_gold)

# ==============================================================================
# 6. ANALYSIS 2: STRUCTURAL RIGIDITIES (The "Null" Result)
# ==============================================================================
# Testing if Education or Family Rejection explains migration

print("--- MODEL 2: STRUCTURAL RIGIDITIES ---")
model_structure <- svyglm(
  state_type == "Gold_Standard_State" ~ education_level + family_support + age, 
  design = lgb_design, 
  family = quasibinomial()
)
summary(model_structure)

# Visualize Education Levels (Brain Drain Check)
brain_drain_stats <- svyby(
  formula = ~education_level, 
  by = ~state_type, 
  design = lgb_design, 
  FUN = svymean
)

plot_brain <- brain_drain_stats %>%
  pivot_longer(cols = starts_with("education_level"), names_to = "level", values_to = "prop") %>%
  filter(str_detect(level, "High")) %>%
  mutate(state_type = ifelse(state_type == "Gold_Standard_State", "Full Rights", "Partial/No Rights"))

p_brain <- ggplot(plot_brain, aes(x = state_type, y = prop, fill = state_type)) +
  geom_col(width = 0.6, alpha = 0.8) +
  scale_fill_manual(values = c("Full Rights" = "#2c3e50", "Partial/No Rights" = "gray70")) +
  geom_text(aes(label = percent(prop, accuracy = 0.1)), vjust = -0.5, size = 5, fontface = "bold") +
  scale_y_continuous(labels = percent, limits = c(0, 0.6)) +
  labs(
    title = "Education Levels by Legal Regime",
    subtitle = "High Human Capital is equally distributed (No 'Brain Drain')",
    y = "% of LGB+ Population with College Degree",
    x = NULL
  ) +
  theme_hc() +
  theme(legend.position = "none")

print(p_brain)
# ggsave("figure_brain_drain.png", p_brain, width = 6, height = 4)

# ==============================================================================
# 7. ANALYSIS 3: THE CONTROL GROUP (Heterosexual Comparison)
# ==============================================================================
# Do straight people also move to "Gold Standard" states? (Economic Gravity Check)

comparison_stats <- svyby(
  formula = ~state_type, 
  by = ~mobility_cohort + orientation_group, 
  design = full_design, 
  FUN = svymean
)

plot_comp <- comparison_stats %>%
  filter(!is.na(mobility_cohort)) %>%
  mutate(
    prop = state_typeGold_Standard_State,
    cohort_label_text = ifelse(mobility_cohort == "0_Youth_Immobile", "Youth", "Adults"),
    cohort_label = factor(cohort_label_text, levels = c("Youth", "Adults"))
  )

p_comp <- ggplot(plot_comp, aes(x = cohort_label, y = prop, 
                                group = orientation_group, 
                                shape = orientation_group)) +
  geom_line(aes(linetype = orientation_group), size = 1, color = "black") +
  geom_point(size = 4, color = "black") +
  scale_shape_manual(values = c("Heterosexual" = 1, "LGB+" = 19)) +
  scale_linetype_manual(values = c("Heterosexual" = "dotted", "LGB+" = "solid")) +
  labs(
    #title = "Migration to Gold Standard States: LGB+ vs. Heterosexuals",
    #subtitle = "LGB+ adults show a stronger sorting effect than heterosexuals",
    y = "% Living in states with legal marriage, civil union recognition and adoption rights",
    x = "Life Stage",
    shape = "Group", linetype = "Group"
  ) +
  theme_minimal() +
  theme(legend.position = "top")

print(p_comp)
ggsave("img/figure_comparison.png", p_comp, width = 6, height = 4)


# ==============================================================================
# 5.4. THE "DIFFERENCE-IN-DIFFERENCES" TEST (LGB+ vs. Hetero)
# ==============================================================================

# We use the full design (LGB + Hetero)
# Model: Probability of living in Gold Standard State
# Predictors: Age Group + Orientation + (Age Group * Orientation)

model_did <- svyglm(
  state_type == "Gold_Standard_State" ~ mobility_cohort * orientation_group, 
  design = full_design, 
  family = quasibinomial()
)

print("--- MODEL 5: DiD INTERACTION (LGB+ vs HETERO) ---")
summary(model_did)

# Calculate Odds Ratios for interpretation
print("--- ODDS RATIOS ---")
exp(coef(model_did))


# ==============================================================================
# 5.4. THE SIMPLE DiD (Linear Probability Model)
# ==============================================================================

# We use 'family = gaussian()' instead of 'quasibinomial()'
# This forces R to treat it as a standard linear regression (OLS).
model_linear_did <- svyglm(
  state_type == "Gold_Standard_State" ~ mobility_cohort * orientation_group, 
  design = full_design, 
  family = gaussian()
)

print("--- MODEL 5: LINEAR DiD (COEFFICIENTS ARE % POINTS) ---")
summary(model_linear_did)



# ==============================================================================
# 5.5. ROBUST DESCRIPTIVE TABLE (With T-Tests)
# ==============================================================================

# 1. Calculate weighted means and standard errors for all 4 groups
group_stats <- svyby(
  formula = ~state_type, 
  by = ~mobility_cohort + orientation_group, 
  design = full_design, 
  FUN = svymean,
  vartype = c("se", "ci")
)

# 2. Extract specific values to build the comparison
# Filter for Gold Standard State outcome
# Note: The column name might be 'state_typeGold_Standard_State'
data_clean <- group_stats %>%
  select(mobility_cohort, orientation_group, 
         mean = state_typeGold_Standard_State, 
         se = se.state_typeGold_Standard_State,
         lower = ci_l.state_typeGold_Standard_State,
         upper = ci_u.state_typeGold_Standard_State)

# 3. Create the "Difference" function
# Z-test for two proportions: (P1 - P2) / sqrt(SE1^2 + SE2^2)
get_diff_test <- function(group_name) {
  sub <- data_clean %>% filter(orientation_group == group_name)
  
  # Youth values
  y_mean <- sub$mean[sub$mobility_cohort == "0_Youth_Immobile"]
  y_se   <- sub$se[sub$mobility_cohort == "0_Youth_Immobile"]
  
  # Adult values
  a_mean <- sub$mean[sub$mobility_cohort == "1_Adult_Mobile"]
  a_se   <- sub$se[sub$mobility_cohort == "1_Adult_Mobile"]
  
  # Difference
  diff <- a_mean - y_mean
  
  # Standard Error of the Difference
  diff_se <- sqrt(y_se^2 + a_se^2)
  
  # T-statistic and P-value (2-tailed)
  t_stat <- diff / diff_se
  p_val <- 2 * (1 - pnorm(abs(t_stat)))
  
  return(c(diff = diff, se = diff_se, p = p_val))
}

# 4. Calculate for both
hetero_test <- get_diff_test("Heterosexual")
lgb_test    <- get_diff_test("LGB+")

# 5. Construct the Final Table Frame
final_table <- data.frame(
  Group = c("Heterosexual", "LGB+"),
  Youth_Prop = c(
    data_clean$mean[data_clean$orientation_group=="Heterosexual" & data_clean$mobility_cohort=="0_Youth_Immobile"],
    data_clean$mean[data_clean$orientation_group=="LGB+" & data_clean$mobility_cohort=="0_Youth_Immobile"]
  ),
  Adult_Prop = c(
    data_clean$mean[data_clean$orientation_group=="Heterosexual" & data_clean$mobility_cohort=="1_Adult_Mobile"],
    data_clean$mean[data_clean$orientation_group=="LGB+" & data_clean$mobility_cohort=="1_Adult_Mobile"]
  ),
  Gap_Points = c(hetero_test["diff"], lgb_test["diff"]),
  Gap_SE = c(hetero_test["se"], lgb_test["se"]),
  P_Value = c(hetero_test["p"], lgb_test["p"])
)

# Formatting for display
final_table_formatted <- final_table %>%
  mutate(
    Youth_Prop = percent(Youth_Prop, 0.1),
    Adult_Prop = percent(Adult_Prop, 0.1),
    Gap_Points = percent(Gap_Points, 0.1),
    Gap_SE = paste0("(", percent(Gap_SE, 0.1), ")"),
    Significance = case_when(
      P_Value < 0.01 ~ "***",
      P_Value < 0.05 ~ "**",
      P_Value < 0.10 ~ "*",
      TRUE ~ "ns"
    )
  ) %>%
  select(Group, Youth_Prop, Adult_Prop, Gap_Points, Gap_SE, Significance)

print("--- FINAL PUBLICATION TABLE ---")
print(final_table_formatted)
