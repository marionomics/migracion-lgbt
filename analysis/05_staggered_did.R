library(bacondecomp)
library(tidyverse)
library(haven)
library(lfe)

source("r/transform_database.R")

equal_marriage <- read.csv("auxiliary/equal_marriage.csv")
equal_marriage <- equal_marriage[, c(1, 6)]
names(equal_marriage) <- c("cve", "year_em")

# Load your dataset (df4)
df4 <- read.csv("path_to_your_dataset.csv") 

# Assuming your dataset has the same columns as shown earlier
names(df4) <- c("ent", "year", "migr", "equal_marriage",
                "from_equal", "from_non_equal", "unempl", "income", "lgbt",
                "discrim", "dm_migr", "dm_unemp", "dm_income", "Estado", "Vivienda")

df4 <- df4 %>%
  mutate(covid = ifelse(year %in% c(2020, 2021), 1, 0)) %>%
  left_join(equal_marriage, by = c("ent" = "cve")) %>%
  mutate(norm_year = year - year_em)

# Create interaction terms for lgbt and discrim with year
df4 <- df4 %>%
  mutate(across(starts_with("lgbt"), list(inter = ~ . * year), .names = "lgbt_{col}_{fn}"),
         across(starts_with("discrim"), list(inter = ~ . * year), .names = "discrim_{col}_{fn}"))

# Define your independent variables (excluding time-invariant variables)
xvar <- c("from_equal", "from_non_equal", "unempl", "income", "dm_migr", "dm_unemp", "dm_income", "Vivienda", "covid", "norm_year")

# Update formula to include interaction terms
interaction_terms <- c("lgbt * year", "discrim * year")
all_vars <- c(xvar, "equal_marriage", interaction_terms)

dd_formula <- as.formula(
  paste("migr ~ ",
        paste(all_vars, collapse = " + "),
        "| year + ent | 0 | ent"
  )
)

# Run the regression
dd_reg <- felm(dd_formula, data = df4)
summary(dd_reg)
