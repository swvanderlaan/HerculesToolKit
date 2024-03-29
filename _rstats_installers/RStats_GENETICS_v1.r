#!/usr/local/bin/Rscript --vanilla

# Alternative shebang for local Mac OS X: "#!/usr/local/bin/Rscript --vanilla"
# Linux version for HPC: #!/hpc/local/CentOS7/dhl_ec/software/R-3.4.0/bin/Rscript --vanilla
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    R STATISTICS UPDATER: GENETICS PACKAGES
    \n
    * Name:        RStats_GENETICS
    * Version:     v1.9.9
    * Last edit:   2022-12-07
    * Created by:  Sander W. van der Laan | s.w.vanderlaan-2@umcutrecht.nl
    \n
    * Description: This script can be used to update R-3+ via the commandline.
    
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")

# CLEAR THE BOARD
rm(list = ls())

#--------------------------------------------------------------------------
### GENERAL SETUP
Today=format(as.Date(as.POSIXlt(Sys.time())), "%Y%m%d")
cat(paste("\nToday's date is: ", Today, ".\n", sep = ''))

cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                              INSTALLATION OF USEFUL PACKAGES
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n
* Loading install function for packages. It will check whether the packages is already installed,
if not it will update.\n")

#--------------------------------------------------------------------------
### FUNCTION TO INSTALL PACKAGES, VERSION A -- This is a function found by 
### Sander W. van der Laan online from @Samir: 
### http://stackoverflow.com/questions/4090169/elegant-way-to-check-for-missing-packages-and-install-them
### Compared to VERSION 1 the advantage is that it will automatically check in both CRAN and Bioconductor

install.packages.auto <- function(x) { 
  x <- as.character(substitute(x)) 
  if(isTRUE(x %in% .packages(all.available = TRUE))) { 
    eval(parse(text = sprintf("require(\"%s\")", x)))
  } else { 
    # Update installed packages - this may mean a full upgrade of R, which in turn
    # may not be warrented. 
    #update.install.packages.auto(ask = FALSE) 
    eval(parse(text = sprintf("install.packages(\"%s\", dependencies = TRUE, repos = \"https://cloud.r-project.org/\")", x)))
  }
  if(isTRUE(x %in% .packages(all.available = TRUE))) { 
    eval(parse(text = sprintf("require(\"%s\")", x)))
  } else {
    if (!requireNamespace("BiocManager"))
      install.packages("BiocManager")
    BiocManager::install() # this would entail updating installed packages, which in turned may not be warrented
    
    # Code for older versions of R (<3.5.0)
    # source("http://bioconductor.org/biocLite.R")
    # Update installed packages - this may mean a full upgrade of R, which in turn
    # may not be warrented.
    # biocLite(character(), ask = FALSE) 
    eval(parse(text = sprintf("BiocManager::install(\"%s\")", x)))
    eval(parse(text = sprintf("require(\"%s\")", x)))
  }
}

cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
cat("\n* Determining R version used...\n")

version

cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
cat("\n* Library paths used...\n")

.libPaths()

cat("\n\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
cat("\n* Updating installed packages...\n")

chooseCRANmirror(ind=1)

cat("\n* Let's update if necessary...\n")
update.packages(checkBuilt = TRUE, ask = FALSE)

# cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#                           Install GenABEL install.packages
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
# install.packages.auto("DatABEL")
# install.packages.auto("GenABEL")
# install.packages.auto("MetABEL")
# install.packages.auto("VariABEL")
# install.packages.auto("CollapsABEL")
# install.packages.auto("RepeatABEL")
# install.packages.auto("PredictABEL") # only works on local environment; not HPC as Tcl/Tk is needed

cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                      Install some Genetics install.packages
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n
* Needed for LDheatmap package...\n")
install.packages.auto("haplo.stats")
install.packages.auto("survival")
install.packages.auto("splines") 
install.packages.auto("LDheatmap")
install.packages.auto("SNPRelate") 
# install.packages.auto("snp.plotter") # not available in this version Bioconductor version 3.16 (BiocManager 1.30.19), R 4.2.2 (2022-10-31)
install.packages.auto("Biostrings")
install.packages.auto("SNPassoc")
# install.packages.auto("SNPtools") # removed from R https://cran.r-project.org/web/packages/SNPtools/index.html
install.packages.auto("GWASExactHW")
install.packages.auto("SKAT")

# To make regional association plots
# install.packages("devtools") 
library(devtools)

# GASSOCPLOT
# https://github.com/jrs95/gassocplot2
# First version, only supports b37
# devtools::install_github("jrs95/gassocplot")
# library(gassocplot)
# Second version
# supports b38 and additional marker labeling
devtools::install_github("jrs95/gassocplot2")
library(gassocplot2)

# RACER
# https://github.com/oliviasabik/RACER
install_github("oliviasabik/RACER") 
library(RACER) 

# install.packages.auto("MultiPhen") # removed from R https://cran.r-project.org/web/packages/MultiPhen/index.html
# https://github.com/mturchin20/bmass
cat("The bmass R package provides accessible functions for running the algorithms described in \n
Stephens 2013 PLoS ONE and applied to multiple large, publicly available GWAS datasets in \n
Turchin and Stephens 2019. bmass conducts a Bayesian multivariate analysis of GWAS data \n
using univariate association summary statistics. Output inclues whether any new SNPs are \n
found as multivariate genome-wide significant as well as posterior probabilities of each \n
significant SNP\'s assignment to different multivariate models.\n

For more details on the results of applying bmass to publicly available GWAS datasets, \n
please see our paper on bioRxiv. For more details regarding the underlying algorthims of \n
bmass, please see Stephens 2013 PLoS ONE.\n

If you find a bug, or you have a question or feedback on our work, please post an issue.")
install.packages.auto("bmass")

# Edit: 2022-04-04
# Author: Sander W. van der Laan
# For some r packages there is an issue, described in these posts.
# Reference: https://medium.com/biosyntax/following-up-library-dependency-when-compiling-r-packages-89f191b9f227
# Reference: https://stackoverflow.com/questions/61829237/r-package-installation-ld-warning-directory-not-found-for-option-l-usr-loca

cat("\n* Needed for Pweight - Bayesian analysis. Reference: https://github.com/dobriban/pweight...\n")
devtools::install_github("dobriban/pweight")
# install.packages.auto("pweight")

cat("\nGWASglue: to harmonize GWAS datasets to a reference and other datasets...\n")
# REF: https://mrcieu.github.io/gwasglue/
# This R package serves as a conduit between packages that can read or query GWAS summary data, 
# and packages that can analyse GWAS summary data.
# For this there are several packages needed or recommended:

install.packages.auto("fansi")
install.packages.auto("rjson")
install.packages.auto("susieR")

# Reference (required!): http://bioconductor.org/packages/release/bioc/html/snpStats.html
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("snpStats")

# Reference: https://github.com/mrcieu/gwasvcf
# it needs BiocGenerics 0.37+ and perhaps you need to do this manually
remotes::install_github("mrcieu/gwasvcf")
# Reference: https://github.com/mrcieu/ieugwasr
devtools::install_github("mrcieu/ieugwasr")

devtools::install_github("mrcieu/gwasglue")

cat("\n\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
#--------------------------------------------------------------------------
### CLOSING MESSAGE
cat("All done updating R on the HPC or your Mac.\n")
cat(paste("\nToday's: ",Today, "\n"))
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
