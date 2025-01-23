README
Overview

This repository contains code for analyzing Tumor Mutational Burden (TMB) at the gene level and visualizing the results using heatmaps and stacked barplots. The workflow filters out common and cancer-related variants, calculates the TMB per gene and sample, and visualizes the top 50 genes contributing to the TMB.

The code is designed to work with MAF (Mutation Annotation Format) files and provides insights into the frequency and distribution of mutations across samples and genes.
Features

    Filtering Variants:
        Removes common and cancer-related variants (e.g., Missense_Mutation, Nonsense_Mutation).
        Focuses on rare or specific mutations relevant for analysis.

    TMB Calculation:
        Computes the TMB for each gene in each sample based on the number of variants per gene divided by the typical exome size (30 Mb by default).

    Visualization:
        Heatmap: Displays the TMB for the top 50 most mutated genes across all samples.
        Stacked Barplot: Illustrates the contribution of each gene to the TMB within each sample, with distinct colors and separating lines.

Dependencies

The code relies on the following R libraries:

    maftools: For reading and processing MAF files.
    dplyr: For data manipulation.
    ggplot2: For creating stacked barplots.
    ComplexHeatmap: For generating heatmaps.
    tidyr: For reshaping data into wide format.

To install these dependencies, run:

install.packages(c("maftools", "dplyr", "ggplot2", "ComplexHeatmap", "tidyr"))
