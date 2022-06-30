# Some notes about ENOE and the questionaire

COE stands for Cuestionario de Ocupación y Empleo. The data is available quarterly and provides detailed information about employment in Mexico.

From this dataset we are interested in:

### Vivienda
(This section is optional)

* Period of the interview (PER). To differenciate between migrations in the time of the year.
* How many people live in the house (P1)

### Hogar Table

* Year of the interview (D_ANIO)
* Month of the interview (D_MES)

### Sociodemográfico

* Zone (LOC)
* Strata (EST)
* Design Strata (EST_D)
* Size of the zone (T_LOC)
* Position in the household (PAR_C)
* Sex (SEX). The survey only includes Male and Female. There is no mention of gender throughout the survey.
* Birthplace (L_NAC_C)
* Education (CS_P13_1)
* Level within education (CS_P13_2)
* Major / Carrera (CS_P14_C). You can choose from a range of majors.
* Children (N_HIJ)
* Married (E_CON)

---

Now we arrive to the questions about migration

**Left**

* Motives for absense (CS_AD_MOT)
* To which State in the republic you left (CS_AD_DES)
    1. Mismo estado
    2. Otro estado
    3. Otro país
    9. No sabe

**Arrived**
* Motives to arrive (CS_NR_MOT)
* Where did you arrive from? (CS_NR_ORI)

---

* If she lives in an urban or rural area. (UR)
* Wage zone (ZONA). 1: Frontier, 2: Rest of the country

--- 
These variables are needed to extrapolate and make inference
* Weight (FAC). Estimated weight to each data point representative of vivienda.

### Cuestionario de Ocupación y Empleo

#### Parte 1

First we capture some socioeconomic data 

* Result of interview (R_DEF). So we can filter only the finished interviews.
* City (CD_A)
* State of the interviewed (ENT)
* Number of times the household has moved (H_MUD).
* Age (EDA). Remember to filter minors from the survey.

---
To calculate weights

* Unidad Primaria de Muestreo (UPM)
* Control (CON)

---
Employment and activities
* Did you do any activities that yields income? (P1A1)
* Helped in family business? (P1A2)
* Did not work last week (P1A3)
* Self-employed? (P1B)
* Reason not to work (P1C)

* **Have you tried looking for work elsewhere?** (P2_1)
* Have you tried looking for work here in Mexico? (P2_2)
* Have you tried setting up a business? (P2_3)
* So you haven't tried to look for work?
* Month you started looking for work (P2A_MES)
* Year you started looking for work ("2A_ANIO)
* Do you NEED to work? (P2F)

About the job
* Benefits (P3M1 to P3M9). Infonavit, daycare, time for care, retirement fund, insurance.
* To get or keep this job did you need to change city or location? (P3O)
* Before this change, in which State did you live? ( P3P1)
* Approximately, how many people, including the owner, work at your workplace? (P3Q).
* Time you started working for the first time (P3R)
* Market / Industry of workplace (P4A). SCIAN code.
* General area of business workplace(P4B)

#### Parte 2

* Income (P7GCAN). In pesos.

---
* Have you tried to look up for work in other country? (P8_1)
* 

