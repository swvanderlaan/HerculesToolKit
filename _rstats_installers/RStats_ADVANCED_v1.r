#!/usr/local/bin/Rscript --vanilla

# Alternative shebang for local Mac OS X: "#!/usr/local/bin/Rscript --vanilla"
# Linux version for HPC: #!/hpc/local/CentOS7/dhl_ec/software/R-3.4.0/bin/Rscript --vanilla
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    R STATISTICS UPDATER: ADVANCED PACKAGES
    \n
    * Name:        RStats_ADVANCED
    * Version:     v1.6.3
    * Last edit:   2022-01-09
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

cat("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                          Install GENERAL install.packages
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")

cat("\n* For VEGAS to work...\n")
install.packages.auto("corpcor") 
install.packages.auto("mvtnorm") 

cat("\n* For clustering and correlation...\n")
install.packages.auto("spatstat")
install.packages.auto("pvclust")
install.packages.auto("mclust")
install.packages.auto("cluster")
install.packages.auto("corrgram")

cat("\n* For heatmaps...\n")
# install.packages.auto("heatmap.plus") # not updated anymore
install.packages.auto("heatmap3")
install.packages.auto("pheatmap")
install.packages.auto("ComplexHeatmap")

install.packages.auto("ape")
install.packages.auto("circlize")
install.packages.auto("SAM")
install.packages.auto("irlba")
install.packages.auto("Matrix")
install.packages.auto("DBI")

cat("\n* Proteomics-specific clustering tools...\n")
install.packages.auto("randomForestSRC")

cat("\n* Install packages to load in foreign data, such as SAS or STATA...\n")
install.packages.auto("foreign")

cat("\n* Packages to load in \"foreign\" data, for new STATA v13 files...\n")
devtools::install_github("sjewo/readstata13", ref="0.4")

cat("\n* Some meta-analysis/forest plots install.packages. Also refer to http://cran.r-project.org/web/views/MetaAnalysis.html...\n")
install.packages.auto("Gmisc")
install.packages.auto("rmeta")
install.packages.auto("diagram")
install.packages.auto("metafor")
install.packages.auto("meta")
install.packages.auto("RISmed")
install.packages.auto("epiR")

cat("\n* Some additional useful packages...\n")
install.packages.auto("AICcmodavg")
install.packages.auto("car")
install.packages.auto("rms")
install.packages.auto("survival")
install.packages.auto("survminer")
install.packages.auto("tableone")
install.packages.auto("forestplot")
install.packages.auto("haven") # for loading SPSS files!

cat("\n* Some additional packages needed for 'powsimR'...\n")
install.packages.auto("methods")
install.packages.auto("stats")
install.packages.auto("Rtsne")
install.packages.auto("moments")
install.packages.auto("minpack.lm")
install.packages.auto("glmnet")
install.packages.auto("MASS")
install.packages.auto("reshape2")
install.packages.auto("tibble")
install.packages.auto("cowplot")
install.packages.auto("scales")
install.packages.auto("cobs")
install.packages.auto("msir")
install.packages.auto("drc")
install.packages.auto("DrImpute")
install.packages.auto("VGAM")

cat("\n\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
#--------------------------------------------------------------------------
### CLOSING MESSAGE
cat("All done updating R on the HPC or your Mac.\n")
cat(paste("\nToday's: ",Today, "\n"))
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
