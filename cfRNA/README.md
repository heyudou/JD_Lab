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

*variability issue*: a recent [publication](./cfRNA_papers/MCF7_variability.pdf) studied 27 strains of MCF7 and found "26% of genes altered by copy number
alterations (CNAs) (range, 7% to 99%) were discordant (Extended Data Fig. 1c–e). These
results indicate that genetic variability across versions of the same cell line is common." 



### RESULTS
*SNP sites to calculate BAF*:
Using a minimum **REF+ALT RNA depth of 10×**, 2,495 MCF7 heterozygous SNPs were retained for allelic-imbalance analysis.

| Chromosome | SNPs (≥10×) |
|---|---:|
| chr1 | 185 |
| chr2 | 221 |
| chr3 | 115 |
| chr4 | 106 |
| chr5 | 118 |
| chr6 | 135 |
| chr7 | 82 |
| chr8 | 111 |
| chr9 | 94 |
| chr10 | 134 |
| chr11 | 116 |
| chr12 | 158 |
| chr13 | 5 |
| chr14 | 125 |
| chr15 | 72 |
| chr16 | 164 |
| chr17 | 141 |
| chr18 | 7 |
| chr19 | 197 |
| chr20 | 102 |
| chr21 | 0 |
| chr22 | 101 |
| chrX | 6 |
| **Total** | **2,495** |


*Calculate the BAF*:
1. Genome-wide folded B-allele fraction 
<img width="4770" height="1770" alt="MCF7_pseudobulk_genomewide_RNA_BAF" src="https://github.com/user-attachments/assets/9ab8d556-edce-49a2-9a43-89548e15f6ac" />


2. Genome-wide folded minor-allele fraction (MAF)
<img width="4770" height="1770" alt="MCF7_pseudobulk_genomewide_RNA_MAF" src="https://github.com/user-attachments/assets/e5006308-7f87-421f-8cd0-1025dc584188" />
MAF ≈ 0.5 → balanced RNA allelic expression
MAF ≈ 0.33 → potentially compatible with a 2:1 allelic ratio
MAF ≈ 0.25 → potentially compatible with 3:1
MAF → 0 → extreme imbalance / monoallelic expression

For sufficiently covered SNPs, RNA allele fraction is calculated as:

    ALT / (REF + ALT)

Regional deviations from balanced allele ratios are then evaluated as potential CNA signals.




## RNA Allelic-Imbalance Visualization

Known MCF7 heterozygous SNPs with **REF+ALT RNA depth ≥10×** were used for allelic-imbalance analysis (2,495 SNPs).

### 1. RNA BAF distribution
<img width="2370" height="1470" alt="04_RNA_BAF_histogram_depth10" src="https://github.com/user-attachments/assets/0c1186a5-6dc7-4f06-a329-af83237f0f84" />


### 2. Genome-wide RNA BAF

RNA B-allele fraction was calculated as:

\[
BAF = \frac{ALT}{REF+ALT}
\]

BAF = 0.5 represents balanced REF/ALT expression, while values approaching 0 or 1 indicate increasing allelic imbalance.

### 3. Genome-wide RNA MAF

BAF was folded into minor-allele fraction:

\[
MAF = \min(BAF,1-BAF)
\]

MAF ranges from **0–0.5**, with lower values indicating stronger allelic imbalance.



*Additional plots*
### 4. Regional MAF

A **25-SNP rolling median** was added to the genome-wide MAF plot, and **15-SNP rolling medians** were generated for individual chromosomes. These help identify regional allelic-imbalance patterns that may correspond to CNAs.

### 5. Chromosome-Level MAF

Boxplots summarize MAF distributions across chromosomes, allowing chromosome-wide differences in allelic imbalance to be compared.



### 6. Depth Sensitivity

Genome-wide MAF was compared at **≥10×, ≥20×, ≥30×, and ≥50×** coverage to assess whether regional patterns remain stable with increasing read-depth stringency.


The next step is to compare these RNA allelic-imbalance patterns with an independent **MCF7 DNA allele-specific copy-number profile**.
