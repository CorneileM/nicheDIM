#' nicheDIM
#'
#' Intuitive niche-breadth estimation in multi-trait and phylogenetic dimensions.
#'
#'
#' @param resource.use A dataframe consisting of proportional resource-use values for any number of resources (cols) used by a list of users (rows) with unique IDs. The first column should represent a list of IDs for resource users (e.g., a list of bat species for which dietary composition was determined), followed by any number of columns, each representing a different resource (e.g., species of moth consumed by bats) with a proportional resource use value given for each user. The sum of an individual row should equal 1.
#' @param dist.matrix A matrix of pairwise trait-distance or dissimilarity values which consists entirely of resources used (e.g., a pairwise colour distance dissimilarty matrix of different flowers species visited by bees), or includes all resources used (e.g., a phylogenetic dissimilarity matrix of all Lepidoptera, including species consumed by different species of bats). Values within the matrix will be converted to proportional values relative to the maximum value within the entire matrix (scale.limit = "none"), or limited only to resources used by users within a resource.use dataframe, or across a list of resource.use dataframes (scale.limit = "used resources"). The maximum scaling value can be set in scale.limit.
#' @param dataset.name A name for your own reference, that identifies the dataset supplied in resource.use. This will be helpful later if you intend compare different data sets.
#' @param file.dir A directory to save the returned dataframe to as a csv file.
#'
#' @return A dataframe with each representing a unique user (organism or entity that utilises resources) with the following columns: "dataset.name"; "UserID"; "users.count" = number of users; "resource.count" = number of resources; "resource.used.count" = number of resources used by user; "Levins" = calculated value for Levin's niche breadth as a reference; "Dist.use" = calculated value for nicheDIM index; "Dist.use.NOTi"; "Dist.use.ALL"; "Dist.resources"  = calculated value for nicheDIM assuming all resources are equally utilised (i.e., gives an indication of the total available nice breadth); "Prop.niche.space.NOTi"; "Prop.niche.space.ALL"
#'
#' nicheDIM()

nicheDIM <- function(resource.use,  dist.matrix, dataset.name,  file.dir) {

  users <- as.vector(row.names(resource.use))
  duplicated.users <- duplicated(users)
  if (any(duplicated.users)) warning(paste("User ID(s) '", unique(users[duplicated.users]), "' is/are not unique; "))
  users.count <- nrow(resource.use)
  resource.count <- ncol(resource.use)

  # create a placeholder dataframe for function
  resource.use.distr.df <- data.frame(matrix(NA,  nrow = 1,  ncol = 12))
  colnames(resource.use.distr.df) <- c("dataset.name", "UserID", "users.count", "resource.count", "resource.used.count", "Levins", "Dist.use","Dist.use.NOTi", "Dist.use.ALL", "Dist.resources", "Prop.niche.space.NOTi", "Prop.niche.space.ALL")

  # convert distance matrix to proportional values relative to the maximum distance in matrix # # # SHOULD ALLOW VALUE TO BE SET
  prop.dist.matrix <- dist.matrix * (1 / max(dist.matrix))

  # SUBSET RESOURCE DISTANCE MATRIX FOR SPECIES IN RESOURCE USE TABLE
  # create vector of resource species names or IDs
  comm.resource.species <- colnames(resource.use)
  # subset the proportional distance matrix for species/IDs listed in the resource use table
  dist.matrix.comm <- prop.dist.matrix[comm.resource.species,  comm.resource.species]  #  [NOTE: add warning if a resource is not present in dist.matrix]
  # set lower triangle of phylogenetic distance matrix to NA to prevent duplication
  dist.matrix.comm[lower.tri(dist.matrix.comm)] <- NA
  # set diagonals to NA
  diag(dist.matrix.comm) <- NA

  # DISTANCE-CORRECTED RESOURCES
  # resources are considered equally abundant,  so only their link distances are considered
  Dist.resources <- ifelse(resource.count == 1, 1, (((resource.count - 1) * mean(dist.matrix.comm,  na.rm = T)) + 1))

  ### DIST.USE FOR USER i

  # LOOP 1: loops through unique users in resource.use dataframe
  for (i in 1:users.count) {

    # PREPARE VALUES AND DATAFRAMES FOR NEXT LOOP
    # subset resource use table by row (i.e.,  resource use for user i)
    user_i.resource.use <- resource.use[i, ]
    # set count values to proportion
    user_i.resource.use <- as.matrix(user_i.resource.use)
    user_i.resource.use <- user_i.resource.use/sum(user_i.resource.use)
    user_i.resource.use <- as.data.frame(user_i.resource.use)
    # calculate the number resources used by user i
    resource.used.count <- as.vector(apply(user_i.resource.use > 0, 1, sum))
    # replace all zeros with NA [NOTE: why?]
    user_i.resource.use[user_i.resource.use == 0] <- NA
    # create spaceholder dataframe for next loop
    resource.use.eq <- data.frame(matrix(NA,  nrow = 1,  ncol =  resource.count))
    colnames(resource.use.eq) <- comm.resource.species
    # create spaceholder dataframe for next loop
    resource.use.imp <- data.frame(matrix(NA,  nrow = 1,  ncol =  resource.count))
    colnames(resource.use.imp) <- comm.resource.species


    # LOOP 2 (within LOOP 1): loops through resources used by user i
    for (j in 1:resource.count) {

      # RESOURCE USE LINK EQUALITY
      resource.use.eq_pre <- data.frame(matrix(user_i.resource.use[, j],  nrow = 1,  ncol =  resource.count))
      colnames(resource.use.eq_pre) <- comm.resource.species
      user_i.resource.use.one <- rbind(user_i.resource.use,  resource.use.eq_pre)
      # calculate usage equality across link by first calculating the absolute difference between resource use values at the tip of links and subtracting it from 1
      user_i.resource.use.one[3, ] <- 1 - abs(user_i.resource.use.one[1, ] - user_i.resource.use.one[2, ])
      resource.use.eq.prelim <- user_i.resource.use.one[3, ]
      # same resource link should be set to NA
      resource.use.eq.prelim[1, j] <- NA
      # add calulated row to spacefiller dataframe
      resource.use.eq <- rbind(resource.use.eq,  resource.use.eq.prelim)

      # RESOURCE USE LINK IMPORTANCE
      resource.use.imp_pre <- data.frame(matrix(user_i.resource.use[, j],  nrow = 1,  ncol =  resource.count))
      colnames(resource.use.imp_pre) <- comm.resource.species
      user_i.resource.use.one <- rbind(user_i.resource.use,  resource.use.imp_pre)
      # calculate usage importance across link by
      resource.use.imp.prelim <- apply(user_i.resource.use.one, 2,  sum)
      # add calulated row to spacefiller dataframe
      resource.use.imp <- rbind(resource.use.imp,  resource.use.imp.prelim)
    }


    ### DIST.USE.NOTi & AVAILABLE NICHE SPACE NOTi (I.E., FOR ALL USERS EXCLUDING USER i, AND THEREFORE AN INDICATION OF NICHE SPACE USED UP)

    # PREPARE VALUES AND DATAFRAMES FOR NEXT LOOP. IF ONLY ONE USER AT SITE, THEN SKIP
    if (users.count < 2) {

    } else {
      # subset resource use table by rowS that do not include user i (i.e.,  resource use for all users except i)
      user_NOTi.resource.use <- resource.use[-i, ]
      # sum all use values NOTi users to get the overall usage across resources for NOTi
      user_NOTi.resource.use$agg <- rep(1, nrow(user_NOTi.resource.use))
      user_NOTi.resource.use <- aggregate(user_NOTi.resource.use, by = list(user_NOTi.resource.use$agg), FUN = sum, na.rm = TRUE)
      rownames(user_NOTi.resource.use) <- c("NOTi")
      user_NOTi.resource.use <- user_NOTi.resource.use[,-1]
      user_NOTi.resource.use <- user_NOTi.resource.use[,-ncol(user_NOTi.resource.use)]
      # set count values to proportion
      user_NOTi.resource.use  <- as.matrix(user_NOTi.resource.use)
      user_NOTi.resource.use  <- user_NOTi.resource.use/sum(user_NOTi.resource.use)
      user_NOTi.resource.use  <- as.data.frame(user_NOTi.resource.use)
      # calculate the number resources used by user NOTi
      resource.used_NOTi.count <- as.vector(apply(user_NOTi.resource.use  > 0, 1, sum))
      # replace all zeros with NA [NOTE: why?]
      user_NOTi.resource.use[user_NOTi.resource.use == 0] <- NA
      # create spaceholder dataframe for next loop
      resource.use_NOTi.eq <- data.frame(matrix(NA,  nrow = 1,  ncol =  resource.count))
      colnames(resource.use_NOTi.eq) <- comm.resource.species
      # create spaceholder dataframe for next loop
      resource.use_NOTi.imp <- data.frame(matrix(NA,  nrow = 1,  ncol =  resource.count))
      colnames(resource.use_NOTi.imp) <- comm.resource.species


      # LOOP 3 (within LOOP 1): loops through resources used by user NOTi
      for (k in 1:resource.count) {

        # RESOURCE USE LINK EQUALITY
        resource.use_NOTi.eq_pre <- data.frame(matrix(user_NOTi.resource.use[, k],  nrow = 1,  ncol =  resource.count))
        colnames(resource.use_NOTi.eq_pre) <- comm.resource.species
        user_NOTi.resource.use.one <- rbind(user_NOTi.resource.use,  resource.use_NOTi.eq_pre)
        # calculate usage equality across link by first calculating the absolute difference between resource use values at the tip of links and subtracting it from 1.
        user_NOTi.resource.use.one[3, ] <- 1 - abs(user_NOTi.resource.use.one[1, ] - user_NOTi.resource.use.one[2, ])
        resource.use_NOTi.eq.prelim <- user_NOTi.resource.use.one[3, ]
        # same resource link should be set to NA
        resource.use_NOTi.eq.prelim[1, k] <- NA
        # add calulated row to spacefiller dataframe
        resource.use_NOTi.eq <- rbind(resource.use_NOTi.eq,  resource.use_NOTi.eq.prelim)

        # RESOURCE USE LINK IMPORTANCE
        resource.use_NOTi.imp_pre <- data.frame(matrix(user_NOTi.resource.use[, k],  nrow = 1,  ncol =  resource.count))
        colnames(resource.use_NOTi.imp_pre) <- comm.resource.species
        user_NOTi.resource.use.one <- rbind(user_NOTi.resource.use,  resource.use_NOTi.imp_pre)
        # calculate usage equality across link by first calculating the difference between resource use values at the tip of links
        resource.use_NOTi.imp.prelim <- apply(user_NOTi.resource.use.one, 2,  sum)
        # add calulated row to spacefiller dataframe
        resource.use_NOTi.imp <- rbind(resource.use_NOTi.imp,  resource.use_NOTi.imp.prelim)
      }

    }

    ### DIST.USE.ALLCOMMM & AVAILABLE NICHE SPACE ALL

    # PREPARE VALUES AND DATAFRAMES FOR NEXT LOOP

    # ALL users table includes all users
    user_ALL.resource.use <- resource.use
    # sum all use values for ALL users to get the overall usage
    user_ALL.resource.use$agg <- rep(1, nrow(user_ALL.resource.use))
    user_ALL.resource.use <- aggregate(user_ALL.resource.use, by = list(user_ALL.resource.use$agg), FUN = sum, na.rm = TRUE)
    rownames(user_ALL.resource.use) <- c("ALL")
    user_ALL.resource.use <- user_ALL.resource.use[,-1]
    user_ALL.resource.use <- user_ALL.resource.use[,-ncol(user_ALL.resource.use)]
    # set count values to proportion
    user_ALL.resource.use  <- as.matrix(user_ALL.resource.use)
    user_ALL.resource.use  <- user_ALL.resource.use/sum(user_ALL.resource.use)
    user_ALL.resource.use  <- as.data.frame(user_ALL.resource.use)
    # calculate the number resources used by ALL users
    resource.used_ALL.count <- as.vector(apply(user_ALL.resource.use  > 0, 1, sum))
    # replace all zeros with NA [NOTE: why?]
    user_ALL.resource.use[user_ALL.resource.use == 0] <- NA
    # create spaceholder dataframe for next loop
    resource.use_ALL.eq <- data.frame(matrix(NA,  nrow = 1,  ncol =  resource.count))
    colnames(resource.use_ALL.eq) <- comm.resource.species
    # create spaceholder dataframe for next loop
    resource.use_ALL.imp <- data.frame(matrix(NA,  nrow = 1,  ncol =  resource.count))
    colnames(resource.use_ALL.imp) <- comm.resource.species


    # LOOP 4 (within LOOP 1): loops through resources used by ALL users
    for (m in 1:resource.count) {

      # RESOURCE USE LINK EQUALITY
      resource.use_ALL.eq_pre <- data.frame(matrix(user_ALL.resource.use[, m],  nrow = 1,  ncol =  resource.count))
      colnames(resource.use_ALL.eq_pre) <- comm.resource.species
      user_ALL.resource.use.one <- rbind(user_ALL.resource.use,  resource.use_ALL.eq_pre)
      # calculate usage equality across link by first calculating the absolute difference between resource use values at the tip of links and subtracting it from 1.
      user_ALL.resource.use.one[3, ] <- 1 - abs(user_ALL.resource.use.one[1, ] - user_ALL.resource.use.one[2, ])
      resource.use_ALL.eq.prelim <- user_ALL.resource.use.one[3, ]
      # same resource link should be set to NA
      resource.use_ALL.eq.prelim[1, m] <- NA
      # add calulated row to spacefiller dataframe
      resource.use_ALL.eq <- rbind(resource.use_ALL.eq,  resource.use_ALL.eq.prelim)

      # RESOURCE USE LINK IMPORTANCE
      resource.use_ALL.imp_pre <- data.frame(matrix(user_ALL.resource.use[, m],  nrow = 1,  ncol =  resource.count))
      colnames(resource.use_ALL.imp_pre) <- comm.resource.species
      user_ALL.resource.use.one <- rbind(user_ALL.resource.use,  resource.use_ALL.imp_pre)
      # calculate usage equality across link by first calculating the difference between resource use values at the tip of links
      resource.use_ALL.imp.prelim <- apply(user_ALL.resource.use.one, 2,  sum)
      # add calulated row to spacefiller dataframe
      resource.use_ALL.imp <- rbind(resource.use_ALL.imp,  resource.use_ALL.imp.prelim)
    }


    ### DIST.USE

    # DIST.USE
    # remove placeholder rows
    resource.use.eq <- resource.use.eq[-1, ]
    resource.use.imp <- resource.use.imp[-1, ]
    # set lower triangle of matrix to NA to prevent duplication
    resource.use.eq[lower.tri(resource.use.eq)] <- NA
    resource.use.imp[lower.tri(resource.use.imp)] <- NA
    # set diagonals to zero
    diag(resource.use.eq) <- NA
    diag(resource.use.imp) <- NA
    # add species names
    rownames(resource.use.eq) <- rownames(dist.matrix.comm)  # [NOTE: rownames not applicable for simple dataframe
    # - either change dataframe to include first col as rownames, or do something else]
    rownames(resource.use.imp) <- rownames(dist.matrix.comm)
    # calculate proportional importance of each link by dividing each link by the sum of all links
    sum.resource.use.imp <- sum(resource.use.imp,  na.rm = T)
    prop.resource.use.imp <- resource.use.imp/sum.resource.use.imp
    # Prelim PD link values
    resource.use.eq.PD <- resource.use.eq*dist.matrix.comm*prop.resource.use.imp
    # sum resource use weighted link distances to get phylogenetic dispersion index
    Dist.use <- ifelse(resource.used.count == 1, 1, (((resource.used.count - 1) * sum(resource.use.eq.PD,  na.rm = T)) + 1))


    ### DIST.USE.NOTi & PROP.NICHE.SPACE.NOTi

    # DIST.USE.NOTi
    if (users.count < 2) {
      Dist.use.NOTi <- NA
    } else {
      # remove placeholder rows
      resource.use_NOTi.eq <- resource.use_NOTi.eq[-1, ]
      resource.use_NOTi.imp <- resource.use_NOTi.imp[-1, ]
      # set lower triangle of matrix to NA to prevent duplication
      resource.use_NOTi.eq[lower.tri(resource.use_NOTi.eq)] <- NA
      resource.use_NOTi.imp[lower.tri(resource.use_NOTi.imp)] <- NA
      # set diagonals to zero
      diag(resource.use_NOTi.eq) <- NA
      diag(resource.use_NOTi.imp) <- NA
      # add species names
      rownames(resource.use_NOTi.eq) <- rownames(dist.matrix.comm)  # [NOTE: rownames not applicable for simple dataframe
      # - either change dataframe to include first col as rownames, or do something else]
      rownames(resource.use_NOTi.imp) <- rownames(dist.matrix.comm)
      # calculate proportional importance of each link by dividing each link by the sum of all links
      sum.resource.use_NOTi.imp <- sum(resource.use_NOTi.imp,  na.rm = T)
      prop.resource.use_NOTi.imp <- resource.use_NOTi.imp/sum.resource.use_NOTi.imp
      # Prelim PD link values
      resource.use_NOTi.eq.PD <- resource.use_NOTi.eq*dist.matrix.comm*prop.resource.use_NOTi.imp
      # sum resource use weighted link distances to get phylogenetic dispersion index
      Dist.use.NOTi <- ifelse(resource.used_NOTi.count == 1, 1, (((resource.used_NOTi.count - 1) * sum(resource.use_NOTi.eq.PD,  na.rm = T)) + 1))
    }

    # PROP.NICHE.SPACE.NOTi
    if (users.count < 2) {
      Prop.niche.space.NOTi <- NA
    } else {
      Prop.niche.space.NOTi <- 1 - Dist.use.NOTi/Dist.resources
    }


    ### DIST.USE.ALL & PROP.NICHE.SPACE.ALL

    # DIST.USE.ALL
    # remove placeholder rows
    resource.use_ALL.eq <- resource.use_ALL.eq[-1, ]
    resource.use_ALL.imp <- resource.use_ALL.imp[-1, ]
    # set lower triangle of matrix to NA to prevent duplication
    resource.use_ALL.eq[lower.tri(resource.use_ALL.eq)] <- NA
    resource.use_ALL.imp[lower.tri(resource.use_ALL.imp)] <- NA
    # set diagonals to zero
    diag(resource.use_ALL.eq) <- NA
    diag(resource.use_ALL.imp) <- NA
    # add species names
    rownames(resource.use_ALL.eq) <- rownames(dist.matrix.comm)  # [NOTE: rownames not applicable for simple dataframe
    # - either change dataframe to include first col as rownames, or do something else]
    rownames(resource.use_ALL.imp) <- rownames(dist.matrix.comm)
    # calculate proportional importance of each link by dividing each link by the sum of all links
    sum.resource.use_ALL.imp <- sum(resource.use_ALL.imp,  na.rm = T)
    prop.resource.use_ALL.imp <- resource.use_ALL.imp/sum.resource.use_ALL.imp
    # Prelim PD link values
    resource.use_ALL.eq.PD <- resource.use_ALL.eq*dist.matrix.comm*prop.resource.use_ALL.imp
    # sum resource use weighted link distances to get phylogenetic dispersion index
    Dist.use.ALL <- ifelse(resource.used_ALL.count == 1, 1, (((resource.used_ALL.count - 1) * sum(resource.use_ALL.eq.PD,  na.rm = T)) + 1))


    # PROP.NICHE.SPACE.ALL
    Prop.niche.space.ALL <- 1 - Dist.use.ALL/Dist.resources


    ### OTHER VARIABLES

    # LEVINS
    # calcualte Levin's index for species i
    Levins <- 1 / sum(user_i.resource.use^2, na.rm = T)

    # USERID
    UserID <- rownames(user_i.resource.use)

    # dataset.name
    dataset.name <- dataset.name

    # ADD CALCULATED VALUES FOR USER i AS A ROW TO SPACEHOLDER DATAFRAME
    resource.use.distr.df.prelim <- data.frame(dataset.name, UserID, users.count, resource.count, resource.used.count, Levins, Dist.use, Dist.use.NOTi, Dist.use.ALL, Dist.resources, Prop.niche.space.NOTi, Prop.niche.space.ALL)

    # add data from i to placeholder dataframe
    resource.use.distr.df <- rbind(resource.use.distr.df,  resource.use.distr.df.prelim)
  }

  # remove placeholder row
  resource.use.distr.df <- resource.use.distr.df[-1, ]
  resource.use.DIST <- resource.use.distr.df
  # write dataframe to a csv file with the file.dir directory and use dataset name as the file name
  write.csv(resource.use.DIST,  file = paste(file.dir, dataset.name, "_nicheDIM.csv", sep = ""), row.names = FALSE)
  resource.use.DIST

}
