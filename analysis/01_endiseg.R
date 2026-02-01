# ==============================================================================
# Research Project: Legal Equality vs. Structural Immobility
# Script: Analysis of LGB+ Migration and Well-being in Mexico
# Data Source: INEGI - ENDISEG 2021
# ==============================================================================

# 1. Setup and Libraries
# ------------------------------------------------------------------------------
# Ensure packages are installed: install.packages(c("tidyverse", "survey", "scales", "ggthemes"))
library(tidyverse)
library(survey)   # Essential for INEGI expansion factors
library(scales)   # For percentage formatting
library(ggthemes) # For clean academic plot styles

# Load Data
# Note: Replace 'conjunto_de_datos...' with your actual dataframe name
# endiseg <- read_csv("")
# Assuming it is already loaded in your environment as 'endiseg'

# ==============================================================================
# 2. Data Cleaning & Variable Definition
# ==============================================================================

# Define "Early Adopter" States (Treatment Group)
# States that legalized Same-Sex Marriage (SSM) well before 2021
early_adopters_codes <- c(
  "09", "23", "05", "08", "18", "04", "14", "16", "17", 
  "07", "21", "01", "24", "19", "03", "20"
)

# State Name Dictionary (For the Plot)
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

df_analysis <- endiseg %>%
  mutate(
    # --- A. Demographic Variables ---
    age = as.numeric(P4_1),
    factor = as.numeric(FACTOR),
    
    # --- B. Define Target Populations ---
    # P8_1: 1-3,6 = LGB+; 4-5 = Heterosexual
    # Note: We group Trans+ (P9_1) here if they also selected LGB orientation, 
    # but strictly following P8_1 for consistency with your previous code.
    orientation_group = case_when(
      P8_1 %in% c("1", "2", "3", "6") ~ "LGB+",
      P8_1 %in% c("4", "5") ~ "Heterosexual",
      TRUE ~ NA_character_
    ),
    
    # --- C. Define Mobility Cohorts (Synthetic Panel) ---
    # Youth (<20) = Immobile Control (Living with parents)
    # Adults (25+) = Mobile Treatment (Can vote with feet)
    mobility_cohort = case_when(
      age >= 15 & age <= 19 ~ "0_Youth_Immobile",
      age >= 25 ~ "1_Adult_Mobile",
      TRUE ~ NA_character_ # Exclude 20-24 as transition years
    ),
    
    # --- D. Define Treatment Status (Geography) ---
    ENT = str_pad(as.character(ENT), 2, pad = "0"), 
    state_type = ifelse(ENT %in% early_adopters_codes, "Treatment_State", "Control_State"),
    
    # --- E. Outcome Variables (Well-being) ---
    # Depression (P10_1_3): 1=Yes, 2=No
    has_depression = ifelse(P10_1_3 == "1", 1, 0),
    # Discrimination (P8_5): 1=Yes, 2=No (Past 12 months)
    suffered_discrimination = ifelse(P8_5 == "1", 1, 0)
  ) %>%
  left_join(state_names, by = "ENT") %>%
  filter(!is.na(orientation_group))

# Create LGB+ Subset
df_lgb <- df_analysis %>% filter(orientation_group == "LGB+")

# ==============================================================================
# 3. Survey Design Object
# ==============================================================================
# CRITICAL: This accounts for the sampling weights (FACTOR).
# Without this, all p-values and percentages are wrong.

full_design <- svydesign(id = ~1, weights = ~factor, data = df_analysis)
lgb_design  <- subset(full_design, orientation_group == "LGB+")

# ==============================================================================
# 4. PLOT 1: Prevalence of LGB+ Population by State (Replication)
# ==============================================================================
# This replicates the horizontal bar chart from your image.

# Calculate weighted percentage of LGB+ people per state
state_stats <- svyby(~orientation_group, ~state_name, full_design, svymean)

# Clean and format for plotting
plot_data_map <- state_stats %>%
  select(state_name, share_lgb = `orientation_groupLGB+`) %>%
  arrange(desc(share_lgb))

# Generate the Plot
p1 <- ggplot(plot_data_map, aes(x = reorder(state_name, share_lgb), y = share_lgb * 100)) +
  geom_col(fill = "gray50", width = 0.8) +
  coord_flip() +
  scale_y_continuous(breaks = seq(0, 10, 1), limits = c(0, 9)) +
  labs(
    #title = "Percentage of Population Identifying as LGB+ by State",
    #subtitle = "States like Colima and Yucatán show highest prevalence",
    x = NULL,
    y = "Percentage (%)",
    #caption = "Source: Authors' elaboration with data from ENDISEG 2021"
  ) +
  theme_minimal() +
  theme(
    panel.grid.major.y = element_blank(),
    axis.text.y = element_text(size = 9),
    plot.title = element_text(face = "bold")
  )

print(p1)
ggsave("img/figure1_prevalence.png", p1, width = 8, height = 6)


# ==============================================================================
# 5. PLOT 2: The "Null Result" (Structural Immobility) - CORRECTED
# ==============================================================================

# Calculate weighted proportions with 95% Confidence Intervals
migration_stats <- svyby(
  formula = ~state_type, 
  by = ~mobility_cohort, 
  design = lgb_design, 
  FUN = svymean,
  vartype = "ci" # This generates the confidence intervals
)

# Prepare data for ggplot
plot_data_null <- migration_stats %>%
  filter(!is.na(mobility_cohort)) %>%
  mutate(
    prop = state_typeTreatment_State,
    # Extract CIs explicitly. The column names from svyby usually match the formula response.
    # We use 'state_typeTreatment_State' because that is the column name R generates for the 'Yes' dummy.
    low  = ci_l.state_typeTreatment_State,
    high = ci_u.state_typeTreatment_State,
    
    # Create the label
    cohort_label_text = ifelse(mobility_cohort == "0_Youth_Immobile", "Youth (15-19)", "Adults (25+)"),
    
    # FIX: Force the order so Youth appears on the Left
    cohort_label = factor(cohort_label_text, levels = c("Youth (15-19)", "Adults (25+)"))
  )

p2 <- ggplot(plot_data_null, aes(x = cohort_label, y = prop, group = 1)) +
  # 1. Draw the error bars first so they are behind the points
  geom_errorbar(aes(ymin = low, ymax = high), width = 0.1, size = 1.2, color = "#2c3e50") +
  # 2. Draw the connecting line
  geom_line(color = "gray70", size = 1.2) +
  # 3. Draw the points on top
  geom_point(size = 6, color = "#2c3e50") +
  # 4. Add the text labels slightly above the points
  geom_text(aes(label = percent(prop, accuracy = 0.1)), vjust = -2, fontface = "bold", size = 5) +
  # 5. formatting
  scale_y_continuous(labels = percent, limits = c(0.40, 0.60)) + # Expanded limits to ensure bars fit
  labs(
    #title = "Regional Distribution of LGB+ Population by Age",
    #subtitle = "Overlapping Confidence Intervals indicate NO significant migration to Safe States",
    y = "Proportion Residing in 'Early Adopter' States",
    x = "Life Stage"
  ) +
  theme_hc() +
  theme(plot.subtitle = element_text(color = "gray40"))

print(p2)
ggsave("img/figure2_structural_immobility.png", p2, width = 7, height = 5)


# ==============================================================================
# 6. PLOT 3: The Economic Gravity Check (Hetero vs LGB+)
# ==============================================================================
# Shows that Heterosexuals move to these states at similar rates (likely for jobs).

# Calculate proportion living in Treatment States for BOTH groups
comparison_stats <- svyby(
  formula = ~state_type, 
  by = ~mobility_cohort + orientation_group, 
  design = full_design, 
  FUN = svymean
)

plot_data_comp <- comparison_stats %>%
  filter(!is.na(mobility_cohort)) %>%
  mutate(
    prop = state_typeTreatment_State,
    # Create Labels
    cohort_label_text = ifelse(mobility_cohort == "0_Youth_Immobile", "Youth", "Adults"),
    # Force the order again
    cohort_label = factor(cohort_label_text, levels = c("Youth", "Adults"))
  )

p3 <- ggplot(plot_data_comp, aes(x = cohort_label, y = prop, color = orientation_group, group = orientation_group)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  scale_color_manual(values = c("Heterosexual" = "gray60", "LGB+" = "#c0392b")) +
  labs(
    #title = "Migration Patterns: LGB+ vs. Heterosexuals",
    #subtitle = "Parallel slopes suggest economic gravity outweighs rights-based migration",
    y = "% Living in Early Adopter States",
    x = "Life Stage",
    color = "Group"
  ) +
  theme_minimal() +
  theme(legend.position = "top")

print(p3)
# ggsave("figure3_comparison.png", p3, width = 6, height = 4)


# ==============================================================================
# 7. STATISTICAL MODELS (Tables for the Paper)
# ==============================================================================

# Model 1: Migration (The Null Result)
# Does Age predict living in a Treatment State for LGB+ people?
model_migration <- svyglm(
  state_type == "Treatment_State" ~ mobility_cohort, 
  design = lgb_design, 
  family = quasibinomial()
)
print("--- MODEL 1: MIGRATION ---")
summary(model_migration)

# Model 2: Depression (Outcomes)
# Does living in a Treatment State reduce depression risk?
model_depression <- svyglm(
  has_depression ~ state_type + age + mobility_cohort, 
  design = lgb_design, 
  family = quasibinomial()
)
print("--- MODEL 2: DEPRESSION ---")
summary(model_depression)

# Model 3: Discrimination (Outcomes)
# Does living in a Treatment State reduce discrimination?
model_discrim <- svyglm(
  suffered_discrimination ~ state_type + age + mobility_cohort, 
  design = lgb_design, 
  family = quasibinomial()
)
print("--- MODEL 3: DISCRIMINATION ---")
summary(model_discrim)


# ==============================================================================
# 8. EXTENSION: Structural Rigidities Analysis
# ==============================================================================

# 1. Feature Engineering
df_structural <- df_lgb %>%
  mutate(
    # --- Social Networks: Family Support ---
    # P8_4_1: 1=Accepted, 2=Obliged to fix, 3=Molested/Aggressed
    # We combine 2 and 3 into "Rejection"
    family_support = case_when(
      P8_4_1 == "1" ~ "Accepted",
      P8_4_1 %in% c("2", "3") ~ "Rejected",
      TRUE ~ "Not_Disclosed/NA"
    ),
    
    # --- Economic Capital: Education (Proxy) ---
    # NIV: 00-01(None/Preschool), 02(Primary), 03(Secondary), 04(High School), 
    # 05-09(Technical/Normal/College), 10(Master/PhD)
    # Simplified: Low (<High School) vs High (College+)
    education_level = case_when(
      as.numeric(NIV) >= 5 ~ "High (College+)",
      as.numeric(NIV) >= 2 & as.numeric(NIV) < 5 ~ "Medium (Basic)",
      TRUE ~ "Low/None"
    ),
    
    # --- Labor Market: Employment Status ---
    # P4_2: 1=Worked, 2=Job but didn't work, 3=Looked for work, 4=Student, 5=Home, 6=Cant work
    is_employed = ifelse(P4_2 %in% c("1", "2"), "Employed", "Unemployed/Inactive")
  )

# 2. Update Design with new variables
structural_design <- svydesign(id = ~1, weights = ~factor, data = df_structural)

# 3. Model 4: The "Brain Drain & Support" Model
# Does having High Education or Family Rejection predict living in a Safe State?
model_structure <- svyglm(
  state_type == "Treatment_State" ~ education_level + family_support + age, 
  design = structural_design, 
  family = quasibinomial()
)

print("--- MODEL 4: STRUCTURAL RIGIDITIES ---")
summary(model_structure)

# ==============================================================================
# FIXED PLOT 4: Evidence of "Brain Drain" (or lack thereof)
# ==============================================================================

# 1. Calculate the stats
brain_drain_stats <- svyby(
  formula = ~education_level, 
  by = ~state_type, 
  design = structural_design, 
  FUN = svymean
)

# 2. Reshape Data (This fixes the "empty plot" issue)
plot_data_brain <- brain_drain_stats %>%
  pivot_longer(
    cols = starts_with("education_level"), 
    names_to = "level", 
    values_to = "prop"
  ) %>%
  # Filter only for the "High" education group to keep it simple
  filter(str_detect(level, "High")) %>%
  # Clean up the state names for the legend
  mutate(state_type = ifelse(state_type == "Treatment_State", "Early Adopter", "Late Adopter"))

# 3. Generate Plot
p4 <- ggplot(plot_data_brain, aes(x = state_type, y = prop, fill = state_type)) +
  geom_col(width = 0.6, alpha = 0.8) +
  scale_fill_manual(values = c("Early Adopter" = "#2c3e50", "Late Adopter" = "gray70")) +
  geom_text(aes(label = percent(prop, accuracy = 0.1)), vjust = -0.5, size = 5, fontface = "bold") +
  scale_y_continuous(labels = percent, limits = c(0, 0.6)) +
  labs(
    title = "Education Levels by State Type",
    subtitle = "No significant 'Brain Drain': High education levels are similar across regions",
    y = "% of LGB+ Population with College Degree",
    x = NULL
  ) +
  theme_hc() +
  theme(legend.position = "none")

print(p4)
# ggsave("figure4_education.png", p4, width = 6, height = 4)

# ==============================================================================
# End of Script
# ==============================================================================