#!/bin/env Rscript --no-save

# Genotype imputation protocol v3 - pre-imputation allele frequency plots
# Written by Kalle Pärn, Marita A. Isokallio, Paavo Häppölä, Javier Nunez Fontarnau and Priit Palta

# Required packages
library(data.table) # For fast fread()

# Input variables
args <- commandArgs(TRUE)
indata <- args[1]
paneldata <- args[2] 

# Read in the frequency files
chip <- fread(indata, header = T)
panel <- fread(paneldata, header = T)

# Generate a dataset tag
indataset <- sub("_chip.frq", "", indata)

# Take an intersection of the panel and chip data based on SNP column (in format CHR_POS_REF_ALT)
isec <- merge(panel, chip, by = "SNP")

# Check that AFs is within range of 10 pp in both datasets
af_ok <- abs(isec$AF.x - isec$AF.y) < 0.1

# Exclude those not within the AF range
exclude <- !af_ok

# Save the plot as jpg
jpeg(paste(indataset, "_AFs.jpg", sep=""))
# Plot first all and then excludable variants
plot(isec$AF.x, isec$AF.y, col=1, pch=20, main="Chip data AF vs. reference panel AF", xlab="Panel AF", ylab="Chip AF")
points(isec[exclude]$AF.x, isec[exclude]$AF.y, col=2, pch=20)
# Draw a legend
legend("topleft", legend=c("Concordant AF", "High AF difference"), col=c(1,2), pch=20, cex=0.9)
dev.off()

# Save the plot as jpg
jpeg(paste(indataset, "_AF_hist.jpg", sep = ""))
# Chip AF histogram for concordant AF variants
hist(isec[!exclude]$AF.y, breaks=100, main="Chip AF for concordant variants", xlab="Chip AF")
dev.off()

# Write out the exclusion list
write.table(isec[exclude]$SNP, paste(indataset, "_exclude.txt", sep=""), quote=F, row.names=F, col.names=F)
