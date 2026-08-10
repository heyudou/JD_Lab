# Detecting cancer in cfRNA

Goal: To detect cancer specific changes in the RNA, to detect aneuploidy, higher variant allele fraction for driver gene mutations.

# Data
For method checking:

use [HCA](https://data.humancellatlas.org/) data: [Breast cancer cells](https://explore.data.humancellatlas.org/projects/f6133d2a-9f3d-4ef9-9c19-c23d6c7e6cc0)

[ENA access](https://www.ebi.ac.uk/ena/browser/view/SRP213890)
[SRA run selector](https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA553537&o=avgspotlen_l%3Aa%3Bacc_s%3Aa)


SRA metadata\
384 single-end RNA-seq MCF7 cells, single-end\
192 Norm cells, 191 Hypoxia cells

Choose 30 Normal cells with ≥1 million reads to make a pseudo-bulk sequencing 








 Download GRCh38 reference file ###
 https://www.gencodegenes.org/human/
 Comprehensive gene annotation → PRI → GTF
 Genome sequence, primary assembly (GRCh38) → PRI → Fasta
