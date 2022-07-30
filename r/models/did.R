source("r/transform_database.R")

names(df4) <- c("ent", "year", "migr", "equal_marriage",
                "from_equal", "from_non_equal", "unempl", "income", "lgbt",
                "discrim", "dm_migr", "dm_unemp", "dm_income", "Estado", "Vivienda")

df4 <- df4 %>%
    mutate(covid = ifelse(year %in% c(2020,2021), 1, 0))

dd_model_from_equal <- lm_robust(from_equal ~ equal_marriage + dm_unemp + 
            lgbt + discrim + dm_migr + covid + Vivienda,
            data = df4,
            weights = ent,
            clusters = equal_marriage
)
summary(dd_model_from_equal)



dd_model_from_non_equal <- lm_robust(from_non_equal ~ equal_marriage + dm_unemp + 
            lgbt + discrim + dm_migr,
            data = df3,
            weights = ent,
            clusters = equal_marriage
)
summary(dd_model_from_non_equal)



dd_model_from_equal[2]
