## Normal vs Cancer genomic differences summary plots

Tissues: \
Bladder, Endometrium and Oral

Subplots:
1. Fraction of genome altered.
2. RNA expression levels
3. Certain driver gene mutation frequency
4. \# of driver genes


FGA Figure
<img width="1500" height="975" alt="Endometrium_Bladder_Oral_FGA_stacked_bar_page-0001" src="https://github.com/user-attachments/assets/f434ca63-2501-4284-9528-ed8ef32e4a4c" />


Cancer FGA data source
TCGA PanCancer data 2018:
Clinical data download from:
[BLCA](https://www.cbioportal.org/study/clinicalData?id=blca_tcga_pan_can_atlas_2018)
[UCEC](https://www.cbioportal.org/study/clinicalData?id=ucec_tcga_pan_can_atlas_2018)
[HNSC](https://www.cbioportal.org/study/clinicalData?id=hnsc_tcga_pan_can_atlas_2018)


cBioportal FGA calculation approach:

FGA alteration aresegments with mean log2 copy number(seg.mean) value greater than 0.2 or less than -0.2 for

FGA in the clinical table is calculated based on the copy number segment data -- it is the fraction of genome that has mean log2 copy number value greater than 0.2 or less than -0.2 for each patient. 

seg.mean = log2​ (tumor copy signal​ / reference copy signal)​

Ideally needs CNV segmentation files to calculate, the file should contain:\
Sample\
Chromosome\
Start\
End\
Num_Probes\
Segment_Mean\


Sources:
\
[Nikolaus Schultz, 2024, threshold = 0.2](https://groups.google.com/g/cbioportal/c/vAmCgG44ge0?utm_source=chatgpt.com) \
[Nikolaus Schultz, 2020, threshold = 0.1](https://groups.google.com/g/cbioportal/c/SqtGhn-AZ4s?utm_source=chatgpt.com)\
[Robert Sheridan, 2019, threshold = 0.2](https://groups.google.com/g/cbioportal/c/oWO1LFXGHHs?utm_source=chatgpt.com)\
[JJ Gao, 2018. threshold = 0.2](https://groups.google.com/g/cbioportal/c/oTNy7Ip6xK0?utm_source=chatgpt.com)



