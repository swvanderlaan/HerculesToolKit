#!/usr/bin/env python3

# Author(s): Roderick S.K. Westerman & Sander W. van der Laan | s.w.vanderlaan@gmail.com | https://vanderlaanand.science
# Date: 2023-12-12
# License: CC-BY-NC-ND 4.0 International
# Disclaimer: "The script is given AS-IS. No liability is taken for its use."
# Version: 1.0
# Usage: ./loci_lookup.py --fileA <path_to_file_A> --fileB <path_to_file_B> --columnA Chr BP --columnB chromosome base_pair_location [--log <path_to_log_file>] [--verbose] 
# Description: This script takes two input files (file A and file B) and performs a lookup based on specified columns.
#              The result is written to an output file, and information about the process is logged.
#              The script dynamically installs required packages if they are not installed, checks if the input files are gzipped,
#              and detects the delimiter used in the input files.
#
# Here's a breakdown of loci_lookup.py's functionality:
#
# Command-line Interface (CLI):
#     loci_lookup.py is designed to be executed from the command line with various options and arguments.
# Input Files (File A and File B):
#     File A is a expected to be a non-gzipped file with comma-, space- or tab-separated values, but it can be gzipped.
#     File B is a gzipped file with comma-, space- or tab-separated values.
# Column Specifications:
#     The user specifies which columns in each file should be used for the lookup. These column names should 
#     designate the chromosome (CHR) and base pair position (POS). 
# Output Directory and Log File:
#     loci_lookup.py allows the user to specify the output directory for the results and the location of the log file.
#     If not specified, it defaults to the current working directory for the output and creates a log file 
#     named loci_lookup.log.
# Verbose Mode:
#     loci_lookup.py has a verbose mode that provides additional information during execution.
# File Type Detection:
#     It uses the magic library to detect the MIME types of File A and File B.
# Delimiter Detection:
#     loci_lookup.py automatically detects the delimiter (either comma, space or tab) used in both files.
# Data Loading:
#     It loads the data from both files into memory using the Polars library, which is similar to Pandas 
#     but designed for better performance.
# Data Merging:
#     loci_lookup.py performs a left join (lookup) operation on the specified columns between File A and File B.
# Output:
#     The merged data is then written to an output file in the specified output directory. The output file 
#     is a space-separated values (CSV) file.
# Logging:
#     loci_lookup.py logs information about the lookup process, including any errors or relevant details, to a log file.
# Timing Information:
#     loci_lookup.py records and prints the time taken for the entire process.

"""
Loci Lookup Script

This script takes two input files (file A and file B) and performs a lookup based on specified columns.
The result is written to an output file, and information about the process is logged.

Usage:
  ./loci_lookup.py --fileA <path_to_file_A> --fileB <path_to_file_B> --columnA Chr BP --columnB chromosome base_pair_location [--log <path_to_log_file>] [--verbose] 

Options:
  -A <path_to_file_A>, --fileA <path_to_file_A>           Path to file A ([non-]gzipped; comma-, space- or tab-separated).
  -B <path_to_file_B>, --fileB <path_to_file_B>           Path to file B ([non-]gzipped; comma-, space- or tab-separated).
  -cA CHR POS, --columnA CHR POS                           Columns in file A.
  -cB chromosome basepair_position, --columnB chromosome basepair_position  Columns in file B.
  -o <output_directory>, --output <output_directory>     Output directory (default: current working directory).
  -l <path_to_log_file>, --log <path_to_log_file>        Path to the log file (default: OUTPUT/loci_lookup.log).
  -v, --verbose                                          Enable verbose mode.
  -V, --version                                          Show version information.
  -h, --help                                             Show this help message and exit.
"""

import argparse
from argparse import RawTextHelpFormatter
import os
import logging
import gzip
import magic # to detect file type

# Check if the required packages are installed
try:
    import polars as pl
except ModuleNotFoundError:
    ### This part is a security concern
    # import subprocess     
    # subprocess.run(["pip", "install", 'polars'])
    # import polars as pl
    ### This is an alternative.
    print("Please install polars 'pip install polars' and try again.")
    raise

VERSION = '1.0'
COPYRIGHT = 'Copyright 1979-2023. CC-BY-NC-ND License. Roderick S.K. Westerman & Sander W. van der Laan | s.w.vanderlaan@gmail.com | https://vanderlaanand.science'
DEFAULT_OUTPUT_FILE = 'loci_lookup.txt'

# Setup logging
def setup_logger(log_file):
    logging.basicConfig(filename=log_file, level=logging.INFO,
                        format='%(asctime)s - %(levelname)s: %(message)s', datefmt='%Y-%m-%d %H:%M:%S')

# Detect delimiter
def detect_delimiter(file_path, num_lines=5):
    """num_lines to read a couple of lines to find the delimiter"""
    file_ext = os.path.splitext(file_path)[1]
    potential_delimiters = [',', '\t', ';']  # Add more if needed

    if file_ext != ".gz":
        with open(file_path, 'r') as file:
            lines = [file.readline().strip() for _ in range(num_lines)]
    else:
        import gzip
        with gzip.open(file_path, 'rt', encoding='utf-8') as file:
            lines = [file.readline().strip() for _ in range(num_lines)]

    for delimiter in potential_delimiters:
        if all(delimiter in line for line in lines):
            return delimiter
    return print(f'Could not detect delimiter in file: {file_path}')

def main():
    print(f'+++++++++++++++++++++++++++')
    print(f'+ Loci Lookup Script v{VERSION} +')
    print(f'+++++++++++++++++++++++++++')
    print(f'')
    print(f'Beginning lookup process...')
    
    parser = argparse.ArgumentParser(description='''
        + Loci Lookup Script v{VERSION} +

        Lookup variants in `--fileB` based on `--fileA`. The lookup is based on specified index columns 
        that should be designating the chromosome and basepair position, `--columnA` and `--columnB`, respectively.
        The `--output` file will a space-delimited [.csv] file.
        The `--log` option adds will indicate where the log will have to be written to, default: current working directory. 
        The `--verbose` option adds the option to print verbose output and write more information to the log, default: False.
        The `--version` option prints the version number and exits.
        The
        This is an example call:

        python3 loci_lookup.py --fileA /file1.txt.gz --fileB /file2.txt.gz --columnA Chr BP --columnB chromosome base_pair_location --output /joined.txt.gz --log /joined.log [optional: --version; --verbose: T/F; --help]
        ''',
        epilog='''
        + Copyright 1979-2023. Roderick S.K. Westerman & Sander W. van der Laan | s.w.vanderlaan@gmail.com | https://vanderlaan.science +''', 
        formatter_class=RawTextHelpFormatter)
    
    parser.add_argument('-A', '--fileA', required=True, help='Path to [non-]gzipped file A; comma-, space-, or tab-delimited.')
    parser.add_argument('-B', '--fileB', required=True, help='Path to [non-]gzipped file B; comma-, space-, or tab-delimited.')
    parser.add_argument('-cA', '--columnA', required=True, nargs=2, metavar=('CHR','POS'), help='Columns in file A (space or tab-separated).')
    parser.add_argument('-cB', '--columnB', required=True, nargs=2, metavar=('chromosome', 'basepair_position'), help='Columns in file B (space or tab-separated).')
    parser.add_argument('-o', '--output', default='', help='Output directory + filename (default: current working directory).')
    parser.add_argument('-l', '--log', required=False, default='./loci_lookup.log', help='Path to the log file (default: loci_lookup.log).')
    parser.add_argument('-v', '--verbose', action='store_true', help='Enable verbose mode.', default=False)
    parser.add_argument('-V', '--version', action='version', version=f'%(prog)s v{VERSION}')

    args = parser.parse_args()
    # Set the output directory
    current_wd = os.getcwd() # Current working directory
    
    # Set up the logging
    # Get the filename and directory from the log argument
    log_filename = os.path.basename(args.log)
    log_dir_path = os.path.dirname(args.log)
    # Create LOG directory if it doesn't exist
    log_dir = os.path.join(current_wd, log_dir_path)
    os.makedirs(os.path.join(log_dir_path), exist_ok=True)

    # Set up the file path for the log file
    log_filename_path = os.path.join(log_dir, log_filename) if args.log else os.path.join(current_wd, log_filename)

    # Set up the logging
    setup_logger(log_filename_path)

    if args.verbose:
        print(f'- Current working directory: [{current_wd}]')
        logging.info(f'Current working directory: {current_wd}')
        
    # Verbose: print the log directory
        print(f'- Created log directory (if it didn\'t exist): [{log_dir}]')
        print(f'- Saving log of lookup: [{log_filename}]')
        logging.info(f'Creating output directory: {log_dir}')
        logging.info(f'Saving log of lookup: {log_filename}')

    # Set the output filename and directory
    if args.output:
        # get the filename and directory from the output argument
        output_filename = os.path.basename(args.output)
        output_dir_path = os.path.dirname(args.output)
        # Create OUTPUT directory if it doesn't exist
        output_dir = os.path.join(current_wd, output_dir_path) # os.path.abspath(os.path.join(current_wd, output_dir_path))
        os.makedirs(os.path.join(output_dir), exist_ok=True)
        
        # Verbose: print the output directory
        if args.verbose:
            print(f'- Created output directory (if it didn\'t exist): [{output_dir}]')
            print(f'- Saving looked up data in: [{output_filename}]')
            logging.info(f'Creating output directory: {output_dir}')
            logging.info(f'Saving looked up data in: {output_filename}')

    # Set the output file path
    output_file_path = os.path.join(output_dir, output_filename) if args.output else os.path.join(current_wd, DEFAULT_OUTPUT_FILE)

    # Verbose: print the output file path
    if args.verbose:
        print(f'- Output file: [{output_file_path}]')
        logging.info(f'Output file: {output_file_path}')

    # Verbose: print the input files
    if args.verbose:
        print(f'- Loci of interest in File A: [{args.fileA}]')
        print(f'- Look-up data in File B: [{args.fileB}]')
        logging.info(f'Loci of interest in File A: {args.fileA}')
        logging.info(f'Look-up data in File B: {args.fileB}')

    # Detect file type using magic
    # https://stackoverflow.com/questions/43580/how-do-i-check-the-file-type-of-a-file-in-python

    mime = magic.Magic(mime=True)
    mime_type_fileA = mime.from_file(args.fileA) #== 'application/gzip'
    mime_type_fileB = mime.from_file(args.fileB) #== 'application/gzip'

    if args.verbose:
        print(f"- Detected files types:")
        print(f"  > File A: [{mime_type_fileA}]")
        print(f"  > File B: [{mime_type_fileB}]")
        logging.info(f"File type of File A: {mime_type_fileA}.")
        logging.info(f"File type of File B: {mime_type_fileB}.")

    # Detect file delimiter 
    if mime_type_fileA == 'application/gzip':
        with gzip.open(args.fileA) as f:
            print(f"- File A is gzipped. Reading...")
            detect_delimiter_A = detect_delimiter(args.fileA)
            detect_delimiter_A_to_str = detect_delimiter_A.encode('unicode_escape').decode('utf-8')
    else:
        with open(args.fileA) as f:
            print(f"- File A plain-text. Reading...")
            detect_delimiter_A = detect_delimiter(args.fileA)
            detect_delimiter_A_to_str = detect_delimiter_A.encode('unicode_escape').decode('utf-8')

    if mime_type_fileB == 'application/gzip':
        with gzip.open(args.fileB) as f:
            print(f"- File B is gzipped. Reading...")
            detect_delimiter_B = detect_delimiter(args.fileB)
            detect_delimiter_B_to_str = detect_delimiter_B.encode('unicode_escape').decode('utf-8')
            
    else:
        with open(args.fileB) as f:
            print(f"- File B plain-text.")
            detect_delimiter_B = detect_delimiter(args.fileB)
            detect_delimiter_B_to_str = detect_delimiter_B.encode('unicode_escape').decode('utf-8')

    if args.verbose:
        print(f"- Detected the following delimiters:")
        print(f"  > File A: [{detect_delimiter_A_to_str}].")
        print(f"  > File B: [{detect_delimiter_A_to_str}].")
        logging.info(f"Delimiter for file A: {detect_delimiter_B_to_str}.")
        logging.info(f"Delimiter for file B: {detect_delimiter_B_to_str}.")

    print(f"Opening File A...")
    if mime_type_fileA == "application/gzip":
        df_fileA = pl.read_csv(gzip.open(args.fileA).read(), separator=detect_delimiter_A, infer_schema_length=10000)
    else:
        df_fileA = pl.read_csv(args.fileA, separator=detect_delimiter_A, infer_schema_length=10000)

    print(f"Opening File B...")
    if mime_type_fileB == "application/gzip":
        df_fileB = pl.read_csv(gzip.open(args.fileB).read(), separator=detect_delimiter_B, infer_schema_length=10000)
    else:
        df_fileB = pl.read_csv(args.fileB, separator=detect_delimiter_B, infer_schema_length=10000)
    
    if args.verbose:
        describe_A = df_fileA.describe()    
        describe_B = df_fileB.describe()
        print(f'- Describe contents of File A:\n{describe_A}')
        print(f'- Describe contents of File B:\n{describe_B}')
        logging.info(f'Describe contents of File A:\n{describe_A}')
        logging.info(f'Describe contents of File B:\n{describe_B}')
                
    # Verbose: print the headers of the files
        print(f'- File A header:\n{df_fileA.columns}')
        print(f'- File B header:\n{df_fileB.columns}')
        logging.info(f'File A header:\n{df_fileA.columns}')
        logging.info(f'File B header:\n{df_fileB.columns}')
        
    # Merge the files
    if args.verbose:
        # Alternatively, write the merged file to disk with all columns
        print(f'- Saving all columns of the merged file to disk while keeping all rows from fileA (useful when debugging in case of \'missing\' variants).')
        # Actually merge the files
        # df_merged = pd.merge(df_fileA, df_fileB, left_on=args.columnA, right_on=args.columnB, how='left', validate='one_to_one')
        df_merged = df_fileA.join(df_fileB, left_on=args.columnA, right_on=args.columnB, how='left')
        # Write the merged file to disk
        # df_merged.to_csv(output_file_path, sep='\t', index=False)
        df_merged.write_csv(output_file_path, has_header=True, separator=' ', null_value='NA',
                 batch_size=1024)
    else:
        # Actually merge the files
        # df_merged = pd.merge(df_fileA, df_fileB, left_on=args.columnA, right_on=args.columnB, how='inner', validate='one_to_one')
        df_merged = df_fileA.join(df_fileB, left_on=args.columnA, right_on=args.columnB, how='left')
        # Write the merged file to disk
        # df_merged.to_csv(output_file_path, sep='\t', index=False, columns=df_fileB.columns)
        df_merged_temp = df_merged.select(df_fileB.columns)
        df_merged_temp.write_csv(output_file_path, has_header=True, separator=' ', null_value='NA',
                 batch_size=1024)

    # Verbose: print the contents of the output file
    if args.verbose:
        print(f'- Checking contents of output file...')
        print(df_merged)
        logging.info(f'Checking contents of output file...')
        logging.info(df_merged)
        # pass
    
    # return df_merged
    
if __name__ == "__main__":
    from time import time
    from datetime import timedelta
    # Start the timer
    t1 = time()
    # Run the main function
    df = main()
    # Stop the timer
    t2 = time()
    # Print the time taken
    print(f'Time taken: {timedelta(seconds=t2-t1)}')
    print(f'')
    print(f'============================')
    print(f'{COPYRIGHT}')