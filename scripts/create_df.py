# This script is the one that creates the dataset and stores it in the data/final route
def run():
    # import modules
    import pandas as pd
    import numpy as np
    import re

    # Auxiliary Data
    columns = pd.read_csv("auxiliary/columns.csv").clave.to_list()
    columns = [x.lower() for x in columns]
    marriage = pd.read_csv('auxiliary/equal_marriage.csv')

    marriage['quarter'] = np.ceil(marriage['month']/3)
    marriage['date'] = marriage['year'] + marriage['quarter']/5 # Its inexact, but it helps to make the simple comparison in the migration table
    marriage = marriage[['cve','date']]

    # Create paths
    paths = []
    def create_path(year, quarter):
        if (year + quarter/5 < 2020.4):
            path = "data/ENOE/raw/"+str(year)+"t"+str(quarter)+"/conjunto_de_datos_coe1_enoe_"+str(year)+"_"+str(quarter)+"t/conjunto_de_datos/conjunto_de_datos_coe1_enoe_"+str(year)+"_"+str(quarter)+"t.csv"
        else:
            path = "data/ENOE/raw/"+str(year)+"t"+str(quarter)+"/conjunto_de_datos_coe1_enoen_"+str(year)+"_"+str(quarter)+"t/conjunto_de_datos/conjunto_de_datos_coe1_enoen_"+str(year)+"_"+str(quarter)+"t.csv"
        return path


    
    # Create dataset
    def create_dataset(year,quarter):
        # Load dataset and reduce the number of columns for the ones that we really need
        df = pd.read_csv(create_path(year,quarter))
        interseccion = list(set(df.columns) & set(columns)) # To avoid any problems in loading the data
        df = pd.read_csv(create_path(year,quarter), usecols=interseccion) # This will load the data again, but only with the columns that we require. Ideally all of them.

        df2 = df.copy() # La data no se toca!
        df2 = df2[df2['eda'] > 14]
        df2['p3o'][df2['p3o'] == " "] = np.NaN # Empty cells should be changed to NaN
        df2['p3o'] = 2- pd.to_numeric(df2['p3o']) # Transform to dummy 1 and 0
        df_enoe = df2.groupby(['ent']).p3o.mean() # Create dataset by state
        df_enoe = pd.DataFrame({'ent':df_enoe.index, 'migr':df_enoe.values}) # Transform Multi-index to dataframe

        df_enoe['year'] = year
        df_enoe['quarter'] =  quarter
        
        # En donde vivias antes?
        df2['p3p2'][df['p3p2'] == " "] = np.NaN # The blank spaces are coded in the dataset as " ". This line changes them to NaN
        migration_table = df2.groupby(['ent', 'p3p2']).size() # Comenzamos a crear una tabla de migraciones usando la base de datos
        migration_table = migration_table.reset_index()
        migration_table = migration_table.pivot(index = 'ent', columns = 'p3p2')
        migration_table['year'] = year
        migration_table['quarter'] = quarter

        # Creamos la tabla de flujos migratorios
        df_flujos = pd.merge(migration_table,marriage, left_on = 'ent', right_on='cve', how='left')
        text = str(df_flujos.columns[0])
        names = [re.search(r"'([A-Za-z0-9_\./\\-]*)'",str(text)) for text in df_flujos.columns]
        columnas = [name.group().replace("'","") for name in names if type(name) == re.Match]
        df_flujos.columns = columnas + ['cve', 'date']
        df_flujos['equal_marriage'] = np.where((df_flujos['date']<= df_flujos['year']+df_flujos['quarter']/5),1,0)

        # List of inclusive and non inclusive states
        inclusive_states = list(df_flujos[df_flujos['equal_marriage'] == 1].cve)
        inclusive_states = [str(i) for i in inclusive_states]
        non_inclusive_states = list(df_flujos[df_flujos['equal_marriage'] == 0].cve)
        non_inclusive_states = [str(i) for i in non_inclusive_states]

        # Usamos la tabla de flujos para crear la base de datos de migraciones por estado
        df_migraciones = pd.DataFrame({'cve':range(1,33)})
        df_migraciones['to_non_equal'] =[df_flujos[df_flujos['equal_marriage'] == 0][str(i)].sum() for i in range(1,33)]
        df_migraciones['to_equal'] =[df_flujos[df_flujos['equal_marriage'] == 1][str(i)].sum() for i in range(1,33)]
        df_migraciones['from_equal'] = [df_flujos[df_flujos['cve'] == i][inclusive_states].sum().sum() for i in range(1,33)]
        df_migraciones['from_non_equal'] = [df_flujos[df_flujos['cve'] == i][non_inclusive_states].sum().sum() for i in range(1,33)]
        df_migraciones = pd.merge(df_flujos[['cve','equal_marriage']],df_migraciones, left_on='cve',right_on='cve', how = 'left')
        #df_migraciones['date'] = year + quarter/5 # Maybe not needed

        # Left Join the Migrations to the table
        df_enoe = pd.merge(df_enoe,df_migraciones, left_on='ent',right_on='cve', how = 'left')

        # Finally we are including an employment indicator
        df2['p1'] = 2 - df['p1']
        df3 = df2.groupby(['ent']).p1.mean()
        df3 = df3.reset_index()

        # Include the new variable by merging it with the main dataframe
        df_enoe = pd.merge(df_enoe,df3, left_on='ent',right_on='ent', how = 'left')

        return df_enoe
    
    df = pd.DataFrame()
    for year in range(2017,2023): # 2017-2023
        for quarter in range(1,2): # 1-5
            try:
                df_to_concatenate = create_dataset(year, quarter)
                df = pd.concat([df, df_to_concatenate], ignore_index=True)
                df.to_csv('data/ENOE/final/lgbt_migration.csv')
                print('He concatenado con exito la base de datos de ' + str(year) + ' en el trimestre ' + str(quarter))
            except Exception as e:
                print("Hubo un error al concatenar la base de datos")
                print(e)
    
    
if __name__ == '__main__':
    run()