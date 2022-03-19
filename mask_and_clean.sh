#Example of a single node pipeline for generating viral tagging contig sets

#!/bin/bash
#SBATCH -c 12
#SBATCH --mem=120g

#Load modules
module load bbtools
module load spades

#generate control contigs
for sample in Baldridge_Control1 Baldridge_Control2 Baldridge_Control4 Baldridge_Control5
do
  spades.py --meta -1 processed_data/${sample}/r1clean.fq -2 processed_data/${sample}/r2clean.fq -o assemblies/${sample}
  reformat.sh in=assemblies/${sample}/scaffolds.fasta out=${sample}_contigs.fasta #no minlength here
done

#Merge all control contigs into a single set
cat *Control*_contigs.fasta > all_control_contigs.fasta

#mask out host bacteria and then mask out controls
for sample in Baldridge_Fp22_CD Baldridge_Fp22_HHC
do
  bbmap.sh in1=processed_data/${sample}/r1clean.fq in2=processed_data/${sample}/r2clean.fq ref=genomes/fp22_assembly.fasta outu1=masked_reads/${sample}_r1.fq outu2=masked_reads/${sample}_r2.fq
  bbmap.sh in1=masked_reads/${sample}_r1.fq in2=masked_reads/${sample}_r2.fq ref=all_control_contigs.fasta outu1=clean_reads/${sample}_r1_clean.fq outu2=clean_reads/${sample}_r2_clean.fq
done

for sample in Baldridge_Fp43_CD Baldridge_Fp43_HHC
do
  bbmap.sh in1=processed_data/${sample}/r1clean.fq in2=processed_data/${sample}/r2clean.fq ref=genomes/fp43_assembly.fasta outu1=masked_reads/${sample}_r1.fq outu2=masked_reads/${sample}_r2.fq
  bbmap.sh in1=masked_reads/${sample}_r1.fq in2=masked_reads/${sample}_r2.fq ref=all_control_contigs.fasta outu1=clean_reads/${sample}_r1_clean.fq outu2=clean_reads/${sample}_r2_clean.fq
done

#assemble clean reads
for sample in Baldridge_Fp22_CD Baldridge_Fp22_HHC Baldridge_Fp43_CD Baldridge_Fp43_HHC
do
  spades.py --meta -1 clean_reads/${sample}_r1_clean.fq -2 clean_reads/${sample}_r2_clean.fq -o assemblies/${sample}_clean
  reformat.sh in=assemblies/${sample}_clean/scaffolds.fasta out=${sample}_clean_contigs.fasta minlength=1500
done
