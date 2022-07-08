# This script is the one that creates the dataset and stores it in the data/final route
def run():
    # import modules
    import pandas as pd
    from numpy import NaN
    from numpy import ceil

    # Auxiliary Data
    columns = pd.read_csv("auxiliary/columns.csv").clave.to_list()
    columns = [x.lower() for x in columns]
    marriage = pd.read_csv('auxiliary/equal_marriage.csv')

    # Create paths
    paths = []
    def create_path(year, quarter):
        path = "data/ENOE/raw/"+str(year)+"t"+str(quarter)+"/conjunto_de_datos_coe1_enoe_"+str(year)+"_"+str(quarter)+"t/conjunto_de_datos/conjunto_de_datos_coe1_enoe_"+str(year)+"_"+str(quarter)+"t.csv"
        return path


    
    # Create dataset
    def create_dataset(year,quarter):
        # Load dataset and reduce the number of columns for the ones that we really need
        df = pd.read_csv(create_path(year,quarter))
        interseccion = list(set(df.columns) & set(columns)) # To avoid any problems in loading the data
        df = pd.read_csv(create_path(year,quarter), usecols=interseccion) # This will load the data again, but only with the columns that we require. Ideally all of them.

        df2 = df.copy() # La data no se toca!
        df2['p3o'][df2['p3o'] == " "] = NaN # Empty cells should be changed to NaN
        df2['p3o'] = 2- pd.to_numeric(df2['p3o']) # Transform to dummy 1 and 0
        df_enoe = df2.groupby(['ent']).p3o.mean() # Create dataset by state
        df_enoe = pd.DataFrame({'ent':df_enoe.index, 'migr':df_enoe.values}) # Transform Multi-index to dataframe

        df_enoe['year'] = year
        df_enoe['quarter'] =  quarter

        return df_enoe
    
    
    for year in range(2017,2018): # 2017-2023
        for quarter in range(1,2): # 1-5
            df = create_dataset(year, quarter)
            df.to_csv('data/ENOE/final/lgbt_migration.csv')
    
    
if __name__ == '__main__':
    run()