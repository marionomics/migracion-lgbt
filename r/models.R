library(tidyverse)

df <- read.csv("data/ENOE/final/lgbt_migration.csv")
equal_marriage <- read.csv("auxiliary/equal_marriage.csv")
head(equal_marriage)

head(df)

# Primer modelo...

# La migración a otros estados con matrimonio igualitario baja al aprobarse me
lm(to_non_equal ~ equal_marriage + as.Date(ISOdate(year,1,1)), data = df) %>%
    summary()
# Y la migración a los estados con matrimonio igualitario parece subir con la aprobación
lm(to_equal ~ equal_marriage + as.Date(ISOdate(year,1,1)), data = df) %>%
    summary()

# Migracion desde estados igualitarios se incrementa :O
lm(from_equal ~ equal_marriage + as.Date(ISOdate(year,1,1)), data = df) %>%
    summary()

# La migración desde estados NO igualitarios cae????
lm(from_non_equal ~ equal_marriage + as.Date(ISOdate(year,1,1)), data = df) %>%
    summary()
