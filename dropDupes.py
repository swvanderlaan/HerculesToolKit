#!/usr/bin/env python
# script to drop duplicate lines given a file

import sys
import pandas as pd
import numpy as np

# set command line arguments
# improvement: get an argument parser in place

raw_data = sys.argv[1] # 0 is the index of name of python prog, 1 is the index of first argument in command line.
column_name_to_sort = sys.argv[2]
new_filename = sys.argv[3]

# read in data
df=pd.read_csv(raw_data, sep=' ')

# drop duplicates
# improvement: get a number of how many duplicates were dropped
df = df.drop_duplicates(subset = column_name_to_sort, keep = "first")

# sort based on column - seems to be extremely slow (MacBook, 2.4 GHz Quad-Core Intel Core i5, 16Gb)
#df.sort_values(by = [column_name_to_sort], inplace = True)

# write to .gz-file
# improvement: command line argument for file name
df.to_csv(new_filename, sep = ' ', compression = "gzip", index = False)

# improvement: 
# - get header in place
# - get functions in place
# - get copyright in place