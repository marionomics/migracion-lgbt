library(estimatr)

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

fe_formula <- as.formula("from_equal ~ equal_marriage + dm_unemp + ent + lgbt + discrim + Vivienda")

model_fe <- lm_robust(formula = fe_formula,
                    data = df4,
                    fixed_effect = ~year,
                    weights = ent,
                    se_type = "stata")

summary(model_fe)


fe_formula_ne <- as.formula("from_non_equal ~ equal_marriage + dm_unemp + ent + lgbt + discrim + Vivienda")

model_fe_ne <- lm_robust(formula = fe_formula_ne,
                    data = df4,
                    fixed_effect = ~year,
                    weights = ent,
                    se_type = "stata")

summary(model_fe)


stargazer::stargazer(model_fe)
model_fe %>%
    tidy %>%
    xtable::xtable()


model_fe_ne %>%
    tidy %>%
    xtable::xtable()


############ Con libreria plm

library('plm')

fe_model <- plm(from_equal ~ equal_marriage + dm_unemp + dm_income + year + lgbt + discrim,
    data = df3,
    model = "within")

summary(fe_model)
