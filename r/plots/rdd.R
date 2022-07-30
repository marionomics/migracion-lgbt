source("r/transform_database.R")


equal_marriage <- read.csv("auxiliary/equal_marriage.csv")
equal_marriage <- equal_marriage[,c(1,6)]
names(equal_marriage) <- c("cve", "year_em")
#equal_marriage$year[is.na(equal_marriage$year)] <- 0

png(filename="img/migration_lgbt.png")
df4 %>%
    left_join(equal_marriage, by = c("ent" = "cve")) %>%
    mutate(norm_year = year - year_em) %>%
    group_by(norm_year) %>%
    mutate(from_equal = mean(from_equal),
            from_non_equal = mean(from_non_equal)) %>%
    select(c("ent", "norm_year", "from_equal", "from_non_equal")) %>%
    reshape2::melt(id.vars = c("ent", "norm_year"), ) %>%
    ggplot(aes(x = norm_year, y = value))+
    geom_line(aes(linetype = variable)) +
    geom_vline(xintercept = 0)+
    labs(x = "Time", y = "Migration")+
    scale_linetype_manual(name = "Source", values = c("solid", "dashed"), labels = c("From States with EM", "From States without EM"))+
    theme_light()
dev.off()
