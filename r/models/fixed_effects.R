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

fe_formula <- as.formula("from_equal ~ equal_marriage + dm_unemp + lgbt + discrim + Vivienda")

model_fe <- lm_robust(formula = fe_formula,
                    data = df4,
                    fixed_effect = ~year,
                    weights = ent,
                    se_type = "stata")

summary(model_fe)


fe_formula_ne <- as.formula("from_non_equal ~ equal_marriage + dm_unemp + ent + lgbt + discrim + Vivienda")

model_fe_ne <- lm_robust(formula = fe_formula_ne,
                    data = df4,
                    fixed_effect = ~year,
                    weights = ent,
                    se_type = "stata")

summary(model_fe_ne)


stargazer::stargazer(model_fe)
model_fe %>%
    tidy %>%
    xtable::xtable()


model_fe_ne %>%
    tidy %>%
    xtable::xtable()


############ Con libreria plm

library('plm')

fe_model <- plm(from_equal ~ equal_marriage + dm_unemp + dm_income + year + lgbt + discrim,
    data = df3,
    model = "within")

summary(fe_model)


#### Heteroskedasticity test

bp_test <- lmtest::bptest(model_fe)
print(bp_test)ç

bp_test_ne <- lmtest::bptest(model_fe_ne)
print(bp_test_ne)


# Estimate the model using lm()
model_lm <- lm(formula = fe_formula, data = df4)

model_lm_ne <- lm(formula = fe_formula_ne, data = df4)

# Calculate heteroskedasticity-robust standard errors
robust_se <- sqrt(diag(vcovHC(model_lm)))
robust_se <- sqrt(diag(vcovHC(model_lm_ne)))

# Use these to perform a robust version of the t-test
lmtest::coeftest(model_lm, vcov = vcovHC(model_lm))

lmtest::coeftest(model_lm_ne, vcov = vcovHC(model_lm_ne))


##############
# Use the Hausman test to justify the use of fixed effects
library(plm)

# Create a panel data structure
pdata <- plm.data(df6, index = c("ent", "year"))

# Estimate the fixed effects model
model_fe_plm <- plm(fe_formula, data = pdata, model = "within")

# Estimate the random effects model
model_re <- plm(fe_formula, data = pdata, model = "random")

# Run the Hausman test
hausman_test <- phtest(model_fe_plm, model_re)
print(hausman_test)

# Find duplicates
duplicates <- df4[duplicated(df4[c("ent", "year")]),]

# Print out duplicates
print(duplicates)

df5 <- df4[!duplicated(df4[c("ent", "year")]),]

library(dplyr)

df6 <- df4 %>%
  group_by(ent, year) %>%
  summarise_all(mean, na.rm = TRUE)



###################################################


# load the plm package
library(plm)



dup_table <- table(index(pdata), useNA = "ifany")
dupes <- dup_table[dup_table > 1]
print(dupes)

# load the dplyr package
library(dplyr)

# remove duplicates based on 'ent' and 'year'
df5 <- df4 %>%
  group_by(ent, year) %>%
  filter(row_number() == 1) %>%
  ungroup()

# first, you need to create pdata.frame
pdata <- plm::pdata.frame(df5, index = c("ent", "year"))

# run your fixed effect model using plm function instead of lm_robust
model_fe <- plm(formula = fe_formula,
                data = pdata,
                model = "within",
                effect = "individual",
                autocor = 1) # "within" is for fixed effects
summary(model_fe)


# perform Wooldridge test for autocorrelation in panel data
plm::pwartest(model_fe)
