#parse a set of CT2 files

import re
import os
import argparse
from pathlib import Path

parser = argparse.ArgumentParser(description="Process a set of Cenote-Taker2 outputs.")
parser.add_argument("--directory", metavar="d", type=str, nargs=1, help="directory containing CT2 files")
parser.add_argument("--output-file", metavar="o", type=str, nargs=1, help="filename to output all data to")

args=parser.parse_args()
#args.directory args.output_file

fsa_extraction_pattern = re.compile("-- closest relative:.*gi\|")

with open(args.output_file[0], 'w') as f:
	f.write("CENOTE_NAME\tDomain\tRealm\tKingdom\tPhylum\tClass\tOrder\tFamily\tSubfamily\tGenus\tSpecies\n")
	for directory in os.listdir(args.directory[0]):
	#open up the summary file for this
		summary_data=[line.strip('\n') for line in open(args.directory[0] + directory + "/" + directory + "_CONTIG_SUMMARY.tsv")][1::]
		for entry in summary_data:
			contig=entry.split('\t')[1]
			try:
				fsa_file=(Path(args.directory[0] + directory + "/sequin_and_genome_maps/" + contig + ".fsa").read_text()).split('\n')[0]
				lineage = fsa_extraction_pattern.search(fsa_file).group(0).lstrip("-- closest relative: ").rstrip(" gi|").split("; ")
				f.write(contig + "\t" + "\t".join(lineage) + '\n')
			except:
				print(contig + " Did not have a corresponding .gbf file")
