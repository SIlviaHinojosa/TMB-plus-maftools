# Load necessary libraries
if (!requireNamespace("maftools", quietly = TRUE)) install.packages("maftools")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")

library(maftools)
library(dplyr)
library(ggplot2)

# Read MAF file
maf_file <- "/your/path/*.maf"
maf_data <- read.maf(maf = maf_file)

# Define common cancer-related variants
common_variants <- c(
  "Missense_Mutation", "Nonsense_Mutation", 
  "Frame_Shift_Del", "Frame_Shift_Ins", 
  "In_Frame_Del", "In_Frame_Ins"
)

# Remove common cancer-related variants from the MAF file
filtered_variants <- maf_data@data[!maf_data@data$Variant_Classification %in% common_variants, ]

# Create a new MAF with the remaining variants
filtered_maf <- read.maf(maf = filtered_variants)

# Calculate TMB per sample for the remaining variants
tmb_filtered <- filtered_maf@variant.type.summary
tmb_filtered$TMB <- tmb_filtered$total / 30  # Typical exome size: 30 Mb

# Filter out any incorrect rows like "Tumor_Sample_Barcode"
tmb_filtered <- tmb_filtered[tmb_filtered$Tumor_Sample_Barcode != "Tumor_Sample_Barcode", ]

# Confirm the structure of the filtered TMB data
head(tmb_filtered)

# Create a summary of remaining variants by sample and classification
variant_summary <- filtered_variants %>%
  group_by(Tumor_Sample_Barcode, Variant_Classification) %>%
  summarise(Count = n(), .groups = "drop") %>%
  group_by(Tumor_Sample_Barcode) %>%
  mutate(Proportion = Count / sum(Count))

# Confirm the structure of the summary
head(variant_summary)

# Plot 1: Simple barplot for TMB per sample with unique colors
ggplot(tmb_filtered, aes(x = reorder(Tumor_Sample_Barcode, -TMB), y = TMB, fill = Tumor_Sample_Barcode)) +
  geom_bar(stat = "identity", color = "black") +
  labs(
    title = "Tumor Mutational Burden (TMB) per Sample",
    x = "Samples",
    y = "TMB (mutations per Mb)"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid = element_blank(),
    axis.line = element_line(color = "black"),
    axis.ticks = element_line(color = "black"),
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 8),
    axis.text.y = element_text(color = "black"),
    legend.position = "none" # Optionally hide legend
  )
# Convert the data to long format for stacked barplot
stacked_bar_data <- filtered_gene_variants %>%
  group_by(Tumor_Sample_Barcode, Hugo_Symbol) %>%
  summarise(Count = n(), .groups = "drop") %>%
  mutate(TMB = Count / exome_size_mb) %>%
  filter(Hugo_Symbol %in% top_genes)  # Keep only top 50 genes

# Stacked barplot for TMB contribution
ggplot(stacked_bar_data, aes(x = Tumor_Sample_Barcode, y = TMB, fill = Hugo_Symbol)) +
  geom_bar(stat = "identity", position = "stack") +
  labs(
    title = "TMB Contribution by Top 50 Genes",
    x = "Samples",
    y = "TMB (mutations per Mb)",
    fill = "Genes"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
    legend.position = "right"
  )
# Convert the data to long format for stacked barplot
stacked_bar_data <- filtered_gene_variants %>%
  group_by(Tumor_Sample_Barcode, Hugo_Symbol) %>%
  summarise(Count = n(), .groups = "drop") %>%
  mutate(TMB = Count / exome_size_mb) %>%
  filter(Hugo_Symbol %in% top_genes)  # Keep only top 50 genes

# Stacked barplot for TMB contribution with black lines
ggplot(stacked_bar_data, aes(x = Tumor_Sample_Barcode, y = TMB, fill = Hugo_Symbol)) +
  geom_bar(stat = "identity", position = "stack", color = "black") +
  labs(
    title = "TMB Contribution by Top 50 Genes",
    x = "Samples",
    y = "TMB (mutations per Mb)",
    fill = "Genes"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid = element_blank(),  # Remove grid lines
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),  # Rotate x-axis labels
    legend.position = "right"  # Place legend on the right
  )
