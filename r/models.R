library(tidyverse)
library(haven)
library(estimatr)
library(plm)

df <- read.csv("data/ENOE/final/lgbt_migration.csv")
#equal_marriage <- read.csv("auxiliary/equal_marriage.csv")
#head(equal_marriage)

path_lgbt = "data/ENDISEG_WEB/final/lgbt.csv"
lgbt <- read.csv(path_lgbt)
head(lgbt[,2:3])

path_discrimination = "data/ENDISEG_WEB/final/discrimination.csv"
discrimination <- read.csv(path_discrimination)
head(discrimination[,c(2,5)])

path_states <- "auxiliary/states.csv"
states <- read.csv(path_states)


df2 <- df %>%
    left_join(lgbt[,2:3], by = "ent") %>%
    left_join(discrimination[,c(2,5)], by = "cve")

df2$ratio[is.na(df2$ratio)] <- 0

df2 <- df2 %>%
    mutate(time = year + quarter/5) %>%
    subset(select = c("ent", "time", "year", "quarter", "migr", "equal_marriage","from_equal", "from_non_equal", "p1", "p6b2", "percentage_lgbt", "ratio"))
    
# Balance and demean panel data
df3 <- df2 %>%
    arrange(ent, time) %>% # acomodar en caso de que se haya desacomodado en algún punto 
    make.pbalanced(balance.type = "shared.individuals") %>%
    mutate(
        dm_migr = migr - ave(migr, ent),
        dm_unemp = p1 - ave(p1, ent),
        dm_income = p1 - ave(p1, ent),
        dm_discrim = ratio - ave(ratio, ent),
        dm_lgbt = percentage_lgbt - ave(percentage_lgbt, ent)
    )

