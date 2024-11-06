
# nicheDIM
*Intuitive niche-breadth estimation in multi-trait and phylogenetic dimensions*

<!-- badges: start -->
<!-- badges: end -->

## What the package does?
This R package contains a set of functions to calculate niche breadth (or resource selectivity) from resource utilisation and resource trait data. Like Levin's nice breadth index, nicheDIM incorporates both the number of resources utilised by an organism, and the distribution of utilisation across these resources. However, nicheDIM also incorporates the relatedness or similarity between resources in any quantifiable dimension to generate a more ecologically realistic measure of niche breadth, while maintaining the conceptual simplicity and comparability of Levin's original index.

## Introduction
The extent to which organisms utilise biotic and abiotic resources available to them in space and time defines their niche. While many indices and statistical methods have been developed to translate data on resource utilisation into a quantification of an organism's niche breadth, Levin's index of niche breadth remains one of the most intuitive and interpretable [Levin 1968](https://books.google.co.za/books?hl=en&lr=&id=yOQ9DwAAQBAJ&oi=fnd&pg=PA3&dq=Levins,+R.+1968.+Evolution+in+changing+environments.+-++Princeton++Univ.+Press,+Princeton,++New+Jersey&ots=Ws88flux7n&sig=I-kN8_2C-xJDZcrXfhR20_Ki-eE). It considers both the number of resources utilised by an organism, and the distribution of utilisation across these resources. Levin's index is calculated as the inverse of the sum of the squares of the proportions of resources utilised by an organism:

$$LI_i = \frac{1}{\sum_{j}^{n} P_j^2}$$

where $LI$ is Levin's index for organism $i$, $n$ is the number of resources utilised by an organism, and $P_j$ is the proportional utilisation of the resource $j$ by organism $i$. Proportional utilisation could be the volume of a resource consumed, the time spent utilising a resource, or the frequency of utilisation of a resource. For example, if an organism utilises two distinct resources in equal measure (e.g., consumes two types of insects in equal proportion) the organism would be given a Levin's niche breadth of 2 ($\frac{1}{\0.5^2 + 0.5^2} = 2$), but if an organism utilises a two resources but spends almost all of its time utilising the one resource, its Levin's niche breadth would be closer to one ($\frac{1}{0.9^2 + 0.1^2} = 1.23$). If the organism utilised 20 different resources with some being utilised slightly more than others, its niche-breadth would be perhaps be somewhere between 15 and 20. Levin's index is intuitive because the niche breadth value translates conceptually into the effective number of different resources utilised by an organism. The first organism in the above example spreads it's utilisation equally over two resources, and so is considered by the Levin's index to have a niche breadth of two resources. The second organism utilises two resources, but almost exclusively utilises one of them, and so is considered to have a niche breadth of only 1.23 resources.

However, Levin's index suffers from a fundamental shortcoming, in that it mathematically considers all resources utilised as equally different from each other. For example, if an organism consumed four species of closely-related moths in equal proportion while a second organism consumed four species of distantly-related insects (e.g., a moth, beetle, fly, and bee), both organisms would have the same Levin's niche breadth of 4, while the first organism clearly has a narrower niche breadth compared to the second. To generate a more ecologically realistic measure of niche breadth nicheDIM incorporates the relatedness or similarity between resources in any quantifiable dimension, while maintaining the conceptual simplicity and comparability of Levin's original index. 

## Installation

You can install the development version of nicheDIM from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("CorneileM/nicheDIM")
```

## Example

**nicheDIM** requires two data sets as input:

1. **Resource utilisation data:** This dataframe should have rows (with row names) representing the different organisms, or resources users. The named columns of the resource utilisation dataframe represent the different resources and their proportional utilisation per user/organism.
2. **Resource trait data:** These data should be in the form of a pair-wise distance matrix, where the rows and columns are the resources, and the values are the distances in trait space between the resources. The resource trait data can be any quantifiable trait that describes the resources, such as body size, chemical composition, or phylogenetic relatedness.

Examples of the two data sets are included in the package and an example of how to calculate niche breadth using these data and the nicheDIM package is shown below:

``` r
library(nicheDIM)

# Load the package data
## Resource utilisation data
pollinator_visits # A fictional dataset of five different pollinator species and their proportional visit rates to 10 different flower species.
View(pollinator_visits) # View the data

## Resource trait data
flower_size # A fictional dataset of flower corolla diameter of the 10 species of flowers represented in the pollinator_visits dataset.
View(flower_size) # View the data. As you'll notice, these data are not yet in the form of a pair-wise distance matrix, but are presented here as context.

flower_size_dist_matrix # A pairwise distance matrix of the flower size data. This matrix will be used as the resource trait data in the nicheDIM function.
View(flower_size_dist_matrix) # View the data

# Calculate niche breadth using the nicheDIM function
# The nicheDIM function requires the resource utilisation data, the resource trait data, a name for your own reference that will be appended to the csv file output, and the path to save the output.
pollinator_flower_size_nicheDIM <- nicheDIM(pollinator_visits,  sflower_size_dist_matrix, "flower_size",  "C:/Users/corne/Downloads/")

# The output of the nicheDIM function is a dataframe with the niche breadth values for each organism in the resource utilisation data.
View(pollinator_flower_size_nicheDIM) # View the output

# More details on the inputs and outputs of the nicheDIM function can be found in the package documentation by running:
?nicheDIM


```

