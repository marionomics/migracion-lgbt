source("r/transform_database.R")

equal_marriage <- read.csv("auxiliary/equal_marriage.csv")
equal_marriage <- equal_marriage[,c(1,6)]
names(equal_marriage) <- c("cve", "year_em")
#equal_marriage$year[is.na(equal_marriage$year)] <- 0


df3 %>%
    left_join(equal_marriage, by = c("ent" = "cve")) %>%
    mutate(norm_year = year - year_em) %>%
    group_by(norm_year) %>%
    mutate(from_equal = mean(from_equal),
            from_non_equal = mean(from_non_equal)) %>%
    ggplot(aes(x = norm_year))+
    geom_line(aes(y = from_equal), size = 0.9)+
    geom_line(aes(y = from_non_equal), linetype = 4)+
    geom_vline(xintercept = 0)+
    labs(x = "Time")+
    theme_light()
