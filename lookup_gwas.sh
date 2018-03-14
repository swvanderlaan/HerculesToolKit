#! /bin/bash
#
#$ -S /bin/bash
#$ -o /hpc/dhl_ec/Dropzone/lookup.gwas.output
#$ -e /hpc/dhl_ec/Dropzone/lookup.gwas.errors
#$ -q long
#$ -M s.w.vanderlaan-2@umcutrecht.nl
#$ -m ea
#$ -cwd
#
# lookup_gwas.v1.sh
#
# Script to lookup results
#
# author: Sander W. van der Laan
# date: 2015-08-17
# 
#
######## EXAMPLE script + submission ########
### echo "sh lookup_gwas.sh CAD `pwd`/clumped_hits.txt `pwd` VARIANT PP_CAD \ " > lookup_snvs_cad.sh
### qsub -S /bin/bash -o lookup_snvs_cad.output -e lookup_snvs_cad.errors -q veryshort -pe threaded 4 -M s.w.vanderlaan-2@umcutrecht.nl -m ea -cwd lookup_snvs_cad.sh

#############################################################################
# Clear the scene!
clear
echo "--------------------------------------------------------------------------------------------------------"
echo "                            SCRIPT TO LOOKUP VARIANTS OR GENES IN (meta-)GWAS/VEGAS DATA"
echo ""
echo "You're here: "`pwd`
echo "Today's:" `date`
echo ""
echo "Version: LOOKUP_GWAS.v1.20150821"
echo ""
echo "Last update: August 21st, 2015"
echo "Written by: Sander W. van der Laan (s.w.vanderlaan-2@umcutrecht.nl)"
echo ""
echo " Lookup variants in (imputed) ExomeChip or GWAS data, or lookup genes in VEGAS results. For this you need"
echo " to pass [5] arguments:"
echo ""
echo "	lookup_gwas.sh arg1 arg2 arg3 arg4 arg5"
echo "	- Argument #1 is the GWAS dataset to query [PHENOTYPE]."
echo "	- Argument #2 is path_to the lookup list - can be list of geneIDs of variantIDs [LOOKUPLIST]."
echo "	- Argument #3 is path_to the OUTPUT directory of this lookup [OUTPUTDIR]."
echo "	- Argument #4 is TYPE of lookup [VARIANT/GENE] -- currently GENE is not working!!!"
echo "	- Argument #5 is PROJECT name (will be printed in output-filename)."
echo ""
echo "--------------------------------------------------------------------------------------------------------"
### START of if-else statement for the number of command-line arguments passed ###
if [[ $# -lt 5 ]] 
then 
	echo "--------------------------------------------------------------------------------------------------------"
	echo "$(basename "$0") error! You must supply [8] arguments:"
	echo "- Argument #1 is the GWAS dataset to query [PHENOTYPE]."
	echo "- Argument #2 is path_to the lookup list - can be list of geneIDs of variantIDs [LOOKUPLIST]."
	echo "- Argument #3 is path_to the OUTPUT directory of this lookup [OUTPUTDIR]."
	echo "- Argument #4 is TYPE of lookup [VARIANT/GENE] -- currently GENE is not working!!!"
	echo "- Argument #5 is the PROJECT name (will be printed in output-filename)."
	echo "An example command would be: lookup_data.sh arg1 arg2 arg3 arg4 arg5"
else
	echo "All arguments are passed. These are the settings:"
	echo "The phenotype..........................: "$1
	echo "The lookup list is.....................: "$2
	echo "The output directory is................: "$3
	echo "The type of lookup is..................: "$4
	echo "The project name is....................: "$5
echo ""	
echo "--------------------------------------------------------------------------------------------------------"
### SETTING VARIABLES BASED ON ARGUMENTS PASSED
# Loading the phenotype file. 
PHENOTYPE=$1 # depends on arg1
	if [[ $PHENOTYPE = "CAD" ]]; then 
		echo "We are looking up variants in data from CARDIoGRAMplusC4D results files. Initiating..."
		PHENOTYPESFILE=/hpc/dhl_ec/data/_cardiogram/cardiogramgwas_plus_c4dmetabo.txt.gz
	elif [[ $PHENOTYPE = "LAS" ]]; then 
		echo "We are looking up variants in data from METASTROKE results files for LAS. Initiating..."
		PHENOTYPESFILE=/hpc/dhl_ec/data/_metastroke/LAS.TBL.gz
	elif [[ $PHENOTYPE = "TC" ]]; then 
		echo "We are looking up variants in data from GLGC results files for total cholesterol. Initiating..."
		PHENOTYPESFILE=/hpc/dhl_ec/data/_lipids/jointGwasMc_TC_edited.txt.gz
	elif [[ $PHENOTYPE = "HDL" ]]; then 
		echo "We are looking up variants in data from GLGC results files for HDL cholesterol. Initiating..."
		PHENOTYPESFILE=/hpc/dhl_ec/data/_lipids/jointGwasMc_HDL_edited.txt.gz
	elif [[ $PHENOTYPE = "LDL" ]]; then 
		echo "We are looking up variants in data from GLGC results files for LDL cholesterol. Initiating..."
		PHENOTYPESFILE=/hpc/dhl_ec/data/_lipids/jointGwasMc_LDL_edited.txt.gz
	elif [[ $PHENOTYPE = "TG" ]]; then 
		echo "We are looking up variants in data from GLGC results files for triglycerides. Initiating..."
		PHENOTYPESFILE=/hpc/dhl_ec/data/_lipids/jointGwasMc_TG_edited.txt.gz
	elif [[ $PHENOTYPE = "BMI" ]]; then 
		echo "We are looking up variants in data from GIANT results files for body mass index (2015). Initiating..."
		PHENOTYPESFILE=/hpc/dhl_ec/data/_giant/GIANT_BMI_Locke_et_al_European_SNP_gwas_mc_merge_nogc.tbl.uniq.gz
	elif [[ $PHENOTYPE = "HEIGHT" ]]; then 
		echo "We are looking up variants in data from GIANT results files for height (2015). Initiating..."
		PHENOTYPESFILE=/hpc/dhl_ec/data/_giant/GIANT_HEIGHT_Wood_et_al_2014_publicrelease_HapMapCeuFreq.txt.gz
	elif [[ $PHENOTYPE = "T2D" ]]; then 
		echo "We are looking up variants in data from DIAGRAM results files. Initiating..."
		PHENOTYPESFILE=/hpc/dhl_ec/data/_diagram/DIAGRAMv3_GWAS_2012DEC17.txt.gz
	elif [[ $PHENOTYPE = "AGATSON" ]]; then 
		echo "We are looking up variants in data from DIAGRAM results files. Initiating..."
		PHENOTYPESFILE=/hpc/dhl_ec/data/_cac/all.AGATSTON_LOG.assoc.dosage.gz
	elif [[ $PHENOTYPE = "CHARGE_CIMT" ]]; then 
		echo "We are looking up variants in data from CHARGE cIMT GWAS results files. Initiating..."
		PHENOTYPESFILE=/hpc/dhl_ec/data/_charge_cimt_plaquepresence/charge.cca.meta9b.txt.gz
	elif [[ $PHENOTYPE = "CHARGE_PP" ]]; then 
		echo "We are looking up variants in data from CHARGE plaque presence GWAS results files. Initiating..."
		PHENOTYPESFILE=/hpc/dhl_ec/data/_charge_cimt_plaquepresence/charge.plq.meta7.txt.gz
	elif [[ $PHENOTYPE = "CIS_eQTL_WESTRA" ]]; then 
		echo "We are looking up variants in data from Westra et al. cis-eQTL in whole blood results files. Initiating..."
		PHENOTYPESFILE=/hpc/dhl_ec/data/_eqtl/Blood_eQTL_browser/westra_WB_Cis_eQTL_Probs_FDR0.5.20121221.txt.gz
	elif [[ $PHENOTYPE = "TRANS_eQTL_WESTRA" ]]; then 
		echo "We are looking up variants in data from Westra et al. trans-eQTL in whole blood results files. Initiating..."
		PHENOTYPESFILE=/hpc/dhl_ec/data/_eqtl/Blood_eQTL_browser/westra_WB_Trans_eQTL_Probs_FDR0.5.20121221.txt.gz
	elif [[ $PHENOTYPE = "CIS_EXON_GEUVADIS" ]]; then 
		echo "We are looking up variants in data from Geuvadis et al. cis-eQTL of exons in whole blood results files. Initiating..."
		PHENOTYPESFILE=/hpc/dhl_ec/data/_eqtl/Geuvadis/EUR373.exon.cis.FDR5.all.rs137.txt.gz
	elif [[ $PHENOTYPE = "CIS_GENE_GEUVADIS" ]]; then 
		echo "We are looking up variants in data from Geuvadis et al. cis-eQTL of gene in whole blood results files. Initiating..."
		PHENOTYPESFILE=/hpc/dhl_ec/data/_eqtl/Geuvadis/EUR373.gene.cis.FDR5.all.rs137.txt.gz
	elif [[ $PHENOTYPE = "CIS_REPEAT_GEUVADIS" ]]; then 
		echo "We are looking up variants in data from Geuvadis et al. cis-eQTL of transcribed repetitive elements in whole blood results files. Initiating..."
		PHENOTYPESFILE=/hpc/dhl_ec/data/_eqtl/Geuvadis/EUR373.repeat.cis.FDR5.all.rs137.txt.gz
	elif [[ $PHENOTYPE = "CIS_TRRATIO_GEUVADIS" ]]; then 
		echo "We are looking up variants in data from Geuvadis et al. cis-eQTL of transcript ratio in whole blood results files. Initiating..."
		PHENOTYPESFILE=/hpc/dhl_ec/data/_eqtl/Geuvadis/EUR373.trratio.cis.FDR5.all.rs137.txt.gz
	elif [[ $PHENOTYPE = "PGC_BIPOLAR" ]]; then 
		echo "We are looking up variants in data from PGC bipolar disorder GWAS results files. Initiating..."
		PHENOTYPESFILE=/hpc/dhl_ec/data/_pgc/pgc.bip.2012-04/pgc.bip.full.2012-04.txt.gz	
	else
		echo "--------------------------------------------------------------------------------------------------------"
		echo " Oh, computer says no! Argument not recognised. The options are: [CAD/LAS] for CAD or large artery "
		echo " stroke associated variants from CARDIoGRAMplusC4D or METASTROKE, respectively. [TC/HDL/LDL/TG] for "
		echo " blood lipids associated variants from GLGC. [BMI/HEIGHT] for BMI or height associated variants from "
		echo " GIANT 2015. [T2D] for type 2 diabetes associated variants from DIAGRAM. [AGATSON] for coronary  "
		echo " calcification associated variants from Van Setten et al. 2014. [] for carotid IMT or plaque presence"
		echo " associated variants from Bis et al. Nat Genet 2010. [CIS_eQTL_WESTRA/TRANS_eQTL_WESTRA] for"
		echo " cis- or trans-eQTLs, respectively, in whole blood from Westra et al. Nat Genet 2013. "
		echo " [CIS_EXON_GEUVADIS/CIS_GENE_GEUVADIS/CIS_REPEAT_GEUVADIS/CIS_TRRATIO_GEUVADIS] for cis-eQTLs in whole "
		echo " blood from the Geuvadis project, i.e. in exons, genes, transcribed repetitive elements or transcript "
		echo " ratios. [PGC_BIPOLAR] for bipolar disorder associated variants. Script is terminated."
		echo ""
		echo "--------------------------------------------------------------------------------------------------------"
		# The wrong arguments are passed, so we'll exit the script now!
		echo " Script was terminated, as the wrong arguments are passed. Refer to the error/output logs for more "
		echo " information..." 
		exit 0
	fi
echo ""
echo "--------------------------------------------------------------------------------------------------------"
echo ""
# Loading the lookup list file (should be a space-delimited list of 1 variant or 1 gene PER line as they
# appear in the results output-files, e.g. 'rs12345 chr1:12345:C_AAC'). 
LOOKUP=$2 # depends on arg3
echo "We will lookup the following variants/genes:"
	while read VARIANTGENE; do 
	for i in $VARIANTGENE; do
		echo "* " $i
	done
done < $LOOKUP
echo "-------------------------"
NUMBER=`cat $LOOKUP | wc -l`
echo "Total: "$NUMBER
	
# Setting the remaining variables
OUTPUTDIR=$3 # depends on arg3
TYPE=$4 # depends on arg4
PROJECT=$5 # depends on arg5

echo ""
echo "--------------------------------------------------------------------------------------------------------"
### SETTING THE TYPE OF LOOKUP DATA AS VARIABLES ###
### We have to set the type (variant or gene) lookup
	if [[ $TYPE = "VARIANT" ]]; then 
		echo "We are looking up variants in (meta-)GWAS results files for $PHENOTYPE. Initiating..."
		echo ""	
			#### SINGLE VARIANT LOOKUP #####
			echo "Lookup data for phenotype: " $PHENOTYPE
			zcat $PHENOTYPESFILE | head -1 > $OUTPUTDIR/$PHENOTYPE.$TYPE.$PROJECT.txt
				while read VARIANT; do
					for v in $VARIANT; do
						echo "Looking for variant: " $v
						zcat $PHENOTYPESFILE | tail -n +2 | awk '( $1 == "'$v'" )' >> $OUTPUTDIR/$PHENOTYPE.$TYPE.$PROJECT.txt
					done
				done < $LOOKUP
			echo "Done looking up data for: "$PHENOTYPE
			NUMBER_VARIANTS=`cat $OUTPUTDIR/$PHENOTYPE.$TYPE.$PROJECT.txt | wc -l`
			echo "Number of variants found: "$NUMBER_VARIANTS
			echo "---------------------------------------------"
	elif [[ $TYPE = "GENES" ]]; then 
		echo "We are looking up genes in VEGAS output. Initiating..."
		#### GENE-BASED ASSOCIATION STUDY = VEGAS LOOKUP #####
		echo "THIS OPTION IS STILL IN BETA -- NOT WORKING!!!"
		echo "Lookup data for phenotype: " $i
		#head -1 $INPUTDIR/$i/$BASEFILENAME.$i.$EXTENSION > $OUTPUTDIR/$i.aegs1kg.$PROJECT.$TYPE.txt
			while read GENE; do
				for v in $GENE; do
				echo "Looking for gene: " $v
			#head -1 $INPUTDIR/aegscombo_ppm2_"$i".assoc.dosage.VEGAS.out > $OUTPUTDIR/VEGAS.$i.$LOOKUP
			#grep -w -f $LOOKUP $INPUTDIR/aegscombo_ppm2_"$i".assoc.dosage.VEGAS.out >> $OUTPUTDIR/VEGAS.$i.$LOOKUP
				done
			done < $LOOKUP
		echo "Done looking up data for "$PHENOTYPE
		NUMBER_GENES=`cat $OUTPUTDIR/$PHENOTYPE.$PROJECT.$TYPE.txt | wc -l`
		echo "Number of genes found: "$NUMBER_GENES
		echo "---------------------------------------------"
	else
		echo "--------------------------------------------------------------------------------------------------------"
		echo " Oh, computer says no! Argument not recognised. The options are: [VARIANT] to look up (a list of) "
		echo " individual variants; or [GENES] to look up (a list of) individual genes - note that you have to supply"
		echo " possible synonyms for a given gene. Script is terminated."
		echo ""
		echo "--------------------------------------------------------------------------------------------------------"
		# The wrong arguments are passed, so we'll exit the script now!
		echo " Script was terminated, as the wrong arguments are passed. Refer to the error/output logs for more "
		echo " information..." 
		exit 0
	fi
echo ""

### END of if-else statement for the number of command-line arguments passed ###
fi 

