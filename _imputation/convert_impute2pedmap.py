"""
Copyright (c) 2012, 2013 The PyPedia Project, http://www.pypedia.com
<br>All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met: 

# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

http://www.opensource.org/licenses/BSD-2-Clause
"""

__pypdoc__ = """
Method: Convert_impute2_to_PEDMAP
Link: http://www.pypedia.com/index.php/Convert_impute2_to_PEDMAP
Retrieve date: Wed, 11 Feb 2015 15:51:28 +0200



Converts from legend and haplotype file of impute2 (https://mathgen.stats.ox.ac.uk/impute/impute_v2.html) to PED and MAP files (http://pngu.mgh.harvard.edu/~purcell/plink/data.shtml#ped)

'''Parameters:'''
*'''chromosome''':  string, the chromosome.
* '''legend_file''': string, the legend filename.
* '''haplotypes_file''': string, the hap filename.
* '''sample_names''' : a Python list with the names of the samples in the haplotypes file. (Optional, if not set the default value is: 0,1,2,3, ..).
* '''sample_names_filename''' : filename with one sample name per line (Optional).
* '''family_id''': a Python list with the family ids of the samples. (Optional, if not set the default value is: 1 for all the samples).
* '''family_id_filename''' : filename with one family id per line (Optional).
* '''p_id''': a Python list with the paternal id. (Optional, if not set the default value is: 0 for all the samples).
* '''p_id_filename''' : filename with one parent_id per line (Optional).
* '''m_id''': a Python list with the maternal id. (Optional, if not set the default value is: 0 for all the samples).
* '''m_id_filename''': filename with one maternal_id per line (Optional).
* '''gender''': a Python list with the gender id. (Optional, if not set the default value is: 3 for all the samples).
* '''gender_filenane''': filename with one gender id per line (Optional)
* '''pheno''': a Python list with the pheno id. (Optional, if not set the default value is: 0 for all the samples). 
* '''pheno_filename''': filename with one pheno id per line (Optional)
* '''output''': The prefix of the output filenames. i.e. if output is "results" then the output files will be output.ped and output.map. If not defined then the basename of the '''legend_file''' will be used.

For more info about the famility_id, p_id, m_id, gender and pheno values check the definition of the PED format: http://pngu.mgh.harvard.edu/~purcell/plink/data.shtml#ped

[[Category:Format Conversion]]
[[Category:Bioinformatics]]
[[Category:Algorithms]]
[[Category:Validated]]



"""

import os

def Convert_impute2_to_PEDMAP(
	chromosome = None, 
	legend_file = None, 
	haplotypes_file = None, 
	sample_names = None,
	sample_names_filename = None,
	family_id = None,
	family_id_filename = None,
	p_id = None,
	p_id_filename = None,
	m_id = None,
	m_id_filename = None,
	gender = None,
	gender_filename = None,
	pheno = None,
	pheno_filename = None,
	output = None, 
	):
	
	legend = open(legend_file).readlines()[1:] # Skip first line from legend
	haplotypes = open(haplotypes_file).readlines()
	
	snps = len(legend)
	
	if not output:
		output = os.path.splitext(legend_file)[0]
	
	map_filename = output + ".map"
	ped_filename = output + ".ped"
	
	map_file = open(map_filename, "w")
	ped = {}
	
	read_filename_lines = lambda filename : [x.replace("\n", "") for x in open(filename, 'U').readlines()] if filename else None
	if not sample_names: sample_names = read_filename_lines(sample_names_filename)
	if not family_id: family_id = read_filename_lines(family_id_filename)
	if not p_id: p_id = read_filename_lines(p_id_filename)
	if not m_id: m_id = read_filename_lines(m_id_filename)
	if not gender: gender = read_filename_lines(gender_filename)
	if not pheno: phrno = read_filename_lines(pheno_filename)
	
	print "Saving map file.."
	for snp_index, pair in enumerate(zip(legend, haplotypes)):
		l_splitted = [x for x in pair[0].replace("\n", "").split() if len(x) > 0]
		h_splitted = [x for x in pair[1].replace("\n", "").split() if len(x) > 0]
		
		for individual_id, genotype in [(index/2, (h_splitted[index], h_splitted[index+1])) for index, value in enumerate(h_splitted) if index % 2 == 0]:
			if not ped.has_key(individual_id):
				ped[individual_id] = {}
				if family_id:
					ped[individual_id]["family_id"] = family_id[individual_id]
				else:
					ped[individual_id]["family_id"] = 1
					
				if sample_names:
					ped[individual_id]["ind_id"] = sample_names[individual_id]
				else:
					ped[individual_id]["ind_id"] = individual_id
				
				if p_id:
					ped[individual_id]["p_id"] = p_id[individual_id]
				else:
					ped[individual_id]["p_id"] = 0
					
				if m_id:
					ped[individual_id]["m_id"] = m_id[individual_id]
				else:
					ped[individual_id]["m_id"] = 0
					
				if gender:
					ped[individual_id]["gender"] = gender[individual_id]
				else:
					ped[individual_id]["gender"] = 3
				
				if pheno:
					ped[individual_id]["pheno"] = pheno[individual_id]
				else:
					ped[individual_id]["pheno"] = 0
					
				ped[individual_id]["geno"] = []
	 	
			if genotype[0] == "0":
				allele1 = l_splitted[2]
			elif genotype[0] == "1":
				allele1 = l_splitted[3]
			else:
				raise Exception("Invalid format in phased file")
			
			if genotype[1] == "0":
				allele2 = l_splitted[2]
			elif genotype[1] == "1":
				allele2 = l_splitted[3]
			else:
				raise Exception("Invalid format in phased file")
	 		
			ped[individual_id]["geno"] += [ allele1, allele2 ]
	 
		if not snp_index % 1000: print snp_index, "/", snps 
	 
		map_file.write( str.join("\t", [str(chromosome), l_splitted[0], "0", l_splitted[1]]) + "\n") 
	map_file.close()
	print "..DONE saving map file"
	
	print "Saving ped file.."
	individuals = len(ped)
	ped_file = open(ped_filename, "w")
	for ind, value in ped.iteritems():
		print "Writing individual:", ind, "/", individuals
		ped_file.write(str.join("\t", [str(x) for x in [value["family_id"], value["ind_id"], value["p_id"], value["m_id"], value["gender"], value["pheno"]] + value["geno"]]) + "\n")
	ped_file.close()
	print "..DONE saving ped file"
	
	return (ped_filename, map_filename)



#Method name =Convert_impute2_to_PEDMAP()
if __name__ == '__main__':
    print __pypdoc__

    returned = Convert_impute2_to_PEDMAP()
    if returned:
        print 'Method returned:'
        print str(returned)
