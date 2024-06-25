# Install devtools if needed
if (!require("devtools")){
    install.packages("devtools")
}

# Install mxmaps from diego valle
devtools::install_github("diegovalle/mxmaps")

library("mxmaps")

df_mxstate_2020$region <- as.numeric(df_mxstate_2020$region)
df_mxstate_2020[c(1)] %>% head()

df_states <- df4 %>%
    group_by(ent)%>%
    summarize(lgbt = mean(lgbt)) %>%
    left_join(df_mxstate_2020[c(1)] ,by = c("ent" = "region"))

mxstate_choropleth(df_states,
                    title = "Prevalence of LGBT")
