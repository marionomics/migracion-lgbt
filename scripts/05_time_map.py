import geopandas as gpd
import matplotlib.pyplot as plt
import pandas as pd

# 1. Load the Data
data = [
    {"State": "Aguascalientes", "Year": 2019}, {"State": "Baja California", "Year": 2021},
    {"State": "Baja California Sur", "Year": 2019}, {"State": "Campeche", "Year": 2016},
    {"State": "Chiapas", "Year": 2017}, {"State": "Chihuahua", "Year": 2015},
    {"State": "Ciudad de México", "Year": 2010}, {"State": "Coahuila", "Year": 2014},
    {"State": "Colima", "Year": 2016}, {"State": "Durango", "Year": 2022},
    {"State": "Guanajuato", "Year": 2021}, {"State": "Guerrero", "Year": 2022},
    {"State": "Hidalgo", "Year": 2019}, {"State": "Jalisco", "Year": 2022},
    {"State": "Mexico", "Year": 2022}, {"State": "Michoacán", "Year": 2016},
    {"State": "Morelos", "Year": 2016}, {"State": "Nayarit", "Year": 2015},
    {"State": "Nuevo León", "Year": 2023}, {"State": "Oaxaca", "Year": 2019},
    {"State": "Puebla", "Year": 2020}, {"State": "Querétaro", "Year": 2021},
    {"State": "Quintana Roo", "Year": 2012}, {"State": "San Luis Potosí", "Year": 2019},
    {"State": "Sinaloa", "Year": 2021}, {"State": "Sonora", "Year": 2021},
    {"State": "Tabasco", "Year": 2022}, {"State": "Tamaulipas", "Year": 2022},
    {"State": "Tlaxcala", "Year": 2020}, {"State": "Veracruz", "Year": 2022},
    {"State": "Yucatán", "Year": 2021}, {"State": "Zacatecas", "Year": 2021}
]
df = pd.DataFrame(data)

# 2. Load Mexico GeoJSON (Direct from GitHub)
url = "https://raw.githubusercontent.com/angelnmara/geojson/master/mexicoHigh.json"
gdf = gpd.read_file(url)

# 3. Clean Names for Matching
# The GeoJSON usually uses standard names; we map 'Mexico' to 'Estado de México' if needed
name_map = {"México": "Mexico", "Distrito Federal": "Ciudad de México"}
gdf['name'] = gdf['name'].replace(name_map)

# 4. Merge Data
gdf = gdf.merge(df, left_on='name', right_on='State', how='left')

# 5. Plot
fig, ax = plt.subplots(1, 1, figsize=(15, 10))
gdf.plot(column='Year', ax=ax, legend=True,
         legend_kwds={'label': "Year of Legalization", 'orientation': "horizontal"},
         cmap='viridis_r', edgecolor='black', linewidth=0.5)
ax.set_title('Expansion of Same-Sex Marriage in Mexico by Year', fontsize=16)
ax.set_axis_off()
plt.show()