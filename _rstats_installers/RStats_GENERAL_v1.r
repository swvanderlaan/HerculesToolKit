#!/usr/local/bin/Rscript --vanilla

# Alternative shebang for local Mac OS X: "#!/usr/local/bin/Rscript --vanilla"
# Linux version for HPC: #!/hpc/local/CentOS7/dhl_ec/software/R-3.4.0/bin/Rscript --vanilla
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    R STATISTICS UPDATER: GENERAL PACKAGES
    \n
    * Name:        RStats_GENERAL
    * Version:     v1.7.3
    * Last edit:   2022-04-03
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

cat("\n* For Rscript --args parsing...\n")
install.packages.auto("optparse")
install.packages.auto("tools")
install.packages.auto("devtools")
# Needed to publish ShinyApps
#install.packages('PKI',,'http://www.rforge.net/') # refer to: https://github.com/s-u/PKI/issues/17
install.packages.auto("rsconnect")
install.packages.auto("shiny")

cat("\n* For R markdown some themes, taken from [http://www.datadreaming.org/post/r-markdown-theme-gallery/]...\n")
install.packages.auto("prettydoc")
install.packages.auto("rmdformats")
install.packages.auto("hrbrthemes")
# hrbrthemes::import_roboto_condensed()
devtools::install_github("hrbrmstr/markdowntemplates")
install.packages.auto("tufte")
install.packages.auto("tint")

# Needed for Bookdown among others
# Ref: https://bookdown.org/yihui/rmarkdown/installation.html
# Install from CRAN
install.packages.auto('rmarkdown')
install.packages.auto('tinytex')
tinytex::install_tinytex()  # install TinyTeX

# Reference: https://github.com/cboettig/knitcitations
library(devtools)
install_github("cboettig/knitcitations")

# Reference: https://github.com/ropensci/RefManageR
install.packages("remotes")
remotes::install_github("ropensci/RefManageR")

library("devtools")
install_github("Pakillo/rmdTemplates")
# install_github("jhollist/manuscriptPackage",build_vignettes=TRUE)
# library("manuscriptPackage")

devtools::install_github("romainfrancois/bibtex")
devtools::install_github("mwmclean/RefManageR")

cat("\n* For several R packages 'xml2' is absolutely critical...\n")
# these give issues with xml2
# * installing *source* package ‘xml2’ ...
# ** package ‘xml2’ successfully unpacked and MD5 sums checked
# ** using staged installation
# Found pkg-config cflags and libs!
# Using PKG_CFLAGS=-I/usr/include/libxml2
# Using PKG_LIBS=-L/usr/lib -lxml2 -lz -lpthread -licucore -lm
# ------------------------- ANTICONF ERROR ---------------------------
# Configuration failed because libxml-2.0 was not found. Try installing:
#  * deb: libxml2-dev (Debian, Ubuntu, etc)
#  * rpm: libxml2-devel (Fedora, CentOS, RHEL)
#  * csw: libxml2_dev (Solaris)
# If libxml-2.0 is already installed, check that 'pkg-config' is in your
# PATH and PKG_CONFIG_PATH contains a libxml-2.0.pc file. If pkg-config
# is unavailable you can set INCLUDE_DIR and LIB_DIR manually via:
# R CMD INSTALL --configure-vars='INCLUDE_DIR=... LIB_DIR=...'

# This seems to be the perfect solution for that
# Refer also to:
# - https://github.com/r-lib/xml2/issues/223
# - https://github.com/r-lib/xml2/issues/232

# devtools::install_github("r-lib/xml2")

install.packages("xml2", configure.vars='INCLUDE_DIR=/usr/local/opt/libxml2/include/libxml2 LIB_DIR=/usr/local/opt/libxml2/lib/')

cat("\n* Useful statistics functions...\n")
install.packages.auto("Hmisc")
install.packages.auto("GetoptLong")
install.packages.auto("gstat")
install.packages.auto("gplots")
install.packages.auto("ggplot2")

# publication ready GGPLOT2 figures
library(devtools)
devtools::install_github("kassambara/ggpubr")
devtools::install_github("NightingaleHealth/ggforestplot")

install.packages.auto("ggthemes")
install.packages.auto("ggsci")
install.packages.auto("gtools")
install.packages.auto("grid")
install.packages.auto("ggExtra")

install.packages.auto("Rmisc")
install.packages.auto("msm")
install.packages.auto("openxlsx")
install.packages.auto("dplyr")
install.packages.auto("tidyr")
install.packages.auto("plyr")
install.packages.auto("readr")
install.packages.auto("stringr")

# To get 'data.table' with 'fwrite' to be able to directly write gzipped-files
# Ref: https://stackoverflow.com/questions/42788401/is-possible-to-use-fwrite-from-data-table-with-gzfile
# install.packages("data.table", repos = "https://Rdatatable.gitlab.io/data.table")
library(data.table)

install.packages.auto("PoiClaClu")
install.packages.auto("RColorBrewer")
# https://yihui.name/formatr/#1-installation -- needed for powsimR
install.packages("formatR", repos = "http://cran.rstudio.com")
### install.packages.auto("rJava")

# https://www.ardata.fr/en/package-r/
# devtools::install_github("davidgohel/gdtools")
install.packages.auto("gdtools")
install.packages.auto("ggiraph")
install.packages.auto("officer")
install.packages.auto("flextable")
install.packages.auto("mschart")
install.packages.auto("rvg")

cat("\n\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
#--------------------------------------------------------------------------
### CLOSING MESSAGE
cat("All done updating R on the HPC or your Mac.\n")
cat(paste("\nToday's: ",Today, "\n"))
cat("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")

