#!/usr/local/bin/Rscript --vanilla

# Alternative shebang for local Mac OS X: "#!/usr/local/bin/Rscript --vanilla"
# Linux version for HPC: #!/hpc/local/CentOS7/dhl_ec/software/R-3.3.1/bin/Rscript --vanilla
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    R STATISTICS UPDATER: VARIOUS OMICS PACKAGES
    \n
    * Name:        RStats_OMICS
    * Version:     v1.9.2
    * Last edit:   2022-04-11
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
update.packages(checkBuilt = TRUE, ask = TRUE)

cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                      Install some 'Omics' packages
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n
* Needed to perform eQTL analyses...\n")
# install.packages.auto("MatrixEQTL")

cat("\n* Needed to perform RNAseq analyses...\n")
install.packages.auto("rtracklayer")
install.packages.auto("GenomicRanges")
install.packages.auto("SummarizedExperiment")
install.packages.auto("DESeq2")
install.packages.auto("edgeR")
install.packages.auto("RcppArmadillo")
install.packages.auto("Biostrings")
install.packages.auto("gdsfmt")
install.packages.auto("git2r")
install.packages.auto("limma")
install.packages.auto("lumi")
install.packages.auto("S4Vectors")
install.packages.auto("annotate")
install.packages.auto("AnnotationDbi")
install.packages.auto("org.Hs.eg.db")
install.packages.auto("calibrate")
install.packages.auto("Gviz")
install.packages.auto("genefilter")
install.packages.auto("geneplotter")
install.packages.auto("GenomeInfoDb")
install.packages.auto("GenomicFeatures")
install.packages.auto("IRanges")
install.packages.auto("GenomeInfoDb")
install.packages.auto("FDb.InfiniumMethylation.hg19")
install.packages.auto("TxDb.Hsapiens.UCSC.hg19.knownGene")
install.packages.auto("ReportingTools")
install.packages.auto("Rsamtools")
install.packages.auto("MEAL")
install.packages.auto("MultiDataSet")
## install.packages.auto("MEALData") # deprecated
install.packages.auto("bacon")
install.packages.auto("qqman")

# Parallelisation
cat("\n* For parallelization...\n")
# For some packages 'ModelMetrics' is needed. If installation fails install this library
# using `homebrew`
# brew install libomp
BiocManager::install("ModelMetrics")
install.packages.auto("BatchJobs")
install.packages.auto("Biobase") # getConfig()
install.packages.auto("BBmisc")
install.packages.auto("stats4")
install.packages.auto("BiocGenerics")
install.packages.auto("BiocParallel")
install.packages.auto("doParallel")
install.packages.auto("parallel")
install.packages.auto("snow")
# dependencies of the 6 packages above
install.packages.auto("lattice")
install.packages.auto("XVector")
install.packages.auto("bumphunter")
install.packages.auto("foreach")
install.packages.auto("iterators")
install.packages.auto("locfit")
install.packages.auto("matrixStats")

install.packages.auto("NBPSeq")
install.packages.auto("RUVSeq")
install.packages.auto("baySeq")
install.packages.auto("NOISeq")
install.packages.auto("EBSeq")

# install.packages.auto("DEDS")
install.packages.auto("Linnorm")
install.packages.auto("MAST")
install.packages.auto("scde")
install.packages.auto("ROTS")
install.packages.auto("monocle")
# BiocManager::install("lpsymphony", version = "3.8")
# BiocManager::install("IHW") # gives issues with BiocManager::install("lpsymphony", version = "3.8")
install.packages.auto("qvalue")

# Making Circos plots of Omics data.
install.packages.auto("OmicCircos")

cat("\n* Installation of 'BASiCS' and its dependencies...\n")
install.packages.auto("scran")
install.packages.auto("scater")
install.packages.auto("scDD")
install.packages.auto("hdf5r")


# Install the devtools package from Hadley Wickham
install.packages.auto("devtools")
library("devtools")

# Required for Seurat
install.packages.auto("igraph")

# Replace '2.3.4' with your desired version
# devtools::install_version(package = "Seurat", version = package_version('2.3.4'))
# source("https://z.umn.edu/archived-seurat")
install.packages.auto("Seurat") # latest version
library("Seurat")

library(devtools)
#install_github("catavallejos/BASiCS", build_vignettes = FALSE, dependencies = TRUE)
# install_github("nghiavtr/BPSC", build_vignettes = FALSE, dependencies = TRUE)
install_github("rhondabacher/SCnorm", 
               build_vignettes = FALSE, dependencies = TRUE)

BiocManager::install("scRNAseq")

BiocManager::install("SingleCellExperiment")

# cat("\n* Installation of 'powsimR' (ref: https:\//github.com\/bvieth\/powsimR)...\n")
library(devtools)

# CRAN PACKAGES
install.packages.auto(c("broom", "cobs", "cowplot", "data.table", "doParallel", "dplyr",
                        "DrImpute", "fastICA", "fitdistrplus", "foreach", "future", "gamlss.dist", "ggplot2",
                        "ggpubr", "ggstance", "grDevices", "grid", "Hmisc", "kernlab", "MASS", "magrittr",
                        "MBESS", "Matrix", "matrixStats", "mclust", "methods", "minpack.lm", "moments",
                        "msir", "NBPSeq", "nonnest2", "parallel", "penalized", "plyr", "pscl", "reshape2",
                        "Rmagic", "rsvd", "Rtsne", "scales", "Seurat", "snow", "sctransform", "stats",
                        "tibble", "tidyr", "truncnorm", "VGAM", "ZIM", "zoo"))

# BIOCONDUCTOR
#    "IHW", # Error with 'lpsymphony' - see remarks below
install.packages.auto(c("bayNorm", "baySeq", "BiocGenerics", "BiocParallel", "DESeq2",
                        "EBSeq", "edgeR", "IHW", "iCOBRA", "limma", "Linnorm", "MAST", "monocle", "NOISeq",
                        "qvalue", "ROTS", "RUVSeq", "S4Vectors", "scater", "scDD", "scde", "scone", "scran",
                        "SCnorm", "SingleCellExperiment", "SummarizedExperiment", "zinbwave"))

# REMARK 1
# install 'IWH' from source, this will also install 'lpsymphony' from source.
# if (!requireNamespace("BiocManager", quietly = TRUE))
#     install.packages("BiocManager")
# BiocManager::install("IHW", version = "3.8")

# REMARK 2
# If the code at REMARK 1 doesn't work, do this:
# Download and install these packages directly in R
# R CMD INSTALL Downloads/lpsymphony_1.10.0.tgz
# R CMD INSTALL Downloads/IHW_1.10.1.tgz

# REMARK 3
# If this throws an error, follow the instructions here:
# https://thecoatlessprofessor.com/programming/openmp-in-r-on-os-x/
# Further information: 
# https://cran.r-project.org/doc/manuals/r-patched/R-admin.html#macOS
# Workflow:
#	- download and install CLANG6+
#	- download and install GFORTRAN
# 	- make and set ~/.R/Makevars

# Regardless, this also needs to be installed.
install.packages.auto("rsvd")

# GITHUB
# install.packages.auto("BPSC")
# install.packages.auto("DECENT")
# install.packages.auto("SAVER")
# install.packages.auto("zingeR")
# 
# devtools::install_github("bvieth/powsimR", build_vignettes = TRUE, dependencies = FALSE)
# library("powsimR")

# HyPrColoc
# Hypothesis Prioritisation in multi-trait Colocalization (HyPrColoc) analyses.
# > hyprcoloc - performs multi-trait colocalization across multiple traits.

# https://github.com/jrs95/hyprcoloc
# there is an issue with the installation to do with the `markdown` packages and writing
# vignettes
# https://github.com/jrs95/hyprcoloc/issues/7

install.packages.auto("devtools")
install_github("jrs95/hyprcoloc", build_vignettes = FALSE)

cat("\n\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
#--------------------------------------------------------------------------
### CLOSING MESSAGE
cat("All done updating R on the HPC or your Mac.\n")
cat(paste("\nToday's: ",Today, "\n"))
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
