#!/usr/local/bin/Rscript --vanilla

# Alternative shebang for local Mac OS X: "#!/usr/local/bin/Rscript --vanilla"
# Linux version for HPC: #!/hpc/local/CentOS7/dhl_ec/software/R-3.3.1/bin/Rscript --vanilla
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    R STATISTICS UPDATER: VARIOUS OMICS PACKAGES
    \n
    * Name:        RStats_OMICS
    * Version:     v1.5
    * Last edit:   2018-01-26
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
          source("http://bioconductor.org/biocLite.R")
          # Update installed packages - this may mean a full upgrade of R, which in turn
          # may not be warrented.
          #biocLite(character(), ask = FALSE) 
          eval(parse(text = sprintf("biocLite(\"%s\")", x)))
          eval(parse(text = sprintf("require(\"%s\")", x)))
     }
}

cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
cat("\n* Determining R version used...\n")

version

cat("\n\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
cat("\n* Updating installed packages...\n")
source("http://bioconductor.org/biocLite.R")
#?BiocUpgrade
#biocLite("BiocUpgrade")
biocLite()

chooseCRANmirror(ind=51)

cat("\n* Let's update if necessary...\n")
update.packages(checkBuilt = TRUE, ask = FALSE)

cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                      Install some 'Omics' packages
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n
* Needed to perform eQTL analyses...\n")
install.packages.auto("MatrixEQTL")

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
install.packages.auto("MEALData")
install.packages.auto("bacon")
install.packages.auto("qqman")

# Parallelisation
cat("\n* For parallelization...\n")
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

install.packages.auto("DEDS")
install.packages.auto("Linnorm")
install.packages.auto("MAST")
install.packages.auto("scde")
install.packages.auto("ROTS")
install.packages.auto("monocle")
install.packages.auto("IHW")
install.packages.auto("qvalue")

cat("\n* Installation of 'BASiCS' and its dependencies...\n")
source("https://bioconductor.org/biocLite.R")
biocLite("SingleCellExperiment")
install.packages.auto("scran")
install.packages.auto("scater")
install.packages.auto("scDD")

BiocInstaller::biocLite("scRNAseq")
library(devtools)
install_github("catavallejos/BASiCS", build_vignettes = FALSE, dependencies = TRUE)

library(devtools)
install_github("nghiavtr/BPSC", build_vignettes = FALSE, dependencies = TRUE)
library(devtools)
install_github("rhondabacher/SCnorm", build_vignettes = FALSE, dependencies = TRUE)

cat("\n* Installation of 'powsimR' (ref: https://github.com/bvieth/powsimR)...\n")
library(devtools)
install_github("bvieth/powsimR", build_vignettes = FALSE, dependencies = FALSE)

cat("\n\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
#--------------------------------------------------------------------------
### CLOSING MESSAGE
cat("All done updating R on the HPC or your Mac.\n")
cat(paste("\nToday's: ",Today, "\n"))
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")