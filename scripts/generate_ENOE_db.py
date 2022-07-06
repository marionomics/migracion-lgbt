import pandas as pd


columns = pd.read_csv("auxiliary/columns.csv").clave.to_list()
columns = [x.lower() for x in columns]

available = pd.read_csv("auxiliary/ENOE_available.csv", names = ['path']).path.to_list()


df = pd.DataFrame()

for ruta in available:
    print('procesando ' + ruta)
    df_temp = pd.read_csv(ruta)
    interseccion = list(set(df_temp.columns) & set(columns))
    
    if 'p3p1' in interseccion:
        print("p3o is in da house!")
        df_temp2 = pd.read_csv(ruta, usecols=interseccion)
        df_temp2['encuesta'] = ruta[13:14]
        df_temp2['quarter'] = ruta[15:16]
        df_temp2['year'] = ruta[16:18]
        df = pd.concat([df,df_temp2])
    else:
        print('No encuentro una variable que nos interesa mucho')

df.to_csv('data/processed/enoe.csv')
print("El proceso fue exitoso. Se creó una tabla única con las siguientes dimensiones: ")
print(df.shape)
