#Statistics plots
#Loading data tables...
setwd("~/PLINK/analyses/originals/AE_AEGS2_AffyAxiomGWCEU1/QC")
het <- read.table("aegs2_axiomgt1_b36_hm2r22atcgqcldprunedbhm2het.het", header = T)
imiss <- read.table("aegs2_axiomgt1_updatemap_MISSING.imiss", header = T)
lmiss <- read.table("aegs2_axiomgt1_updatemap_MISSING.lmiss", header = T)
ibd <- read.table("aegs2_axiomgt1_b36_hm2r22atcgqcldprunedbhm2_genome.genome", header = T)


#Identity-by-state#
pdf(file="aegs2_axiomgt1_b36_hm2r22atcgqcldprunedbhm2_genome.IBD.pdf")
hist(ibd$PI_HAT, breaks=50, main="Identity-by-state", xlab="PI-hat", ylab="# Individuals", ylim=c(0,500000), col="steelblue", cex.axis="0.8")
#abline(v=mean(het$F)-3*sd(het$F), lty=2, col="red")
#abline(v=mean(het$F)+3*sd(het$F), lty=2, col="red")
abline(v=0.2, col="red", lty=1)
dev.off()
postscript(file="aegs2_axiomgt1_b36_hm2r22atcgqcldprunedbhm2_genome.IBD.eps",width=10, height=10,paper="special",horizontal=FALSE)
hist(ibd$PI_HAT, breaks=50, main="Identity-by-state", xlab="PI-hat", ylab="# Individuals", ylim=c(0,500000), col="steelblue", cex.axis="0.8")
#abline(v=mean(het$F)-3*sd(het$F), lty=2, col="red")
#abline(v=mean(het$F)+3*sd(het$F), lty=2, col="red")
abline(v=0.2, col="red", lty=1)
dev.off()
#Identity-by-state#
pdf(file="aegs2_axiomgt1_b36_hm2r22atcgqcldprunedbhm2_genome.IBD_ADAPTED.pdf")
hist(ibd$PI_HAT, breaks=40, main="Identity-by-state", xlab="PI-hat", ylab="# Individuals", ylim=c(0,500), col="steelblue", cex.axis="0.8")
#abline(v=mean(het$F)-3*sd(het$F), lty=2, col="red")
#abline(v=mean(het$F)+3*sd(het$F), lty=2, col="red")
abline(v=0.2, col="red", lty=1)
dev.off()
postscript(file="aegs2_axiomgt1_b36_hm2r22atcgqcldprunedbhm2_genome.IBD_ADAPTED.eps",width=10, height=10,paper="special",horizontal=FALSE)
hist(ibd$PI_HAT, breaks=40, main="Identity-by-state", xlab="PI-hat", ylab="# Individuals", ylim=c(0,500), col="steelblue", cex.axis="0.8")
#abline(v=mean(het$F)-3*sd(het$F), lty=2, col="red")
#abline(v=mean(het$F)+3*sd(het$F), lty=2, col="red")
abline(v=0.2, col="red", lty=1)
dev.off()

#Inbreeding coefficient#
pdf(file="aegs2_axiomgt1_b36_hm2r22atcgqcldprunedbhm2het.HET.pdf")
hist(het$F, breaks=40, main="Inbreeding coefficient", xlab="F-statistic", ylab="# Individuals", ylim=c(0,250), col="steelblue", cex.axis="0.8")
abline(v=mean(het$F)-3*sd(het$F), lty=2, col="red")
abline(v=mean(het$F)+3*sd(het$F), lty=2, col="red")
abline(v=mean(het$F), col="red", lty=1)
dev.off()
postscript(file="aegs2_axiomgt1_b36_hm2r22atcgqcldprunedbhm2het.HET.eps",width=10, height=10,paper="special",horizontal=FALSE)
hist(het$F, breaks=40, main="Inbreeding coefficient", xlab="F-statistic", ylab="# Individuals", ylim=c(0,250), col="steelblue", cex.axis="0.8")
abline(v=mean(het$F)-3*sd(het$F), lty=2, col="red")
abline(v=mean(het$F)+3*sd(het$F), lty=2, col="red")
abline(v=mean(het$F), col="red", lty=1)
dev.off()

#Plotting per sample missingness per heterozygosity#
pdf(file="aegs2_axiomgt1_b36_hm2r22atcgqcldprunedbhm2het.imiss_vs_het.pdf")
imiss$logF_MISS = log10(imiss[,6])
het$meanHet = (het$N.NM. - het$O.HOM.)/het$N.NM.
library("geneplotter")
colors  <- densCols(imiss$logF_MISS,het$meanHet)
plot(imiss$logF_MISS,het$meanHet, col=colors, xlim=c(-3,0),ylim=c(0,0.5),pch=16, main="Proportion missing genotypes vs. heterozygosity rate", xlab="Proportion of missing genotypes", ylab="Heterozygosity rate",axes=F)
axis(2,at=c(0,0.05,0.10,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5),tick=T)
axis(1,at=c(-3,-2,-1,0),labels=c(0,0.001,0.01,0.1))
abline(h=mean(het$meanHet)-3*sd(het$meanHet), lty=2, col="red")
abline(h=mean(het$meanHet)+3*sd(het$meanHet), lty=2, col="red")
#vertical cutoff line for call rate at 3%
abline(v=-1.5228787452803375627049720967449, col="darkgreen", lty=2)
dev.off()
postscript(file="aegs2_axiomgt1_b36_hm2r22atcgqcldprunedbhm2het.imiss_vs_het.eps",width=10, height=10,paper="special",horizontal=FALSE)
imiss$logF_MISS = log10(imiss[,6])
het$meanHet = (het$N.NM. - het$O.HOM.)/het$N.NM.
library("geneplotter")
colors  <- densCols(imiss$logF_MISS,het$meanHet)
plot(imiss$logF_MISS,het$meanHet, col=colors, xlim=c(-3,0),ylim=c(0,0.5),pch=16, main="Proportion missing genotypes vs. heterozygosity rate", xlab="Proportion of missing genotypes", ylab="Heterozygosity rate",axes=F)
axis(2,at=c(0,0.05,0.10,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5),tick=T)
axis(1,at=c(-3,-2,-1,0),labels=c(0,0.001,0.01,0.1))
abline(h=mean(het$meanHet)-3*sd(het$meanHet), lty=2, col="red")
abline(h=mean(het$meanHet)+3*sd(het$meanHet), lty=2, col="red")
#vertical cutoff line for call rate at 3%
abline(v=-1.5228787452803375627049720967449, col="darkgreen", lty=2)
dev.off()

#Plotting per sample missingness per inbreeding coefficient
pdf(file="aegs2_axiomgt1_b36_hm2r22atcgqcldprunedbhm2het.imiss_vs_hetADAPTED.pdf")
library("geneplotter")
colors  <- densCols(imiss$F_MISS,het$F)
plot(imiss$F_MISS,het$F, col=colors, xlim=c(0,0.10),ylim=c(-0.50,0.50), pch=16, main="Proportion missing genotypes vs. inbreeding coefficient", xlab="Proportion missing genotypes", ylab="Inbreeding coefficient (F)", axes=F)
axis(2,at=c(-0.50,-0.40,-0.30,-0.20,-0.10,0,0.10,0.20,0.30,0.40,0.50),labels=c(-0.50,-0.40,-0.30,-0.20,-0.10,0,0.10,0.20,0.30,0.40,0.50),tick=T)
axis(1,at=c(0,0.025,0.05,0.075,0.10),labels=c(0,0.025,0.050,0.075,0.100))
abline(h=mean(het$F)-3*sd(het$F), lty=2, col="red")
abline(h=mean(het$F)+3*sd(het$F), lty=2, col="red")
#vertical cutoff line for call rate at 3%
abline(v=0.03, col="darkgreen", lty=2)
dev.off()
postscript(file="aegs2_axiomgt1_b36_hm2r22atcgqcldprunedbhm2het.imiss_vs_hetADAPTED.eps",width=10, height=10,paper="special",horizontal=FALSE)
library("geneplotter")
colors  <- densCols(imiss$F_MISS,het$F)
plot(imiss$F_MISS,het$F, col=colors, xlim=c(0,0.10),ylim=c(-0.5,0.5), pch=16, main="Proportion missing genotypes vs. inbreeding coefficient", xlab="Proportion missing genotypes", ylab="Inbreeding coefficient (F)", axes=F)
axis(2,at=c(-0.50,-0.40,-0.30,-0.20,-0.10,0,0.10,0.20,0.30,0.40,0.50),labels=c(-0.50,-0.40,-0.30,-0.20,-0.10,0,0.10,0.20,0.30,0.40,0.50),tick=T)
axis(1,at=c(0,0.025,0.05,0.075,0.10),labels=c(0,0.025,0.050,0.075,0.100))
abline(h=mean(het$F)-3*sd(het$F), lty=2, col="red")
abline(h=mean(het$F)+3*sd(het$F), lty=2, col="red")
#vertical cutoff line for call rate at 3%
abline(v=0.03, col="darkgreen", lty=2)
dev.off()


