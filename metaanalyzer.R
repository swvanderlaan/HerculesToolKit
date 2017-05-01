#!/hpc/local/CentOS7/dhl_ec/software/R-3.3.3/bin/Rscript --vanilla

### Mac OS X version
### #!/usr/local/bin/Rscript --vanilla

### Linux version
### #!/hpc/local/CentOS7/dhl_ec/software/R-3.3.3/bin/Rscript --vanilla

cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Meta-Analyzer -- Miscellaneous
    \n
    * Version: v1.0.0.
    * Last edit: 2017-05-01
    * Created by: Sander W. van der Laan | s.w.vanderlaan-2@umcutrecht.nl
    \n
    * Description:  Meta-analysis of two arbitrary tables. 
    The script should be usuable on both any Linux distribution with R 3+ installed, Mac OS X and Windows.
    
    ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")

### Usage: ./metaanalyzer.R -p projectdir -i inputdir -e extension -o outputdir [OPTIONAL: -v verbose (DEFAULT) -q quiet]
###        ./metaanalyzer.R --projectdir projectdir --inputdir inputdir --extension extension --outputdir outputdir [OPTIONAL: --verbose verbose (DEFAULT) -quiet quiet]

cat("\n* Clearing the environment...\n\n")
### CLEAR THE BOARD
rm(list=ls())

cat("\n* Loading function to install packages...\n\n")
### Prerequisite: 'optparse'-library
### * Manual: http://cran.r-project.org/web/packages/optparse/optparse.pdf
### * Vignette: http://www.icesi.edu.co/CRAN/web/packages/optparse/vignettes/optparse.pdf

### Don't say "Loading required package: optparse"...
###suppressPackageStartupMessages(require(optparse))
###require(optparse)

### The part of installing (and loading) packages via Rscript doesn't properly work.
### FUNCTION TO INSTALL PACKAGES
install.packages.auto <- function(x) { 
  x <- as.character(substitute(x)) 
  if(isTRUE(x %in% .packages(all.available = TRUE))) { 
    eval(parse(text = sprintf("require(\"%s\")", x)))
  } else { 
    # Update installed packages - this may mean a full upgrade of R, which in turn
    # may not be warrented. 
    #update.packages(ask = FALSE) 
    eval(parse(text = sprintf("install.packages(\"%s\", dependencies = TRUE, repos = \"http://cran-mirror.cs.uu.nl/\")", x)))
  }
  if(isTRUE(x %in% .packages(all.available = TRUE))) { 
    eval(parse(text = sprintf("require(\"%s\")", x)))
  } else {
    source("http://bioconductor.org/biocLite.R")
    # Update installed packages - this may mean a full upgrade of R, which in turn
    # may not be warrented.
    #biocLite(character(), ask = FALSE) 
    eval(parse(text = sprintf("biocLite(\"%s\")", x)))
    eval(parse(text = sprintf("require(\"%s\")", x)))
  }
}

cat("\n* Checking availability of required packages and installing if needed...\n\n")
### INSTALL PACKAGES WE NEED
install.packages.auto("optparse")
install.packages.auto("tools")
install.packages.auto("dplyr")
install.packages.auto("tidyr")
install.packages.auto("data.table")

cat("\nDone! Required packages installed and loaded.\n\n")

cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")

### OPTION LISTING
option_list = list(
  make_option(c("-i", "--inputdir"), action="store", default=NA, type='character',
              help="Path to the input data, relative to the project directory; can be tab, comma, space or semicolon delimited, as well as gzipped."),
  make_option(c("-f1", "--file1"), action="store", default=NA, type='character',
              help="File number 1 to be analyzed."),
  make_option(c("-f2", "--file2"), action="store", default=NA, type='character',
              help="File number 2 to be analyzed."),
  make_option(c("-o", "--outputdir"), action="store", default=NA, type='character',
              help="Path to the output directory."),
  make_option(c("-v", "--verbose"), action="store_true", default=TRUE,
              help="Should the program print extra stuff out? [logical (FALSE or TRUE); default %default]"),
  make_option(c("-s", "--silent"), action="store_false", dest="verbose",
              help="Make the program not be verbose.")
  #make_option(c("-c", "--cvar"), action="store", default="this is c",
  #            help="a variable named c, with a default [default %default]")  
)
opt = parse_args(OptionParser(option_list=option_list))

#--------------------------------------------------------------------------

### FOR LOCAL DEBUGGING
### MacBook Pro
#MACDIR="/Users/swvanderlaan/PLINK/analyses"
### Mac Pro
MACDIR="/Volumes/EliteProQx2Media/PLINK/analyses"

### original
opt$inputdir=paste0(MACDIR, "/test_ewas")
opt$file1="aems450k1.sign_plaque.txt"
opt$file2="aems450k2.sign_plaque.txt"
opt$outputdir="output"


### FOR LOCAL DEBUGGING

#--------------------------------------------------------------------------

if (opt$verbose) {
  ### You can use either the long or short name; so opt$a and opt$avar are the same.
  ### Show the user what the variables are.
  cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
  cat("* Checking the settings as given through the flags.")
  cat("\n - The input data directory .............................: ")
  cat(opt$inputdir)
  cat("\n - File number 1 to be analyzed .........................: ")
  cat(opt$file1)
  cat("\n - File number 2 to be analyzed .........................: ")
  cat(opt$file2)
  cat("\n - The output directory..................................: ")
  cat(opt$outputdir)
  cat("\n\n")
}
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
cat("Starting \"Meta-Analyzer\".")

### START OF THE PROGRAM
### main point of program is here, do this whether or not "verbose" is set
#if(!is.na(opt$projectdir) & !is.na(opt$inputdir) & !is.na(opt$extension) & !is.na(opt$outputdir)) {
  cat(paste("\n\nWe are going to parse the GWAS data, by parsing and doing some initial quality control of the data.
Analysing the results in.................: '",basename(opt$inputdir),"'
Only files with [ ",opt$extension," ] will be analyzed.
Parsed results will be saved here........: '", opt$outputdir, "'.\n",sep=''))
  
  ### GENERAL SETUP
  Today=format(as.Date(as.POSIXlt(Sys.time())), "%Y%m%d")
  cat(paste("\nToday's date is: ", Today, ".\n", sep = ''))
  
  #### DEFINE THE LOCATIONS OF DATA
  ROOT_loc = opt$inputdir # argument 1
  
  cat("\nChecking existence of output directory and creating it if necessary.\n")
  OUT_loc = opt$outputdir # argument 3
  
  if (file.exists(paste(ROOT_loc, OUT_loc, "/", sep = "/", collapse = "/"))) {
    cat(paste0("* '", OUT_loc,"' exists in '", ROOT_loc, "' and is a directory..."))
  } else if (file.exists(paste(ROOT_loc, OUT_loc, sep = "/", collapse = "/"))) {
    cat(paste0("* '", OUT_loc,"' exists in '", ROOT_loc, "' but is a file..."))
    # you will probably want to handle this separately
  } else {
    cat(paste0("* '", OUT_loc,"' does not exist in '", ROOT_loc, "' - creating it now..."))
    dir.create(file.path(ROOT_loc, OUT_loc))
  }
  
  if (file.exists(paste(ROOT_loc, OUT_loc, "/", sep = "/", collapse = "/"))) {
    # By this point, the directory either existed or has been successfully created
    setwd(file.path(ROOT_loc, OUT_loc))
  } else {
    cat(paste0("*** ERROR *** '", OUT_loc,"' does not exist - you likely have a 'rights' issue..."))
    # Handle this error as appropriate
  }
  
  cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
  
  ### LOADING RESULTS FILES
  cat("\nLoading data.\n")
  ### Testing separator of data
  data_connection1 <- file(paste0(ROOT_loc,"/",opt$file1))
  data_connection2 <- file(paste0(ROOT_loc,"/",opt$file2))
  TESTDELIMITER1 <- readLines(data_connection1, n = 1)
  TESTDELIMITER2 <- readLines(data_connection2, n = 1)
  close(data_connection1)
  close(data_connection2)
  cat("\n* Checking delimiter now...")
  cat("\n* Data header looks like this:\n")
  print(TESTDELIMITER1)
  print(TESTDELIMITER2)
  if(grepl(",", TESTDELIMITER1) == TRUE || grepl(",", TESTDELIMITER2) == TRUE){
    cat("\n* Data is comma-seperated, loading...\n")
    dataset1 = fread(paste0(opt$inputdir,"/",opt$file1), header = TRUE, sep = ",",
                         dec = ".", na.strings = c("", "NA", "na", "Na",
                                                   "NaN", "Nan", ".",
                                                   "N/A","n/a", "N/a"),
                         blank.lines.skip = TRUE)
    dataset2 = fread(paste0(opt$inputdir,"/",opt$file2), header = TRUE, sep = ",",
                     dec = ".", na.strings = c("", "NA", "na", "Na",
                                               "NaN", "Nan", ".",
                                               "N/A","n/a", "N/a"),
                     blank.lines.skip = TRUE)
    
  } else if(grepl(";", TESTDELIMITER1) == TRUE || grepl(";", TESTDELIMITER2) == TRUE) {
    cat("\n\n* Data is semicolon-seperated, loading...\n")
    dataset1 = fread(paste0(opt$inputdir,"/",opt$file1), header = TRUE, sep = ";",
                     dec = ".", na.strings = c("", "NA", "na", "Na",
                                               "NaN", "Nan", ".",
                                               "N/A","n/a", "N/a"),
                     blank.lines.skip = TRUE)
    dataset2 = fread(paste0(opt$inputdir,"/",opt$file2), header = TRUE, sep = ";",
                     dec = ".", na.strings = c("", "NA", "na", "Na",
                                               "NaN", "Nan", ".",
                                               "N/A","n/a", "N/a"),
                     blank.lines.skip = TRUE)
    
  } else if(grepl("\\t", TESTDELIMITER1) == TRUE || grepl("\\t", TESTDELIMITER2) == TRUE) {
    cat("\n\n* Data is tab-seperated, loading...\n")
    dataset1 = fread(paste0(opt$inputdir,"/",opt$file1), header = TRUE, sep = "\t",
                     dec = ".", na.strings = c("", "NA", "na", "Na",
                                               "NaN", "Nan", ".",
                                               "N/A","n/a", "N/a"),
                     blank.lines.skip = TRUE)
    dataset2 = fread(paste0(opt$inputdir,"/",opt$file2), header = TRUE, sep = "\t",
                     dec = ".", na.strings = c("", "NA", "na", "Na",
                                               "NaN", "Nan", ".",
                                               "N/A","n/a", "N/a"),
                     blank.lines.skip = TRUE)
    
  } else if(grepl("\\s", TESTDELIMITER1) == TRUE || grepl("\\s", TESTDELIMITER2) == TRUE) {
    cat("\n\n* Data is space-seperated, loading...\n")
    dataset1 = fread(paste0(opt$inputdir,"/",opt$file1), header = TRUE, sep = " ",
                     dec = ".", na.strings = c("", "NA", "na", "Na",
                                               "NaN", "Nan", ".",
                                               "N/A","n/a", "N/a"),
                     blank.lines.skip = TRUE)
    dataset2 = fread(paste0(opt$inputdir,"/",opt$file2), header = TRUE, sep = " ",
                     dec = ".", na.strings = c("", "NA", "na", "Na",
                                               "NaN", "Nan", ".",
                                               "N/A","n/a", "N/a"),
                     blank.lines.skip = TRUE)
    
  } else if(grepl("[:blank:]", TESTDELIMITER1) == TRUE || grepl("[:blank:]", TESTDELIMITER2) == TRUE) {
    cat("\n\n* Data is blankspace-seperated, loading...\n")
    dataset1 = fread(paste0(opt$inputdir,"/",opt$file1), header = TRUE, sep = " ",
                     dec = ".", na.strings = c("", "NA", "na", "Na",
                                               "NaN", "Nan", ".",
                                               "N/A","n/a", "N/a"),
                     blank.lines.skip = TRUE)
    dataset2 = fread(paste0(opt$inputdir,"/",opt$file2), header = TRUE, sep = " ",
                     dec = ".", na.strings = c("", "NA", "na", "Na",
                                               "NaN", "Nan", ".",
                                               "N/A","n/a", "N/a"),
                     blank.lines.skip = TRUE)
    
  } else {
    cat ("\n\n*** ERROR *** Something is rotten in the City of Gotham. The data is neither comma,
         tab, space, nor semicolon delimited. Remember: in this version all files have to have the same
         separator-types (future versions will include other combinations). Double back, please.\n\n", 
         file=stderr()) # print error messages to stder
  }
  
  
  ### Getting a list of the dataframes
  dfList <- list(dataset1, dataset2)
  
  ### Selecting the columns we want
  cat("\n* selecting required columns, and creating them if not present...")
  VectorOfColumnsWeWant <- c("^marker$", "^snp$", "^rsid$", "^cpg$", 
                             "^chr$", "^chrom$", "^chromosome$", 
                             "^position$", "^bp$",
                             "^effect[_]allele$", "^minor[_]allele$", "^risk[_]allele$", "^coded[_]allele$", 
                             "^effectallele$", "^minorallele$", "^riskallele$", "^codedallele$",
                             "^other[_]allele$", "^major[_]allele$", "^non[_]effect[_]allele$", "^non[_]coded[_]allele$", 
                             "^otherallele$", "^majorallele$", "^noneffectallele$", "^noncodedallele$", 
                             "^strand$", 
                             "^beta$", "^effect[_]size$", "^effectsize$", 
                             "^se.$", "^se$", 
                             "^p.value$", "^p$", "^p.val$", "^pvalue$", "^pval$", # p-value
                             "^q.value$", "^q$", "^q.val$", "^qvalue$", "^qval$", # p-value
                             "^[remc]af$", # effect/minor allele frequency
                             "^hwe.value$", "^hwe$", "^hwe.val$", 
                             "^n$", "^samplesize$",
                             "^n_case.$", "^n_control.$", "^n_cntrl.$",
                             "^imputed$", 
                             "^info$")
  matchExpression <- paste(VectorOfColumnsWeWant, collapse = "|")

  for (i in seq_along(dfList)) {
    assign(paste("dataset.selection", i, sep = "_"), dfList[[i]] %>% select(matches(matchExpression, ignore.case = TRUE)) )
  }

  ### Change column names case to all 'lower cases'
  names(dataset.selection_1) <- tolower(names(dataset.selection_1))
  names(dataset.selection_2) <- tolower(names(dataset.selection_2))
  
  cat("\n* renaming columns where necessary...")
  ### Rename columns
  ### - variant column will become "Marker" unless it's a CpG
  ### - chromosome & bp columns will become "CHR" and "BP"
  ### - if MAF/minor/major available, thus effect size must be relative to minor, so:
  ###   - MAF = CAF = RAF = EAF -- will be coded as "MAF"
  ###   - minor = coded = effect = risk -- will be coded as "MinorAllele"
  ###   - major = noncoded = noneffect = nonrisk = other -- will be coded as "MajorAllele"
  ### - if MAF/[coded/effect/risk]/[noncoded/noneffect/nonrisk/other], thus the effect 
  ###   size must be relative to [coded/effect/risk], so:
  ###   - MAF = CAF = RAF = EAF -- will be coded as "MAF"
  ###   - coded = effect = risk -- will be coded as "[Coded/Effect/Risk]Allele"
  ###   - noncoded = noneffect = nonrisk = other -- will be coded as "OtherAllele"
  ###   Set these three accordingly, other wise set these to CAF/coded/other
  ###
  
  ### Creating a list of the datasets with the selection of columns
  dfList.selection <- list(dataset.selection_1, dataset.selection_2)
  
  ### looping over this list to do some further re-naming and calculations
  for (i in seq_along(dfList.selection)) {
    ### Rename columns -- strand
    dfList.selection[[i]] <- select(dfList.selection[[i]], Strand = matches("^strand$"), everything())
    
    ### Rename columns -- imputation
    dfList.selection[[i]] <- select(dfList.selection[[i]], Info = matches("^info$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], Imputed = matches("^imputed$"), everything())
    
    ### Rename columns -- n cases and controls
    dfList.selection[[i]] <- select(dfList.selection[[i]], N_controls = matches("^n_control.$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], N_controls = matches("^n_ctrl.$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], N_cases = matches("^n_case.$"), everything())
    
    ### Rename columns -- sample size
    dfList.selection[[i]] <- select(dfList.selection[[i]], N = matches("^n$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], N = matches("^samplesize$"), everything())
    
    ### Rename columns -- HWE p-value
    dfList.selection[[i]] <- select(dfList.selection[[i]], HWE_P = matches("^hwe.value$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], HWE_P = matches("^hwe$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], HWE_P = matches("^hwe.val$"), everything())
    
    ### Rename columns -- p-value
    dfList.selection[[i]] <- select(dfList.selection[[i]], Q = matches("^q.value$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], Q = matches("^q_value$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], Q = matches("^q$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], Q = matches("^q.val$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], Q = matches("^q_val$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], Q = matches("^qvalue$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], Q = matches("^qval$"), everything())
    
    ### Rename columns -- p-value
    dfList.selection[[i]] <- select(dfList.selection[[i]], P = matches("^p.value$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], P = matches("^p_value$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], P = matches("^p$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], P = matches("^p.val$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], P = matches("^p_val$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], P = matches("^pvalue$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], P = matches("^pval$"), everything())
    
    ### Rename columns -- standard error
    dfList.selection[[i]] <- select(dfList.selection[[i]], SE = matches("^se.$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], SE = matches("^se$"), everything())
    
    ### Rename columns -- beta/effect size
    dfList.selection[[i]] <- select(dfList.selection[[i]], Beta = matches("^beta$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], Beta = matches("^effect[_]size$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], Beta = matches("^effectsize$"), everything())
    
    ### Rename columns -- allele frequency
    dfList.selection[[i]] <- select(dfList.selection[[i]], RAF = matches("^raf$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], EAF = matches("^eaf$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], MAF = matches("^maf$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], CAF = matches("^caf$"), everything())
    
    ### Rename columns -- non effect allele
    dfList.selection[[i]] <- select(dfList.selection[[i]], OtherAllele = matches("^non[_]effect[_]allele$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], OtherAllele = matches("^noneffectallele$"), everything())
    
    ### Rename columns -- other allele
    dfList.selection[[i]] <- select(dfList.selection[[i]], OtherAllele = matches("^other[_]allele$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], OtherAllele = matches("^otherallele$"), everything())
    
    ### Rename columns -- non coded allele
    dfList.selection[[i]] <- select(dfList.selection[[i]], OtherAllele = matches("^non[_]coded[_]allele$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], OtherAllele = matches("^noncodedallele$"), everything())
    
    ### Rename columns -- major allele
    dfList.selection[[i]] <- select(dfList.selection[[i]], MajorAllele = matches("^major[_]allele$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], MajorAllele = matches("^majorallele$"), everything())
    
    #### Rename columns -- coded allele
    dfList.selection[[i]] <- select(dfList.selection[[i]], CodedAllele = matches("^coded[_]allele$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], CodedAllele = matches("^codedallele$"), everything())
    
    ### Rename columns -- effect allele
    dfList.selection[[i]] <- select(dfList.selection[[i]], EffectAllele = matches("^effect[_]allele$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], EffectAllele = matches("^effectallele$"), everything())
    
    ### Rename columns -- risk allele
    dfList.selection[[i]] <- select(dfList.selection[[i]], RiskAllele = matches("^risk[_]allele$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], RiskAllele = matches("^riskallele$"), everything())
    
    ### Rename columns -- minor allele
    dfList.selection[[i]] <- select(dfList.selection[[i]], MinorAllele = matches("^minor[_]allele$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], MinorAllele = matches("^minorallele$"), everything())
    
    ### Rename columns -- base pair position
    dfList.selection[[i]] <- select(dfList.selection[[i]], BP = matches("^position$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], BP = matches("^bp$"), everything())
    
    ### Rename columns -- chromosome
    dfList.selection[[i]] <- select(dfList.selection[[i]], CHR = matches("^chr$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], CHR = matches("^chrom$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], CHR = matches("^chromosome$"), everything())
    
    ### Rename columns -- marker name
    dfList.selection[[i]] <- select(dfList.selection[[i]], Marker = matches("^marker$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], Marker = matches("^snp$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], Marker = matches("^rsid$"), everything())
    dfList.selection[[i]] <- select(dfList.selection[[i]], Marker = matches("^cpg$"), everything())
    
    
    ### Rename columns -- removing leading 'zeros'
    cat("\n* removing leading 'zeros' from chromosome number...")
    dfList.selection[[i]]$CHR <- gsub("(?<![0-9])0+", "", dfList.selection[[i]]$CHR, perl = TRUE)
    
    cat("\n* changing X to 23, Y to 24, XY to 25, and MT to 26...")
    ### Renaming chromosomes -- 'PLINK' standard: 
    ### X    X chromosome                    -> 23
    ### Y    Y chromosome                    -> 24
    ### XY   Pseudo-autosomal region of X    -> 25
    ### MT   Mitochondrial                   -> 26
    
    ### Rename chromosomes
    dfList.selection[[i]]$CHR[dfList.selection[[i]]$CHR == "X" | dfList.selection[[i]]$CHR == "x"] <- 23
    dfList.selection[[i]]$CHR[dfList.selection[[i]]$CHR == "Y" | dfList.selection[[i]]$CHR == "y"] <- 24
    dfList.selection[[i]]$CHR[dfList.selection[[i]]$CHR == "XY" | 
                                dfList.selection[[i]]$CHR == "xY" | 
                                dfList.selection[[i]]$CHR == "Xy" | 
                                dfList.selection[[i]]$CHR == "xy"] <- 25
    dfList.selection[[i]]$CHR[dfList.selection[[i]]$CHR == "MT" | 
                                dfList.selection[[i]]$CHR == "Mt" | 
                                dfList.selection[[i]]$CHR == "mT" | 
                                dfList.selection[[i]]$CHR == "mt"] <- 26
    
    ### set 'chromosome' column to integer
    dfList.selection[[i]] <- mutate(dfList.selection[[i]], CHR = as.integer(CHR)) # convert to numeric
    dfList.selection[[i]] <- mutate(dfList.selection[[i]], BP = as.integer(BP)) # convert to numeric
    
    ### Calculating general statistics if not available
    cat("\n* calculating 'allele frequencies'...")
    ### calculate MAF -- *only* if MAF/minor allele/major allele *not* present
    ###                  the effect size must be relative to the effect/coded allele and EAF
    ### calculate EAF -- *only* if MAF/minor allele/major allele *is* present - 
    ###                  if they are, the effect size must be relative to the minor
    
    if("MAF" %in% colnames(dfList.selection[[i]])) {
      cat("\n- minor allele frequency is present, checking for minor/major allele...")
      
      if("MinorAllele" %in% colnames(dfList.selection[[i]])) {
        cat("\n- minor allele is present, checking for major allele...")
        
        if("MajorAllele" %in% colnames(dfList.selection[[i]])) {
          cat("\n- minor/major allele is also present, setting effect/other allele, 
              and calculating effect allele frequency...") # we will only set the effect/other alleles here, and get rid of minor/major alleles later
          dfList.selection[[i]]$EAF <- dfList.selection[[i]]$MAF
          dfList.selection[[i]]$EffectAllele <- dfList.selection[[i]]$MinorAllele
          dfList.selection[[i]]$OtherAllele <- dfList.selection[[i]]$MajorAllele
          
        } else {
          cat("\n\n*** ERROR *** Something is rotten in the City of Gotham. If there's a 'minor allele', 
              a 'major allele' must be present as well.", file=stderr()) # print error messages to stder
        } } } else if("OtherAllele" %in% colnames(dfList.selection[[i]])) {
          cat("\n- other alleles are present, calculating minor allele frequency...") # we only care for MAF
          
          if("EAF" %in% colnames(dfList.selection[[i]])) {
            cat("\n- calculating 'MAF' using 'effect allele frequency'...")
            dfList.selection[[i]]$MAF <- ifelse(dfList.selection[[i]]$EAF < 0.50, 
                                                dfList.selection[[i]]$EAF, 1-dfList.selection[[i]]$EAF)
            
          } else if("RAF" %in% colnames(dfList.selection[[i]])) {
            cat("\n- calculating 'MAF' using 'risk allele frequency'...")
            dfList.selection[[i]]$MAF <- ifelse(dfList.selection[[i]]$RAF < 0.50, 
                                                dfList.selection[[i]]$RAF, 1-dfList.selection[[i]]$RAF)
            colnames(dfList.selection[[i]])[colnames(dfList.selection[[i]]) == "RAF"] <- "EAF"
            
          } else if("CAF" %in% colnames(dfList.selection[[i]])) {
            cat("\n- calculating 'MAF' using 'coded allele frequency'...")
            dfList.selection[[i]]$MAF <- ifelse(dfList.selection[[i]]$CAF < 0.50, 
                                                dfList.selection[[i]]$CAF, 1-dfList.selection[[i]]$CAF)
            colnames(dfList.selection[[i]])[colnames(dfList.selection[[i]]) == "CAF"] <- "EAF"
            
          } else {
            cat("\n\n*** ERROR *** Something is rotten in the City of Gotham. 'MAF', EAF', 'RAF', nor 'CAF' is present. Double back, please.", file=stderr()) # print error messages to stder
          } 
          
        } else {
          cat("\n\n*** ERROR *** Something is rotten in the City of Gotham. There's something wrong with the allele frequencies. Double back, please.", file=stderr()) # print error messages to stder
          
        } 
    
    ### Calculate MAC
    cat("\n* calculating 'minor allele count' (MAC)...")
    dfList.selection[[i]]$MAC <- (dfList.selection[[i]]$MAF*dfList.selection[[i]]$N*2)
    
  }

  cat("\nCreating the final parsed dataset.")
  cat("\n- making empty dataframes...")
  
  ### Again looping over the list, and calculating the needed sizes of these dataframes...
  for (i in seq_along(dfList.selection)) {
    col.Classes = c("character", "integer", "integer", "character", 
                    "character", "character", 
                    "numeric", "numeric", "numeric", "numeric", "numeric", 
                    "numeric", "numeric", "numeric", 
                    "integer", "integer", "integer", 
                    "character")
    col.Names = c("Marker", "CHR", "BP", "Strand", 
                  "EffectAllele", "OtherAllele", 
                  "EAF", "MAF", "MAC", "HWE_P", "Info",
                  "Beta", "SE", "P",
                  "N", "N_cases", "N_controls",
                  "Imputed")
    assign(paste("num_rows", i, sep = "_"), length(dfList.selection[[i]]$Marker))
    assign(paste("num_cols", i, sep = "_"), length(col.Names))
  }
  
  for (i in seq_along(dfList.selection)) {
    ### inverse variance weighted z-score
    dfList.selection[[i]]$weight = 1 / (dfList.selection[[i]]$SE * dfList.selection[[i]]$SE)
    dfList.selection[[i]]$weighted_beta = dfList.selection[[i]]$Beta * dfList.selection[[i]]$weight
  }
  
  for(i in length(dfList.selection)) {
    total_weighted_beta = sum(dfList.selection[[1]]$weighted_beta, dfList.selection[[2]]$weighted_beta, na.rm = FALSE)
    total_weight = dfList.selection[[1]]$weight + dfList.selection[[2]]$weight
    total_weight_squared = dfList.selection[[1]]$weight * dfList.selection[[2]]$weight
  }
  
  
  
  ### Function to create empty table
  create_empty_table <- function(num_rows, num_cols) {
    GWASDATA_PARSED <- data.frame(matrix(NA, nrow = num_rows, ncol = num_cols))
    
    return(GWASDATA_PARSED)
  }
  
  GWASDATA_PARSED <- create_empty_table(num_rows, num_cols)
  colnames(GWASDATA_PARSED) <- col.Names
  
  cat("\n- adding data to dataframe...")
  cat("\n  > adding the new markers...")
  GWASDATA_PARSED$Marker <- as.character(paste("chr",GWASDATA_RAWSELECTION$CHR,":",
                                                  GWASDATA_RAWSELECTION$BP,":",
                                                  GWASDATA_RAWSELECTION$OtherAllele,"_",
                                                  GWASDATA_RAWSELECTION$EffectAllele, 
                                                  sep = ""))
  
  cat("\n  > adding the original markers...")
  GWASDATA_PARSED$MarkerOriginal <- GWASDATA_RAWSELECTION$MarkerOriginal
  
  cat("\n  > changing NA to '0' for Chr...")
  GWASDATA_PARSED$CHR <- GWASDATA_RAWSELECTION$CHR
  GWASDATA_PARSED <- GWASDATA_PARSED %>% mutate(CHR = ifelse(is.na(CHR),0,CHR)) # unknown chromosomes are set to '0'
  
  cat("\n  > changing NA to '0' for BP...")
  GWASDATA_PARSED$BP <- GWASDATA_RAWSELECTION$BP
  GWASDATA_PARSED <- GWASDATA_PARSED %>% mutate(BP = ifelse(is.na(BP),0,BP))# unknown base pair positions are set to '0'
  
  cat("\n  > adding strand information...")
  GWASDATA_PARSED$Strand <- ifelse(("Strand" %in% colnames(GWASDATA_RAWSELECTION)) == TRUE, 
                                   GWASDATA_RAWSELECTION$Strand, "+") # we always assume that the +-strand was used
  
  cat("\n  > adding alleles...")
  GWASDATA_PARSED$EffectAllele <- ifelse(GWASDATA_RAWSELECTION$EffectAllele != "NA", GWASDATA_RAWSELECTION$EffectAllele, "NA")
  GWASDATA_PARSED$OtherAllele <- ifelse(GWASDATA_RAWSELECTION$OtherAllele != "NA", GWASDATA_RAWSELECTION$OtherAllele, "NA")
  
  cat("\n  > adding allele statistics...")
  GWASDATA_PARSED$EAF <- ifelse(GWASDATA_RAWSELECTION$EAF != "NA", GWASDATA_RAWSELECTION$EAF, "NA")
  GWASDATA_PARSED$MAF <- ifelse(GWASDATA_RAWSELECTION$MAF != "NA", GWASDATA_RAWSELECTION$MAF, "NA")
  GWASDATA_PARSED$MAC <- ifelse(GWASDATA_RAWSELECTION$MAC != "NA", GWASDATA_RAWSELECTION$MAC, "NA")
  
  if(("HWE_P" %in% colnames(GWASDATA_RAWSELECTION)) == TRUE){
    GWASDATA_PARSED$HWE_P <- ifelse(GWASDATA_RAWSELECTION$HWE_P != "NA", GWASDATA_RAWSELECTION$HWE_P, "NA")
  } else {
    GWASDATA_PARSED$HWE_P <- "NA" # this is not always present
  } 
  
  if(("Info" %in% colnames(GWASDATA_RAWSELECTION)) == TRUE){
    GWASDATA_PARSED$Info <- ifelse(GWASDATA_RAWSELECTION$Info != "NA", GWASDATA_RAWSELECTION$Info, "1") # in case "NA" we set it to 1
  } else {
    GWASDATA_PARSED$Info <- "1" # in case of genotyped data
  }
  
  cat("\n  > adding test statistics...")  
  GWASDATA_PARSED$Beta <- ifelse(GWASDATA_RAWSELECTION$Beta != "NA", GWASDATA_RAWSELECTION$Beta, "NA")
  GWASDATA_PARSED$SE <- ifelse(GWASDATA_RAWSELECTION$SE != "NA", GWASDATA_RAWSELECTION$SE, "NA")
  GWASDATA_PARSED$P <- ifelse(GWASDATA_RAWSELECTION$P != "NA", GWASDATA_RAWSELECTION$P, "NA")
  
  cat("\n  > adding sample information statistics...")  
  GWASDATA_PARSED$N <- ifelse(GWASDATA_RAWSELECTION$N != "NA", GWASDATA_RAWSELECTION$N, "NA")
  
  if(("N_cases" %in% colnames(GWASDATA_RAWSELECTION)) == TRUE){
    GWASDATA_PARSED$N_cases <- ifelse(GWASDATA_RAWSELECTION$N_cases != "NA", GWASDATA_RAWSELECTION$N_cases, "NA")
  } else {
    GWASDATA_PARSED$N_cases <- "NA" # in case of quantitative trait analyses
  } 
  
  if(("N_controls" %in% colnames(GWASDATA_RAWSELECTION)) == TRUE){
    GWASDATA_PARSED$N_controls <- ifelse(GWASDATA_RAWSELECTION$N_controls != "NA", GWASDATA_RAWSELECTION$N_controls, "NA")
  } else {
    GWASDATA_PARSED$N_controls <- "NA" # in case of quantitative trait analyses
  }
  
  if(("Imputed" %in% colnames(GWASDATA_RAWSELECTION)) == TRUE){
    GWASDATA_PARSED$Imputed <- ifelse(GWASDATA_RAWSELECTION$Imputed != "NA", GWASDATA_RAWSELECTION$Imputed, "NA")
  } else {
    GWASDATA_PARSED$Imputed <- "2" # 2 = no information, 1 = imputed, 0 = genotyped
  }
  
  cat("\nAll done creating the final parsed dataset.")
  ### SAVE NEW DATA ###
  cat("\n\nSaving parsed data...\n")
  write.table(GWASDATA_PARSED, 
              paste0(ROOT_loc, "/", OUT_loc, "/", 
                     basename(opt$datagwas), 
                     ".pdat"),
              quote = FALSE , row.names = FALSE, col.names = TRUE, 
              sep = "\t", na = "NA", dec = ".")
  
  ### CLOSING MESSAGE
  cat(paste("\nAll done parsing [",file_path_sans_ext(basename(opt$datagwas), compression = TRUE),"].\n"))
  cat(paste("\nToday's date is: ", Today, ".\n", sep = ''))
  
  # } else {
  #   cat("\n\n\n\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
  #   cat("\n*** ERROR *** You didn't specify all variables:\n
  #       - --p/projectdir    : Path to the project directory.
  #       - --d/datagwas      : Path to the GWAS data, relative to the project directory;
  #       can be tab, comma, space or semicolon delimited, as well as gzipped.
  #       - --o/outputdir     : Path to output directory.",
  #       file=stderr()) # print error messages to stderr
  # }

cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
# 
# ### SAVE ENVIRONMENT | FOR DEBUGGING
# save.image(paste0(ROOT_loc, "/", OUT_loc, "/", Today,"_", basename(opt$datagwas),"_DEBUG_GWAS_PARSER.RData"))


# 
# write.table(sign_plaque, file = "/Volumes/EliteProQx2Media/PLINK/analyses/test_ewas/aems450k1.sign_plaque.txt", 
#             row.names = FALSE, sep = "\t", quote = FALSE, na = "NA", dec = ".")
# write.table(sign_plaque_AEM2, file = "/Volumes/EliteProQx2Media/PLINK/analyses/test_ewas/aems450k2.sign_plaque.txt", 
#             row.names = FALSE, sep = "\t", quote = FALSE, na = "NA", dec = ".")
# 
# AEM_COX_Results$CpG <- row.names(AEM_COX_Results)
# write.table(AEM_COX_Results, file = "/Volumes/EliteProQx2Media/PLINK/analyses/test_ewas/aems450k1.cox.txt", 
#             row.names = FALSE, sep = "\t", quote = FALSE, na = "NA", dec = ".")
# AEM2_COX_Results$CpG <- row.names(AEM2_COX_Results)
# write.table(AEM2_COX_Results, file = "/Volumes/EliteProQx2Media/PLINK/analyses/test_ewas/aems450k2.cox.txt", 
#             row.names = FALSE, sep = "\t", quote = FALSE, na = "NA", dec = ".")





