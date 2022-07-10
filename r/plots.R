library(tidyverse)

df <- read.csv("data/ENOE/final/lgbt_migration.csv")

head(df)

df %>%
    group_by(year,equal_marriage)%>%
    summarise(migr =  mean(migr)) %>%
    ggplot(aes(x = year, y = migr, color = factor(equal_marriage)))+
    geom_line()+
    theme_minimal()

# Let's check the average flows over time. 

df %>%
    group_by(year) %>%
    summarise(to_ne = mean(to_non_equal),
                to_e = mean(to_equal),
                from_e = mean(from_equal),
                from_ne = mean(from_non_equal)) %>%
    ggplot(aes(x = year))+
        geom_line(aes(y = to_e), linetype = "dashed")+
        geom_line(aes(y = to_ne))+
        geom_line(aes(y= from_e), linetype = "dashed")+
        geom_line(aes(y= from_ne))+
        #scale_linetype_manual("Tipo de estados", values = c('Con matrimonio igualitario', 'Sin matrimonio igualitario'))+
        labs(x = "Tiempo", y = "Flujos Migratorios")
        theme_minimal()



