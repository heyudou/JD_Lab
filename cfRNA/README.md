# Detecting cancer in cfRNA

Goal: To detect cancer specific changes in the RNA, to detect aneuploidy, higher variant allele fraction for driver gene mutations.



## Table of Contents

- [MCF7 cell lines for proof of concept] (#MCF7 cell lines for proof of concept)
- [Getting Started](#getting-started)


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



### RNA Allelic-Imbalance Visualization

Known MCF7 heterozygous SNPs with **REF+ALT RNA depth ≥10×** were used for allelic-imbalance analysis (2,495 SNPs).

### 1. RNA BAF distribution
<img width="2370" height="1470" alt="04_RNA_BAF_histogram_depth10" src="https://github.com/user-attachments/assets/0c1186a5-6dc7-4f06-a329-af83237f0f84" />


### 2. Genome-wide RNA BAF
<img width="4770" height="1770" alt="MCF7_pseudobulk_genomewide_RNA_BAF" src="https://github.com/user-attachments/assets/9ab8d556-edce-49a2-9a43-89548e15f6ac" />
RNA B-allele fraction was calculated as:

\[
BAF = \frac{ALT}{REF+ALT}
\]

BAF = 0.5 represents balanced REF/ALT expression, while values approaching 0 or 1 indicate increasing allelic imbalance.

### 3. Genome-wide RNA MAF
<img width="4770" height="1770" alt="MCF7_pseudobulk_genomewide_RNA_MAF" src="https://github.com/user-attachments/assets/e5006308-7f87-421f-8cd0-1025dc584188" />
MAF ≈ 0.5 → balanced RNA allelic expression
MAF ≈ 0.33 → potentially compatible with a 2:1 allelic ratio
MAF ≈ 0.25 → potentially compatible with 3:1
MAF → 0 → extreme imbalance / monoallelic expression
BAF was folded into minor-allele fraction:

    ALT / (REF + ALT)

MAF ranges from **0–0.5**, with lower values indicating stronger allelic imbalance.



*Additional plots*
### 4. Regional MAF

A **25-SNP rolling median** was added to the genome-wide MAF plot, and **15-SNP rolling medians** were generated for individual chromosomes. These help identify regional allelic-imbalance patterns that may correspond to CNAs.

### 5. Chromosome-Level MAF

Boxplots summarize MAF distributions across chromosomes, allowing chromosome-wide differences in allelic imbalance to be compared.



### 6. Depth Sensitivity

Genome-wide MAF was compared at **≥10×, ≥20×, ≥30×, and ≥50×** coverage to assess whether regional patterns remain stable with increasing read-depth stringency.



2 strongest candidates for potential CNV
### Strongest Candidate Regions of Regional Allelic Imbalance

Two regions showed the clearest combination of **dense SNP coverage** and a **sustained regional shift in RNA MAF**:

- **chr19: ~10–20 Mb**  
  RNA MAF is consistently shifted toward approximately **0.2–0.3** across multiple neighboring SNPs, suggesting a strong regional allelic-imbalance signal. :contentReference[oaicite:0]{index=0}

<img width="3269" height="1320" alt="chr19_MAF_rolling15_depth10" src="https://github.com/user-attachments/assets/36e21934-4b1e-4bfb-a0a0-0dfe7f06b614" />

- **chr2: ~225–245 Mb**  
  A dense cluster of informative SNPs shows a coordinated decrease in RNA MAF from approximately **0.45 toward ~0.28** near the distal end of chromosome 2. :contentReference[oaicite:1]{index=1}

<img width="3264" height="1320" alt="chr2_MAF_rolling15_depth10" src="https://github.com/user-attachments/assets/13924b33-a500-48ba-9d6b-d843f439ee47" />


These regions are considered **candidate allele-specific genomic alterations**, not definitive CNV calls, until validated against an independent DNA copy-number reference.



Next Step: compare these RNA allelic-imbalance patterns with an independent **MCF7 DNA allele-specific copy-number profile**. Also obtain more MCF7 heterozygous sites.


## HCC1395 cell lines for proof of concept

### Design

**Strategy**: Use triple-negative breast cancer (TNBC) cell line (HCC1395) and a B lymphocyte-derived normal cell line (HCC1395BL) from the same donor from the American Type Culture Collection (ATCC).


**Rationale**: Find matched trio: tumor and normal DNA seq and RNA seq from the same donor.


**Source**: From [publication](chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/https://wjarr.com/sites/default/files/fulltext_pdf/WJARR-2026-0887.pdf?utm_source=chatgpt.com) Table 2.

Replication of the chromosome-arm allelic-imbalance analysis from Yizhak et al.



### Goal

The purpose of this analysis is to test whether **RNA-seq can recover copy-number-associated allelic imbalance observed in tumor DNA**.

The analysis is based on the allelic-imbalance approach used by Yizhak et al. in Figure S15.

The basic idea is:

1. Identify germline heterozygous SNPs from matched normal DNA.
2. Measure REF and ALT allele fractions at those same SNPs in tumor DNA.
3. Measure REF and ALT allele fractions at those same SNPs in tumor RNA.
4. Group SNPs by chromosome arm.
5. Determine whether chromosome-arm allelic imbalance observed in tumor DNA is reproduced in RNA.

The HCC1395 breast cancer cell line was used as a proof-of-concept because matched normal WES, tumor WES, and tumor RNA-seq data are available.

---

# 1. Input datasets

Three sequencing datasets were used.

| SRA run | Sample | Assay | Role |
|---|---|---|---|
| SRR7890845 | HCC1395BL | WES | matched normal DNA |
| SRR7890844 | HCC1395 | WES | tumor DNA |
| SRR9134727 | HCC1395 | RNA-seq | tumor RNA |

FASTQs:

```text
fastq/
├── SRR7890844_1.fastq.gz
├── SRR7890844_2.fastq.gz
├── SRR7890845_1.fastq.gz
├── SRR7890845_2.fastq.gz
├── SRR9134727_1.fastq.gz
└── SRR9134727_2.fastq.gz
```

The WES reads were 126-bp paired-end reads.

The RNA-seq reads were 76-bp paired-end reads.

---

# 2. Reference genome

All analyses used GRCh38.

Shared reference directory:

```text
/projects/csf_cfrna_projects/phe/reference/
```

Important files included:

```text
genome/
    GRCh38.primary_assembly.genome.fa

annotation/
    gencode.v50.primary_assembly.annotation.gtf
    gencode.v50.primary_assembly.exons.GRCh38.bed

star_index/

chromosome_arms/
    chromosome_arms_GRCh38.bed
```

The chromosome-arm BED contains the 44 autosomal chromosome arms:

```text
1p
1q
2p
2q
...
22p
22q
```

For WES variant calling, analysis was restricted to:

```text
gencode.v50.primary_assembly.exons.GRCh38.bed
```

rather than traversing the entire genome.

Note that this BED represents GENCODE exon regions and is not the original sequencing kit's capture BED.

---

# 3. Overall workflow

```text
                     HCC1395BL
                    Normal WES
                   SRR7890845
                        │
                        ▼
                    BWA-MEM
                        │
                        ▼
                 MarkDuplicates
                        │
                        ▼
               GATK HaplotypeCaller
               exon-restricted GRCh38
                        │
                        ▼
               Germline SNP calling
                        │
                        ▼
          Select heterozygous SNPs
                        │
                        ▼
                  62,227 SNPs
                        │
                        ▼
                  DP >= 10
                  GQ >= 20
                        │
                        ▼
                  49,261 SNPs
                        │
              ┌─────────┼─────────┐
              │         │         │
              ▼         ▼         ▼
          Normal WES  Tumor WES  Tumor RNA
                      HCC1395    HCC1395
                        │         │
                        └────┬────┘
                             ▼
                      samtools mpileup
                             │
                             ▼
                       REF/ALT counts
                             │
                             ▼
                        Allele fraction
                             │
                             ▼
                   Yizhak-style filters
                             │
                   Normal AF 0.05–0.95
                       RNA DP >= 10
                             │
                             ▼
                       9,688 SNPs
                             │
                             ▼
                  chromosome-arm assignment
                             │
                             ▼
                       9,670 SNPs
                             │
                 ┌───────────┴───────────┐
                 ▼                       ▼
             Tumor DNA                Tumor RNA
            allele fraction          allele fraction
                 │                       │
                 └───────────┬───────────┘
                             ▼
                chromosome-arm comparison
```

---

# 4. DNA alignment

Tumor and normal WES reads were aligned against GRCh38 using:

```text
BWA 0.7.17
```

The resulting coordinate-sorted BAMs were:

```text
bam/tumor_WES/HCC1395.sorted.bam
bam/normal_WES/HCC1395BL.sorted.bam
```

Read groups were included during alignment so the BAMs could be processed correctly by GATK.

---

# 5. Duplicate marking

PCR/optical duplicates were marked using:

```text
GATK 4.6.2.0 MarkDuplicates
```

The analysis-ready WES BAMs were:

```text
bam/tumor_WES/HCC1395.markdup.bam
bam/normal_WES/HCC1395BL.markdup.bam
```

---

# 6. RNA alignment

HCC1395 RNA-seq was aligned using:

```text
STAR 2.7.11b
```

against the GRCh38 STAR index.

Output BAM:

```text
bam/tumor_RNA/SRR9134727.Aligned.sortedByCoord.out.bam
```

RNA alignment statistics were:

| Metric | Result |
|---|---:|
| Input reads | 30,200,567 |
| Uniquely mapped | 85.08% |
| Multiple loci | 11.18% |
| Unmapped: too short | 3.56% |
| Unmapped: too many mismatches | 0.00% |
| Other unmapped | 0.07% |

Thus, the RNA-seq alignment provided sufficient mapped reads for allele-specific analysis.

---

# 7. Germline variant calling

Germline variants were identified from the matched normal:

```text
HCC1395BL
```

using GATK HaplotypeCaller followed by GenotypeGVCFs.

Importantly, variant calling was restricted to the exon BED:

```bash
-L gencode.v50.primary_assembly.exons.GRCh38.bed
```

This substantially reduced computation compared with traversing the complete GRCh38 genome.

Outputs:

```text
results/germline_exome/
├── HCC1395BL.exome.g.vcf.gz
└── HCC1395BL.exome.raw.vcf.gz
```

---

# 8. Selection of heterozygous SNPs

Only:

- SNPs
- biallelic sites
- heterozygous genotypes in HCC1395BL

were retained.

The genotype was explicitly selected using:

```text
vc.getGenotype("HCC1395BL").isHet()
```

This produced:

```text
62,227 heterozygous SNPs
```

The normal WES heterozygous calls had:

```text
Median DP = 47
Median GQ = 99
```

indicating generally strong sequencing support.

---

# 9. Germline SNP quality control

An additional technical QC filter was applied before using the germline SNPs for allele counting.

Required:

```text
DP >= 10
GQ >= 20
```

Results:

| Filter | SNPs |
|---|---:|
| Initial heterozygous SNPs | 62,227 |
| DP >= 10 | 49,371 |
| GQ >= 20 | 61,671 |
| GQ >= 30 | 59,911 |
| DP >= 10 AND GQ >= 20 | **49,261** |

Therefore:

```text
49,261
```

high-confidence germline heterozygous SNPs were carried forward.

The filtered VCF was:

```text
HCC1395BL.exome.het_snps.DP10_GQ20.vcf.gz
```

---

# 10. Allele counting

The same 49,261 germline heterozygous positions were interrogated in:

```text
HCC1395BL normal WES
HCC1395 tumor WES
HCC1395 tumor RNA
```

using:

```text
samtools mpileup
```

with:

```text
minimum mapping quality = 20
minimum base quality    = 20
```

The three pileups were:

```text
HCC1395BL.normal_WES.mpileup
HCC1395.tumor_WES.mpileup
HCC1395.tumor_RNA.mpileup
```

This approach is important because the RNA was **not independently variant-called**.

Instead, RNA was queried only at germline heterozygous positions already identified from matched normal DNA.

---

# 11. REF and ALT allele fractions

For each SNP, REF and ALT supporting reads were counted.

Allele fraction was calculated as:

\[
AF = \frac{ALT}{REF + ALT}
\]

This was calculated independently for:

```text
normal WES
tumor WES
tumor RNA
```

The resulting table was:

```text
results/allele_counts/HCC1395.all_allele_counts.tsv
```

---

# 12. Yizhak-style filtering

The downstream analysis followed the filtering logic described by Yizhak et al.

Sites were required to have:

```text
Normal DNA AF >= 0.05
Normal DNA AF <= 0.95
RNA depth >= 10
```

Results:

| Stage | SNPs |
|---|---:|
| High-confidence germline heterozygous SNPs | 49,261 |
| Pass normal DNA AF 0.05–0.95 | 48,934 |
| RNA DP >= 10 | 9,703 |
| Pass both filters | **9,688** |

Thus, approximately 19.7% of the high-confidence WES heterozygous SNPs had sufficient RNA coverage for the final comparison.

Final filtered table:

```text
results/allele_counts/HCC1395.Yizhak_filtered.tsv
```

---

# 13. Minor-allele fraction

For chromosome-arm-level allelic-imbalance analysis, allele fractions were transformed to:

\[
minAF = \min(AF,\;1-AF)
\]

Therefore:

```text
AF = 0.50  -> minAF = 0.50
AF = 0.40  -> minAF = 0.40
AF = 0.20  -> minAF = 0.20
AF = 0.05  -> minAF = 0.05
AF = 0.95  -> minAF = 0.05
```

Interpretation:

```text
minAF ≈ 0.5
    │
    └── balanced heterozygosity

minAF approaching 0
    │
    └── strong allelic imbalance
```

This transformation allows REF-dominant and ALT-dominant imbalance to be summarized using the same statistic.

---

# 14. Chromosome-arm assignment

Each SNP was assigned to one of the 44 autosomal chromosome arms using:

```text
chromosome_arms_GRCh38.bed
```

Of the 9,688 filtered SNPs:

```text
9,670
```

were retained in the final autosomal chromosome-arm SNP table.

The final SNP-level table was:

```text
results/allelic_imbalance/HCC1395.S15.snp_level.tsv
```

Thus, the DNA and RNA plots use exactly the **same 9,670 genomic SNP positions**.

This paired design is important: differences between the DNA and RNA plots therefore cannot be explained simply by plotting different SNP sets.

---

# 15. Chromosome-arm summary

For each chromosome arm, mean `minAF` was calculated separately for:

```text
normal DNA
tumor DNA
tumor RNA
```

Output:

```text
results/allelic_imbalance/
HCC1395.S15.chromosome_arm_summary.tsv
```

The major question was whether chromosome arms showing low tumor-DNA `minAF` also showed low tumor-RNA `minAF`.

---

# 16. DNA–RNA chromosome-arm correlation

To avoid unstable estimates from chromosome arms represented by very few SNPs, correlation analysis was restricted to arms with:

```text
>= 10 informative SNPs
```

This resulted in:

```text
39 chromosome arms
```

used for the quantitative DNA–RNA comparison.

The observed agreement was:

```text
Pearson r  = 0.987
Spearman ρ = 0.974
```

This represents extremely strong concordance between tumor-DNA and tumor-RNA chromosome-arm allelic imbalance in HCC1395.

---

# 17. Figure S15-style visualization

The final visualization contains three panels.

## Panel A — Tumor DNA

Plots allele fraction for each of the 9,670 informative SNPs across chromosomes 1–22.

Y-axis:

```text
Tumor DNA allele fraction
0 ─────────────── 1
```

Individual dots represent SNPs.

Chromosome-arm-level averages are overlaid.

---

## Panel B — Tumor RNA

Plots RNA allele fraction at the **same 9,670 SNP positions**.

Therefore:

```text
Tumor DNA: 9,670 dots
Tumor RNA: 9,670 dots
```

This permits direct visual comparison between DNA and RNA allelic imbalance.

---

## Panel C — DNA versus RNA chromosome-arm imbalance

Each point represents a chromosome arm.

X-axis:

```text
Tumor DNA mean min(AF, 1-AF)
```

Y-axis:

```text
Tumor RNA mean min(AF, 1-AF)
```

Arms with at least 10 SNPs are included.

The strong DNA–RNA correlation demonstrates that chromosome-arm allelic imbalance measured from DNA can be recovered from RNA.

---

# 18. Interpretation

The analysis provides a proof of concept that RNA-seq contains strong information about chromosome-scale allelic imbalance.

The expected behavior is:

```text
Matched normal DNA

REF  ██████████
ALT  ██████████

AF ≈ 0.5
        │
        ▼
balanced heterozygosity
```

If a tumor undergoes allele-specific copy-number alteration:

```text
Tumor DNA

REF  █████████████████
ALT  ███

AF shifts away from 0.5
        │
        ▼
allelic imbalance
```

If RNA molecules transcribed from that chromosome preserve the underlying imbalance:

```text
Tumor RNA

REF  ███████████████
ALT  ███

RNA AF also shifts away from 0.5
```

The strong chromosome-arm correlation observed in HCC1395 supports this model.

---

# 19. Important limitations

This experiment is a proof of concept and does not by itself establish that RNA allele fractions are direct measurements of DNA copy number.

RNA allelic fractions can also be affected by:

- allele-specific expression
- transcriptional regulation
- RNA editing
- mapping bias
- expression level
- stochastic sampling at low RNA depth
- nonsense-mediated decay
- imprinting
- cis-regulatory variation

The purpose of aggregating many heterozygous SNPs across a chromosome arm is to reduce the influence of individual locus-specific effects.

Another limitation is that the exome intervals were generated from GENCODE v50 rather than from the exact historical WES capture kit.

---

# 20. Key result

The complete workflow reduced:

```text
62,227
raw heterozygous SNPs
        │
        ▼
49,261
high-confidence germline SNPs
DP >= 10, GQ >= 20
        │
        ▼
9,688
normal-AF + RNA-depth filtered SNPs
        │
        ▼
9,670
autosomal chromosome-arm SNPs
        │
        ▼
39 chromosome arms with >=10 SNPs
        │
        ▼
DNA vs RNA allelic imbalance
        │
        ├── Pearson r  = 0.987
        └── Spearman ρ = 0.974
```

Therefore, in the HCC1395 system, **RNA-seq recapitulates the chromosome-arm allelic-imbalance signal observed in tumor DNA with very high concordance**.

This provides a strong proof of concept for using RNA-derived allelic imbalance as a signal associated with underlying tumor genomic copy-number alterations.





# Reproduction of Yizhak et al. Figure S15

Original S15

<img width="599" height="569" alt="S15" src="https://github.com/user-attachments/assets/f956437c-00e2-46a8-bdce-a41f46e09866" />


Replicated:

<img width="8404" height="6450" alt="TCGA_S15_alt3_all_cases" src="https://github.com/user-attachments/assets/300609b2-d7c0-4e22-907e-6b3b50e28a9a" />

This project reproduces the allelic-imbalance (AI) analysis shown in **Figure S15 of Yizhak et al.**, comparing allele fractions (AF) measured from matched normal DNA, tumor DNA, and tumor RNA.

Four TCGA cases shown in the original figure were analyzed:

- **CESC-DS-A0VK (A)**
- **CESC-FU-A23K (B)**
- **KIRC-AK-3447 (C)**
- **LUAD-05-4398 (D)**

## Workflow

Matched normal WXS, tumor WXS, and tumor RNA-seq BAMs were obtained from GDC.

Germline heterozygous SNPs were identified from normal DNA using GATK HaplotypeCaller. REF/ALT read counts were then measured at these positions in normal DNA, tumor DNA, and tumor RNA.

For each SNP:

`AF = ALT / (REF + ALT)`

For chromosome-arm AI analysis, AF was folded around 0.5:

`minAF = min(AF, 1 - AF)`

and the mean `minAF` was calculated for each chromosome arm.

Lower arm-level mean `minAF` indicates stronger allelic imbalance.

---

## Calling Allelic Imbalance

A major distinction between the reproduction and the original analysis is how an arm is classified as **allelically imbalanced**.

### Original Yizhak method

Yizhak et al. did **not use a universal AF or mean-minAF threshold**.

Instead, they examined the empirical distribution of mean `minAF` for each chromosome arm across thousands of GTEx samples.

The study analyzed **6,729 GTEx samples**, excluded 329 samples with excessive AI, and fitted an arm-specific **beta distribution** using samples containing at least 100 heterozygous sites.

The procedure was approximately:

```text
Individual heterozygous SNPs
            │
            ▼
       Calculate AF
            │
            ▼
   min(AF, 1 - AF)
            │
            ▼
Mean minAF for chromosome arm
            │
            ▼
Empirical distribution of that arm
across thousands of GTEx samples
            │
            ▼
 Fit arm-specific beta distribution
            │
            ▼
 Calculate one-sided P value
            │
            ▼
   Multiple-testing correction
            │
            ▼
          Q < 0.05
            │
            ▼
     Allelic imbalance
```



## RNA-only SNP Panel Construction and chr22 Test

To identify candidate heterozygous sites from RNA-seq without matched DNA, we constructed a population-based SNP panel from `Homo_sapiens_assembly38.dbsnp138.vcf`.

### Population SNP filtering

Starting from the whole-genome dbSNP138 VCF:

| Filtering step | SNPs remaining |
|---|---:|
| All dbSNP records | 60,691,395 |
| Autosomal records (chr1–22) | 58,373,860 |
| Biallelic SNVs | 51,049,361 |
| Sites with 1000 Genomes CAF | 36,545,720 |
| MAF ≥ 0.20 | 3,274,054 |
| Unique MAF ≥ 0.20 SNP positions | 3,274,045 |
| Within GENCODE v50 exons MAF ≥ 0.20 SNP positions| **205,511** |
| Within GENCODE v50 exons ≥ 0.15 SNP positions| **255,051** |
| Within GENCODE v50 exons ≥ 0.10 SNP positions| **318,004** |
| Within GENCODE v50 exons ≥ 0.05 SNP positions| **418,124** |

The final population panel therefore contains **205,511 common, exonic, biallelic SNPs** with MAF ≥ 0.20.

**Generating Biallelic SNVs**

Starting with 58,373,860 autosomal dbSNP records (chr1–22), variants were restricted to biallelic single-nucleotide variants (SNVs). Records were excluded if they were:

Multiallelic: more than one alternative allele (e.g., REF=A, ALT=G,T)
Insertions: ALT contains additional bases (e.g., REF=A, ALT=AT)
Deletions: REF contains additional bases (e.g., REF=AT, ALT=A)
MNVs or other non-SNV variants: both alleles span multiple bases (e.g., REF=AC, ALT=GT)
Non-standard alleles: REF or ALT contains bases other than A, C, G, or T

After filtering, 51,049,361 biallelic SNVs remained.




### Chromosomal distribution of candidate SNPs

The 205,511 exonic candidate SNPs were distributed across the 22 autosomes as follows:

| Chromosome | Candidate SNPs | Chromosome | Candidate SNPs |
|---|---:|---|---:|
| chr1 | 17,720 | chr12 | 10,660 |
| chr2 | 15,405 | chr13 | 5,579 |
| chr3 | 12,014 | chr14 | 7,220 |
| chr4 | 10,682 | chr15 | 7,271 |
| chr5 | 10,742 | chr16 | 7,948 |
| chr6 | 14,688 | chr17 | 8,858 |
| chr7 | 10,828 | chr18 | 4,964 |
| chr8 | 8,833 | chr19 | 10,841 |
| chr9 | 7,949 | chr20 | 5,018 |
| chr10 | 8,963 | chr21 | 3,203 |
| chr11 | 11,251 | chr22 | **4,874** |
| **Total** |  |  | **205,511** |

Chromosome 22 contains **4,874 candidate SNPs** and was selected for the initial proof-of-concept RNA allele-counting test.

### chr22 test — TCGA-05-4398 RNA-seq

Chromosome 22 was used as an initial test of the RNA-only allele-counting workflow. The exonic population panel contained **4,874 candidate SNPs on chr22**. RNA REF/ALT counts were obtained from the TCGA-05-4398 RNA-seq BAM using `samtools mpileup` with mapping quality ≥20 and base quality ≥20.

```text
Candidate SNPs on chr22:           4,874
Sites reported by mpileup:         3,760
Reference mismatches removed:          0
Sites with REF/ALT coverage:       2,816
Sites with DP >= 10:               1,243
DP >= 10 + AF 0.05-0.95:            463

Mean raw ALT AF:                  0.4654
Mean minAF:                       0.2764
```

The result captured the alelle imbalance from previosu plot:
```test
===== Plot summary =====
Sample:          TCGA-05-4398
Chromosome:      chr22
Sites plotted:   463
Mean minAF:      0.2764
Mean lower AF:   0.2520
Mean upper AF:   0.7055
```

[chr22_AI.pdf](https://github.com/user-attachments/files/31805576/chr22_AI.pdf)




## DCB Allelic Imbalance Analysis in TCGA RNA-seq

### Project Rationale

This project tests whether **allelic imbalance (AI) at common transcribed SNPs within cancer-associated dark channel biomarker (DCB) genes** can provide an additional signal for cancer detection. The 19 lung/breast DCB genes identified by Larson et al. have very low expression in normal cfRNA but are detectable in cancer. We therefore test whether allele-specific expression within these cancer-associated transcripts can provide an orthogonal signal of tumor origin.

Candidate SNP panels were generated from dbSNP138/1000 Genomes by selecting biallelic exonic SNPs at population MAF thresholds of **5%, 10%, 15%, and 20%**. The MAF threshold is used to enrich for SNPs likely to be heterozygous in an individual; population allele frequency is **not** treated as the expected RNA allelic ratio.

### Initial RNA Coverage Assessment

As a first test, the four TCGA RNA-seq samples previously analyzed for allelic imbalance were examined for coverage at the DCB SNPs. Because the higher-MAF panels are subsets of the MAF5 panel, `samtools mpileup` was performed once across the **198 MAF≥5% candidate SNPs**, and the results were subsequently filtered to the MAF10, MAF15, and MAF20 panels.

RNA coverage was sufficient to support further allele-specific analysis. At **MAF≥5% and RNA depth ≥10**, the four samples contained **109, 46, 42, and 48 covered candidate SNPs**, respectively. In comparison, restricting to MAF≥20% reduced these numbers to **37, 18, 11, and 17**.

These results indicate that lowering the population MAF threshold substantially increases the number of potentially informative DCB loci while retaining adequate RNA coverage. The next step is to quantify **REF and ALT read counts** at these covered sites and identify candidate allelic imbalance, followed by comparison with matched DNA genotypes to distinguish true heterozygous loci from homozygous sites.


### DCB SNP Coverage by MAF Threshold

| TCGA Case | MAF ≥5% | MAF ≥10% | MAF ≥15% | MAF ≥20% |
|---|---:|---:|---:|---:|
| **TCGA-05-4398** | 109 / 198 (55.1%) | 75 / 141 (53.2%) | 56 / 110 (50.9%) | 37 / 86 (43.0%) |
| **TCGA-AK-3447** | 46 / 198 (23.2%) | 30 / 141 (21.3%) | 22 / 110 (20.0%) | 18 / 86 (20.9%) |
| **TCGA-DS-A0VK** | 42 / 198 (21.2%) | 31 / 141 (22.0%) | 23 / 110 (20.9%) | 11 / 86 (12.8%) |
| **TCGA-FU-A23K** | 48 / 198 (24.2%) | 36 / 141 (25.5%) | 29 / 110 (26.4%) | 17 / 86 (19.8%) |

**Table:** Number of candidate DCB SNPs with **RNA depth ≥10**. Values are shown as `covered SNPs / total candidate SNPs (% of panel)`. Lowering the population MAF threshold substantially increases the absolute number of DCB SNPs available for allele-specific analysis. Even at MAF ≥5%, all four samples retain dozens of well-covered loci, with TCGA-05-4398 containing 109 sites at DP ≥10.



## DCB RNA SNP Coverage and Allelic-Imbalance Screening

We screened common SNPs located within the 19 dark-channel biomarker (DCB) genes to determine which loci are observable in tumor RNA and potentially informative for allelic-imbalance (AI) analysis. Four TCGA tumor RNA-seq samples were used for this pilot analysis:

| TCGA case | Cancer type |
|---|---|
| TCGA-05-4398 | Lung adenocarcinoma (LUAD) |
| TCGA-AK-3447 | Kidney renal clear cell carcinoma (KIRC) |
| TCGA-DS-A0VK | Cervical cancer (CESC) |
| TCGA-FU-A23K | Cervical cancer (CESC) |

### Candidate DCB SNP panels

Population-common biallelic SNPs within DCB exons were identified using dbSNP138/1000 Genomes allele frequencies. Four nested SNP panels were generated at different population minor allele frequency (MAF) thresholds:

| Population MAF threshold | Candidate DCB SNPs |
|---|---:|
| ≥5% | 198 |
| ≥10% | 141 |
| ≥15% | 110 |
| ≥20% | 86 |

Lower MAF thresholds provide more candidate SNPs, whereas higher MAF thresholds enrich for SNPs that are more likely to be heterozygous in an individual.

### Initial RNA coverage assessment

The initial analysis used the raw depth (`RNA_DP`) reported by `samtools mpileup`. Using `RNA_DP ≥10`, the following apparent RNA coverage was observed:

| TCGA case | MAF ≥5% | MAF ≥10% | MAF ≥15% | MAF ≥20% |
|---|---:|---:|---:|---:|
| TCGA-05-4398 | 109 / 198 (55.1%) | 75 / 141 (53.2%) | 56 / 110 (50.9%) | 37 / 86 (43.0%) |
| TCGA-AK-3447 | 46 / 198 (23.2%) | 30 / 141 (21.3%) | 22 / 110 (20.0%) | 18 / 86 (20.9%) |
| TCGA-DS-A0VK | 42 / 198 (21.2%) | 31 / 141 (22.0%) | 23 / 110 (20.9%) | 11 / 86 (12.8%) |
| TCGA-FU-A23K | 48 / 198 (24.2%) | 36 / 141 (25.5%) | 29 / 110 (26.4%) | 17 / 86 (19.8%) |

For the MAF ≥5% panel, there are 198 possible SNPs per sample and therefore:

    198 SNPs × 4 samples = 792 possible SNP × sample observations

Of these 792 possibilities, 411 had `RNA_DP > 0`:

    TCGA-05-4398     161
    TCGA-AK-3447      61
    TCGA-DS-A0VK      82
    TCGA-FU-A23K     107
                     ---
    Total            411

Among these 411 observations, 245 had raw `RNA_DP ≥10`:

    TCGA-05-4398     109
    TCGA-AK-3447      46
    TCGA-DS-A0VK      42
    TCGA-FU-A23K      48
                     ---
    Total            245

### Important correction: raw RNA_DP includes splice skips

Inspection of the mpileup data revealed that raw `RNA_DP` is not equivalent to the number of actual RNA nucleotides covering a SNP.

RNA-seq reads frequently contain CIGAR `N` operations representing spliced regions. `samtools mpileup` represents these reference skips as `<` or `>` characters. These reads can contribute to the reported pileup depth even though they do not provide an A, C, G, or T nucleotide at the SNP position.

For example, an AGR2 SNP showed:

    chr7:16802114 G>A

    RNA_DP       = 2697
    REF_COUNT    = 0
    ALT_COUNT    = 0
    REF_ALT_DP   = 0

Thus, thousands of RNA alignments were associated with the genomic coordinate, but they predominantly represented reads splicing across the position rather than actual nucleotide observations at the SNP. The value 2697 represents the number of pileup observations/read skips, not the length of the intron.

This can occur because a position may be annotated as exonic in one transcript isoform while being spliced out in the transcript isoforms predominantly expressed in a particular sample.

For allelic analysis, the appropriate callable RNA depth is therefore:

    REF_ALT_DP = REF_COUNT + ALT_COUNT

rather than raw `RNA_DP`.

### Corrected allele-callable RNA coverage

After counting only actual REF and ALT nucleotides, the number of MAF ≥5% SNP/sample observations with `REF_ALT_DP ≥10` decreased substantially:

| TCGA case | Raw RNA_DP ≥10 | Actual REF+ALT DP ≥10 |
|---|---:|---:|
| TCGA-05-4398 | 109 | 70 |
| TCGA-AK-3447 | 46 | 0 |
| TCGA-DS-A0VK | 42 | 15 |
| TCGA-FU-A23K | 48 | 15 |
| **Total** | **245** | **100** |

Therefore, only 100 of the original 792 possible MAF ≥5% SNP/sample observations had at least 10 actual REF/ALT RNA bases suitable for reliable allele-fraction calculation.

For these sites, RNA minor allele fraction is calculated as:

    RNA minor AF =
        min(REF_COUNT, ALT_COUNT)
        -------------------------
        REF_COUNT + ALT_COUNT

Sites with no actual REF/ALT observations cannot have an RNA minor allele fraction calculated, regardless of how large their raw `RNA_DP` value is.

### Matched-normal DNA further identifies informative SNPs

RNA allelic skew alone does not establish true allelic imbalance because the individual must first be heterozygous at the SNP.

Matched-normal WXS GATK heterozygous calls were therefore intersected with the RNA-callable DCB SNPs. Of the 100 MAF ≥5% SNP/sample observations with `REF_ALT_DP ≥10`, only 8 were confirmed as heterozygous in matched-normal DNA and had sufficient RNA coverage for DNA-versus-RNA AI analysis:

    792 possible DCB SNP/sample combinations
                  ↓
    411 with raw RNA_DP > 0
                  ↓
    245 with raw RNA_DP ≥10
                  ↓
    100 with actual REF+ALT_DP ≥10
                  ↓
      8 matched-normal DNA HET + RNA DP≥10
                  ↓
       DNA-versus-RNA AI testing

The eight evaluable sites consisted of seven SNPs in TCGA-05-4398 and one SNP in TCGA-FU-A23K. No SNPs in TCGA-AK-3447 or TCGA-DS-A0VK simultaneously satisfied the matched-normal heterozygosity and RNA `REF_ALT_DP ≥10` requirements.
