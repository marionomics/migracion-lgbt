library(tidyverse)

df <- read.csv("data/ENOE/final/lgbt_migration.csv")

# Auxiliary datasets
equal_marriage <- read.csv("auxiliary/equal_marriage.csv")

head(df)

df %>%
    group_by(year,equal_marriage)%>%
    summarise(migr =  mean(migr)) %>%
    ggplot(aes(x = year, y = migr, color = factor(equal_marriage)))+
    geom_line()+
    theme_minimal()

# Let's check the average flows over time. 

png(filename="img/flujos.png")
df %>%
    group_by(year) %>%
    summarise(to_ne = mean(to_non_equal),
                to_e = mean(to_equal),
                from_e = mean(from_equal),
                from_ne = mean(from_non_equal)) %>%
    ggplot(aes(x = year))+
        geom_line(aes(y = to_e), linetype = "dashed", size = 1)+
        geom_line(aes(y = to_ne), size = 1)+
        geom_line(aes(y= from_e), linetype = "dashed")+
        geom_line(aes(y= from_ne))+
        scale_linetype_manual(name = "Flujos migratorios", labels = c('uno', 'dos'))+
        labs(x = "Time", y = "Migration flows")+
        theme_minimal()

dev.off()

# 10-07-2022. No entiendo lo que estoy viendo. Me parece que hay mas flujos en los estados con apertura?

# Again average flows but with normalized time... what about it?

df %>%
    left_join(equal_marriage[,c(1,6)], by = c("cve")) %>%
    mutate(year = year.x - year.y) %>%
    group_by(year) %>%
    summarise(emigracion = mean(to_non_equal) + mean(to_equal),
                inmigracion = mean(from_equal) + mean(from_non_equal)
                )%>%
    reshape2::melt(id.vars = c("year")) %>%
    ggplot(aes(x = year, y = value, linetype = variable))+        
        geom_line() +
        theme_minimal()


#### Grafico de barras con la discriminación por estados

path_discrimination = "data/ENDISEG_WEB/final/discrimination.csv"
discrimination <- read.csv(path_discrimination)
path_states <- "auxiliary/states.csv"
states <- read.csv(path_states)

disc2 <- discrimination %>%
    left_join(states, by = "cve")

disc2$ratio[18] <- 0

# Ok this one is really weird... REALLY DURANGO has a lower rate of discrimination?
# Perhaps we just have less openly gay ppl?
disc2 %>%
    mutate(norm_disc = ratio - mean(ratio)) %>%
    ggplot(aes(x = state, y = norm_disc)) +
    geom_bar(stat = "identity") +
    coord_flip()

path_lgbt = "data/ENDISEG_WEB/final/lgbt.csv"

lgbt <- read.csv(path_lgbt)
lgbt <- lgbt %>%
    left_join(states, by = c("ent" = "cve"))

lgbt %>%
    mutate(above_average = ifelse(percentage_lgbt > mean(percentage_lgbt),1,0)) %>%
    ggplot(aes(x = state, y =percentage_lgbt, fill = factor(above_average)))+
    geom_bar(stat = "identity") +
    geom_hline(yintercept = mean(lgbt$percentage_lgbt), linetype = 3)+
    coord_flip() +
    theme_minimal()

