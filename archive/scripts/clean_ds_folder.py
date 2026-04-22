# This is script to remove all datasets from ENOE that does not have the necessary columns for analysis
# Thread carefully here!

import os


path = "./data/ENOE"
for filename in os.listdir(path):
    print(filename)