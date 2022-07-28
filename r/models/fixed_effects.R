library(estimatr)

source("r/transform_database.R")

names(df3) <- c("ent", "year", "migr", "equal_marriage",
                "from_equal", "from_non_equal", "unempl", "income", "lgbt",
                "discrim", "dm_migr", "dm_unemp", "dm_income")

df3 %>%
    head()

fe_formula <- as.formula("from_equal ~ equal_marriage + dm_income + year + lgbt")

model_fe <- lm_robust(formula = fe_formula,
                    data = df3,
                    fixed_effect = ~ent)

summary(model_fe)



############ Con libreria plm

library('plm')

fe_model <- plm(from_equal ~ equal_marriage + dm_unemp + dm_income + year + lgbt + discrim,
    data = df3,
    model = "within")

summary(fe_model)
