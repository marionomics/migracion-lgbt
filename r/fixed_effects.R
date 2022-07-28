source("r/transform_database.R")

names(df3) <- c("ent", "year", "migr", "equal_marriage",
                "from_equal", "from_non_equal", "unempl", "income", "lgbt",
                "discrim", "dm_migr", "dm_unemp", "dm_income")

df3 %>%
    head()

fe_formula <- as.formula("from_equal ~ equal_marriage + dm_unemp + dm_income + lgbt + discrim")

model_fe <- lm_robust(formula = fe_formula,
                    data = df3,
                    fixed_effect = ~ent)

summary(model_fe)
