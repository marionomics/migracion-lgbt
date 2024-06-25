library(bacondecomp)
library(tidyverse)
library(haven)
library(lfe)


source("r/transform_database.R")


equal_marriage <- read.csv("auxiliary/equal_marriage.csv")
equal_marriage <- equal_marriage[,c(1,6)]
names(equal_marriage) <- c("cve", "year_em")

names(df4) <- c("ent", "year", "migr", "equal_marriage",
                "from_equal", "from_non_equal", "unempl", "income", "lgbt",
                "discrim", "dm_migr", "dm_unemp", "dm_income", "Estado", "Vivienda")

df4 <- df4 %>%
  mutate(covid = ifelse(year %in% c(2020,2021), 1, 0)) %>%
  left_join(equal_marriage, by = c("ent" = "cve")) %>%
  mutate(norm_year = year - year_em)

head(df4)


dd_formula <- as.formula(
  paste(" ~ ",
        paste(
          paste(xvar, collapse = " + "),
          paste("equal_marriage", collapse = " + "), sep = " + "),
        "| year + ent | 0 | ent"
  )
)

dd_reg <- felm(dd_formula, weights = castle$popwt, data = castle)
summary(dd_reg)
