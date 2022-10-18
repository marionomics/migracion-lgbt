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

##############################################

df4 %>% head()

df4$from_equal[!(df$equal_marriage)] %>% mean()
df4$from_equal[(df$equal_marriage == 1)] %>% mean()

sacar_media <- function(year, equal){
if(equal == TRUE){
    columna = 5
} else{ columna = 6}
mean(df4[df4$year == year,columna][(df$equal_marriage == 1)], na.rm = TRUE)
}

flows <- c()
for(i in 2017:2022){
    flows <- append(flows, sacar_media(i,0))
}
flows


###############
# Average flows by state before and after

df4 %>%
    group_by(Estado) %>%
    summarize(flows = mean(from_equal[norm_year >= 0], na.rm = TRUE) / mean(from_equal[norm_year < 0], na.rm = TRUE)) %>%
    print(n = 31)



names(df4)
