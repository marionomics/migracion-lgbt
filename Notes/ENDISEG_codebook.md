# ENDISEG Variable Codebook

Variables used from the Encuesta Nacional sobre Diversidad Sexual y de Genero (ENDISEG) 2021. The full documentation and questionnaire are available at <https://www.inegi.org.mx/programas/endiseg/2021/>.

## Survey Design Variables

| Variable | Description | Notes |
|----------|-------------|-------|
| `FACTOR` | Expansion factor (sampling weight) | **Must** be used in all analyses via `survey` package |
| `ENT` | State code (1--32) | Matches ENOE state codes and `auxiliary/states.csv` |

## Demographics

| Variable | Description | Notes |
|----------|-------------|-------|
| `P4_1` | Age | Numeric. Used to construct cohort groups. |
| `NIV` | Education level code | Used for structural rigidity analysis |

## Sexual Orientation (Section 8)

| Variable | Description | Coding |
|----------|-------------|--------|
| **`P8_1`** | Sexual orientation self-identification | See coding below |
| `P8_4_1` | Family response to LGBTQ status | Acceptance/rejection |
| **`P8_5`** | Experienced discrimination in past 12 months | 1 = Yes |

### P8_1 Coding (Sexual Orientation)

This is the core variable for identifying the LGB+ population. The question reads: *"Conforme a lo anterior, usted se considera..."* (Based on the above, you consider yourself...)

| Code | Label | Group assignment |
|------|-------|-----------------|
| 1 | Gay / Lesbian | LGB+ |
| 2 | Bisexual | LGB+ |
| 3 | Other non-heterosexual orientation | LGB+ |
| 4 | Heterosexual | Heterosexual |
| 5 | Heterosexual (confirmed) | Heterosexual |
| 6 | Questioning / unsure | LGB+ |

The scripts collapse these into a binary: `orientation_group` = "LGB+" (codes 1, 2, 3, 6) vs "Heterosexual" (codes 4, 5).

According to ENDISEG, approximately 5% of the Mexican population aged 15+ identifies as LGB+, and about 82.6% of LGB+ individuals report discovering their orientation by age 18.

## Mental Health (Section 10)

| Variable | Description | Coding |
|----------|-------------|--------|
| **`P10_1_3`** | Depression indicator | 1 = Yes. Used as well-being outcome in regression models. |

## Constructed Variables Used in Analysis

These are created within the R scripts from the raw ENDISEG variables:

| Variable | Definition | Script |
|----------|-----------|--------|
| `orientation_group` | "LGB+" if P8_1 in {1,2,3,6}; "Heterosexual" if P8_1 in {4,5} | 01_endiseg.R |
| `mobility_cohort` | "0_Youth_Immobile" (ages 15--19) or "1_Adult_Mobile" (ages 25+). Ages 20--24 excluded. | 01_endiseg.R |
| `state_type` (early adopters) | "Treatment_State" if state legalized SSM before 2021 (16 states); "Control_State" otherwise | 01_endiseg.R |
| `state_type` (gold standard) | "Gold_Standard_State" if state has SSM + civil union + adoption: CDMX, Coahuila, Campeche, Michoacan (codes 09, 05, 04, 16); "Rest_of_Mexico" otherwise | 02_gold_standard.R |
| `in_gold_standard` | Numeric 0/1 version of gold-standard treatment | 03_did2x2.R |
| `has_depression` | 1 if P10_1_3 == "1" | 01_endiseg.R |
| `suffered_discrimination` | 1 if P8_5 == "1" | 01_endiseg.R |

## Treatment Definitions

The project uses two treatment definitions, reflecting different thresholds of rights recognition:

### Early adopters (01_endiseg.R)

States that legalized SSM before the ENDISEG survey date (2021). 16 states qualify:

| Code | State | Year |
|------|-------|------|
| 09 | Ciudad de Mexico | 2010 |
| 23 | Quintana Roo | 2012 |
| 05 | Coahuila | 2014 |
| 08 | Chihuahua | 2015 |
| 18 | Nayarit | 2015 |
| 04 | Campeche | 2016 |
| 06 | Colima | 2016 |
| 16 | Michoacan | 2016 |
| 17 | Morelos | 2016 |
| 07 | Chiapas | 2018 |
| 01 | Aguascalientes | 2019 |
| 13 | Hidalgo | 2019 |
| 19 | Nuevo Leon | 2019 |
| 20 | Oaxaca | 2019 |
| 24 | San Luis Potosi | 2019 |
| 03 | Baja California Sur | 2019 |

### Gold standard (02_gold_standard.R, 03_did2x2.R)

States with **all three** rights recognized (SSM + civil union + adoption) before 2021. Only 4 states qualify:

| Code | State | Year |
|------|-------|------|
| 09 | Ciudad de Mexico | 2010 |
| 05 | Coahuila | 2014 |
| 04 | Campeche | 2016 |
| 16 | Michoacan | 2016 |

This stricter definition is more likely to capture jurisdictions with genuinely inclusive legal environments, where the full ecosystem of family rights is available.
