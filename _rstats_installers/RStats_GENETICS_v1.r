#!/usr/local/bin/Rscript --vanilla

# Alternative shebang for local Mac OS X: "#!/usr/local/bin/Rscript --vanilla"
# Linux version for HPC: #!/hpc/local/CentOS7/dhl_ec/software/R-3.4.0/bin/Rscript --vanilla
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    R STATISTICS UPDATER: GENETICS PACKAGES
    \n
    * Name:        RStats_GENETICS
    * Version:     v1.9.2
    * Last edit:   2019-03-19
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
install.packages.auto("snp.plotter")
install.packages.auto("SNPassoc")
# install.packages.auto("SNPtools") # removed from R https://cran.r-project.org/web/packages/SNPtools/index.html
install.packages.auto("GWASExactHW")
install.packages.auto("SKAT")

## cat("\n* Needed for multivariate analysis...\n") # Not available???
# install.packages.auto("MultiPhen") # removed from R https://cran.r-project.org/web/packages/MultiPhen/index.html

cat("\n* Needed for Pweight - Bayesian analysis. Reference: https://github.com/dobriban/pweight...\n")
devtools::install_github("dobriban/pweight")
# install.packages.auto("pweight")

cat("\n\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
#--------------------------------------------------------------------------
### CLOSING MESSAGE
cat("All done updating R on the HPC or your Mac.\n")
cat(paste("\nToday's: ",Today, "\n"))
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
