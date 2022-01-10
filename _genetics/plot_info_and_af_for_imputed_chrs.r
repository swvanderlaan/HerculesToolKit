#!/bin/env Rscript --no-save

# Genotype imputation protocol v3 - post-imputation QA plots
# Written by Kalle Pärn, Marita A. Isokallio, Paavo Häppölä, Javier Nunez Fontarnau and Priit Palta

# Required packages
library(data.table) # for fast fread()
library(sm)  # for density plotting

# Input variables
args <- commandArgs(TRUE)
indataset <- args[1]
paneldata <- args[2]

# Reference panel frequency file
panel <- fread(paneldata, header = T)

# Generate plots and save as a png file per chromosome
for (chr in 1:23) {
         print(paste("Working on chr ", chr, " now..."))

         # Creates the filename as <dataset>_chr#_postimputation_summary_plots.png
         png(filename = paste(indataset, "_chr", chr, "_postimputation_summary_plots.png", sep = ""), width = 1200, height = 1200, unit = "px")

         # Set the plots as two rows and columns
         par(mfrow = c(2,2))
         par(cex.axis = 1.6, cex.lab = 1.5, cex.main = 1.6)

         # Read in data for a file <dataset>_chr#_varID_AF_INFO_GROUP.txt
         imp_vars <- fread(paste(indataset, "_chr", chr, "_varID_AF_INFO_GROUP.txt", sep = ""), header = TRUE)

         # Create random sample for INFO score plot instead of plotting all values
         rand1 <- sample(1:dim(imp_vars)[1], 100000, replace = FALSE)
         temp1 <- imp_vars[rand1,]

         # Merge by common variants, SNP column in format CHR_POS_REF_ALT 
         isec <- merge(panel, imp_vars, by="SNP")

         # Plot INFO score distributions
         sm.density.compare(temp1$INFO, temp1$AF_GROUP, xlab = "Impute2-like INFO score", ylab = "Density", col = col, lty = rep(1,3), lwd = 3, xlim = c(0,1), cex = 1.4, h = 0.05)
         title(paste("Imputation of chr", chr, " variants", sep = ""))
         legend("topleft", legend = c("MAF > 5%", "MAF 0.5-5%", "MAF < 0.5%"), lty = c(1, 1, 1), lwd = c(2.5, 2.5, 2.5), col = c("red", "green3", "blue"))

         # Plot AF of panel vs. imputed variants
         plot(isec$AF.x, isec$AF.y, col = 1, pch = 20, main = "Imputed AF vs. reference panel AF", xlab = "Reference panel AF", ylab = "Imputed AF", xlim = c(0,1), ylim = c(0,1))

         # Imputed data AF histogram for intersecting variants
         hist(isec$AF.y, breaks = 200, main = "AF distribution of imputed variants", xlab = "Imputed AF")

         # Plot absolute AF difference as imputed AF - panel AF
         isec$POS <- as.numeric(as.character(data.frame(do.call('rbind', strsplit(as.character(isec$SNP),'_',fixed=TRUE)))[,2]))
         # Order the variants by position
         sisec <- isec[order(isec$POS),]
         plot(sisec$POS, sisec$AF.y - sisec$AF.x, main = "Absolute AF differences along the chromosome", col = rgb(0,100,0,50, maxColorValue=255), ylim = c(-0.1, 0.1), pch = 16, xlab = "Chromosome position", ylab = "AF difference (imputed - panel)")

         # Close the png
         dev.off()
}
