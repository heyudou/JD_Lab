library(tidyverse)
make_cancer_bins <- function(file, cancer_label, tissue_label) {
  
  tcga <- read_tsv(file, show_col_types = FALSE)
  
  fga_col <- grep("Fraction Genome Altered", names(tcga), value = TRUE)
  
  fga <- tcga %>%
    select(all_of(fga_col)) %>%
    rename(FGA = all_of(fga_col)) %>%
    mutate(FGA = as.numeric(FGA)) %>%
    filter(!is.na(FGA))
  
  fga %>%
    mutate(
      FGA_bin = case_when(
        FGA == 0 ~ "0% (No CNA)",
        FGA > 0 & FGA <= 0.05 ~ ">0–5%",
        FGA > 0.05 & FGA <= 0.20 ~ "5–20%",
        FGA > 0.20 & FGA <= 0.50 ~ "20–50%",
        FGA > 0.50 ~ ">50%"
      )
    ) %>%
    count(FGA_bin) %>%
    mutate(
      Percent = 100 * n / sum(n),
      Group = cancer_label,
      Tissue = tissue_label
    )
}

ucec_bins <- make_cancer_bins(
  file = "ucec_tcga_pan_can_atlas_2018_clinical_data.tsv",
  cancer_label = "UCEC\n(n=519)",
  tissue_label = "Endometrium"
)

blca_bins <- make_cancer_bins(
  file = "blca_tcga_pan_can_atlas_2018_clinical_data.tsv",
  cancer_label = "BLCA\n(n=406)",
  tissue_label = "Bladder"
)

hnsc_bins <- make_cancer_bins(
  file = "hnsc_tcga_pan_can_atlas_2018_clinical_data.tsv",
  cancer_label = "HNSC\n(n=517)",
  tissue_label = "Oral"
)

normal_endo_bins <- tibble(
  Tissue = "Endometrium",
  Group = "Normal Endometrium\n(n=28)",
  FGA_bin = c("0% (No CNA)", ">0–5%", "5–20%", "20–50%", ">50%"),
  n = c(24, 4, 0, 0, 0)
) %>%
  mutate(Percent = 100 * n / sum(n))

normal_bladder_bins <- tibble(
  Tissue = "Bladder",
  Group = "Normal Bladder\n(n=20)",
  FGA_bin = c("0% (No CNA)", ">0–5%", "5–20%", "20–50%", ">50%"),
  n = c(7, 12, 1, 0, 0)
) %>%
  mutate(Percent = 100 * n / sum(n))

normal_oral_bins <- tibble(
  Tissue = "Oral",
  Group = "oral leukoplakia\n(n=89)",
  FGA_bin = c("0% (No CNA)", ">0–5%", "5–20%", "20–50%", ">50%"),
  n = c(28, 61, 0, 0, 0)
) %>%
  mutate(Percent = 100 * n / sum(n))

plot_df <- bind_rows(
  normal_bladder_bins,
  blca_bins,
  normal_endo_bins,
  ucec_bins,
  normal_oral_bins,
  hnsc_bins
)

plot_df$FGA_bin <- factor(
  plot_df$FGA_bin,
  levels = c(
    ">50%",
    "20–50%",
    "5–20%",
    ">0–5%",
    "0% (No CNA)"
  )
)

plot_df <- plot_df %>%
  mutate(
    xpos = case_when(
      Tissue == "Bladder" & Group == "Normal Bladder\n(n=20)" ~ 1,
      Tissue == "Bladder" & Group == "BLCA\n(n=406)" ~ 2,
      
      Tissue == "Endometrium" & Group == "Normal Endometrium\n(n=28)" ~ 4,
      Tissue == "Endometrium" & Group == "UCEC\n(n=519)" ~ 5,
      
      Tissue == "Oral" & Group == "oral leukoplakia\n(n=89)" ~ 7,
      Tissue == "Oral" & Group == "HNSC\n(n=517)" ~ 8
    ),
    text_color = ifelse(
      FGA_bin == "0% (No CNA)",
      "white",
      "black"
    )
  )

fga_colors <- c(
  "0% (No CNA)" = "#65a1f2a6",
  ">0–5%" = "#FFF176",
  "5–20%" = "#FDB863",
  "20–50%" = "#F46D43",
  ">50%" = "#D73027"
)

p <- ggplot(
  plot_df,
  aes(
    x = xpos,
    y = Percent,
    fill = FGA_bin
  )
) +
  geom_col(
    width = 1.0,
    color = "white",
    linewidth = 0.5
  ) +
  geom_text(
    aes(
      label = ifelse(
        Percent > 0,
        paste0(round(Percent, 1), "%"),
        ""
      ),
      color = text_color
    ),
    position = position_stack(vjust = 0.5),
    size = 5,
    show.legend = FALSE
  ) +
  annotate("text", x = 1.5, y = -10, label = "Bladder", size = 5) +
  annotate("text", x = 4.5, y = -10, label = "Endometrium", size = 5) +
  annotate("text", x = 7.5, y = -10, label = "Oral", size = 5) +
  scale_color_identity() +
  scale_fill_manual(
    values = fga_colors,
    breaks = c(
      ">50%",
      "20–50%",
      "5–20%",
      ">0–5%",
      "0% (No CNA)"
    ),
    name = "Fraction Genome Altered"
  ) +
  scale_x_continuous(
    breaks = c(1, 2, 4, 5, 7, 8),
    labels = c(
      "Normal Baldder\n(n=20)",
      "BLCA\n(n=406)",
      "Normal Endometrium\n(n=28)",
      "UCEC\n(n=519)",
      "oral leukoplakia\n(n=89)",
      "HNSC\n(n=517)"
    ),
    expand = c(0.02, 0.02)
  ) +
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(0, 100, 20),
    labels = function(x) paste0(x, "%"),
    expand = c(0, 0)
  ) +
  coord_cartesian(
    ylim = c(0, 100),
    clip = "off"
  ) +
  labs(
    title = "Fraction of Genome Altered",
    x = NULL,
    y = "Fraction of cases (%)",
    caption =
      "Sources: Normal endometrium data from Moore et al., Nature 2020 (257 sample over 28 individual).
                Endometrial carcinoma data from TCGA-UCEC_2018. 
                Normal bladder data from Lawson et al., Science 2020 (2,097 sample over 20 individual). 
                Bladder cancer data from TCGA-BLCA_2018. 
                Oral leukoplakia data from Wils et al. Clin. Cancer Res.2023.
                Oral cancer data from HNSC-TCGA_2018."
  ) +
  theme_classic(base_size = 16) +
  theme(
    plot.title = element_text(size = 20, hjust = 0.5),
    axis.title.y = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.x = element_text(angle = 30,hjust = 1,vjust = 1),
    #axis.text.x = element_text(size = 8),
    legend.title = element_text(size = 15),
    legend.text = element_text(size = 13),
    legend.position = "right",
    plot.margin = margin(t = 10, r = 10, b = 55, l = 10),
    plot.caption = element_text(size = 10, hjust = 0, margin = margin(t = 12))
  )

print(p)

ggsave(
  "Endometrium_Bladder_Oral_FGA_stacked_bar.png",
  plot = p,
  width = 10,
  height = 6.5,
  dpi = 300
)

