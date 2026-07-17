# Normal vs Cancer genomic differences summary plots

Tissues: \
Bladder, Endometrium and Oral

Subplots:
1. Fraction of genome altered.
2. RNA expression levels
3. Certain driver gene mutation frequency
4. \# of driver genes


FGA Preliminary Figure
<img width="1500" height="975" alt="Endometrium_Bladder_Oral_FGA_stacked_bar_page-0001" src="https://github.com/user-attachments/assets/f434ca63-2501-4284-9528-ed8ef32e4a4c" />


## Cancer FGA data source
TCGA PanCancer data 2018:
Clinical data download from:
[BLCA](https://www.cbioportal.org/study/clinicalData?id=blca_tcga_pan_can_atlas_2018)
[UCEC](https://www.cbioportal.org/study/clinicalData?id=ucec_tcga_pan_can_atlas_2018)
[HNSC](https://www.cbioportal.org/study/clinicalData?id=hnsc_tcga_pan_can_atlas_2018)


cBioportal FGA calculation approach:

"FGA in the clinical table is calculated based on the copy number segment data -- it is the fraction of genome that has mean log2 copy number value greater than 0.2 or less than -0.2 for each patient. " (2018, JJ Gao)

seg.mean = log2​ (tumor copy signal​ / reference copy signal)​

Ideally needs CNV segmentation files to calculate. But based on this definition: \
SV-only samples should remain FGA = 0 \
cnLOH-only samples should remain FGA = 0 


Sources:
\
[Nikolaus Schultz, 2024, threshold = 0.2](https://groups.google.com/g/cbioportal/c/vAmCgG44ge0?utm_source=chatgpt.com) \
[Nikolaus Schultz, 2020, threshold = 0.1](https://groups.google.com/g/cbioportal/c/SqtGhn-AZ4s?utm_source=chatgpt.com)\
[Robert Sheridan, 2019, threshold = 0.2](https://groups.google.com/g/cbioportal/c/oWO1LFXGHHs?utm_source=chatgpt.com)\
[JJ Gao, 2018. threshold = 0.2](https://groups.google.com/g/cbioportal/c/oTNy7Ip6xK0?utm_source=chatgpt.com)



## 2020 Moores et al. Normal Endometrium [paper](https://www.nature.com/articles/s41586-020-2214-z):
*28 women 257 samples* \
"Somatic copy-number changes and structural variants were found in 36 out of 257 (14%) normal endometrial glands, almost all of which carried just a single change"  

24 samples had SV only (FGA=0) \
11 samples had CNV only \
1 sample had both SV and CNV

of the 12 CNV posisitve samples, 8 are cnLOH (FGA=0), 4 had a true segment that can be used to compute for FGA:

| Sample             | Dosage-altered length | Approximate FGA |
| ------------------ | --------------------: | --------------: |
| PD39952b_EMD_15_A3 |              29.59 Mb |           1.03% |
| PD40107b_EMD_18_G4 |              52.69 Mb |           1.83% |
| PD40659c_EMD_19_C1 |              15.01 Mb |           0.52% |
| PD41860b_EMD_G12   |             124.30 Mb |           4.32% |

All unique person(4 out of 28). Sample PD41860b_EMD_G12 have two altered segments.

## 2020 Lawson et al. Normal Urothelium [paper](https://www.science.org/doi/10.1126/science.aba8347)
*We sequenced 2097 bladder microbiopsies from 20 individuals using targeted (n = 1914 microbiopsies), whole-exome (n = 655), and whole-genome (n = 88) sequencing.*

"Copy number alterations were detected in only 28% of urothelial exomes, with the most common changes involving whole or arm-level gains of chromosomes 13, 14, 15, and 16 and losses of chromosomes 9 and 21"

Analysis:

cross-referencing supplementary tables 2 and 6 shows that a total of 70 samples have CNV segments, their sequenicng approaches are:
| Sequencing combination  |                                                 Number of CNV samples |
| ----------------------- | --------------------------------------------------------------------: |
| WES only                |                                                                **64** |
| WES + WGS               |                                                                 **6** |
| WGS only                |                                                                 **0** |
| Targeted only           |                                                                 **0** |

supplmenetary methods indicates exome capture kit: \
Agilent SureSelect Human All Exon V5 bait set \
Catalog number: S04380110

"Only 370 of 655 exomes underwent ASCAT CNV analysis."\
of which 295 were normal urotheliums

50 had at least one reported CNV segment
46 had a dosage-altering CNA 
4 had cnLOH only (FGA=0)


Final FGA table:
| Patient ID | Microbiopsy ID     | Patient / Data Access ID | Sequencing approach | # CNA segs | # cnLOH Segments |  Altered bp | Reconstructed FGA (%) | FGA Bin |
| ---------- | ------------------ | ------------------------ | ------------------- | ---------: | ---------------: | ----------: | --------------------: | ------- |
| C04        | C04_72M_b06_lo0025 | PD38778g_lo0025          | Targeted + WES      |          3 |                0 | 146,381,269 |                 5.08% | 5–20%   |
| T10        | T10_68F_b01_lo0012 | PD43379b_lo0012          | WES + WGS           |          1 |                0 |  77,996,159 |                 2.71% | 0.1–5%  |
| T14        | T14_75F_b01_lo0028 | PD43378b_lo0028          | WES                 |          1 |                0 |  58,976,600 |                 2.05% | 0.1–5%  |
| T12        | T12_70M_b08_lo0015 | PD43303i_lo0015          | Targeted + WES      |         12 |                0 |  46,868,559 |                 1.63% | 0.1–5%  |
| T07        | T07_59M_b01_lo0041 | PD42032b_lo0041          | Targeted + WES      |          5 |                0 |  34,376,059 |                 1.19% | 0.1–5%  |
| T05        | T05_58M_b01_lo0013 | PD43376b_lo0013          | WES                 |          7 |                0 |  24,503,396 |                 0.85% | 0.1–5%  |
| T09        | T09_61M_b05_lo0007 | PD42031f_lo0007          | Targeted + WES      |          3 |                0 |  11,803,250 |                 0.41% | 0.1–5%  |
| T11        | T11_69F_b05_lo0049 | PD40843f_lo0049          | Targeted + WES      |          3 |                0 |  10,595,313 |                 0.37% | 0.1–5%  |
| T04        | T04_55M_b05_lo0009 | PD43377f_lo0009          | WES                 |          2 |                0 |  10,449,267 |                 0.36% | 0.1–5%  |
| T01        | T01_25F_b04_lo0004 | PD40842e_lo0004          | Targeted + WES      |          2 |                1 |   6,413,902 |                 0.22% | 0.1–5%  |
| T08        | T08_61F_b01_lo0165 | PD37726b_lo0165          | Targeted + WES      |          2 |                0 |   6,376,697 |                 0.22% | 0.1–5%  |
| T02        | T02_35F_b05_lo0002 | PD39461f_lo0002          | Targeted + WES      |          1 |                1 |   4,193,516 |                 0.15% | 0.1–5%  |
| T03        | T03_53F_b08_lo0079 | PD40794i_lo0079          | Targeted + WES      |          1 |                0 |   4,089,882 |                 0.14% | 0.1–5%  |
