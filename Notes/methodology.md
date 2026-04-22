# Methodology Notes

## Theoretical Motivation

Migration decisions are modeled as a cost-benefit comparison. A potential migrant evaluates:

```
E(R) = p(employment) * p(legal safety) * earnings(destination) - earnings(origin) - C(migration)
```

where `C` includes financial costs (moving, housing), social costs (leaving networks), and psychological costs. For LGB+ individuals in restrictive states, SSM legalization elsewhere increases the expected return by raising `p(legal safety)`. However, in Mexico's context of high informality and limited savings, `C` may be prohibitively high, preventing the migration response that neoclassical theory would predict.

The Tiebout hypothesis ("voting with your feet") predicts that diverse populations should cluster in jurisdictions that guarantee their rights. This project tests whether that sorting occurs in practice, or whether structural economic barriers dominate.

## Why internal (not international) migration?

Mexico's non-synchronous SSM legalization (2010--2023) creates a natural experiment within a single country. Interstate migration avoids confounds from immigration law, language barriers, and currency differences. The variation in treatment timing across 32 states enables quasi-experimental methods.

## Model 1: Staggered Difference-in-Differences (ENOE)

**Scripts**: `analysis/04_struc_change.R`, `analysis/05_staggered_did.R`

### Data

Quarterly ENOE microdata (2017--2022) aggregated to the state-quarter level. The outcome is the total migration inflow to each state, constructed from the job-migration question (`P3O`) and origin state (`P3P2`).

### Event study specification

```
Y_it = sum_k[ beta_k * 1(t - T_i = k) ] + alpha_i + gamma_t + epsilon_it
```

- `Y_it`: migration inflow to state `i` in quarter `t`
- `T_i`: quarter of SSM legalization in state `i`
- `k`: years relative to reform (event time), with `k = -1` as reference
- `alpha_i`: state fixed effects (absorb time-invariant state characteristics)
- `gamma_t`: time fixed effects (absorb national shocks, e.g., COVID)
- Standard errors clustered at the state level

Implemented with the `fixest` package (`feols` with `i()` for dynamic coefficients).

### Structural break (Chow test)

Because individual event-study coefficients are noisy, the data is aggregated into a centered time series (averaging across states at each event time `k`) and a segmented regression is estimated:

```
Y_k = beta_0 + beta_1 * k + delta_0 * D_k + delta_1 * (k * D_k) + epsilon_k
```

- `D_k = 1` if `k >= 0` (post-reform)
- `delta_0`: intercept shift (immediate jump)
- `delta_1`: slope shift (change in trend)

This distinguishes between a sudden migration response and a gradual sorting process.

### Bacon decomposition

In staggered DiD designs, the two-way fixed effects (TWFE) estimator is a weighted average of all possible 2x2 DiD comparisons, including problematic "already-treated vs later-treated" comparisons. The `bacondecomp` package decomposes the overall estimate to check for negative weights or heterogeneous treatment effects that could bias the TWFE estimate.

### Covariates (staggered DiD)

The full specification in `analysis/05_staggered_did.R` includes:
- `from_equal`, `from_non_equal`: migration flows by origin type
- `unempl`: state employment rate
- `income`: average state income
- `dm_migr`, `dm_unemp`, `dm_income`: de-meaned versions (within-state)
- `Vivienda`: housing price index (SHF)
- `covid`: COVID period indicator
- `norm_year`: years relative to reform

## Model 2: Synthetic Cohort Comparison (ENDISEG)

**Scripts**: `analysis/01_endiseg.R`, `analysis/02_gold_standard.R`, `analysis/03_did2x2.R`

### Intuition

If LGB+ individuals migrate toward inclusive states once they gain economic independence, then the geographic distribution of LGB+ **adults** should be more concentrated in inclusive states than the distribution of LGB+ **youth** (who are still living with parents and cannot relocate).

The heterosexual population serves as a counterfactual: any youth-to-adult shift in their geographic distribution reflects general economic gravity (e.g., people moving to Mexico City for jobs), not rights-based sorting.

### Design

Two age cohorts from ENDISEG 2021:
- **Youth (15--19)**: assumed immobile (still in parental homes). Acts as a proxy for the "natural" birth distribution of LGB+ individuals across states.
- **Adults (25+)**: possess legal and economic agency to migrate.
- **Ages 20--24 excluded**: transition period where moves may be temporary (university, first jobs) and hard to classify as permanent migration.

Two orientation groups:
- **LGB+**: codes 1, 2, 3, 6 from variable P8_1
- **Heterosexual**: codes 4, 5

The outcome is the proportion of each group living in "treatment" states (those with comprehensive rights).

### The 2x2 DiD table

|  | Youth (15--19) | Adults (25+) | Difference |
|--|---------------|-------------|------------|
| **Heterosexual** | A | B | B - A |
| **LGB+** | C | D | D - C |
| **DiD** | | | (D - C) - (B - A) |

The DiD estimate `(D - C) - (B - A)` isolates the rights-based sorting component after netting out the economic gravity that affects everyone.

### Statistical implementation

- All proportions are survey-weighted using `svydesign(id = ~1, weights = ~factor)`
- The DiD is estimated as a linear probability model: `svyglm(in_gold_standard ~ mobility_cohort * orientation_group, family = gaussian())`
- The interaction term gives the DiD estimate in percentage points
- Z-tests for proportions are used for the descriptive 2x2 table

### Treatment definitions

Two thresholds are tested:
1. **Early adopters** (16 states): any state that legalized SSM before 2021
2. **Gold standard** (4 states): states with SSM + civil union + adoption (CDMX, Coahuila, Campeche, Michoacan)

The gold standard definition yields the significant result, consistent with the idea that comprehensive rights (not just marriage) signal a genuinely inclusive environment.

## Important Caveats

1. **No individual migration data by orientation.** ENOE does not ask about sexual orientation. The event study measures total migration, not LGB+-specific migration.
2. **Cross-sectional identification.** The ENDISEG cohort comparison is cross-sectional, not a panel. We observe distributions at one point in time, not individual moves.
3. **Correlation, not causation.** SSM legalization is correlated with broader social, economic, and political changes. The observed patterns may partly reflect these correlated factors.
4. **Small population share.** LGB+ individuals constitute ~5% of the population. Any migration signal is diluted in aggregate ENOE data, which explains the null event-study coefficients.
5. **Staggered design caveats.** Late-adopting states dominate the pre-trend estimates; early adopters dominate the post-trend. The Bacon decomposition helps assess the severity of this issue.
