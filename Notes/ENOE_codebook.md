# ENOE Variable Codebook

Variables extracted from the Cuestionario de Ocupacion y Empleo (COE) for use in this project. The full ENOE documentation is available at <https://www.inegi.org.mx/programas/enoe/15ymas/>.

## Identifiers and Survey Design

| Variable | Description | Notes |
|----------|-------------|-------|
| `FAC` | Expansion factor (sampling weight) | Required for weighted estimates |
| `UPM` | Primary sampling unit (Unidad Primaria de Muestreo) | Used for variance estimation |
| `CON` | Control number | Household identifier |
| `ENT` | State code (1--32) | See `auxiliary/states.csv` for mapping |
| `CD_A` | City code | Urban area identifier |
| `PER` | Interview period | Quarter of the year |
| `R_DEF` | Interview result | Filter for completed interviews only |

## Sociodemographics

| Variable | Description | Notes |
|----------|-------------|-------|
| `EDA` | Age | Filter: 15+ only |
| `SEX` | Sex | 1 = Male, 2 = Female. No gender identity question. |
| `N_HIJ` | Number of children | |
| `E_CON` | Marital status | |
| `CS_P13_1` | Highest education level | |
| `CS_P13_2` | Grade within education level | |
| `CS_P14_C` | Major / career | INEGI classification |
| `L_NAC_C` | Birthplace | State code |
| `LOC` | Locality (zone) | |
| `EST` / `EST_D` | Stratum / Design stratum | |
| `T_LOC` | Locality size | Urban/rural classification |
| `PAR_C` | Position in household | Head, spouse, child, etc. |
| `UR` | Urban/rural | |
| `ZONA` | Wage zone | 1 = Border, 2 = Rest of country |
| `H_MUD` | Number of times household has moved | |

## Migration Questions (Key Variables)

These are the variables central to the analysis.

| Variable | Description | Coding |
|----------|-------------|--------|
| **`P3O`** | Did you have to move to get or keep this job? | 1 = Yes, 2 = No. Reverse-coded in pipeline: `2 - P3O` gives 1 = moved, 0 = did not. |
| **`P3P1`** | Before moving, which state did you live in? | State name (text) |
| **`P3P2`** | State code of previous residence | Numeric state code (1--32). Used to construct origin-destination migration flows. |

### Migration motive variables (departure)

| Variable | Description |
|----------|-------------|
| `CS_AD_MOT` | Motive for absence from household |
| `CS_AD_DES` | Destination state: 1 = Same state, 2 = Other state, 3 = Other country, 9 = Unknown |

### Migration motive variables (arrival)

| Variable | Description |
|----------|-------------|
| `CS_NR_MOT` | Motive for arriving at current household |
| `CS_NR_ORI` | State of origin |

## Employment and Job Characteristics

| Variable | Description | Coding |
|----------|-------------|--------|
| `P1` | Worked at least one hour last week? | 1 = Yes, 2 = No. Reverse-coded: `2 - P1`. |
| `P1A1` | Did income-generating activities? | |
| `P1A2` | Helped in family business? | |
| `P1A3` | Did not work last week | |
| `P1B` | Self-employed? | |
| `P1C` | Reason for not working | |
| `P2_1` | Tried looking for work elsewhere (abroad)? | |
| `P2_2` | Tried looking for work in Mexico? | |
| `P2_3` | Tried starting a business? | |
| `P2A_MES` | Month started looking for work | |
| `P2A_ANIO` | Year started looking for work | |
| `P2F` | Need to work? | |
| `P3M1`--`P3M9` | Job benefits | Infonavit, daycare, retirement, insurance, etc. |
| `P3Q` | Workplace size (number of workers) | |
| `P3R` | Time at current job | |
| `P4A` | Industry (SCIAN code) | |
| `P4B` | General business area | |

## Income

| Variable | Description | Notes |
|----------|-------------|-------|
| `P6B2` | Monthly income in pesos | Used as state-level control variable |
| `P6C` | Income in minimum wages | |
| `P7GCAN` | Total income (alternate measure) | In COE2 |

## Constructed Variables (in `data/ENOE/final/lgbt_migration.csv`)

These are created by `scripts/02_create_dataset.py`:

| Variable | Description | Source |
|----------|-------------|--------|
| `ent` | State code | ENT |
| `year` | Year | From file path |
| `quarter` | Quarter (1--4) | From file path |
| `migr` | Average job-related migration rate | Mean of reverse-coded P3O by state |
| `equal_marriage` | SSM legal in this state-quarter? | Merged from `auxiliary/equal_marriage.csv` |
| `from_equal` | Migrants arriving from states with SSM | Pivot of P3P2, classified by origin state's SSM status |
| `from_non_equal` | Migrants arriving from states without SSM | Same as above |
| `p1` | Employment rate | Mean of reverse-coded P1 by state |
| `p6b2` | Average monthly income | Mean of P6B2 by state |
