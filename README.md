# migracion-lgbt

**Non-synchronous legalization of same-sex marriage and internal migration patterns in Mexico**

*Legalizacion asincronica del matrimonio igualitario y patrones de migracion interna en Mexico*

## Overview

Between 2010 and 2023, Mexican states legalized same-sex marriage (SSM) at different times, creating a patchwork of jurisdictions where LGBT+ rights were recognized to varying degrees. This project investigates whether that non-synchronous legalization acted as a pull factor for internal migration toward more inclusive states.

Drawing on neoclassical migration theory and the Tiebout hypothesis ("voting with your feet"), we test whether legal recognition of SSM, civil unions, and same-sex adoption is associated with a spatial redistribution of the LGB+ population. We treat legalization as a proxy for broader social acceptance and ask two questions:

1. Did the staggered legalization of SSM coincide with measurable changes in migration flows?
2. Is the spatial distribution of the LGB+ population distinct from general economic migration patterns observed in the heterosexual population?

## Theoretical Framework

Migration decisions balance expected returns against costs. In the microeconomic model used here, a potential migrant compares destination earnings (weighted by employment probability and legal environment) against origin income and the total cost of moving, including psychological costs. For LGBT+ individuals in restrictive states, legalization elsewhere increases the expected return of moving. However, in a developing economy with high informality and limited savings, migration costs may be prohibitively high, trapping individuals in hostile environments even when rights are recognized elsewhere.

## Empirical Strategy

The analysis uses three complementary approaches:

### 1. Staggered Difference-in-Differences / Event Study (`analysis/03_did2x2.R`, `analysis/05_staggered_did.R`)

Using quarterly ENOE microdata (2017--2022), we treat SSM legalization as a staggered treatment across states and estimate a dynamic event-study model with state and time fixed effects. The dependent variable is the total migration inflow to each state. This allows us to trace whether migration trends shift in the years following legalization.

### 2. Structural Break Analysis (`analysis/04_struc_change.R`)

Because the event study coefficients are individually insignificant, we aggregate migration data into a centered time series relative to each state's reform year and estimate a Chow-type segmented regression. This tests for a change in the intercept (immediate jump) and/or slope (gradual trend shift) at the moment of legalization.

### 3. Synthetic Cohort Comparison (`analysis/01_endiseg.R`, `analysis/02_gold_standard.R`)

Using the 2021 ENDISEG survey, we compare the geographic distribution of LGB+ youth (ages 15--19, assumed immobile and still in parental homes) against LGB+ adults (ages 25+, with legal and economic agency to migrate). The heterosexual population serves as a counterfactual, controlling for the natural economic gravity of large cities. If rights-based sorting exists, the adult LGB+ population should be more concentrated in states with full rights recognition (SSM + civil union + adoption) than what the youth baseline predicts.

## Key Results

- **No immediate migration response.** The event study finds no statistically significant jump in migration inflows in the years immediately following SSM legalization.
- **A gradual trend shift.** The structural break analysis detects a statistically significant change in the migration trend slope (~5.9 units per year, p < 0.1) after legalization, suggesting a slow, long-term sorting process rather than a sudden relocation.
- **Sorting in cross-sectional data.** The ENDISEG cohort comparison shows that LGB+ adults are significantly more concentrated in states with full rights recognition than LGB+ youth (+6.5 pp, p < 0.01), while the equivalent gap for the heterosexual population is smaller (+2.2 pp), yielding a difference-in-differences of +4.3 pp. This gap cannot be explained by the timing of sexual orientation discovery (82.6% identify their orientation by age 18, per ENDISEG).
- **Structural immobility persists.** Despite higher educational attainment, LGB+ individuals face higher workplace discrimination (28.1% vs 18.4%) and slightly lower labor force participation, consistent with the hypothesis that economic barriers constrain rights-based migration in developing economies.

## Data Sources

- **ENOE** (Encuesta Nacional de Ocupacion y Empleo), 2017--2022, INEGI
- **ENDISEG** (Encuesta Nacional sobre Diversidad Sexual y de Genero), 2021, INEGI

## Project Structure

```
migracion-lgbt/
├── analysis/              # R analysis scripts (run in order)
│   ├── 01_endiseg.R       # ENDISEG 2021 survey analysis
│   ├── 02_gold_standard.R # Gold-standard prevalence estimates
│   ├── 03_did2x2.R        # 2x2 difference-in-differences
│   ├── 04_struc_change.R  # Structural break analysis
│   └── 05_staggered_did.R # Staggered DiD with fixed effects
│
├── scripts/               # Python data pipeline (run in order)
│   ├── 01_download_ENOE.py    # Download ENOE microdata
│   ├── 02_create_dataset.py   # Build analysis dataset
│   ├── 03_plot_migration.py   # Migration trend plots
│   ├── 04_timeline.py         # Policy timeline figure
│   └── 05_time_map.py         # Geographic visualization
│
├── r/                     # R utility functions
├── auxiliary/             # Reference tables (equal marriage dates, etc.)
├── data/                  # All data (gitignored, generated by pipeline)
├── notebooks/             # Exploratory Jupyter notebooks
├── tables/                # Output tables
├── img/                   # Output figures
├── archive/               # Superseded scripts (see archive/README.md)
├── Notes/                 # Research notes
└── public/                # Public-facing materials
```

## Replication

### Prerequisites

**Python** (3.8+):
```bash
pip install -r requirements.txt
```

**R** packages:
```r
install.packages(c("tidyverse", "survey", "scales", "ggthemes",
                    "strucchange", "fixest", "bacondecomp", "haven", "lfe"))
```

### Steps

1. **Download data** (Python): run `scripts/01_download_ENOE.py` from the project root. This populates `data/`.
2. **Build dataset** (Python): run `scripts/02_create_dataset.py` to produce `data/ENOE/final/lgbt_migration.csv`.
3. **R analysis**: open `migracion-lgbt.Rproj` in RStudio and run scripts in `analysis/` in numbered order (01 through 05).
4. **Figures** (Python): run `scripts/03_plot_migration.py`, `04_timeline.py`, and `05_time_map.py` for Python-generated plots. R scripts in `analysis/` also produce figures saved to `img/`.

## License

See [LICENSE](LICENSE).
