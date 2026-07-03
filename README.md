# HerculesToolKit

A collection of scripts that make heavy 'omics' work a bit lighter. Scripts cover general-purpose data wrangling, genetics QC and imputation, HPC job management, and R/Python package maintenance. All scripts are annotated for debugging purposes and future reference.

Scripts are tested on Rocky 8 / CentOS 7 Linux (SLURM or SGE HPC) and macOS. Most bash and Python scripts run on either platform without modification; R scripts require R 3+.

---

## Repository layout

| Folder / file | Contents |
|---|---|
| *(root)* | General-purpose data wrangling and analysis scripts |
| [`_genetics/`](#_genetics) | Genotype QC, VCF handling, GWAS reference preparation |
| [`_imputation/`](#_imputation) | IMPUTE2 / Minimac3 format converters |
| [`_rstats_installers/`](#_rstats_installers) | R package installer / updater scripts |
| [`_sample_file_creator/`](#_sample_file_creator) | Helper to build GWAS sample files |
| [`_utilities/`](#_utilities) | HPC and system utilities |
| [`_intheworks/`](#_intheworks) | Scripts under development (beta/incomplete) |
| [`_archived/`](#_archived) | Superseded scripts kept for reference |

---

## Root — general data wrangling

### `alt_models.py`
Run alternative genetic association models (additive, dominant, recessive, etc.) using PLINK 1.9 / PLINK 2 for a set of phenotypes and variants. Produces per-model result files.

```
python alt_models.py [options]
```

### `alt_models_summarize.py`
Concatenate and summarise the per-model result files produced by `alt_models.py`. Handles both logistic and linear regression outputs, strips trailing whitespace, and archives intermediates as a tarball.

```
python alt_models_summarize.py [options]
```

### `dropDupes.py`
Drop duplicate rows in a space-delimited file based on a given column, then write the result to a gzipped file. Thin wrapper around pandas `drop_duplicates`.

```
python dropDupes.py <input_file> <column_name> <output_file.gz>
```

### `dukenukem.sh`
Recites Duke Nukem quotes at random intervals via macOS `say`. Useful for background entertainment during long HPC runs.

### `gitupdater.sh`
Update all local git repositories under a given root directory in one go. Loops over directories and runs `git pull`.

### `liftover.py`
Convert genomic coordinates between genome builds (hg19 ↔ hg38) using `pyliftover`. Reads a delimited input file, lifts over the specified position column, and writes results to an output directory.

```
python liftover.py --input <file> --build <b37_to_b38|b38_to_b37> [--output_dir DIR] [--verbose]
```

### `loci_lookup.py`
*Authors: Roderick S.K. Westerman & Sander W. van der Laan.*  
Look up genomic loci from file A in file B by matching chromosome and base-pair position columns. Auto-detects gzip compression and delimiters. Results are written to an output file with a log.

```
python loci_lookup.py --fileA <file> --fileB <file> \
    --columnA Chr BP --columnB chromosome base_pair_location \
    [--output_dir DIR] [--log FILE] [--verbose]
```

### `mergeTables.pl`
*Originally by Paul I.W. de Bakker.*  
Merge two (large) tables on an index column. Neither file needs to be sorted. Supports gzipped inputs.

```
perl mergeTables.pl --file1 FILE1 --file2 FILE2 --index INDEX \
    --format [GZIP1|GZIP2|GZIPB|NORM] [--replace]
```

### `mergeTables.py` / `mergeTables.ipynb`
Python port of `mergeTables.pl` (by Bram van Es / Mike Puijk). Same merge logic; supports gzipped files, auto-detects delimiters. The notebook version (`mergeTables.ipynb`) provides an interactive walkthrough.

```
python mergeTables.py --in_file1 FILE1 --in_file2 FILE2 \
    --indexID COLUMN --out_file OUTPUT [--replace] [--verbose]
```

### `monitor.sh`
SLURM job monitoring helper. Wraps `squeue`/`sacct` calls to display concise job status for the current user.

### `numberoffields.pl`
Report the number of fields (columns) per row in a file. Useful for sanity-checking malformed tables.

```
perl numberoffields.pl <file>
```

### `overlap.pl`
*By Jessica van Setten & Sander W. van der Laan.*  
Print lines from a source file whose key column matches any value from a lookup file.

```
perl overlap.pl LOOKUP.txt COLUMN# SOURCE.txt COLUMN# > output.txt
```

### `parse_molqtl.py`
Extract and analyse molQTL results from the Athero-Express Biobank Study. Reads Parquet result files, filters by trait and population, and writes summary outputs.

```
python parse_molqtl.py --trait HTRA1 --project_name PROJECT --population EUR
```

### `parseTable.pl`
*Originally by Paul I.W. de Bakker.*  
Extract specific columns from a space/tab-delimited file piped via STDIN.

```
cat table.txt | perl parseTable.pl --col COL1[,COL2,...] [--sep SEP] [--no-header]
```

### `removedupes.pl`
Remove duplicate lines from a (gzipped) file. Lines do not need to be sorted.

```
perl removedupes.pl INPUT [GZIP|NORM] OUTPUT
```

### `uniquefy.pl`
Make a list unique by printing only the first occurrence of each value in column 1.

```
perl uniquefy.pl <file> > unique_file
```

### Template scripts
Boilerplate starters for new scripts:

| File | Purpose |
|---|---|
| `BASIC_BASH_SCRIPT.sh` | SGE-annotated bash template |
| `BASIC_PERL_SCRIPT.pl` | Perl template |
| `BASIC_R_SCRIPT.R` | R template |
| `BASIC_RMD_SCRIPT.Rmd` | R Markdown template |

---

## `_genetics/`

Scripts for genotype quality control, VCF handling, and GWAS reference panel preparation.

### `check_vcf/checkVCF.py`
Validate a VCF file against a reference FASTA — checks allele concordance, strand issues, and format errors. Originally from the Abecasis lab.

### `fix_vcf.py`
Fix known issues in VCF files from the Athero-Express GWAS cohorts (AEGS1/2/3) using `qctool`. Interactively guides through chromosome-by-chromosome correction.

### `vcf_to_plink.convert.sh` *(SLURM)*
Convert 1000 Genomes Phase 1 VCF files to BCF / PLINK format using `bcftools` and `plink2`.

### `vcf_to_plink.variantlists.sh` *(SLURM)*
Build per-chromosome variant lists from 1000 Genomes Phase 3 VCFs as a precursor to PLINK conversion.

### `create.1kGp3v5.plink.sh` *(SLURM)*
Create PLINK-format files from 1000 Genomes Phase 3 v5 VCFs, retaining only bi-allelic variants.

### `gwaslab.prep_ref.hpc.sh` *(SLURM)*
Prepare 1000 Genomes Phase 3 reference data for GWAS harmonisation / normalisation with [GWASLab](https://cloufield.github.io/gwaslab/).

### `fastlmm.sh`
Setup script to create symlinks and Lmod module file for FaST-LMM (mixed-model association) on the HPC. Run once by an admin.

### `variant.extraction.sh`
Example script demonstrating how to extract a specific variant of interest from imputed VCF data using `bcftools`.

### `plot_af.r`
Pre-imputation allele-frequency QC plots: compares chip frequencies against a reference panel and flags variants with >10 percentage-point deviation.  
*From the Genotype Imputation Protocol v3 (Pärn et al.).*

### `plot_info_and_af_for_imputed_chrs.r`
Post-imputation QA plots (INFO score and allele frequency) per chromosome saved as PNG files.  
*From the Genotype Imputation Protocol v3 (Pärn et al.).*

### Statistics R scripts
R scripts for GWAS QC plots using PLINK output (Hardy-Weinberg, missingness, heterozygosity, IBD). Intended to be run interactively after adjusting the `setwd()` / file paths at the top.

| File | Stage |
|---|---|
| `Statistics_priortoSAMPLE_QC.R` | Pre-sample-QC plots (HWE, missingness, MAF) |
| `Statistics_priortoSAMPLE_QC_additionals.R` | Additional pre-QC plots (heterozygosity, IBD) |
| `Statistics_SAMPLE_QC.R` | Post-sample-QC plots |
| `Statistics_QCb36b37.R` | Build 36 vs 37 QC comparison plots |

---

## `_imputation/`

Scripts to convert imputed genotype data between formats.

### `convert_impute2dosage.pl` / `convert_impute2dosage.sh`
*By Jessica van Setten & Sander W. van der Laan.*  
Convert IMPUTE2 `*.gen.gz` files (three per-genotype probabilities AA/AB/BB) to PLINK-style dosage format (single B-allele dosage). Produces `.dose.gz`, `.map`, and `.fam` files.

```
# Shell wrapper (recommended):
bash convert_impute2dosage.sh

# Or Perl directly:
perl convert_impute2dosage.pl INPUT.gen.gz [GZIP|NORM] OUTPUT.dosage
```

### `convert_impute2pedmap.py`
Convert IMPUTE2 output to PLINK PED/MAP format. From the PyPedia project.

### `convert.Minimac3ToOxford.py`
*By Tim Bezemer, designed by Sander W. van der Laan.*  
Convert Minimac3 VCF output to Oxford GEN format.

### `get.variantIDs.mich_imp.sh` *(SGE)*
Extract and update variant IDs from Michigan Imputation Server output.

### `mich_imp_prep.sh` *(SGE)*
Prepare data for submission to the Michigan Imputation Server (HRC reference panel).

---

## `_rstats_installers/`

Command-line R scripts for installing and updating R packages on HPC or local systems.

| Script | Packages installed |
|---|---|
| `RStats_GENERAL_v1.r` | General-purpose CRAN packages (tidyverse, data.table, etc.) |
| `RStats_ADVANCED_v1.r` | Advanced / less common CRAN and Bioconductor packages |
| `RStats_GENETICS_v1.r` | Genetics packages (qqman, GenomicRanges, etc.) |
| `RStats_OMICS_v1.r` | Multi-omics packages |
| `RStats_DNAm_v1.r` | DNA methylation packages (minfi, ChAMP, etc.) |
| `RStats_MR_v1.r` | Mendelian randomisation packages (TwoSampleMR, MendelianRandomization) |
| `RStats_Updater_v1.r` | Update all installed packages |

```
Rscript RStats_GENERAL_v1.r
```

### `rupdater.sh`
Shell wrapper that calls the R package updater scripts in sequence. Useful as a cron job or after an R version upgrade.

### `create_worcs.R` / `install_worcs.R`
Scripts to install and initialise a [WORCS](https://github.com/cjvanlissa/worcs) (Workflow for Open Reproducible Code in Science) project.

---

## `_sample_file_creator/`

### `sample_file_creator.R`
Select phenotype and covariate columns from a master data file and write a GWAS-ready sample file. Edit the `setwd()` path and column selection at the top before running.

Supporting files:
- `usethisfile.sample` — example sample file template
- `var_selection.txt` — example variable selection list

---

## `_utilities/`

System and HPC utility scripts.

### `du_space_check.sh` *(SLURM or interactive)*
Report disk usage for a given folder. Runs `du --max-depth=2` and writes a dated log. Also produces a per-user (depth-1 subfolder) summary sorted largest-first, identifying the top user.

```bash
# Interactive
bash du_space_check.sh --input /hpc/dhl_ec [--log FILE] [--verbose]

# SLURM
sbatch du_space_check.sh --input /hpc/dhl_ec --verbose
```

Output files (both dated `YYYYMMDD`):
- `YYYYMMDD.du_space_check.log` — full `du --max-depth=2` listing
- `YYYYMMDD.du_space_check.per_user.log` — per-user summary with top-user callout

### `brewupdater.sh`
Update, upgrade, and clean up Homebrew on macOS in one command (`brew doctor` → `brew update` → `brew upgrade` → `brew cleanup`).

### `checkmd5sum.sh`
Verify downloaded files against an MD5SUM file.

```
bash checkmd5sum.sh [source_to_check] [md5sum_file]
```

### `prep_mac4science.sh`
Set up a fresh macOS machine for scientific computing: installs Homebrew, common CLI tools, and configures the shell environment.

### `rename_seqno.sh`
Rename a batch of files to a new base name with sequential numbers.

### `find-dup.py`
Find duplicate files in a directory tree using a fast hash-based approach (compares file size first, then SHA-1).

```
python find-dup.py <folder> [<folder>...]
```

### `getlines.py`
Extract specific fields (Index, Name, Chr, Position) from a genotyping manifest file and write to a formatted output. Paths are hard-coded — edit before use.

### Text / table manipulation (Perl)

These are small Perl utilities for reformatting and converting tabular data:

| Script | Purpose |
|---|---|
| `cleanup.pl` | Clean up badly formatted text files (line endings, whitespace, sorting) |
| `convertCRLF.pl` | Convert Windows CRLF line endings to Unix LF |
| `csv2html.pl` | Convert CSV to a simple HTML table |
| `csv2tab.pl` | Convert CSV to TAB-delimited format |
| `domath.pl` | Perform sum, average, or count on lines of numerical input |
| `HTMLList.pl` | Create an HTML ordered or unordered list from text input |
| `HTMLTable.pl` | Create an HTML table from CSV or TAB-delimited input |
| `merge.pl` | Merge two files on a key column (alternative to `mergeTables.pl`) |
| `pivot.pl` | Pivot columns to rows in a table |
| `wordfreq.pl` | Count word frequency in a text file (with configurable stop-word list) |

---

## `_intheworks/`

Scripts that are functional but incomplete or under active development. Use with caution.

### `checkPerlModules.pl`
Check which Perl modules are installed; install any that are missing. *(Beta)*

### `make_readable.pl`
Reformat a whitespace-delimited table for human readability by padding columns to equal width.

### `metaanalyzer.R`
Meta-analysis of *n* tables using z-score, fixed-effects, and random-effects methods. Indexed by a key variable (e.g. SNP, CpG, Gene). Requires: key variable, beta, SE, p-value, n. *(In development)*

---

## `_archived/`

Superseded scripts retained for historical reference. Not recommended for new work.

| Script | Notes |
|---|---|
| `baselinetable.R` | Early baseline-table generator; superseded by newer R workflows |
| `check_mich_imp.sh` | SGE-era script to check Michigan Imputation Server output |
| `convert.minimac3.sh` | Minimac3 format converter (use `convert.Minimac3ToOxford.py` instead) |
| `convert.minimac3.conf` | Configuration file for `convert.minimac3.sh` |
| `parse_1000Gp3v5_20130502.sh` | SLURM script to parse the original 1000G Phase 3 release VCFs |

---

#### The MIT License (MIT)
##### Copyright (c) 1979-2026 Sander W. van der Laan | s.w.vanderlaan [at] gmail [dot] com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Reference: http://opensource.org.
