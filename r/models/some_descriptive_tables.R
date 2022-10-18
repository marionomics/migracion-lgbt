# In this script we use the table as modified in fixed_effects.R to show some statistics

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


df4 %>% head()    
