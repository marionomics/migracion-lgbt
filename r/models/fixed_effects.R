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



########################################################

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


## Export initial models
stargazer::stargazer(model_fe)
model_fe %>%
    tidy %>%
    xtable::xtable()

model_fe_ne %>%
    tidy %>%
    xtable::xtable()

## Prepare models for stargazer (log-transformed, incremental specs)

fe_formula1 <- as.formula("log(from_equal) ~ equal_marriage")
fe_formula2 <- as.formula("log(from_equal) ~ equal_marriage + dm_unemp ")
fe_formula3 <- as.formula("log(from_equal) ~ equal_marriage + dm_unemp + lgbt")
fe_formula4 <- as.formula("log(from_equal) ~ equal_marriage + dm_unemp + lgbt + discrim")
fe_formula5 <- as.formula("log(from_equal) ~ equal_marriage + dm_unemp + lgbt + discrim + Vivienda")
fe_formula6 <- as.formula("log(from_equal) ~ equal_marriage + dm_unemp + lgbt + discrim + Vivienda + covid")

model_fe1 <- lm_robust(formula = fe_formula1,
                    data = df4,
                    fixed_effect = ~year,
                    weights = ent,
                    se_type = "stata")
model_fe2 <- lm_robust(formula = fe_formula2,
                    data = df4,
                    fixed_effect = ~year,
                    weights = ent,
                    se_type = "stata")
model_fe3 <- lm_robust(formula = fe_formula3,
                    data = df4,
                    fixed_effect = ~year,
                    weights = ent,
                    se_type = "stata")
model_fe4 <- lm_robust(formula = fe_formula4,
                    data = df4,
                    fixed_effect = ~year,
                    weights = ent,
                    se_type = "stata")
model_fe5 <- lm_robust(formula = fe_formula5,
                    data = df4,
                    fixed_effect = ~year,
                    weights = ent,
                    se_type = "stata")
model_fe6 <- lm_robust(formula = fe_formula6,
                    data = df4,
                    fixed_effect = ~year,
                    weights = ent,
                    se_type = "stata")

summary(model_fe1)
summary(model_fe2)
summary(model_fe3)
summary(model_fe4)
summary(model_fe5)
summary(model_fe6)

## Non equal to stargazer

formulas <- c("log(from_non_equal) ~ equal_marriage + dm_unemp + lgbt + discrim + Vivienda",
                "log(from_non_equal) ~ equal_marriage + dm_unemp + lgbt + discrim",
                "log(from_non_equal) ~ equal_marriage + dm_unemp + lgbt",
                "log(from_non_equal) ~ equal_marriage + dm_unemp",
                "log(from_non_equal) ~ equal_marriage")



show_model <- function(model) {
    return(summary(lm_robust(formula = as.formula(formulas[model]),
                    data = df4,
                    fixed_effect = ~year,
                    weights = ent,
                    se_type = "stata")))
}

show_model(5)

############ Con libreria plm

library('plm')

fe_model <- plm(from_equal ~ equal_marriage + dm_unemp + dm_income + year + lgbt + discrim,
    data = df3,
    model = "within")

summary(fe_model)

m1 <- lm(fe_formula1, data = df4)
m2 <- lm(fe_formula2, data = df4)
m3 <- lm(fe_formula3, data = df4)
m4 <- lm(fe_formula4, data = df4)
m5 <- lm(fe_formula5, data = df4)

#stargazer::stargazer(m1, m2, m3, m4, m5)


## The effect on employment

df4
