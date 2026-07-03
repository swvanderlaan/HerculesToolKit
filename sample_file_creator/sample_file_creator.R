## Goal: script to select phenotype and covariates from complete list of info and write a sample file

################################################################################


## WD
setwd("/home/arjan/Cardio/Projects/Causality_plaque_phenotypes_and_GWAS/")

## libraries
library(tidyverse)
library(haven)
library(readxl)


################################################################################


# load data sources

## Selection of phenotypes and covariates
var_selection <- read_tsv("var_selection.txt") ## this needs to be a tab-delimited file

## Exclusion List
exclusion_list <- read_delim("exclusion_nonAEGS.list", delim = " ", col_names = "id_2")

## Athero-Express
path <- "/home/arjan/Cardio/Athero-Express/2018-1NEW_AtheroExpressDatabase_ScientificAE_230218.sav"
ae <- read_sav(path)

## Key Table:
keyt <- read_xlsx("20190115_AEGS_AExoS_FAM_SAMPLE_FILE_BASE_MINIMAL.xlsx", sheet = 2, na = "NA")


################################################################################


# Athero-Express
## tidy
names(ae) %<>%
     str_replace_all("\\.", "_") %>%
     tolower()

ae %<>% map_df(.f = function(x) {
     if (class(x) == 'labelled') as_factor(x)
     else x}) %>%
     rename(sex = gender) %>%
     mutate(latest = str_replace_all(latest, c("52015-10-10" = "2015-10-10"))) %>%
     print()
     
# mutate(study_number = str_replace(study_number, "([0-9]+)", "ae\\1"))

## annotate the df by hand
# manual_classses_ae <- read_tsv("Variable_classes_AB.csv") %>%
#      t() %>%
#      as.data.frame() %>%
#      rownames_to_column() %>%
#      as_tibble() %>%
#      rename(variables = 1, class_of_variable = 2) %>%
#      mutate(class_of_variable = str_replace_all(class_of_variable, c("numerical" = "numeric"))) %>%
#      print()

manual_classses_ae <- read_tsv("Variable_classes_AB.csv") %>%
     gather() %>%
     rename(variables = 1, class_of_variable = 2) %>%
     mutate(class_of_variable = str_replace_all(class_of_variable, c("numerical" = "numeric"))) %>%
     print()

## check whether column variables of manual_classes_ae corresponds to colnames ae
all(manual_classses_ae$variables == colnames(ae))

## if not in right order:
# manual_classses_ae <- manual_classses_ae[match(manual_classses_ae$variables, names(ae)),]

# ae_copy <- ae ## create ae copy for double checking

## edit class types of ae variables
funs <- sapply(paste0("as.", manual_classses_ae$class_of_variable), match.fun)
ae[] <- Map(function(dd, f) f(as.character(dd)), ae, funs)

# There were 22 warnings (use warnings() to see them)
# Warning messages:
# 1: In f(as.character(dd)) : NAs introduced by coercion
# 2: In f(as.character(dd)) : NAs introduced by coercion
# 3: In f(as.character(dd)) : NAs introduced by coercion
# 4: In f(as.character(dd)) : NAs introduced by coercion
# 5: In f(as.character(dd)) : NAs introduced by coercion
# 6: In f(as.character(dd)) : NAs introduced by coercion
# 7: In f(as.character(dd)) : NAs introduced by coercion
# 8: In f(as.character(dd)) : NAs introduced by coercion
# 9: In f(as.character(dd)) : NAs introduced by coercion
# 10: In f(as.character(dd)) : NAs introduced by coercion
# 11: In f(as.character(dd)) : NAs introduced by coercion
# 12: In f(as.character(dd)) : NAs introduced by coercion
# 13: In f(as.character(dd)) : NAs introduced by coercion
# 14: In f(as.character(dd)) : NAs introduced by coercion
# 15: In f(as.character(dd)) : NAs introduced by coercion
# 16: In f(as.character(dd)) : NAs introduced by coercion
# 17: In f(as.character(dd)) : NAs introduced by coercion
# 18: In f(as.character(dd)) : NAs introduced by coercion
# 19: In f(as.character(dd)) : NAs introduced by coercion
# 20: In f(as.character(dd)) : NAs introduced by coercion
# 21: In f(as.character(dd)) : NAs introduced by coercion
# 22: In f(as.character(dd)) : NAs introduced by coercion

## Check NA per variable
# na_count_ae_copy <-sapply(ae_copy, function(y) sum(length(which(is.na(y))))) %>% 
#      data.frame() %>%
#      rownames_to_column() %>%
#      as_tibble() %>%
#      rename(variables = 1, ae_copy = 2)
# na_count_ae <-sapply(ae, function(y) sum(length(which(is.na(y))))) %>% 
#      tibble()
# na_count <- cbind(na_count_ae_copy, na_count_ae) %>%
#      as_tibble() %>%
#      rename(ae = 3)
# variables_warnings <- na_count[!(na_count$ae_copy %in% na_count$ae),]
# ## this yields 14 variables with more NAs in ae than in the copy of the original ae
# colSums(variables_warnings[2:3])

# latest: one date is wrong: 52015-10-10; should probably be 2015-10-10
# eaindexr and eaindexl both have text "amputated leg", while the variables are numerical - some measure in left or right leg, that obviously can't be assessed when the leg has been amputated?
# trem1: one string "Analyzed but below detection limit" is converted to NA
# concneur, concneur3, concnitr, concresp, concanal, concanal3, concothe, and concoth2 contain the phrase "zo nodig", which is converted to NA when as.numeric is applied
# concdig and concdig2 contain the phrase "af en toe", which is converted to NA when as.numeric is applied

# Still missing 8 warnings, though. Perhaps a warning per string? Perhaps I missed some strings next to the ones described above, although in the same variable?
# check columns with: table(as.factor(ae_copy$trem1))
# manually checking these variables it turns out they all only have one phrase, and the number of instances of that phrase per variable matches the number of introduced NA per variable
# Therefore, still missing 8 warnings, but all introduced NAs are accounted for

## see: https://stackoverflow.com/questions/40304448/change-class-of-variables-in-a-data-frame-using-another-reference-data-frame


################################################################################


## Key Table
keyt %<>%
     rename_all(tolower) %>%
     mutate_at(.vars = "sex", .funs = tolower) %>%
     slice(-1) %>%
     mutate_at(vars(c("aegs_type", "aexos", "aems450k", "cohort", "study_type", "sex")), funs(as.factor)) %>%
     mutate_at(vars(c("pc1", "pc2", "pc3", "pc4", "pc5", "pc6", "pc7", "pc8", "pc9", "pc10")), funs(as.numeric)) %>%
     print()


################################################################################


# Build complete sample file from ae and keyt, apply exclusions, check variable type

## merge dataframes - get rid of non-overlapping rows
sample_file_total <- inner_join(keyt, ae, by = "study_number") %>%
     rename(sex = sex.x)

## filter out exclusion list
# check how many of the exclusion list are in our list:
table(sample_file_total$id_2 %in% exclusion_list$id_2)
# FALSE  TRUE 
# 1522     4 
# Therefore, we expect to filter out 4 rows
sample_file_total <- filter(sample_file_total, !sample_file_total$id_2 %in% exclusion_list$id_2)

## sanity check: does sample sex of all samples correspond between the two dataframes used for merge?
all(sample_file_total$sex %in% sample_file_total$sex.y)


# Automatic check for binary and continuous variables

## check factor variables for binary variables
is.fact <- sapply(sample_file_total, is.factor)
factors.df <- sample_file_total[, is.fact]
levels.df <- lapply(factors.df, levels)
binary_variables <- names(levels.df)[lengths(levels.df) == 2]

## check factor variables for continuous variables
is.num <- sapply(sample_file_total, is.numeric)
continuous_variables <- names(sample_file_total[, is.num])


################################################################################


# Variable selection
## assign identifiers to each
var_selection %<>%
     rename_all(tolower) %>%
     mutate(identifier_covar = ifelse(.$name %in% continuous_variables, "C", "D")) %>%
     mutate(identifier_pheno = ifelse(.$name %in% binary_variables, "B", "P")) %>%
     print()


################################################################################


# Build sample file out of three parts

## 1. Base
sample_file_base <- select(sample_file_total, index, study_number, michimp_id, id_1, id_2) %>%
     add_row(.before = 1, index = 1, study_number = 0, michimp_id = 0, id_1 = 0, id_2 = 0) ## identifiers: index for these is 1, and all base variables have 0 as identifier


## 2. Covariates
sample_file_covariates <- select(sample_file_total, study_number, var_selection$name[var_selection$covariate == "Yes"]) %>%
     print()

identifier_covar <- colnames(sample_file_covariates) %>%
     enframe(value = "varname", name = NULL) %>%
     left_join(var_selection, by = c("varname" = "name")) %>%  ## assign identifiers to variables, based on var_selection; variables that are not in var_selection get NA as value
     select(varname, identifier_covar) %>%
     mutate_all(funs(replace(., which(is.na(.)), 0))) %>% ## change NA to 0 as identifier
     mutate(varname = factor(varname, levels = unique(varname))) %>% ## assign levels to variables to make sure correct order is maintained when transposing
     spread(varname, identifier_covar) %>% ## transpose
     print()

sample_file_covariates <- rbind(identifier_covar, sample_file_covariates) %>%
     mutate_at(vars(c("study_number")), funs(as.numeric))
     
     
## 3. Phenotypes
sample_file_phenotypes <- select(sample_file_total, study_number, var_selection$name[var_selection$phenotype == "Yes"])

identifier_pheno <- colnames(sample_file_phenotypes) %>%
     enframe(value = "varname", name = NULL) %>%
     left_join(var_selection, by = c("varname" = "name")) %>%
     select(varname, identifier_pheno) %>%
     mutate_all(funs(replace(., which(is.na(.)), 0))) %>%
     mutate(varname = factor(varname, levels = unique(varname))) %>%
     spread(varname, identifier_pheno) %>%
     print()

sample_file_phenotypes <- rbind(identifier_pheno, sample_file_phenotypes) %>%
     mutate_at(vars(c("study_number")), funs(as.numeric))


## Sample file
sample_file <- left_join(sample_file_base, sample_file_covariates, by = "study_number") %>%
     left_join(sample_file_phenotypes, by = "study_number", suffix = c("_covar", "_pheno"))


## Write file
write_tsv(sample_file, "usethisfile.sample")
