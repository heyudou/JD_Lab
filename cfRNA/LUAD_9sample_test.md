# cfRNA Cancer Detection: TCGA-LUAD Allelic-Imbalance Validation

## Objective

Test whether allelic imbalance (AI) can be detected from cfRNA by first validating the approach in TCGA lung adenocarcinoma (LUAD) samples spanning different levels of copy-number alteration.

## Cohort selection

This cBioPortal [clinical table](https://www.cbioportal.org/study/clinicalData?id=luad_tcga_pan_can_atlas_2018) contained **500 primary-tumor samples with nonmissing FGA values**. Samples were divided into FGA tertiles and three were randomly selected from each tertile using random seed `20260911`.

| FGA group | FGA range | Eligible samples |
| --- | ---: | ---: |
| Low | ≤0.1503 | 167 |
| Intermediate | 0.1504–0.3305 | 166 |
| High | >0.3305 | 167 |

## Selected samples

| FGA group | TCGA sample ID | TCGA case ID | FGA |
| --- | --- | --- | ---: |
| Low | TCGA-86-A4P8-01 | TCGA-86-A4P8 | 0.0001 |
| Low | TCGA-86-7714-01 | TCGA-86-7714 | 0.0639 |
| Low | TCGA-05-4430-01 | TCGA-05-4430 | 0.0992 |
| Intermediate | TCGA-67-4679-01 | TCGA-67-4679 | 0.1694 |
| Intermediate | TCGA-55-7283-01 | TCGA-55-7283 | 0.2525 |
| Intermediate | TCGA-93-8067-01 | TCGA-93-8067 | 0.3251 |
| High | TCGA-62-A471-01 | TCGA-62-A471 | 0.4409 |
| High | TCGA-69-7973-01 | TCGA-69-7973 | 0.4716 |
| High | TCGA-L4-A4E5-01 | TCGA-L4-A4E5 | 0.5246 |

All nine samples are labeled `Primary` with `Matched` somatic status in cBioPortal. Availability of tumor WXS, matched-normal WXS, and tumor RNA-seq BAM files must be confirmed in GDC before the cohort is finalized.

## Immediate next steps

1. Confirm tumor WXS, matched-normal WXS, and tumor RNA-seq BAM availability in GDC.
2. Replace any sample missing a required data type with another reproducibly selected sample from the same FGA tertile.
3. Run the AI-detection workflow.
4. Compare detected AI across the low-, intermediate-, and high-FGA groups.
