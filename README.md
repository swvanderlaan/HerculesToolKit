# HerculesToolKit

This repository contains a collection of scripts that make heavy 'omics' work a bit lighter. 

All scripts are annotated for debugging purposes - and future reference. Scripts will work within the context of a certain Linux environment (in this case a CentOS7 system on a SUN Grid Engine background). 

The installation procedure is quite straightforward, and only entails two steps consisting of command one-liners that are *easy* to read. You can copy/paste each example command, per block of code. For some steps you need administrator privileges. Follow the steps in consecutive order.

```
these `mono-type font` illustrate commands illustrate terminal commands. You can copy & paste these.
```

To make it easier to copy and paste, long commands that stretch over multiple lines are structered as follows:

```
Multiline commands end with a dash \
	indent 4 spaces, and continue on the next line. \
	Copy & paste these whole blocks of code.
```

Although we made it easy to just select, copy and paste and run these blocks of code, it is not a good practise to blindly copy and paste commands. Try to be aware about what you are doing. And never, never run `sudo` commands without a good reason to do so. 

We have tested fastQTLToolKit on CentOS7, OS X El Capitan (version 10.11.[x]), and macOS Sierra (version 10.12.[x]). 

--------------

## List of scripts

**checkPerlModules.pl**

BETA-version. Purpose: to check the availability of certain Perl modules on the system. Will install those that are not present, and update those that are.

**convert_impute2dosage.pl**

Converts IMPUTE2 *.gen-files to PLINK-style 'dosage' format. Perl-version.

**convert_impute2dosage.sh**

Converts IMPUTE2 *.gen-files to PLINK-style 'dosage' format. BASH-version.

**mergeTables.pl**

Merge two (large) tables based on an index-column. Command: 

```
merge_tables.pl --file1 datafile_1 --file2 datafile_2 --index index_string --format [GZIP1/GZIP2/GZIPB/NORM] [--replace]
```

Prints all contents of `datafile_2`, each row is followed by the corresponding columns from `datafile_1` (indexed on `index_string`). The argument `--format` indicates which of the files are gzipped. If `--replace` is specified, only the contents of `datafile_2` are output with relevant elements replaced by those in `datafile_1`.

**metaanalyzer.R**

Meta-analysis of *n* tables. Will be z-score, fixed-effects, and random-effects meta-analysis of each row indexed by a key-variable (e.g. SNP, CpG, Gene). Requires: key-variable, beta (effect size), s.e. (standard error), p-value, n (sample size).

**numberoffields.pl**

Calculates the number of fields per row in a file.

**overlap.pl**

Find the overlap between two files.

```
overlap.pl datafile_1 [column-number] datafile_2 [column-number] > new_datafile_3
```

**removedupes.pl**

Remove duplicate rows in a file. Three arguments are required: `original-filename`, `gzip/norm`, and `new-filename`.

```
removedupes.pl datafile_1 [GZIP/NORM] new_datafile_1
```

`[GZIP/NORM]`: indicates whether the original file (`datafile_1`) is gzipped (`GZIP`) or not (`NORM`).

**uniquefy.pl**

Make a given list (in a file) unique.

```
uniquefy.pl datafile_1 > new_datafile_1
```

--------------

#### The MIT License (MIT)
Copyright (c) 1979-2017 | Sander W. van der Laan | s.w.vanderlaan-2 [at] umcutrecht.nl

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:   

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Reference: http://opensource.org.
