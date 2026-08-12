# Detecting cancer in cfRNA

Goal: To detect cancer specific changes in the RNA, to detect aneuploidy, higher variant allele fraction for driver gene mutations.

## MCF7 cell lines for proof of concept

### Design
**Strategy**: Use single cell RNAseq of MCF7 to construct pseudobulk RNAseq MCF7.

**Rationale**: Individual Smart-seq2 cell is too sparse and noisy for a clean genome-wide allelic-imbalance test.

**Advantage**: Can later construct controlled synthetic mixturs of cancer and normal RNA cocktails resembling cfRNA.


This single-cell RNA-seq dataset provides a flexible framework for developing and testing an RNA-based CNA/allelic-imbalance detection method. By combining individual MCF7 cells, we can first create a high-signal pseudobulk to determine whether known cancer-associated copy-number changes can be recovered from RNA. Because individual cells remain separately sequenced, we can later construct controlled synthetic mixtures of cancer and normal RNA at defined tumor fractions and sequencing depths, generating many replicate “cfRNA-like” cocktails to characterize sensitivity and limit of detection. This also allows us to independently evaluate expression-depth and allelic-imbalance signals and determine whether combining them improves cancer detection.

### Data
use [HCA](https://data.humancellatlas.org/) data: [Single cell sequencing of breast cancer cells](https://explore.data.humancellatlas.org/projects/f6133d2a-9f3d-4ef9-9c19-c23d6c7e6cc0)

[ENA access](https://www.ebi.ac.uk/ena/browser/view/SRP213890)
[SRA run selector](https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA553537&o=avgspotlen_l%3Aa%3Bacc_s%3Aa)

SRA metadata summary\
384 single-end RNA-seq MCF7 cells, single-end\
192 Norm cells, 191 Hypoxia cells

Choose 30 Normal cells with ≥1 million reads to make a pseudo-bulk sequencing 



### Workflow

project location on discovery HPC: /projects/csf_cfrna_projects/phe/allelic_imbalance_MCF7_test/

    MCF7 Smart-seq2 FASTQs
              ↓
        FastQC / MultiQC
              ↓
       STAR alignment (GRCh38)
              ↓
       Individual cell BAMs
              ↓
       30-cell pseudobulk
              ↓
    MCF7 heterozygous SNP panel
              ↓
       REF / ALT RNA counts
              ↓
       Allelic imbalance
              ↓
       Regional CNA signal
              ↓
    Compare with DNA CNA reference


Reference files required:

**STAR alignment reference files:**

Current [GRCh38 reference](https://www.gencodegenes.org/human/)\
Comprehensive gene annotation → PRI → GTF\
Genome sequence, primary assembly (GRCh38) → PRI → Fasta

gencode.v50.primary_assembly.annotation.gtf\
GRCh38.primary_assembly.genome.fa


**MCF7 heterozygous SNPs**

Table S1 of [publication](https://pmc.ncbi.nlm.nih.gov/articles/PMC8666669/?utm_source=chatgpt.com#appsec2) listed approximately **11,500 MCF7 heterozygous SNPs**, which will be used to define informative loci. 
These SNPs are reported in hg19 coordinates, they are converted to GRCh38 and validated against the same reference genome used for RNA alignment.

**MCF7 CNV profile**




For sufficiently covered SNPs, RNA allele fraction is calculated as:

    ALT / (REF + ALT)

Regional deviations from balanced allele ratios are then evaluated as potential CNA signals.


