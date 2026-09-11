# cfRNA Cancer Detection: TCGA-LUAD Allelic-Imbalance Validation

## Objective

Test whether allelic imbalance (AI) can be detected from cfRNA by first validating the approach in TCGA lung adenocarcinoma (LUAD) samples spanning different levels of copy-number alteration.

## Initial cohort selection

Select [**9 TCGA-LUAD samples**](https://www.cbioportal.org/study/clinicalData?id=luad_tcga_pan_can_atlas_2018) using fraction of genome altered (FGA) values from the cBioPortal sample table:

| FGA group | Selection | Samples |
| --- | --- | ---: |
| Low | Randomly select 3 samples from the lowest FGA third | 3 |
| Intermediate | Randomly select 3 samples from the middle FGA third | 3 |
| High | Randomly select 3 samples from the highest FGA third | 3 |

Within each FGA group, samples will be selected randomly using a recorded random seed so that the selection is reproducible. Only samples with the required matched data for AI analysis will be eligible.

## Immediate next steps

1. Export the TCGA-LUAD sample table and FGA values from cBioPortal.
2. Confirm availability of the required DNA and RNA-seq data.
3. Divide eligible samples into FGA tertiles.
4. Randomly select three samples per tertile and record the seed and selected sample IDs.
5. Run the AI-detection workflow and compare results across the low-, intermediate-, and high-FGA groups.

## Cohort record

| FGA group | TCGA case/sample ID | FGA | DNA available | RNA available | Included |
| --- | --- | ---: | --- | --- | --- |
| Low | TBD | TBD | TBD | TBD | TBD |
| Low | TBD | TBD | TBD | TBD | TBD |
| Low | TBD | TBD | TBD | TBD | TBD |
| Intermediate | TBD | TBD | TBD | TBD | TBD |
| Intermediate | TBD | TBD | TBD | TBD | TBD |
| Intermediate | TBD | TBD | TBD | TBD | TBD |
| High | TBD | TBD | TBD | TBD | TBD |
| High | TBD | TBD | TBD | TBD | TBD |
| High | TBD | TBD | TBD | TBD | TBD |
