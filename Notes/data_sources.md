# Data Sources

This project uses two official Mexican surveys produced by INEGI (Instituto Nacional de Estadistica y Geografia).

## ENOE (Encuesta Nacional de Ocupacion y Empleo)

- **Full name**: Encuesta Nacional de Ocupacion y Empleo (National Occupation and Employment Survey)
- **Producer**: INEGI
- **Coverage**: 2017--2022, quarterly (24 waves)
- **Universe**: Persons aged 15 and older in selected households across all 32 states
- **URL**: <https://www.inegi.org.mx/programas/enoe/15ymas/>
- **Format**: CSV files inside ZIP archives, one per quarter, Latin-1 encoding

ENOE provides detailed labor-market information at the individual level. For this project, the critical feature is that it asks respondents whether they had to **move to a different state** to obtain or keep their current job (variable `P3O`), and if so, **from which state** they moved (`P3P2`). This allows us to construct interstate migration flows by quarter for each state.

### How it is used

1. `scripts/01_download_ENOE.py` downloads the raw quarterly ZIPs from INEGI and extracts them into `data/ENOE/raw/`.
2. `scripts/02_create_dataset.py` reads the extracted CSVs (questionnaire parts COE1 and COE2), merges them, and produces `data/ENOE/final/lgbt_migration.csv` with:
   - `migr`: average job-related migration rate per state-quarter
   - `from_equal` / `from_non_equal`: counts of migrants arriving from states with/without SSM
   - `p1`: employment rate
   - `p6b2`: average monthly income

### Questionnaire structure

ENOE has two questionnaire parts relevant to this project:

| Part | Contents |
|------|----------|
| **COE1** | Sociodemographics (age, sex, state, education), migration questions (P3O, P3P1, P3P2), job benefits (P3M1--P3M9) |
| **COE2** | Income (P6B2), additional employment detail |

See [ENOE_codebook.md](ENOE_codebook.md) for the full list of variables used.

### Survey weights

ENOE includes expansion factors (`FAC`) that make the sample representative at the state level. The Python pipeline uses these weights when computing averages.

---

## ENDISEG (Encuesta Nacional sobre Diversidad Sexual y de Genero)

- **Full name**: Encuesta Nacional sobre Diversidad Sexual y de Genero (National Survey on Sexual and Gender Diversity)
- **Producer**: INEGI
- **Year**: 2021 (first and only edition to date)
- **Universe**: Persons aged 15 and older in selected households across all 32 states
- **URL**: <https://www.inegi.org.mx/programas/endiseg/2021/>
- **Press release**: <https://www.inegi.org.mx/contenidos/saladeprensa/boletines/2022/endiseg/Resul_Endiseg21.pdf>
- **Sample size**: ~48,500 respondents
- **Format**: CSV (Latin-1 encoding), approximately 1 GB uncompressed

ENDISEG is Mexico's first nationally representative survey on sexual orientation and gender identity. It allows identification of LGB+ individuals and provides information on discrimination, mental health, family acceptance, and demographics by state.

### How it is used

The R analysis scripts (`analysis/01_endiseg.R` through `analysis/03_did2x2.R`) load the ENDISEG microdata directly and construct:

- **Sexual orientation groups** from variable `P8_1`:
  - LGB+: codes 1 (gay/lesbian), 2 (bisexual), 3 (other non-heterosexual), 6 (questioning)
  - Heterosexual: codes 4, 5
- **Age cohorts** from variable `P4_1`:
  - Youth (15--19): assumed immobile, still in parental homes
  - Adults (25+): legal and economic agency to migrate
  - Ages 20--24 excluded (transition period)
- **State-level treatment**: whether the respondent's state has SSM, civil union, and/or adoption rights

### Survey weights (critical)

All ENDISEG analyses **must** use INEGI's expansion factor (`FACTOR`) via the R `survey` package. Without proper weighting:

- Population percentages are biased (some states are oversampled)
- Standard errors are incorrect
- Statistical tests are invalid

The scripts use `svydesign(id = ~1, weights = ~factor)` and survey-weighted functions (`svyby()`, `svyglm()`, `svymean()`). **Do not** replace these with unweighted calls to `lm()`, `glm()`, or `mean()`.

### How to obtain the ENDISEG microdata

1. Go to <https://www.inegi.org.mx/programas/endiseg/2021/#microdatos>
2. Download the CSV version of "Tmodulo" (thematic module)
3. Extract to `data/conjunto_de_datos_endiseg_2021_csv/conjunto_de_datos_tmodulo_endiseg_2021/conjunto_de_datos/`
4. The file should be named `conjunto_de_datos_tmodulo_endiseg_2021.csv`

---

## Auxiliary Data

### Equal marriage legalization dates (`auxiliary/equal_marriage.csv`)

A hand-compiled table of same-sex marriage legalization dates for all 32 Mexican states, including:

- `matrimonio`: whether SSM is legal (1/0)
- `union_civil`: whether civil unions are recognized (1/0)
- `adopcion`: whether same-sex adoption is legal (1/0)
- `year`, `month`, `day`: date of legalization
- `metodo`: legal mechanism (legislative statute, judicial decree, gubernatorial decree, jurisprudence)

Sources: Diario Oficial de la Federacion, state gazettes, and news reports. See the paper for the full timeline (Figure 1).

Note: states coded `0` for `matrimonio` (Durango, Guerrero, Estado de Mexico, Tabasco, Tamaulipas) had de facto access via judicial amparo but no formal legislative approval during the study period.

### Housing price index (`data/SHF_Vivienda/`)

State-level housing price indices from the Sociedad Hipotecaria Federal (SHF), used as a control variable in the staggered DiD model (`analysis/05_staggered_did.R`).

### ENDISEG-derived aggregates (`data/ENDISEG_WEB/final/`)

Two CSV files aggregated from ENDISEG at the state level:
- `lgbt.csv`: percentage of LGB+ population by state
- `discrimination.csv`: discrimination rates by state

These are used by `r/transform_database.R` to merge with the ENOE panel.
