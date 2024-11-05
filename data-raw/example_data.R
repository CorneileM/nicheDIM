# EXAMPLE DATA
# We will create a fictional dataset of five different pollinator species and the ten different flower species they visit. The dataset will consist of a resource use table and three pairwise distance matrix tables for flower traits. The resource use table will consist of the proportional use of different flower species by different pollinator species. The three pairwise distance matrix tables will represent pairwise differences in color, size, and tube length of the flower species visited by the pollinators.

# Flower species
flowers <- c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J")

# Pollinator species
pollinators <- c("1", "2", "3", "4", "5")

# Resource use table
pollinator_visits <- data.frame(matrix(c(0.1, 0.0, 0.0, 0.0, 0.0, 0.6, 0.3, 0.0, 0.0, 0.0,
                                         0.0, 0.4, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1,
                                         0.05, 0.0, 0.3, 0.15, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0,
                                         0.1, 0.15, 0.0, 0.2, 0.1, 0.05, 0.1, 0.2, 0.0, 0.2,
                                         0.7, 0.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), nrow = 5, ncol = 10, byrow = TRUE))
rownames(pollinator_visits) <- pollinators
colnames(pollinator_visits) <- flowers

# FLOWER TRAITS
# Color
# First we'll create a dataframe representing mean color values (primary wavelengths measured in nm) for each flower species where the first column represents the flower species and the second column represents the mean color value.
color <- data.frame(matrix(c("A", 710, "B", 550, "C", 600, "D", 650, "E", 610, "F", 750, "G", 780, "H", 510, "I", 670, "J", 580), nrow = 10, ncol = 2, byrow = TRUE))
colnames(color) <- c("species", "color")

# Next we'll convert the color values to a pairwise distance matrix with column and row names representing the flower species.
color_dist <- as.matrix(dist(color$color))
# Add rownames and colnames
rownames(color_dist) <- color$species
colnames(color_dist) <- color$species

# Size
# First we'll create a dataframe representing mean flower size values (corolla diameter in mm) for each flower species where the first column represents the flower species and the second column represents the mean size value.
size <- data.frame(matrix(c("A", 22, "B", 12, "C", 27, "D", 25, "E", 8, "F", 31, "G", 7, "H", 18, "I", 9, "J", 13), nrow = 10, ncol = 2, byrow = TRUE))
colnames(size) <- c("species", "size")

# Next we'll convert the size values to a pairwise distance matrix with column and row names representing the flower species.
size_dist <- as.matrix(dist(size$size))
# Add rownames and colnames
rownames(size_dist) <- size$species
colnames(size_dist) <- size$species

# Tube length
# First we'll create a dataframe representing mean flower tube length values (corolla tube length in mm) for each flower species where the first column represents the flower species and the second column represents the mean tube length value.
tube_length <- data.frame(matrix(c("A", 31, "B", 20, "C", 5, "D", 3, "E", 7, "F", 16, "G", 2, "H", 17, "I", 4, "J", 6), nrow = 10, ncol = 2, byrow = TRUE))
colnames(tube_length) <- c("species", "tube_length")

# Next we'll convert the tube length values to a pairwise distance matrix with column and row names representing the flower species.
tube_length_dist <- as.matrix(dist(tube_length$V2))
# Add rownames and colnames
rownames(tube_length_dist) <- tube_length$species
colnames(tube_length_dist) <- tube_length$species

# Add prepared data to package
usethis::use_data(pollinator_visits, size_dist, color_dist, tube_length_dist)

