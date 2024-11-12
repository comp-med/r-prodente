
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `prodente`: **Pro**tein **De**terminants **En**richment **Tes**ting for UK Biobak Study Characteristics

<!-- badges: start -->
<!-- badges: end -->

The goal of `prodente` is to make results from an upcoming publication
immediately accessible and useful.

## Installation

You can install the development version of `prodente` directly from
GitHub:

``` r
library(remotes)
install_github("comp-med/prodente")
```

## Getting Started

The API consists only of a hand-full of functions that mostly make
working with the results table more convenient. Each important results
object is immediately available as accessible data.

``` r
library(prodente)
```

``` r
data(protein_mapping_table)
data(participant_characteristics_labels)
```

## Example
