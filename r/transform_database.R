library(tidyverse)
library(haven)
library(estimatr)
library(plm)
library(zoo) # Para trabajar con fechas

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

# Add time as time
#df2$date <- as.Date(ISOdate(df3$year, 1, 1))
#df2$fecha <- df2$year + df2$quarter/5

df2$ratio[is.na(df2$ratio)] <- 0

df2 <- df2 %>%
    subset(select = c("ent", "year", "migr", "equal_marriage","from_equal", "from_non_equal", "p1", "p6b2", "percentage_lgbt", "ratio"))
    
# Balance and demean panel data
df3 <- df2 %>%
    arrange(ent, year) %>% # acomodar en caso de que se haya desacomodado en algún punto 
    make.pbalanced(balance.type = "shared.individuals") %>%
    mutate(
        dm_migr = migr - ave(migr, ent),
        dm_unemp = p1 - ave(p1, ent),
        dm_income = p1 - ave(p1, ent)
    )

## Agregar vivienda

shf <- readxl::read_excel("data/SHF_Vivienda/Indice SHF datos abiertos 1_trim_2022.xlsx")

global <- c("Nacional", "Nueva", "Usada",
            "Casa sola", "Casa en condominio - depto.",
            "Económica - Social", "Media - Residencial",
            "ZM Valle México", "ZM Guadalajara",
            "ZM Monterrey", "ZM PueblaTlax", "ZM Toluca",
            "ZM Tijuana", "ZM León", "ZM Querétaro")

states
shf2 <- shf %>% 
    filter(Trimestre == 1) %>%
    filter(Año %in% 2017:2022)%>%
    filter(!Global %in% global) %>%
    filter(is.na(Municipio)) %>%
    select(c("Estado", "Indice")) %>%
    left_join(states[,c(1,3)], by = c("Estado" = "state"))

df4 <- df3 %>%
    left_join(shf2, by =c("ent" = "cve"))

df4 %>%
    head()
