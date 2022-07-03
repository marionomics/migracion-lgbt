# This script helps Identify the datasets that hold the required columns. It returns the list

def run():
    from pandas import read_csv
    print("Inicio de la ejecución...")
    columns = read_csv("data/auxiliary/columns.csv").clave.to_list()
    columns = [x.lower() for x in columns]
    for encuesta in range(1,3):
        for year in range(10,21):
            for quarter in range(1,5):
                path = "data/ENOE/coe"+str(encuesta)+"t"+str(quarter)+str(year)+".csv"
                print(path)

if __name__ == "__main__":
    run()