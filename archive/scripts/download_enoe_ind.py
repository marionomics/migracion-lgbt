#

from logging import exception
import os.path
from urllib.request import urlopen
from zipfile import ZipFile
from io import BytesIO


def run():
    url = "https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/datosabiertos/2018/2018_trim1_enoe_csv.zip"
    year = 2018
    quarter = 1

    try:
        if os.path.exists("data/ENOE/raw/"+str(year)+"t"+str(quarter)):
            print("data/ENOE/raw/"+str(year)+"t"+str(quarter)+" is already an existing file")
        else:
            print("Loading data for ENOE in year "+ str(year)+", quarter "+str(quarter))
            resp = urlopen(url)
            zipfile = ZipFile(BytesIO(resp.read()))
            zipfile.extractall("data/ENOE/raw/"+str(year)+"t"+str(quarter))
            print('Successfully downloaded data')
    except Exception as e:
        print("There was a problem loading data for ENOE in year "+ str(year)+", quarter "+str(quarter))
        print(e)


if __name__ == '__main__':
    run()