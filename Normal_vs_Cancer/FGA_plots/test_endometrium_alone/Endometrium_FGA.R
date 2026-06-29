library(tidyverse)

###############################################################
# Read TCGA clinical file
###############################################################

tcga <- read_tsv(
  "ucec_tcga_pan_can_atlas_2018_clinical_data.tsv",
  show_col_types = FALSE
)

###############################################################
# Automatically locate the FGA column
###############################################################

fga_col <- grep(
  "Fraction Genome Altered",
  names(tcga),
  value = TRUE
)

fga <- tcga %>%
  select(all_of(fga_col)) %>%
  rename(FGA = all_of(fga_col)) %>%
  filter(!is.na(FGA))

###############################################################
# Bin TCGA samples by FGA
###############################################################

cancer_bins <- fga %>%
  mutate(
    FGA_bin = case_when(
      FGA == 0 ~ "0% (No CNA)",
      FGA > 0 & FGA <= 0.05 ~ ">0–5%",
      FGA > 0.05 & FGA <= 0.20 ~ "5–20%",
      FGA > 0.20 & FGA <= 0.50 ~ "20–50%",
      TRUE ~ ">50%"
    )
  ) %>%
  count(FGA_bin) %>%
  mutate(
    Percent = 100 * n / sum(n),
    Group = paste0("UCEC\n(n=", sum(n), ")")
  )

###############################################################
# Moore et al. Nature 2020
###############################################################

normal_bins <- tibble(
  FGA_bin = c(
    "0% (No CNA)",
    ">0–5%",
    "5–20%",
    "20–50%",
    ">50%"
  ),
  n = c(
    221,
    36,
    0,
    0,
    0
  )
) %>%
  mutate(
    Percent = 100 * n / sum(n),
    Group = "Normal\n(n=257)"
  )

###############################################################
# Combine
###############################################################

plot_df <- bind_rows(
  normal_bins,
  cancer_bins
)

###############################################################
# X-axis order
###############################################################

plot_df$Group <- factor(
  plot_df$Group,
  levels = c(
    "Normal\n(n=257)",
    "UCEC\n(n=519)"
  )
)

###############################################################
# IMPORTANT
# Reverse factor order so blue is plotted first (bottom)
###############################################################

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

###############################################################
# Text colors
###############################################################

plot_df <- plot_df %>%
  mutate(
    text_color = ifelse(
      FGA_bin == "0% (No CNA)",
      "white",
      "black"
    )
  )

###############################################################
# Colors
###############################################################

fga_colors <- c(
  "0% (No CNA)" = "#2F80ED",
  ">0–5%" = "#FFF176",
  "5–20%" = "#FDB863",
  "20–50%" = "#F46D43",
  ">50%" = "#D73027"
)

###############################################################
# Plot
###############################################################

p <- ggplot(
  plot_df,
  aes(
    x = Group,
    y = Percent,
    fill = FGA_bin
  )
) +
  
  geom_col(
    width = 0.65,
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
    fontface = "bold",
    show.legend = FALSE
  ) +
  
  scale_color_identity() +
  
  scale_fill_manual(
    
    values = fga_colors,
    
    # Legend from highest to lowest
    breaks = c(
      ">50%",
      "20–50%",
      "5–20%",
      ">0–5%",
      "0% (No CNA)"
    ),
    
    name = "Fraction Genome Altered"
    
  ) +
  
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(0, 100, 20),
    labels = function(x) paste0(x, "%"),
    expand = c(0, 0)
  ) +
  
  labs(
    title = "Fraction of Genome Altered",
    x = NULL,
    y = "Fraction of cases (%)",
    caption =
      "Sources: Normal endometrium data from Moore et al. (Nature, 2020; n = 257 glands from 28 women).\nEndometrial carcinoma data from TCGA-UCEC_2018 (n = 519 tumors)."
  ) +
  
  theme_classic(base_size = 16) +
  
  theme(
    
    plot.title = element_text(
      face = "bold",
      size = 20,
      hjust = 0.5
    ),
    
    axis.title.y = element_text(
      face = "bold",
      size = 18
    ),
    
    axis.text.x = element_text(
      face = "bold",
      size = 16
    ),
    
    legend.title = element_text(
      face = "bold",
      size = 15
    ),
    
    legend.text = element_text(
      size = 13
    ),
    
    legend.position = "right",
    
    plot.caption = element_text(
      size = 10,
      hjust = 0,
      margin = margin(t = 12)
    )
    
  )

###############################################################
# Display
###############################################################

print(p)

###############################################################
# Save
###############################################################

ggsave(
  "Endometrium_FGA_stacked_bar.pdf",
  plot = p,
  width = 8,
  height = 6.5,
  dpi = 300
)
