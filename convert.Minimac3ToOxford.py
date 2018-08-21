import gzip
import io
from sys import argv, exit
import sys

COLUMNS_TO_KEEP = ["ID", "ID", "POS", "REF", "ALT", "UPID"]

SOME_FILE=argv[1]
try:

	with gzip.open(SOME_FILE, "rb") as gz:
		f = io.BufferedReader(gz)
		colmap = []
		for line in f.readlines():
			line = line.strip()
			if line.startswith("##"): 
				continue;
			if line.startswith("#"):
				colmap = line.split('\t')
				continue		
			fields = line.split("\t")
			for col in COLUMNS_TO_KEEP:
				for index, field in enumerate(fields):
					if colmap[index] == col:
						sys.stdout.write(field + " ")
					elif col == "UPID" and colmap[index].startswith("UPID"):
						UPID_GP = field.split(":")[2]
						UPID_GP = UPID_GP.split(",")
						sys.stdout.write(" ".join(UPID_GP)+ " ")

			sys.stdout.write('\n')

except IOError:

	exit()