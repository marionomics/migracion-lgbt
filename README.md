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

- **ENOE** (Encuesta Nacional de Ocupacion y Empleo), 2017--2022, INEGI -- [variable codebook](Notes/ENOE_codebook.md)
- **ENDISEG** (Encuesta Nacional sobre Diversidad Sexual y de Genero), 2021, INEGI -- [variable codebook](Notes/ENDISEG_codebook.md)

For download instructions, survey design details, and auxiliary data descriptions, see [Notes/data_sources.md](Notes/data_sources.md).

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
├── Notes/                 # Documentation (codebooks, methodology, data sources)
└── public/                # Public-facing materials
```

## Replication

For detailed methodology, model specifications, and important caveats, see [Notes/methodology.md](Notes/methodology.md).

### Prerequisites

**Python** (3.8+):
```bash
pip install -r requirements.txt
```

**R** (4.0+):
```r
install.packages(c("tidyverse", "survey", "scales", "ggthemes",
                    "strucchange", "fixest", "bacondecomp", "haven", "lfe",
                    "estimatr", "plm", "readxl"))
```

### Step 1: Download ENOE microdata

From the project root:

```bash
python scripts/01_download_ENOE.py
```

This downloads quarterly ENOE ZIPs from INEGI (2017--2022) and extracts them into `data/ENOE/raw/`. Files are ~200 MB per quarter; the full download is approximately 5 GB. The script skips quarters that have already been downloaded.

### Step 2: Download ENDISEG microdata (manual)

ENDISEG must be downloaded manually from INEGI:

1. Go to <https://www.inegi.org.mx/programas/endiseg/2021/#microdatos>
2. Download the CSV version of the thematic module ("Tmodulo")
3. Extract the contents to `data/conjunto_de_datos_endiseg_2021_csv/`

The R scripts expect the file at:
```
data/conjunto_de_datos_endiseg_2021_csv/conjunto_de_datos_tmodulo_endiseg_2021/conjunto_de_datos/conjunto_de_datos_tmodulo_endiseg_2021.csv
```

### Step 3: Build the analysis dataset

```bash
python scripts/02_create_dataset.py
```

This reads raw ENOE CSVs, merges questionnaire parts, computes migration and employment indicators per state-quarter, and writes `data/ENOE/final/lgbt_migration.csv`. See [Notes/ENOE_codebook.md](Notes/ENOE_codebook.md) for variable definitions.

### Step 4: Run R analysis

Open `migracion-lgbt.Rproj` in RStudio (this sets the working directory to the project root so all relative paths resolve correctly). Then run scripts in order:

| Script | Input | Output | Notes |
|--------|-------|--------|-------|
| `analysis/01_endiseg.R` | ENDISEG microdata | `img/figure1_prevalence.png`, `img/figure2_structural_immobility.png` | Load ENDISEG CSV into the `endiseg` variable before running. Uses survey weights. |
| `analysis/02_gold_standard.R` | ENDISEG microdata | `img/figure_gold_standard.png`, `img/figure_comparison.png` | Stricter treatment definition (4 states with full rights). |
| `analysis/03_did2x2.R` | ENDISEG microdata | `img/did_plot.png` | 2x2 DiD comparing LGB+ vs heterosexual youth-to-adult gaps. |
| `analysis/04_struc_change.R` | `data/ENOE/final/lgbt_migration.csv` | Structural break results, event study plot | Chow test + fixest event study on ENOE panel. |
| `analysis/05_staggered_did.R` | Built by `r/transform_database.R` | Bacon decomposition, fixed-effects estimates | Sources `r/transform_database.R` internally; requires ENOE + ENDISEG + SHF data. |

**Important**: Scripts 01--03 require the ENDISEG microdata to be loaded into the R environment as `endiseg` before execution. You can do this with:

```r
endiseg <- read.csv("data/conjunto_de_datos_endiseg_2021_csv/conjunto_de_datos_tmodulo_endiseg_2021/conjunto_de_datos/conjunto_de_datos_tmodulo_endiseg_2021.csv")
```

All ENDISEG analyses use INEGI expansion factors via the `survey` package. See [Notes/data_sources.md](Notes/data_sources.md) for why this is critical.

### Step 5: Generate Python figures

```bash
python scripts/03_plot_migration.py   # Migration trend plot
python scripts/04_timeline.py         # Policy timeline (SSM, civil union, adoption by state)
python scripts/05_time_map.py         # Choropleth map of legalization years
```

These read from `data/ENOE/final/lgbt_migration.csv` and/or hardcoded reference data. Output goes to `img/`.

## Documentation

| File | Contents |
|------|----------|
| [Notes/data_sources.md](Notes/data_sources.md) | Where to obtain ENOE and ENDISEG, auxiliary data descriptions, survey weight requirements |
| [Notes/ENOE_codebook.md](Notes/ENOE_codebook.md) | ENOE variable definitions, migration questions, constructed variables |
| [Notes/ENDISEG_codebook.md](Notes/ENDISEG_codebook.md) | ENDISEG variable definitions, orientation coding, treatment definitions |
| [Notes/methodology.md](Notes/methodology.md) | Model specifications, identification strategy, econometric details, caveats |

## License

See [LICENSE](LICENSE).
