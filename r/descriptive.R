
# Data Paths
path_df = "data/ENOE/final/lgbt_migration.csv"
path_discrimination = "data/ENDISEG_WEB/final/discrimination.csv"

df <- read.csv(path_df)
discrimination <- read.csv(path_discrimination)

head(discrimination)
df %>%
    left_join(discrimination, by = 'cve') %>%
    colnames()
