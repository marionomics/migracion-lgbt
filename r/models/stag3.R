library(bacondecomp)
library(tidyverse)
library(haven)
library(lfe)

source("r/transform_database.R")

equal_marriage <- read.csv("auxiliary/equal_marriage.csv")
equal_marriage <- equal_marriage[, c(1, 6)]
names(equal_marriage) <- c("cve", "year_em")

names(df4) <- c("ent", "year", "migr", "equal_marriage", "from_equal", "from_non_equal", "unempl", "income", "lgbt", "discrim", "dm_migr", "dm_unemp", "dm_income", "Estado", "Vivienda")

df4 <- df4 %>%
  mutate(covid = ifelse(year %in% c(2020, 2021), 1, 0)) %>%
  left_join(equal_marriage, by = c("ent" = "cve")) %>%
  mutate(norm_year = year - year_em)

# Variables for fixed effects and interaction terms
fe_vars <- c("equal_marriage", "dm_unemp", "lgbt", "discrim", "Vivienda")
interaction_terms <- paste0(fe_vars, " * year")

# Model with 'from_equal' as the dependent variable
dd_formula_equal <- as.formula(paste("from_equal ~", paste(fe_vars, collapse = " + "), "+", paste(interaction_terms, collapse = " + "), "| year + ent | 0 | ent"))

dd_reg_equal <- felm(dd_formula_equal, data = df4)
summary(dd_reg_equal)

# Model with 'from_non_equal' as the dependent variable
dd_formula_non_equal <- as.formula(paste("from_non_equal ~", paste(fe_vars, collapse = " + "), "+", paste(interaction_terms, collapse = " + "), "| year + ent | 0 | ent"))

dd_reg_non_equal <- felm(dd_formula_non_equal, data = df4)
summary(dd_reg_non_equal)
