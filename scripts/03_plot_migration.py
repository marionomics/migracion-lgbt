import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

def plot_single_trend():
    # 1. Load your dataset
    # Assuming the script is run from the project root
    df = pd.read_csv("data/ENOE/final/lgbt_migration.csv")

    # 2. Reconstruct the 'Year of Legalization' (year_em)
    # Since I don't have your auxiliary file, I used the official years.
    # If you have your file, you can replace this dictionary with:
    # em_map = pd.read_csv('auxiliary/equal_marriage.csv').set_index('cve')['year'].to_dict()
    
    year_em_map = {
        1: 2019,  # Aguascalientes
        2: 2017,  # Baja California
        3: 2019,  # Baja California Sur
        4: 2016,  # Campeche
        5: 2014,  # Coahuila
        6: 2016,  # Colima
        7: 2018,  # Chiapas
        8: 2015,  # Chihuahua
        9: 2010,  # Ciudad de México
        10: 2022, # Durango
        11: 2021, # Guanajuato
        12: 2022, # Guerrero
        13: 2019, # Hidalgo
        14: 2016, # Jalisco
        15: 2022, # México
        16: 2016, # Michoacán
        17: 2016, # Morelos
        18: 2015, # Nayarit
        19: 2019, # Nuevo León
        20: 2019, # Oaxaca
        21: 2020, # Puebla
        22: 2021, # Querétaro
        23: 2012, # Quintana Roo
        24: 2019, # San Luis Potosí
        25: 2021, # Sinaloa
        26: 2021, # Sonora
        27: 2022, # Tabasco
        28: 2022, # Tamaulipas
        29: 2020, # Tlaxcala
        30: 2022, # Veracruz
        31: 2022, # Yucatán
        32: 2021  # Zacatecas
    }

    # Map the legalization year to the dataframe
    df['year_em'] = df['ent'].map(year_em_map)

    # 3. Calculate Normalized Year (Time relative to reform)
    # We use decimal years for precision (quarter/4)
    df['current_time'] = df['year'] + (df['quarter'] - 1) / 4
    df['norm_year'] = df['current_time'] - df['year_em']
    
    # Round to nearest integer or 0.25 step if you prefer granularity
    # Matching your R logic (group by integer year deviation)
    df['norm_year_int'] = df['norm_year'].astype(int)

    # 4. Calculate Total Migration (The "One Line" Requirement)
    # Summing migration from Equal + Non-Equal states
    df['total_migration'] = df['from_equal'] + df['from_non_equal']

    # 5. Group by relative time and calculate mean
    df_plot = df.groupby('norm_year_int')['total_migration'].mean().reset_index()

    # Filter plot range to avoid noise at the extremes (e.g., -5 to +5 years)
    # df_plot = df_plot[(df_plot['norm_year_int'] >= -5) & (df_plot['norm_year_int'] <= 5)]

    # 6. Plotting
    plt.figure(figsize=(10, 6))
    
    # The Line
    sns.lineplot(data=df_plot, x='norm_year_int', y='total_migration', color='#2c3e50', linewidth=2.5)
    
    # The "Reform" vertical line
    plt.axvline(x=0, color='#e74c3c', linestyle='--', alpha=0.8, label='Marriage Equality Legalization')
    
    # Styling
    #plt.title('Total Migration Inflow vs. Time of Legalization', fontsize=14, pad=15)
    plt.xlabel('Years Relative to Legalization (0 = Reform Year)', fontsize=11)
    plt.ylabel('Average Migration Inflow', fontsize=11)
    plt.grid(True, linestyle=':', alpha=0.6)
    plt.legend()
    
    # Save or Show
    plt.tight_layout()
    plt.savefig("img/migration_lgbt_single_line.png", dpi=300)
    plt.show()
    print("Plot saved to img/migration_lgbt_single_line.png")

if __name__ == "__main__":
    plot_single_trend()