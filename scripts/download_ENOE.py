# This script downloads Open data from ENOE deom 2017 to 2022

from os import remove
import pandas as pd
from urllib.request import urlopen
from zipfile import ZipFile
from io import BytesIO
import os.path

def run():
    for year in range(2017,2023):
        for quarter in range(1,5):
            if str(year)+str(quarter) in [str(y)+str(i) for y in range(2020,2023) for i in range(1,5)]:
                # Enoe_N
                url = "https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/datosabiertos/"+str(year)+"/conjunto_de_datos_enoen_"+str(year)+"_"+str(quarter)+"t_csv.zip"
            elif str(year)+str(quarter) in [str(y)+str(i) for y in range(2018,2021) for i in range(1,5)]:
                url = "https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/datosabiertos/"+str(year)+"/conjunto_de_datos_enoe_"+str(year)+"_"+str(quarter)+"t_csv.zip"
            else:
                url = "https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/datosabiertos/"+str(year)+"/"+str(year)+"_trim"+str(quarter)+"_enoe_csv.zip"
            try:
                if os.path.exists("data/ENOE/raw/"+str(year)+"t"+str(quarter)):
                    print("data/ENOE/raw/"+str(year)+"t"+str(quarter)+" is already an existing file")
                else:
                    print("Loading data for ENOE in year "+ str(year)+", quarter "+str(quarter))
                    resp = urlopen(url)
                    zipfile = ZipFile(BytesIO(resp.read()))
                    zipfile.extractall("data/ENOE/raw/"+str(year)+"t"+str(quarter))
            except:
                print("There was a problem loading data for ENOE in year "+ str(year)+", quarter "+str(quarter))
            

if __name__=='__main__':
    run()