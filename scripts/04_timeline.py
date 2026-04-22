import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from matplotlib.lines import Line2D

# 1. UPDATED DATA (Including 'Civil_Union')
data = [
    {"State": "Aguascalientes", "Marriage_Date": "2 de abril de 2019", "Adoption": "Sí", "Civil_Union": "No"},
    {"State": "Baja California", "Marriage_Date": "16 de junio de 2021", "Adoption": "Sí", "Civil_Union": "No"},
    {"State": "Baja California Sur", "Marriage_Date": "27 de junio de 2019", "Adoption": "No", "Civil_Union": "No"},
    {"State": "Campeche", "Marriage_Date": "10 de mayo de 2016", "Adoption": "Sí", "Civil_Union": "Sí"},
    {"State": "Chiapas", "Marriage_Date": "11 de julio de 2017", "Adoption": "Sí", "Civil_Union": "No"},
    {"State": "Chihuahua", "Marriage_Date": "11 de junio de 2015", "Adoption": "Sí", "Civil_Union": "No"},
    {"State": "Ciudad de México", "Marriage_Date": "29 de diciembre de 2009", "Adoption": "Sí", "Civil_Union": "Sí"},
    {"State": "Coahuila", "Marriage_Date": "1 de septiembre de 2014", "Adoption": "Sí", "Civil_Union": "Sí"},
    {"State": "Colima", "Marriage_Date": "25 de mayo de 2016", "Adoption": "Sí", "Civil_Union": "No"},
    {"State": "Durango", "Marriage_Date": "16 de septiembre de 2022", "Adoption": "Sí", "Civil_Union": "No"},
    {"State": "Guanajuato", "Marriage_Date": "20 de diciembre de 2021", "Adoption": "No", "Civil_Union": "No"},
    {"State": "Guerrero", "Marriage_Date": "25 de octubre de 2022", "Adoption": "No", "Civil_Union": "No"},
    {"State": "Hidalgo", "Marriage_Date": "24 de mayo de 2019", "Adoption": "Sí", "Civil_Union": "No"},
    {"State": "Jalisco", "Marriage_Date": "6 de abril de 2022", "Adoption": "Sí", "Civil_Union": "No"},
    {"State": "México", "Marriage_Date": "11 de octubre de 2022", "Adoption": "No", "Civil_Union": "No"},
    {"State": "Michoacán", "Marriage_Date": "18 de mayo de 2016", "Adoption": "Sí", "Civil_Union": "Sí"},
    {"State": "Morelos", "Marriage_Date": "18 de mayo de 2016", "Adoption": "Sí", "Civil_Union": "No"},
    {"State": "Nayarit", "Marriage_Date": "17 de diciembre de 2015", "Adoption": "Sí", "Civil_Union": "No"},
    {"State": "Nuevo León", "Marriage_Date": "14 de junio de 2023", "Adoption": "Sí", "Civil_Union": "No"},
    {"State": "Oaxaca", "Marriage_Date": "28 de agosto de 2019", "Adoption": "No", "Civil_Union": "No"},
    {"State": "Puebla", "Marriage_Date": "3 de noviembre de 2020", "Adoption": "Sí", "Civil_Union": "No"},
    {"State": "Querétaro", "Marriage_Date": "22 de septiembre de 2021", "Adoption": "Sí", "Civil_Union": "No"},
    {"State": "Quintana Roo", "Marriage_Date": "3 de mayo de 2012", "Adoption": "Sí", "Civil_Union": "No"},
    {"State": "San Luis Potosí", "Marriage_Date": "17 de mayo de 2019", "Adoption": "Sí", "Civil_Union": "No"},
    {"State": "Sinaloa", "Marriage_Date": "15 de junio de 2021", "Adoption": "No", "Civil_Union": "No"},
    {"State": "Sonora", "Marriage_Date": "23 de septiembre de 2021", "Adoption": "No", "Civil_Union": "No"},
    {"State": "Tabasco", "Marriage_Date": "19 de octubre de 2022", "Adoption": "No", "Civil_Union": "No"},
    {"State": "Tamaulipas", "Marriage_Date": "26 de octubre de 2022", "Adoption": "Sí", "Civil_Union": "No"},
    {"State": "Tlaxcala", "Marriage_Date": "8 de diciembre de 2020", "Adoption": "No", "Civil_Union": "Sí"},
    {"State": "Veracruz", "Marriage_Date": "2 de junio de 2022", "Adoption": "Sí", "Civil_Union": "Sí"},
    {"State": "Yucatán", "Marriage_Date": "25 de agosto de 2021", "Adoption": "No", "Civil_Union": "No"},
    {"State": "Zacatecas", "Marriage_Date": "14 de diciembre de 2021", "Adoption": "No", "Civil_Union": "No"}
]

df = pd.DataFrame(data)

# 2. Date Parsing
months = {
    "enero": 1, "febrero": 2, "marzo": 3, "abril": 4, "mayo": 5, "junio": 6,
    "julio": 7, "agosto": 8, "septiembre": 9, "octubre": 10, "noviembre": 11, "diciembre": 12
}

def parse_date(date_str):
    try:
        parts = date_str.lower().split()
        day = int(parts[0])
        month = months[parts[2]]
        year = int(parts[4])
        return pd.Timestamp(year=year, month=month, day=day)
    except:
        return None

df['Date'] = df['Marriage_Date'].apply(parse_date)
df = df.sort_values('Date')
df = df.reset_index(drop=True) # Reset index for clean y-axis spacing

# 3. Create the Plot
fig, ax = plt.subplots(figsize=(14, 13))

# Draw the horizontal lollipop lines first
y_range = range(len(df))
ax.hlines(y=y_range, xmin=df['Date'].min(), xmax=df['Date'], color='skyblue', alpha=0.5)

# --- PLOTTING LOGIC ---
# We loop through the groups to assign markers (Shapes) and colors
# Shape: Civil Union (Diamond=Yes, Circle=No)
# Color: Adoption (Green=Yes, Red=No)

markers = {'Sí': 'D', 'No': 'o'} # D = Diamond, o = Circle
colors = {'Sí': '#4CAF50', 'No': '#F44336'}

for cu_status in ['Sí', 'No']:
    for ad_status in ['Sí', 'No']:
        # Filter data
        subset = df[(df['Civil_Union'] == cu_status) & (df['Adoption'] == ad_status)]
        
        if not subset.empty:
            ax.scatter(
                subset['Date'], 
                subset.index, 
                c=colors[ad_status], 
                marker=markers[cu_status], 
                s=130, # Size
                edgecolor='black', # Add outline for better visibility
                linewidth=0.5,
                alpha=1, 
                zorder=3
            )

# Add State Names
for i, (date, state) in enumerate(zip(df['Date'], df['State'])):
    ax.text(date, i, f"  {state}", va='center', fontsize=10, fontfamily='sans-serif')

# 4. Formatting
ax.xaxis.set_major_locator(mdates.YearLocator())
ax.xaxis.set_major_formatter(mdates.DateFormatter('%Y'))
ax.set_yticks([])
#ax.set_title('Timeline of LGBT+ Rights in Mexico: Marriage, Adoption, and Civil Unions', fontsize=18, pad=20)
ax.set_xlabel('Year of Marriage Legalization', fontsize=12)

# Spines & Grid
ax.spines['left'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.spines['top'].set_visible(False)
ax.grid(axis='x', linestyle='--', alpha=0.5)

# 5. Custom Legend
legend_elements = [
    # Color Legend
    Line2D([0], [0], marker='o', color='w', label='Adoption: Allowed',
           markerfacecolor='#4CAF50', markersize=12, markeredgecolor='k'),
    Line2D([0], [0], marker='o', color='w', label='Adoption: Not Allowed',
           markerfacecolor='#F44336', markersize=12, markeredgecolor='k'),
    
    # Spacer
    Line2D([0], [0], color='w', label=' ', markersize=0),
    
    # Shape Legend
    Line2D([0], [0], marker='D', color='w', label='Civil Union: Available',
           markerfacecolor='gray', markersize=12, markeredgecolor='k'),
    Line2D([0], [0], marker='o', color='w', label='Civil Union: Not Available',
           markerfacecolor='gray', markersize=12, markeredgecolor='k'),
]

ax.legend(handles=legend_elements, loc='lower right', title="Legal Status", frameon=True)

plt.tight_layout()
plt.show()