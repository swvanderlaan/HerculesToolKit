cat("====================================================================================================
*                                      BASIC R SCRIPT TO DO STUFF
*
* Version:      version 1.2
*
* Last update: 2019-03-19
* Written by: Sander W. van der Laan (s.w.vanderlaan-2@umcutrecht.nl)
*                                                    
* Description: Script to be used as a basis for scripts.
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
install.packages.auto("Hmisc") # for some general statistics
install.packages.auto("foreign") # to read SPSS files

# Create datestamp
Today = format(as.Date(as.POSIXlt(Sys.time())), "%Y%m%d")

###	UtrechtSciencePark Colours Scheme
###
### Website to convert HEX to RGB: http://hex.colorrrs.com.
### For some functions you should divide these numbers by 255.
###
###	No.	Color				HEX		RGB							CMYK					CHR		MAF/INFO
### --------------------------------------------------------------------------------------------------------------------
###	1	yellow				#FBB820 (251,184,32)				(0,26.69,87.25,1.57) 	=>	1 		or 1.0 > INFO
###	2	gold				#F59D10 (245,157,16)				(0,35.92,93.47,3.92) 	=>	2		
###	3	salmon				#E55738 (229,87,56) 				(0,62.01,75.55,10.2) 	=>	3 		or 0.05 < MAF < 0.2 or 0.4 < INFO < 0.6
###	4	darkpink			#DB003F ((219,0,63)					(0,100,71.23,14.12) 	=>	4		
###	5	lightpink			#E35493 (227,84,147)				(0,63,35.24,10.98) 	=>	5 		or 0.8 < INFO < 1.0
###	6	pink				#D5267B (213,38,123)				(0,82.16,42.25,16.47) 	=>	6		
###	7	hardpink			#CC0071 (204,0,113)					(0,0,0,0) 	=>	7		
###	8	lightpurple			#A8448A (168,68,138)				(0,0,0,0) 	=>	8		
###	9	purple				#9A3480 (154,52,128)				(0,0,0,0) 	=>	9		
###	10	lavendel			#8D5B9A (141,91,154)				(0,0,0,0) 	=>	10		
###	11	bluepurple			#705296 (112,82,150)				(0,0,0,0) 	=>	11		
###	12	purpleblue			#686AA9 (104,106,169)				(0,0,0,0) 	=>	12		
###	13	lightpurpleblue		#6173AD (97,115,173/101,120,180)	(0,0,0,0) 	=>	13		
###	14	seablue				#4C81BF (76,129,191)				(0,0,0,0) 	=>	14		
###	15	skyblue				#2F8BC9 (47,139,201)				(0,0,0,0) 	=>	15		
###	16	azurblue			#1290D9 (18,144,217)				(0,0,0,0) 	=>	16		 or 0.01 < MAF < 0.05 or 0.2 < INFO < 0.4
###	17	lightazurblue		#1396D8 (19,150,216)				(0,0,0,0) 	=>	17		
###	18	greenblue			#15A6C1 (21,166,193)				(0,0,0,0) 	=>	18		
###	19	seaweedgreen		#5EB17F (94,177,127)				(0,0,0,0) 	=>	19		
###	20	yellowgreen			#86B833 (134,184,51)				(0,0,0,0) 	=>	20		
###	21	lightmossgreen		#C5D220 (197,210,32)				(0,0,0,0) 	=>	21		
###	22	mossgreen			#9FC228 (159,194,40)				(0,0,0,0) 	=>	22		or MAF > 0.20 or 0.6 < INFO < 0.8
###	23	lightgreen			#78B113 (120,177,19)				(0,0,0,0) 	=>	23/X
###	24	green				#49A01D (73,160,29)					(0,0,0,0) 	=>	24/Y
###	25	grey				#595A5C (89,90,92)					(0,0,0,0) 	=>	25/XY	or MAF < 0.01 or 0.0 < INFO < 0.2
###	26	lightgrey			#A2A3A4	(162,163,164)				(0,0,0,0) 	=> 	26/MT
### 
### ADDITIONAL COLORS
### 27	midgrey				#D7D8D7
### 28	very lightgrey		#ECECEC
### 29	white				#FFFFFF
### 30	black				#000000
### --------------------------------------------------------------------------------------------------------------------

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
cat("SETUP ANALYSIS")
# Assess where we are
getwd()
# Set locations
INP_loc = "/Users/svanderlaan/Library/Mobile Documents/com~apple~CloudDocs/Genomics/AE-AAA_GS_DBs"
OUT_loc = "/Users/swvanderlaan/r"

cat("====================================================================================================")
cat("LOAD DATASET")
setwd(INP_loc)
list.files()
dataCST3 = read.table("/Users/swvanderlaan/PLINK/analyses/cystatinc/forest/snp_cystc.txt", 
                      header = TRUE, na.strings = c("NA", "missing"), sep="\t")

### -----------------------------------------------------------------------------------
cat("SNP VS. CYSTATIN C LEVELS")
#postscript(paste(Today,"_BASIC_PLOT_FROM_R.ps"), width=10, height=8, onefile=TRUE)
# decrease margins so the full space is used
options(na.action = "na.pass")
par(mar=c(4,4,1,2))
# fit random-effects model (use slab argument to define study labels)
resCST3 <- rma(yi = dataCST3$beta, sei = dataCST3$se, method = "FE", slab = dataCST3$study)
# set up forest plot (with 2x2 table counts added; rows argument is used
# to specify exactly in which rows the outcomes will be plotted)
forest(resCST3, annotate = TRUE,  addfit = TRUE, addcred = TRUE, showweights = FALSE, 
       alim = c(-0.16,0.05),
       xlab="per minor allele", 
       mlab = "Overall (I2 = 45.6%, p = 0.056)",
       ilab = cbind(format(dataCST3$N, big.mark = ",") ), 
       ilab.xpos = c(-0.20),  
       pch = 19,
       psize = 1,
       cex = 1.25,
       font = 1
)

# set font expansion factor (as in forest() above) and use bold italic
# font and save original settings in object 'op'
op <- par(cex = 1, font = 1)
# add column headings to the plot
par(font = 2)
text(c(-0.25, -0.20, 0), 11, 
     c("Studies", "N", "Beta [95% C.I.]"), 
     cex = 1, pos = 4)
# set par back to the original settings
par(op)
#dev.off()

cat("====================================================================================================")
cat("SAVE THE DATA")
save.image(paste0(INP_loc,"/",Today,"_BASIC_DATA_FROM_R.RData"))



