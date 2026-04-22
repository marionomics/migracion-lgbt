# migracion-lgbt

In this project we explore the hypothesis that discrimination against LGBT+ people as a cause of migration.

En este proyecto exploramos la discriminación a las personas LGBT como causa de la migración interna en México.


You can read the manuscript of the article in the link: https://docs.google.com/document/d/1QiWp5SE2xpwli11z_yadPEzZB5JpeTo-WCNoQacPUD4/edit?usp=sharing

## Notebooks

* [Load the dataset from url of ENOE](https://github.com/marionomics/migracion-lgbt/blob/main/notebooks/extract_datasets.ipynb). You can start here. This should have been just a script, but I started it as a notebook and it has a bit of explanation.

## Scripts

At some point during the research I had to filter all the datasets from ENOE, since not always I found the required element. So I decided to use a script to identify which datasets have the required colums. The list is found in `auxiliary/ENOE_available.csv`, and it can be run with script on `scripts/find_datasets.py`.

## Data
All raw data gets downloaded in `data` folder automatically when running the `extract_datasets` notebook.