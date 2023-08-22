#!/bin/bash
#
#################################################################################################
### PARAMETERS SLURM
#SBATCH --job-name=prep_ref                                  														# the name of the job
#SBATCH -o /hpc/dhl_ec/data/references/1000G/Phase3/VCF_format/gwaslab.prep_ref.hpc.log 	        # the log file of this job
#SBATCH --error /hpc/dhl_ec/data/references/1000G/Phase3/VCF_format/gwaslab.prep_ref.hpc.errors	# the error file of this job
#SBATCH --time=12:00:00                                             														# the amount of time the job will take: -t [min] OR -t [days-hh:mm:ss]
#SBATCH --mem=16G                                                    														# the amount of memory you think the script will consume, found on: https://wiki.bioinformatics.umcutrecht.nl/bin/view/HPC/SlurmScheduler
#SBATCH --gres=tmpspace:512G                                        														# the amount of temporary diskspace per node
#SBATCH --mail-user=s.w.vanderlaan-2@umcutrecht.nl                  														# where should be mailed to?
#SBATCH --mail-type=FAIL                                            														# when do you want to receive a mail from your job?  Valid type values are NONE, BEGIN, END, FAIL, REQUEUE
                                                                    														# or ALL (equivalent to BEGIN, END, FAIL, INVALID_DEPEND, REQUEUE, and STAGE_OUT), 
                                                                    														# Multiple type values may be specified in a comma separated list. 
####    Note:   You do not have to specify workdir: 
####            'Current working directory is the calling process working directory unless the --chdir argument is passed, which will override the current working directory.'
####            TODO: select the type of interpreter you'd like to use
####            TODO: Find out whether this job should dependant on other scripts (##SBATCH --depend=[state:job_id])
####
#################################################################################################
#
# You can use the variables below (indicated by "#$") to set some things for the submission system.
# Another useful tip: you can set a job to run after another has finished. Name the job 
# with "-N SOMENAME" and hold the other job with -hold_jid SOMENAME". 
# Further instructions: https://wiki.bioinformatics.umcutrecht.nl/bin/view/HPC/HowToS#Run_a_job_after_your_other_jobs
#
# It is good practice to properly name and annotate your script for future reference for
# yourself and others. Trust me, you'll forget why and how you made this!!!

echo ""
echo "                   Create, Split, and Merge Reference VCFs - HPC version"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# Process reference data for harmonization/normalization of GWAS data with GWASLab
# https://cloufield.github.io/gwaslab/Reference/
#
# created by: Sander W. van der Laan | s.w.vanderlaan-2@umcutrecht.nl
# last updated: 2023-08-22
# v 1.0.1

### Loading the gwas-environment
### You need to also have the conda init lines in your .bash_profile/.bashrc file
echo "..... > loading required conda environment containing the gwaslab and associated packages installation..."
eval "$(conda shell.bash hook)"
conda activate gwas

REF_loc="/hpc/dhl_ec/data/references"
REF1Kgp3v5_loc="${REF_loc}/1000G/Phase3"
VCF_loc="${REF1Kgp3v5_loc}/VCF_format"

echo "References:     ${REF_loc}"
echo "1000G, phase 3: ${REF1Kgp3v5_loc}"
echo "VCF-files:      ${VCF_loc}"

# extract POP sample ID
echo "Extracting sample list per population."
# awk '$3=="EUR"{print $1}' "${REF1Kgp3v5_loc}"/integrated_call_samples_v3.20130502.ALL.panel > "${REF1Kgp3v5_loc}"/integrated_call_samples_v3.20130502.EUR.sample
# awk '$3=="AFR"{print $1}' "${REF1Kgp3v5_loc}"/integrated_call_samples_v3.20130502.ALL.panel > "${REF1Kgp3v5_loc}"/integrated_call_samples_v3.20130502.AFR.sample
# awk '$3=="AMR"{print $1}' "${REF1Kgp3v5_loc}"/integrated_call_samples_v3.20130502.ALL.panel > "${REF1Kgp3v5_loc}"/integrated_call_samples_v3.20130502.AMR.sample
# awk '$3=="SAS"{print $1}' "${REF1Kgp3v5_loc}"/integrated_call_samples_v3.20130502.ALL.panel > "${REF1Kgp3v5_loc}"/integrated_call_samples_v3.20130502.SAS.sample
# awk '$3=="EAS"{print $1}' "${REF1Kgp3v5_loc}"/integrated_call_samples_v3.20130502.ALL.panel > "${REF1Kgp3v5_loc}"/integrated_call_samples_v3.20130502.EAS.sample
awk '{print $1}' "${REF1Kgp3v5_loc}"/integrated_call_samples_v3.20130502.ALL.panel | tail -n +2 > "${REF1Kgp3v5_loc}"/integrated_call_samples_v3.20130502.ALL.sample

# process
for pop in ALL; do # AFR AMR SAS EAS EUR were already processed
echo "Processing data for ${pop}."
# 	for chr in {1..22}; do
# 	echo "> parsing chromosome ${chr}."
# 		bcftools view -S "${REF1Kgp3v5_loc}"/integrated_call_samples_v3.20130502."${pop}".sample "${VCF_loc}"/ALL.chr"${chr}".phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz | \
# 			bcftools norm -m-any --check-ref w -f "${REF_loc}"/1000G/human_g1k_v37.fasta | \
# 			bcftools annotate -x ID,INFO -I +'%CHROM:%POS:%REF:%ALT' | \
# 			bcftools norm --rm-dup both | \
# 			bcftools +fill-tags -Oz  -- -t AF  \
# 				> "${VCF_loc}"/"${pop}".chr"${chr}".split_norm_af.vcf.gz
# 		tabix -p vcf "${VCF_loc}"/"${pop}".chr"${chr}".split_norm_af.vcf.gz
# 	ls "${VCF_loc}"/"${pop}".chr"${chr}".split_norm_af.vcf.gz 
# 	ls "${VCF_loc}"/"${pop}".chr"${chr}".split_norm_af.vcf.gz >> "${VCF_loc}"/"${pop}".concat_list.txt 
# 	done

	# merge
	echo "> merging and sorting all data."
	bcftools concat -a -d both -f "${VCF_loc}"/"${pop}".concat_list.txt -Ob | bcftools sort -Oz  > "${VCF_loc}"/"${pop}".ALL.split_norm_af.1kgp3v5.hg19.vcf.gz
	tabix -p vcf "${VCF_loc}"/"${pop}".ALL.split_norm_af.1kgp3v5.hg19.vcf.gz
done