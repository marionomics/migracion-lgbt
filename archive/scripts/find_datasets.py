# This script helps Identify the datasets that hold the required columns. It returns the list

def run():
    import csv
    from pandas import read_csv
    print("Inicio de la ejecución...")
    columns = read_csv("auxiliary/columns.csv").clave.to_list()
    columns = [x.lower() for x in columns]
    datasets = []
    for encuesta in range(1,3): #1-3
        for year in range(10,21): # 10-21
            for quarter in range(1,5): # 1-5
                path = "data/ENOE/coe"+str(encuesta)+"t"+str(quarter)+str(year)+".csv"
                try:                    
                    df = read_csv(path)
                    if not list(set(df.columns) & set(columns)):
                        print("Intersection of columns in file coe"+str(encuesta)+"t"+str(quarter)+str(year)+" with the list of variables needed is empty")
                    else:
                        datasets.append(path)
                        print("Added "+path+ " to the list of available datasets")
                        with open('auxiliary/ENOE_available.csv', 'w', newline='') as f:
                            wr = csv.writer(f, quoting=csv.QUOTE_ALL)
                            wr.writerow(path)
                except:
                    print("No pude abrir el archivo " + path)
    
    # Write dataset list in csv file
    with open('auxiliary/ENOE_available.csv', 'w') as f:
        for ds in datasets:
            f.write(ds + '\n')


                

if __name__ == "__main__":
    run()