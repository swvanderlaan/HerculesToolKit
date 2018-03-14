import os,string,re
z=open("M00682_Platte1-16_Standard_Format1_FORPAUL-1.txt","a")
z.write("Index\tName\tChr\tPosition\n")
f=open("test.txt","r").readlines()
for l in f:
    if "exm" in l:
        l=string.split(l,"\t")
        snp=l[0]
        index=l[8]
        chrom=l[18]
        pos=l[19]
        z.write("%s\t%s\t%s\t%s\n"%(index,snp,chrom,pos))
z.close()
        
        
