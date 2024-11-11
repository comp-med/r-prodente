
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `prete`: Protein Enrichment Testing for UK Biobak Study Characteristics

<!-- badges: start -->
<!-- badges: end -->

The goal of prete is to make results from an upcoming publication
immediately accessible and useful.

## Installation

You can install the development version of `prete` like so:

``` r
library(remotes)
install_github("comp-med/prete")
```

## Getting Started

The API consists only of a hand-full of functions that mostly make
working with the results table more convenient. Each important results
object is immediately available as accessible data.

``` r
library(prete)

# 
data(participant_characteristics_labels)
data(protein_mapping_table)
data(variance_decomposition_background)
```

``` r
data(protein_mapping_table)
data(participant_characteristics_labels)
```

## Example
