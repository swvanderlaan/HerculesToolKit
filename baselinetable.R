cat("====================================================================================================
*                                      BASELINE TABLES
*
* Version:      version 1.0
*
* Last update: 2018-02-07
* Written by: Sander W. van der Laan (s.w.vanderlaan-2@umcutrecht.nl)
*                                                    
* Description: Script to create baseline tables.
*
*
====================================================================================================")
cat("CLEAR THE BOARD")
rm(list = ls())

cat("====================================================================================================")
cat("GENERAL R SETUP ")

### FUNCTION TO INSTALL PACKAGES, VERSION A -- This is a function found by 
### Sander W. van der Laan online from @Samir: 
### http://stackoverflow.com/questions/4090169/elegant-way-to-check-for-missing-packages-and-install-them
### Compared to VERSION 1 the advantage is that it will automatically check in both CRAN and Bioconductor
cat("Creating some functions and loading packages...")
install.packages.auto <- function(x) { 
  x <- as.character(substitute(x)) 
  if (isTRUE(x %in% .packages(all.available = TRUE))) { 
    eval(parse(text = sprintf("require(\"%s\")", x)))
  } else { 
    # Update installed packages - this may mean a full upgrade of R, which in turn
    # may not be warrented. 
    #update.packages(ask = FALSE) 
    eval(parse(text = sprintf("install.packages(\"%s\", 
                              dependencies = TRUE, 
                              repos = \"https://cloud.r-project.org/\")", x)))
  }
  if (isTRUE(x %in% .packages(all.available = TRUE))) { 
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
# In this case I'm keeping track of the various packages, as versions and 
# actual loading of the libraries gave issues before.
cat("\n* General packages...\n")
# for survival analyses
install.packages.auto("survival")
install.packages.auto("survminer")
# for general statistics
install.packages.auto("Hmisc")
install.packages.auto("openxlsx") # om heel snel Excel te laden.
install.packages.auto("dplyr") 
install.packages.auto("data.table") # dit is veel sneller dan dataframe
install.packages.auto("devtools")
install.packages.auto("tableone") # om baseline tables te maken
install.packages.auto("haven") # SPSS te laden
# install.packages.auto("tidyverse") 
# install.packages.auto("lubridate")

# Create datestamp
Today = format(as.Date(as.POSIXlt(Sys.time())), "%Y%m%d")

###	UtrechtSciencePark Colours Scheme
###
### Website to convert HEX to RGB: http://hex.colorrrs.com.
### For some functions you should divide these numbers by 255.
###
### No. Color             HEX     RGB                       CMYK                        CHR   MAF/INFO
### --------------------------------------------------------------------------------------------------------------------
### 01  yellow            #FBB820 (251,184,32)              (0,26.69,87.25,1.57)    =>  01    or 1.0 > INFO
### 02  gold              #F59D10 (245,157,16)              (0,35.92,93.47,3.92)    =>  02    
### 03  salmon            #E55738 (229,87,56)               (0,62.01,75.55,10.2)    =>  03    or 0.05 < MAF < 0.2 or 0.4 < INFO < 0.6
### 04  darkpink          #DB003F ((219,0,63)               (0,100,71.23,14.12)     =>  04    
### 05  lightpink         #E35493 (227,84,147)              (0,63,35.24,10.98)      =>  05    or 0.8 < INFO < 1.0
### 06  pink              #D5267B (213,38,123)              (0,82.16,42.25,16.47)   =>  06    
### 07  hardpink          #CC0071 (204,0,113)               (0,0,0,0)               =>  07    
### 08  lightpurple       #A8448A (168,68,138)              (0,0,0,0)               =>  08    
### 09  purple            #9A3480 (154,52,128)              (0,0,0,0)               =>  09    
### 10  lavendel          #8D5B9A (141,91,154)              (0,0,0,0)               =>  10    
### 11  bluepurple        #705296 (112,82,150)              (0,0,0,0)               =>  11    
### 12  purpleblue        #686AA9 (104,106,169)             (0,0,0,0)               =>  12    
### 13  lightpurpleblue   #6173AD (97,115,173/101,120,180)  (0,0,0,0)               =>  13    
### 14  seablue           #4C81BF (76,129,191)              (0,0,0,0)               =>  14    
### 15  skyblue           #2F8BC9 (47,139,201)              (0,0,0,0)               =>  15    
### 16  azurblue          #1290D9 (18,144,217)              (0,0,0,0)               =>  16    or 0.01 < MAF < 0.05 or 0.2 < INFO < 0.4
### 17  lightazurblue     #1396D8 (19,150,216)              (0,0,0,0)               =>  17    
### 18  greenblue         #15A6C1 (21,166,193)              (0,0,0,0)               =>  18    
### 19  seaweedgreen      #5EB17F (94,177,127)              (0,0,0,0)               =>  19    
### 20  yellowgreen       #86B833 (134,184,51)              (0,0,0,0)               =>  20    
### 21  lightmossgreen    #C5D220 (197,210,32)              (0,0,0,0)               =>  21    
### 22  mossgreen         #9FC228 (159,194,40)              (0,0,0,0)               =>  22    or MAF > 0.20 or 0.6 < INFO < 0.8
### 23  lightgreen        #78B113 (120,177,19)              (0,0,0,0)               =>  23/X
### 24  green             #49A01D (73,160,29)               (0,0,0,0)               =>  24/Y
### 25  grey              #595A5C (89,90,92)                (0,0,0,0)               =>  25/XY or MAF < 0.01 or 0.0 < INFO < 0.2
### 26  lightgrey         #A2A3A4	(162,163,164)             (0,0,0,0)               =>  26/MT
### 
### ADDITIONAL COLORS
### 27  midgrey           #D7D8D7
### 28  very lightgrey    #ECECEC
### 29  white             #FFFFFF
### 30  black             #000000

uithof_color = c("#FBB820","#F59D10","#E55738","#DB003F","#E35493","#D5267B",
                 "#CC0071","#A8448A","#9A3480","#8D5B9A","#705296","#686AA9",
                 "#6173AD","#4C81BF","#2F8BC9","#1290D9","#1396D8","#15A6C1",
                 "#5EB17F","#86B833","#C5D220","#9FC228","#78B113","#49A01D",
                 "#595A5C","#A2A3A4", "#D7D8D7", "#ECECEC", "#FFFFFF", "#000000")

uithof_color_legend = c("#FBB820", "#F59D10", "#E55738", "#DB003F", "#E35493",
                        "#D5267B", "#CC0071", "#A8448A", "#9A3480", "#8D5B9A",
                        "#705296", "#686AA9", "#6173AD", "#4C81BF", "#2F8BC9",
                        "#1290D9", "#1396D8", "#15A6C1", "#5EB17F", "#86B833",
                        "#C5D220", "#9FC228", "#78B113", "#49A01D", "#595A5C",
                        "#A2A3A4", "#D7D8D7", "#ECECEC", "#FFFFFF", "#000000")
cat("====================================================================================================")

cat("====================================================================================================")
cat("\nSETUP ANALYSIS")
# Assess where we are
getwd()
# Set locations
### Operating System Version

### Mac Pro
# ROOT_loc = "/Volumes/EliteProQx2Media"

### MacBook
ROOT_loc = "/Users/swvanderlaan"

### SOME VARIABLES WE NEED DOWN THE LINE
PROJECTDATASET = "PROJECTDATASET" # some project dataset name
PROJECTNAME = "PROJECTNAME" # some project name
SUBPROJECTNAME1 = "SUBPROJECTNAME1" # some sub-project name #2
SUBPROJECTNAME2 = "SUBPROJECTNAME2" # some sub-project name #2
MAIN_trait = "SmokerCurrent" # Phenotype

GENOMIC_loc = paste0(ROOT_loc, "/Library/Mobile Documents/com~apple~CloudDocs/Genomics/")
DATABASE_loc = paste0(GENOMIC_loc,"/AE-AAA_GS_DBs")

# My locations of genetic data
INP_PLINK_AE_loc = paste0(ROOT_loc, "/PLINK/_AE_Originals")

# My project directories
MAIN_loc = paste0(ROOT_loc, "/PLINK/analyses/baseline")

cat("\nCreate a new analysis directories.")
cat(paste0("\n* main directory based on ",PROJECTDATASET,"."))
ifelse(!dir.exists(file.path(MAIN_loc, "/",PROJECTDATASET)), 
       dir.create(file.path(MAIN_loc, "/",PROJECTDATASET)), 
       FALSE)
INP_loc = paste0(MAIN_loc, "/",PROJECTDATASET)

cat(paste0("\n* analysis directory based on ",PROJECTNAME,"."))
ifelse(!dir.exists(file.path(INP_loc, "/",PROJECTNAME)), 
       dir.create(file.path(INP_loc, "/",PROJECTNAME)), 
       FALSE)
ANALYSIS_loc = paste0(INP_loc,"/",PROJECTNAME)

cat("\n* sub-directory for plots.")
ifelse(!dir.exists(file.path(ANALYSIS_loc, "/PLOTS")), 
       dir.create(file.path(ANALYSIS_loc, "/PLOTS")), 
       FALSE)
PLOT_loc = paste0(ANALYSIS_loc,"/PLOTS")

cat("\n* sub-directory for Cox-regression plots.")
ifelse(!dir.exists(file.path(PLOT_loc, "/COX")), 
       dir.create(file.path(PLOT_loc, "/COX")), 
       FALSE)
COX_loc = paste0(PLOT_loc,"/COX")

cat("\n* sub-directory for QC-plots.")
ifelse(!dir.exists(file.path(PLOT_loc, "/QC")), 
       dir.create(file.path(PLOT_loc, "/QC")), 
       FALSE)
QC_loc = paste0(PLOT_loc,"/QC")

cat("\n* sub-directory for general output.")
ifelse(!dir.exists(file.path(ANALYSIS_loc, "/OUTPUT")), 
       dir.create(file.path(ANALYSIS_loc, "/OUTPUT")), 
       FALSE)
OUT_loc = paste0(ANALYSIS_loc, "/OUTPUT")

cat("====================================================================================================")
cat("LOAD DATASETS")
setwd(INP_loc)
list.files()

cat("* get Athero-Express Biobank Study Database...")
# METHOD 1: It seems this method gives loads of errors and warnings, which all are hard to comprehend
#           or debug. We expect 3,527 samples, and 927 variables; we get 927 variables!!!
# library(foreign)
# AEdata = as.data.table(?read.spss(file.choose(),
#                        trim.factor.names = TRUE, trim_values = TRUE, # we trim spaces in values
#                        reencode = TRUE, # we re-encode to the local locale encoding
#                        add.undeclared.levels = "append", # we do *not* want to convert to R-factors
#                        use.value.labels = FALSE, # we do *not* convert variables with value labels into R factors
#                        use.missings = TRUE, sub = "NA", # we will set every missing variable to NA
#                        duplicated.value.labels = "condense", # we will condense duplicated value labels
#                        to.data.frame = TRUE))
# AEdata.labels <- as.data.table(attr(AEdata, "variable.labels"))
# names(AEdata.labels) <- "Variable"

# METHOD 2: Using library("haven") importing seems flawless; best argument being:
#           we expect 3,527 samples and 888 variables, which is what you'd get with this method
#           So for now, METHOD 2 is prefered. 

AEdata = read_spss(file.choose())

# writing off the SPSS data to an Excel.
# fwrite(AEdata, file = paste0(INP_loc,"/2017-1NEW_AtheroExpressDatabase_ScientificAE_20171306_v1.0.values.xlsx"), 
#        sep = ";", na = "NA", dec = ".", col.names = TRUE, row.names = FALSE,
#        dateTimeAs = "ISO", showProgress = TRUE, verbose = TRUE)
# warnings()
# rownames(AEdata) <- AEdata$STUDY_NUMBER
AEdata[1:10, 1:10]
dim(AEdata)

cat("====================================================================================================")
cat("SELECTION THE SHIZZLE")

### Artery levels
# AEdata$Artery_summary: 
#           value                                                                                   label
# NOT USE - 0 No artery known (yet), no surgery (patient ill, died, exited study), re-numbered to AAA
# USE - 1                                                                  carotid (left & right)
# USE - 2                                               femoral/iliac (left, right or both sides)
# NOT USE - 3                                               other carotid arteries (common, external)
# NOT USE - 4                                   carotid bypass and injury (left, right or both sides)
# NOT USE - 5                                                         aneurysmata (carotid & femoral)
# NOT USE - 6                                                                                   aorta
# NOT USE - 7                                            other arteries (renal, popliteal, vertebral)
# NOT USE - 8                        femoral bypass, angioseal and injury (left, right or both sides)

### AEdata$informedconsent
#           value                                                                                           label
# NOT USE - -999                                                                                         missing
# NOT USE - 0                                                                                        no, died
# USE - 1                                                                                             yes
# USE - 2                                                             yes, health treatment when possible
# USE - 3                                                                        yes, no health treatment
# USE - 4                                                yes, no health treatment, no commercial business
# NOT USE - 5                                                          yes, no tissue, no commerical business
# NOT USE - 6                      yes, no tissue, no questionnaires, no medical info, no commercial business
# USE - 7                             yes, no questionnaires, no health treatment, no commercial business
# USE - 8                                          yes, no questionnaires, health treatment when possible
# NOT USE - 9                  yes, no tissue, no questionnaires, no health treatment, no commerical business
# USE - 10                               yes, no health treatment, no medical info, no commercial business
# NOT USE - 11 yes, no tissue, no questionnaires, no health treatment, no medical info, no commercial business
# USE - 12                                                     yes, no questionnaires, no health treatment
# NOT USE - 13                                                             yes, no tissue, no health treatment
# NOT USE - 14                                                               yes, no tissue, no questionnaires
# NOT USE - 15                                                  yes, no tissue, health treatment when possible
# NOT USE - 16                                                                                  yes, no tissue
# USE - 17                                                                     yes, no commerical business
# USE - 18                                     yes, health treatment when possible, no commercial business
# USE - 19                                                    yes, no medical info, no commercial business
# USE - 20                                                                          yes, no questionnaires
# NOT USE - 21                         yes, no tissue, no questionnaires, no health treatment, no medical info
# NOT USE - 22                  yes, no tissue, no questionnaires, no health treatment, no commercial business
# USE - 23                                                                            yes, no medical info
# USE - 24                                                  yes, no questionnaires, no commercial business
# USE - 25                                    yes, no questionnaires, no health treatment, no medical info
# USE - 26                  yes, no questionnaires, health treatment when possible, no commercial business
# USE - 27                                                      yes,  no health treatment, no medical info
# NOT USE - 28                                                                             no, doesn't want to
# NOT USE - 29                                                                              no, unable to sign
# NOT USE - 30                                                                                 no, no reaction
# NOT USE - 31                                                                                        no, lost
# NOT USE - 32                                                                                     no, too old
# NOT USE - 34                                            yes, no medical info, health treatment when possible
# NOT USE - 35                                             no (never asked for IC because there was no tissue)
# USE - 36                    yes, no medical info, no commercial business, health treatment when possible
# NOT USE - 37                                                                                    no, endpoint
# USE - 38                                                         wil niets invullen, wel alles gebruiken
# USE - 39                                           second informed concents: yes, no commercial business
# NOT USE - 40                                                                              nooit geincludeerd

cat("- sanity checking PRIOR to selection")
library(data.table)
ae.gender <- ifelse(AEdata$Gender == 0, "Female", "Male")
ae.hospital <- ifelse(AEdata$Hospital == 1, "Antonius", "UMCU")
table(ae.gender, ae.hospital, dnn = c("Sex", "Hospital"))
rm(ae.gender, ae.hospital)

# I change numeric and factors manually because, well, I wouldn't know how to fix it otherwise
# to have this 'tibble' work with 'tableone'... :-)
AEdata$diastoli <- as.numeric(AEdata$diastoli)
AEdata$systolic <- as.numeric(AEdata$systolic)
AEdata$Age <- as.numeric(AEdata$Age)
AEdata$GFR_MDRD <- as.numeric(AEdata$GFR_MDRD)
AEdata$BMI <- as.numeric(AEdata$BMI)
AEdata$eCigarettes <- as.numeric(AEdata$eCigarettes)
AEdata$ePackYearsSmoking <- as.numeric(AEdata$ePackYearsSmoking)

# to_factor(AEdata$Gender)
# to_factor(AEdata$Hospital)
# to_factor(AEdata$KDOQI)
# to_factor(AEdata$BMI_WHO)
# to_factor(AEdata$DM.composite)
# to_factor(AEdata$Hypertension.composite)
# to_factor(AEdata$Hypertension.drugs)
# to_factor(AEdata$Med.anticoagulants)
# to_factor(AEdata$Med.all.antiplatelet)
# to_factor(AEdata$Med.Statin.LLD)
# to_factor(AEdata$Stroke_Dx)
# to_factor(AEdata$Symptoms.4g)
# to_factor(AEdata$restenos)

AEdata.CEA <- subset(AEdata, 
                     Artery_summary == 1 & # we only want carotids
                       informedconsent != 40 & informedconsent != 37 & informedconsent != 35 & # we are really strict in selecting based on 'informed consent'!
                       informedconsent != 34 & informedconsent != 32 & informedconsent != 31 &
                       informedconsent != 30 & informedconsent != 29 & informedconsent != 28 &
                       informedconsent != 22 & informedconsent != 21 & informedconsent != 16 &
                       informedconsent != 15 & informedconsent != 14 & informedconsent != 13 &
                       informedconsent != 11 & informedconsent != 9 & informedconsent != 6 &
                       informedconsent != 5 & informedconsent != 0 & informedconsent != -999)
AEdata.CEA[1:10, 1:10]
dim(AEdata.CEA)

AEdata.CEAplusFEA <- subset(AEdata,
                            (Artery_summary == 1 | Artery_summary == 2 ) & # we only want carotids
                              informedconsent != 40 & informedconsent != 37 & informedconsent != 35 & # we are really strict in selecting based on 'informed consent'!
                              informedconsent != 34 & informedconsent != 32 & informedconsent != 31 &
                              informedconsent != 30 & informedconsent != 29 & informedconsent != 28 &
                              informedconsent != 22 & informedconsent != 21 & informedconsent != 16 &
                              informedconsent != 15 & informedconsent != 14 & informedconsent != 13 &
                              informedconsent != 11 & informedconsent != 9 & informedconsent != 6 &
                              informedconsent != 5 & informedconsent != 0 & informedconsent != -999)
AEdata.CEAplusFEA[1:10, 1:10]
dim(AEdata.CEAplusFEA)

cat("===========================================================================================")
cat("CREATE BASELINE TABLE")

# Baseline table variables
basetable_vars = c("Age", "Gender", 
                   "TC_final", "LDL_final", "HDL_final", "TG_final", 
                   "systolic", "diastoli", "GFR_MDRD", "BMI", 
                   "KDOQI", "BMI_WHO",
                   "eCigarettes", "ePackYearsSmoking",
                   "DM.composite", "Hypertension.composite", 
                   "Hypertension.drugs", "Med.anticoagulants", "Med.all.antiplatelet", "Med.Statin.LLD", 
                   "Stroke_Dx", "Symptoms.4g", "restenos")
basetable_bin = c("Gender", 
                  "KDOQI", "BMI_WHO",
                  "DM.composite", "DM.composite", 
                  "Hypertension.drugs", "Med.anticoagulants", "Med.all.antiplatelet", "Med.all.antiplatelet", 
                  "Stroke_Dx", "Symptoms.4g", "restenos")
basetable_con = basetable_vars[!basetable_vars %in% basetable_bin]

# Create baseline tables
# http://rstudio-pubs-static.s3.amazonaws.com/13321_da314633db924dc78986a850813a50d5.html
AEdata.CEAplusFEA.tableOne = print(CreateTableOne(vars = basetable_con, 
                                                  factorVars = basetable_bin,
                                                  strata = MAIN_trait, 
                                                  data = AEdata.CEAplusFEA), 
                                   nonnormal = c(), quote = FALSE, showAllLevels = TRUE,
                                   format = "p", contDigits = 3)[,1:3]


# Write basetable
write.xlsx(file = paste0(OUT_loc, "/",Today,".AE.BaselineTable.",MAIN_trait,".xlsx"), 
           format(AEdata.tableOne, digits = 5, scientific = FALSE) , row.names = TRUE, col.names = TRUE)

# Check for NA, add manually to table
CLIN = colData(aems450k1.MvaluesQCplaqueClean)[, as.integer(labels(colnames(colData(aems450k1.MvaluesQCplaqueClean))))]
CLIN = CLIN[!is.na(CLIN$SmokerCurrent),]
for (x in basetable_vars){
  print(paste(x, "smoker", table(is.na(CLIN[CLIN$SmokerCurrent == "yes", x]))["FALSE"]))
  print(paste(x, "non-smoker", table(is.na(CLIN[CLIN$SmokerCurrent == "no", x]))["FALSE"]))
}
table(CLIN[CLIN$SmokerCurrent == "yes", "Symptoms.4g"], useNA = "always")
table(CLIN[CLIN$SmokerCurrent == "no", "Symptoms.4g"], useNA = "always")

CLIN = colData(aems450k2.MvaluesQCplaqueClean)[, as.integer(labels(colnames(colData(aems450k2.MvaluesQCplaqueClean))))]
CLIN = CLIN[!is.na(CLIN$SmokerCurrent),]
for (x in basetable_vars){
  print(paste(x, "smoker", table(is.na(CLIN[CLIN$SmokerCurrent == "yes", x]))["FALSE"]))
  print(paste(x, "non-smoker", table(is.na(CLIN[CLIN$SmokerCurrent == "no", x]))["FALSE"]))
}
table(CLIN[CLIN$SmokerCurrent == "yes", "Symptoms.4g"], useNA = "always")
table(CLIN[CLIN$SmokerCurrent == "no", "Symptoms.4g"], useNA = "always")

CLIN = colData(aems450k1.MvaluesQCbloodClean)[, as.integer(labels(colnames(colData(aems450k1.MvaluesQCbloodClean))))]
CLIN = CLIN[!is.na(CLIN$SmokerCurrent),]
for (x in basetable_vars){
  print(paste(x, "smoker", table(is.na(CLIN[CLIN$SmokerCurrent == "yes", x]))["FALSE"]))
  print(paste(x, "non-smoker", table(is.na(CLIN[CLIN$SmokerCurrent == "no", x]))["FALSE"]))
}
table(CLIN[CLIN$SmokerCurrent == "yes", "Symptoms.4g"], useNA = "always")
table(CLIN[CLIN$SmokerCurrent == "no", "Symptoms.4g"], useNA = "always")



cat("* Plotting qq-plots for all data...")
pdf(paste0(PLOT_loc,"/",Today,".aems450k.meta.smoking.Transformation.QQ.pdf"), 
    paper = "a4r", onefile = TRUE)
par(mfrow = c(3,5), mar = c(3,3,3,1))
for(x in 3:5){
  qqnorm(AEData_2016.data.raw[,x], main = paste0("Raw ",colnames(AEData_2016.data.raw)[x]), 
         cex.main = 0.60)
  qqline(AEData_2016.data.raw[,x], col = "#595A5C")
  qqnorm(AEData_2016.data.rm[,x], main = paste0("Raw ",colnames(AEData_2016.data.rm)[x],"\noutliers removed"), 
         cex.main = 0.60)
  qqline(AEData_2016.data.rm[,x], col = "#F59D10")
  qqnorm(AEData_2016.data.log[,x], main = paste0("LN-transformed ",colnames(AEData_2016.data.log)[x]), 
         cex.main = 0.60)
  qqline(AEData_2016.data.log[,x], col = "#2F8BC9")
  qqnorm(AEData_2016.data.log2[,x], main = paste0("Log2-transformed ",colnames(AEData_2016.data.log2)[x]), 
         cex.main = 0.60)
  qqline(AEData_2016.data.log2[,x], col = "#E55738")
  qqnorm(AEData_2016.data.BC[,x], main = paste0("BC-transformed ",colnames(AEData_2016.data.BC)[x]), 
         cex.main = 0.60)
  qqline(AEData_2016.data.BC[,x], col = "#9FC228")
}
dev.off()

cat("* Plotting histograms for all data...")

# Een forloop die een PDF maakt met allemaal histogrammen
pdf(paste0(PLOT_loc,"/",Today,".aems450k.meta.smoking.Transformation.Histogram.pdf"), 
    paper = "a4r", onefile = TRUE)
par(mfrow=c(3,5), mar=c(3,3,3,1)) # 3 bij 5 kolommen en rijen.
for(x in 3:5){
  hist(AEData_2016.data.raw[,x], main = paste0("Raw ", colnames(AEData_2016.data.raw)[x]), 
       col = "#595A5C", cex.main = 0.60)
  mtext(table(is.na(AEData_2016.data.raw[,x]))["FALSE"], cex=0.60)
  mtext(round(table(AEData_2016.data.raw[,x] == 0)["TRUE"]/table(is.na(AEData_2016.data.raw[,x]))["FALSE"]*100,2), cex=0.60, side=4, line=-1)
  
  hist(AEData_2016.data.rm[,x], main = paste0("Raw ", colnames(AEData_2016.data.rm)[x], "\noutliers removed"), 
       col = "#F59D10", cex.main = 0.60)
  mtext(table(is.na(AEData_2016.data.rm[,x]))["FALSE"], cex=0.60)
  mtext(round(table(AEData_2016.data.rm[,x] == 0)["TRUE"]/table(is.na(AEData_2016.data.rm[,x]))["FALSE"]*100,2), cex=0.60, side=4, line=-1)
  
  hist(AEData_2016.data.log[,x], main = paste0("LN-transformed ", colnames(AEData_2016.data.log)[x]), 
       col = "#2F8BC9", cex.main = 0.60)
  mtext(table(is.na(AEData_2016.data.log[,x]))["FALSE"], cex=0.60)
  mtext(round(table(AEData_2016.data.log[,x] == 0)["TRUE"]/table(is.na(AEData_2016.data.log[,x]))["FALSE"]*100,2), cex=0.60, side=4, line=-1)
  
  hist(AEData_2016.data.log2[,x], main = paste0("Log2-transformed ", colnames(AEData_2016.data.log2)[x]), 
       col = "#E55738", cex.main = 0.60)
  mtext(table(is.na(AEData_2016.data.log2[,x]))["FALSE"], cex=0.60)
  mtext(round(table(AEData_2016.data.log2[,x] == 0)["TRUE"]/table(is.na(AEData_2016.data.log2[,x]))["FALSE"]*100,2), cex=0.60, side=4, line=-1)
  
  hist(AEData_2016.data.BC[,x], main = paste0("BC-transformed ", colnames(AEData_2016.data.BC)[x]), 
       col = "#9FC228", cex.main = 0.60)
  mtext(table(is.na(AEData_2016.data.BC[,x]))["FALSE"], cex=0.60)
  mtext(round(table(AEData_2016.data.BC[,x] == 0)["TRUE"]/table(is.na(AEData_2016.data.BC[,x]))["FALSE"]*100,2), cex=0.60, side=4, line=-1)
}
dev.off()

cat("* Parsing new data...") # print op je scherm wat ie doet


names(AEData_2016.data.log)[names(AEData_2016.data.log) == "macmean0"] <- "MacrophagesPercLN"