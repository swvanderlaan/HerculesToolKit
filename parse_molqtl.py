#!/usr/bin/env python3
"""
Script for extracting and analyzing molQTL results from the Athero-Express Biobank Study.

Usage:
    python script_name.py --trait HTRA1 --project_name PROJECTNAME --population EUR

Options:
    --trait: Phenotype of interest (default: HTRA1)
    --project_name: Name of the project (default: HTRA1)
    --population: Population code (default: EUR)
"""

# Version information
VERSION_NAME = 'parse_molqtl'
VERSION = '1.0.0'
VERSION_DATE = '2024-01-12'
COPYRIGHT = 'Copyright 1979-2024. Sander W. van der Laan | s.w.vanderlaan [at] gmail [dot] com | https://vanderlaanand.science.'
COPYRIGHT_TEXT = f'\nThe MIT License (MIT). \n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and \nassociated documentation files (the "Software"), to deal in the Software without restriction, \nincluding without limitation the rights to use, copy, modify, merge, publish, distribute, \nsublicense, and/or sell copies of the Software, and to permit persons to whom the Software is \nfurnished to do so, subject to the following conditions: \n\nThe above copyright notice and this permission notice shall be included in all copies \nor substantial portions of the Software. \n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, \nINCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR \nPURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS \nBE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, \nTORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE \nOR OTHER DEALINGS IN THE SOFTWARE. \n\nReference: http://opensource.org.'

import os
import importlib
import subprocess
from datetime import datetime
import time
import argparse

import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
import polars as pl
from scipy import stats
import numpy as np
import cmcrameri as ccm
from cmcrameri import cm
import matplotlib.pyplot as plt
import seaborn as sns
import gwaslab as gl

def check_install_package(package_name):
    try:
        importlib.import_module(package_name)
    except ImportError:
        print(f'{package_name} is not installed. Installing it now...')
        subprocess.check_call(['pip', 'install', package_name])

def molqtl_merge_and_export(target_variants, sumstats, left_col, right_col, sort_column, output_csv):
    print(f'Merging target variants with nominal cis-eQTLs.')
    temp = target_variants.join(sumstats, left_on=left_col, right_on=right_col, how="inner")
    print(f'> Sorting the DataFrame by column "{sort_column}" in descending order.')
    result = temp.sort(sort_column)
    del temp
    print(f'> Showing the first 5 rows of the DataFrame.')
    print(result)
    print(f'> Exporting the Polars DataFrame to a CSV file.')
    result.write_csv(output_csv)

def main(args):
#     parser = argparse.ArgumentParser(description=f'''
# + {VERSION_NAME} v{VERSION} +

# This script identifies and organizes multiplicate files based on specified criteria, such as `--output` for the
# output file name, study type (`--study_type`), stain name (`--stain`). It prioritizes multiplicates according to 
# certain rules. It provides options (`--verbose`) to output information about the multiplicates and log statistics 
# using `--log`.

# Images are expected to be of the form `study_typestudy_number.[additional_info.]stain.[random_info.]file_extension`, 
# e.g., `AE1234.T01-12345.CD34.ndpi`, where `AE` is the `study_type`, `1234` is the `study_number`, 
# `T01-12345` is the `additional_info` and optional, `CD34` is the stain name, and `ndpi` is the `file_extension`. 
# The `random_info` is optional and can be any random string of characters, e.g. `2017-12-22_23.54.03`. The 
# `file_extension` is expected to be `ndpi` or `TIF` for the original image files. 

# The script will move all files with the same `study_number` and `stain` name to the duplicate folder. It will 
# prioritize the files based on the following criteria:
# - There is a ndpi > keep ndpi, `keep_this_one`
# - Different creation date > keep latest file, `different_date_kept_latest`
# - Same date, different type > keep ndpi, `same_date_diff_type_kept_ndpi`
# - Same date, same type, different checksum > keep biggest, `same_date_same_type_diff_checksum_biggest`
# - Same date, same type, same checksum > keep first one, `same_date_same_type_same_checksum_keep_this_one`
# - When none of the above apply > `cannot_assign_priority`

# Example usage:
# python slideDupIdentify.py --study_type AE --stain CD34 --output duplicate_files [options: --force --dry_run --verbose]
#         ''',
#         epilog=f'''
# + {VERSION_NAME} v{VERSION}. {COPYRIGHT} \n{COPYRIGHT_TEXT}+''', 
#         formatter_class=argparse.RawTextHelpFormatter)
#     parser.add_argument('--image_folder', '-i', help='Specify the folder where images are located (default: current directory). Optional.')
#     parser.add_argument('--study_type', '-t', required=True, help='Specify the study type prefix, e.g., AE. Required.')
#     parser.add_argument('--stain', '-s', required=True, help='Specify the stain name, e.g., CD34. Required.')
#     parser.add_argument('--out_file', '-o', required=True, help='Specify the output file name (without extension) to write duplicate information. Required.')
#     parser.add_argument('--force', '-f', action='store_true', help='Force overwrite if the output file already exists. Optional.')
#     parser.add_argument('--dry_run', '-d', action='store_true', help='Perform a dry run (report in the terminal, no actual file operations. Optional.')
#     parser.add_argument('--debug', '-D', action='store_true', help='Print debug information. Optional.')
#     parser.add_argument('--verbose', '-v', action='store_true', help='Print the number of duplicate samples identified. Optional.')
#     parser.add_argument('--version', '-V', action='version', version=f'%(prog)s {VERSION} ({VERSION_DATE}).')
#     args = parser.parse_args()

#     # Set the debug variable
#     debug=args.debug
    
#     # Start the timer
#     start_time = time.time()

#     print(f"+ {VERSION_NAME} v{VERSION} ({VERSION_DATE}) +")
#     print(f"\nIdentify and move multiplicate image files based on specified criteria for:\n> study_type: {args.study_type}\n> stain: {args.stain}")
    
#     if debug:
#         print(f"\n>>> Debugging Mode: ON <<<\n")

    # Set some general defaults
    TRAIT_OF_INTEREST = args.trait
    PROJECTNAME = args.project_name
    POPULATION = args.population
    PLOTS_loc = "PLOTS"
    molQTL_loc = "molQTL_results"

    # Get today's date
    today_date = datetime.now()
    FORMATTED_TODAY = today_date.strftime("%Y%m%d")

    # Create directories if they don't exist
    for directory in [molQTL_loc, PLOTS_loc]:
        if not os.path.exists(directory):
            os.makedirs(directory)

    # Reference and GWAS data directories (provide your paths)
    REF_loc = "/Users/slaan3/PLINK/references"
    GWAS_loc = "/Users/slaan3/PLINK/_GWAS_Datasets"

    # Check contents of reference and GWAS directories
    print(f'Checking contents of the reference directory:')
    print(os.listdir(REF_loc))

    print(f'Checking contents of the GWAS directory:')
    print(os.listdir(GWAS_loc))

    # molQTL data directories (provide your paths)
    NOM_CIS_EQTL_loc = "/Users/slaan3/git/CirculatoryHealth/molqtl/results/version1_aernas1_firstrun/nom_cis_eqtl"
    PERM_CIS_MQTL_loc = "/Users/slaan3/git/CirculatoryHealth/molqtl/results/perm_cis_mqtl"
    PERM_TRANS_EQTL_loc = "/Users/slaan3/git/CirculatoryHealth/molqtl/results/version1_aernas1_firstrun/perm_trans_eqtl"
    PERM_TRANS_MQTL_loc = "/Users/slaan3/git/CirculatoryHealth/molqtl/results/perm_trans_mqtl"

    # Check contents of molQTL data directories
    for directory in [NOM_CIS_EQTL_loc, PERM_CIS_MQTL_loc, PERM_TRANS_EQTL_loc, PERM_TRANS_MQTL_loc]:
        print(f'Checking contents of the directory: {directory}')
        print(os.listdir(directory))

    # Load the list of variants of interest for this project
    target_variants = pl.read_excel(source=os.path.join("targets/targets.xlsx"), sheet_name="Variants")

    # Load nominal cis-eQTL data
    sumstats_nom_cis_eqtl = pl.read_parquet(source=os.path.join(NOM_CIS_EQTL_loc, "tensorqtl_nominal_cis_qtl_pairs.annot.parquet"))

    # Merge and export nominal cis-eQTL data
    molqtl_merge_and_export(target_variants, sumstats_nom_cis_eqtl, "VariantID", "VariantID",
                            "pval_nominal", os.path.join(molQTL_loc, FORMATTED_TODAY + "." + PROJECTNAME + ".nom_cis_eqtl.csv"))

    # Clean up
    del sumstats_nom_cis_eqtl

    # Load nominal cis-mQTL data
    file_path_perm_cis_mqtl = os.path.join(PERM_CIS_MQTL_loc, "tensormqtl.perm_cis_mqtl.txt")
    sumstats_perm_cis_mqtl = pl.read_csv(file_path_perm_cis_mqtl, has_header=True, separator="\t", ignore_errors=True)

    # Merge and export nominal cis-mQTL data
    molqtl_merge_and_export(target_variants, sumstats_perm_cis_mqtl, "VariantID", "variant_id",
                            "pval_nominal", os.path.join(molQTL_loc, FORMATTED_TODAY + "." + PROJECTNAME + ".perm_cis_mqtl.csv"))

    # Clean up
    del sumstats_perm_cis_mqtl

    # Load nominal trans-eQTL data
    file_path_perm_trans_eqtl = os.path.join(PERM_TRANS_EQTL_loc, "tensorqtl_trans_full.trans_qtl_pairs.parquet")
    sumstats_perm_trans_eqtl = pl.read_parquet(file_path_perm_trans_eqtl)

    # Merge and export nominal trans-eQTL data
    molqtl_merge_and_export(target_variants, sumstats_perm_trans_eqtl, "VariantID", "variant_id",
                            "pval", os.path.join(molQTL_loc, FORMATTED_TODAY + "." + PROJECTNAME + ".perm_trans_eqtl.csv"))

    # Clean up
    del sumstats_perm_trans_eqtl

    # Load nominal trans-mQTL data
    file_path_perm_trans_mqtl = os.path.join(PERM_TRANS_MQTL_loc, "tensormqtl_perm_trans_qtl_pairs.annot.parquet")
    sumstats_perm_trans_mqtl = pl.read_parquet(file_path_perm_trans_mqtl)

    # Merge and export nominal trans-mQTL data
    molqtl_merge_and_export(target_variants, sumstats_perm_trans_mqtl, "VariantID", "VariantID",
                            "pval_perm", os.path.join(molQTL_loc, FORMATTED_TODAY + "." + PROJECTNAME + ".perm_trans_mqtl.csv"))

    # Clean up
    del sumstats_perm_trans_mqtl

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Script for extracting and analyzing molQTL results.")
    parser.add_argument("--trait", default="HTRA1", help="Phenotype of interest (default: HTRA1)")
    parser.add_argument("--project_name", default="HTRA1", help="Name of the project (default: HTRA1)")
    parser.add_argument("--population", default="EUR", help="Population code (default: EUR)")
    args = parser.parse_args()
    main(args)

#    # Calculate the elapsed time in seconds
#     elapsed_time = time.time() - start_time
#     # Convert seconds to a timedelta object
#     time_delta = timedelta(seconds=elapsed_time)
#     # Extract hours, minutes, seconds, and milliseconds
#     hours, remainder = divmod(time_delta.seconds, 3600)
#     minutes, seconds = divmod(remainder, 60)
#     milliseconds = round(time_delta.microseconds / 1000)
#     # Print the script execution time in the desired format
#     formatted_time = f"{hours} hours, {minutes} minutes, {seconds} seconds, {milliseconds} milliseconds"

#    # Write the statistics to a log file
#     try:
#         with open(log_file_path, 'w') as log_file:
#             log_file.write(f"+ {VERSION_NAME} v{VERSION} +")
#             log_file.write(f"\nLookup WSI files in VirtuaSlides of the Athero-Express and AAA-Express Biobank Studies.\n")
#             log_file.write(f"\nExecuted lookup using the following conditions:")
#             log_file.write(f"\n> Study type: {args.study_type}")
#             log_file.write(f"\n> Direcor(y/ies): {args.dir}")
#             log_file.write(f"\n> Samples: {args.samples}\n")

#             ### WANT TO ADD THIS LATER ###
#             # log_file.write(f"\nFound the following samples:.\n")
#             # log_file.write(f" > sample - directory - filename") # {sample} - {directory} - {file}
#             # log_file.write(f"Total WSI samples found: X .\n") # {sum(study_numbers_count.values())}
#             # log_file.write(f"Total WSI samples search for: Y .\n") # {len(study_numbers_count)}
#             # log_file.write(f"Total WSI samples not found: Z .\n") # {len(study_numbers_count) - sum(study_numbers_count.values())}
            
#             log_file.write(f"\nScript executed on {today_date.strftime('%Y-%m-%d')}. Total execution time was {formatted_time} ({time.time() - start_time:.2f} seconds).\n")
#             log_file.write(f"\n+ {VERSION_NAME} v{VERSION}. {COPYRIGHT} +")
#             log_file.write(f"\n{COPYRIGHT_TEXT}")

#             ### WANT TO ADD THIS LATER ###
#             # Print the statistics to the terminal
#             # if args.verbose:
#             #     print(f"Total WSI samples found: X .\n") # {sum(study_numbers_count.values())}
#             #     print(f"Total WSI samples search for: Y .\n") # {len(study_numbers_count)}
#             #     print(f"Total WSI samples not found: Z .\n") # {len(study_numbers_count) - sum(study_numbers_count.values())}
#         print(f"\nLog written to [{log_file_path}].")

#     except Exception as e:
#         print(f"\nError: For some reason I couldn't write to the log file: {e}. Log was not written. ")

#     print(f"\nScript executed on {today_date.strftime('%Y-%m-%d')}. Total execution time was {formatted_time} (minus writing time).")

# if __name__ == "__main__":
#     main()

# # Print the version number
# print(f"\n+ {VERSION_NAME} v{VERSION} ({VERSION_DATE}). {COPYRIGHT} +")
# print(f"{COPYRIGHT_TEXT}")
# # End of file
