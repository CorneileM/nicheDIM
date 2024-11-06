
# nicheDIM

<!-- badges: start -->
<!-- badges: end -->

## Introduction
The extent to which organisms utilise biotic and abiotic resources available to them in space and time defines their niche. While many indices and statistical methods have been developed to translate data on resource utilisation into a quantification of an organism's niche properties and breadth, Levin's index of niche breadth remains one of the most intuitive and interpretable. It considers both the number of resources utilised by an organism, and the distribution of utilisation across these resources. For example, if an organism utilises two distinct resources in equal measure (e.g., consumes two types of insects in equal proportion) the organism would be given a Levin's niche breadth of 2, but if an organism utilises a two resources but spends almost all of its time utilising the one resource, its Levin's niche breadth would be closer to one. If the organism utilised 20 different resources with some being utilised slightly more than others, its niche-breadth would be perhaps be somewhere between 15 and 20. Levin's index is intuitive because the niche breadth value translates conceptually into the effective number of different resources utilised by an organism.

However, Levin's index suffers from a fundamental shortcoming, in that it mathematically considers all resources utilised as equally different from each other. For example, if an organism four species of closely-related moths in equal proportion while a second organism consumed four species of distanly-related insects (e.g., a moth, beetle, fly, and bee), both organisms would have the same Levin's niche breadth of 4. To generate a more ecologically realistic measure of niche breadth nicheDIM also incorporates the relatedness or similarity between resources in any quantifiable dimension, while maintaining the conceptual simplicity and comparability of Levin's original index.

## Installation

You can install the development version of nicheDIM from [GitHub](https://github.com/) with:

``` r
devtools::install_github("CorneileM/nicheDIM")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(nicheDIM)
## basic example code
```

