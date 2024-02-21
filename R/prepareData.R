#' Interactive preparation of biodiversity records for trend analysis
#'
#' Combines available rbta functions into a single function prompting user inputs to decide sampling frequency filter and target rank informed by outputted graphics, including plotting of environmental collection bias at specified sampling frequency thresholds
#'
#' @param df a dataframe of survey information with at least two columns named timestep and site. The row names of meta must match the row names of mat.
#' @param bg a data frame of background environmental data with columns corresponding to environmental variables.
#' @param points a data frame of environmental data at sampling locations, with columns corresponding to environmental variables.
#' @param vars a vector of environmental variable name(s) to be assessed for collection bias. Must be column names in both bg and points.
#' @param mat a matrix of detections (binary variables), counts or densities with columns corresponding to the row names of info. The row names of mat must match the row names of df.
#' @param info a data frame of taxonomic information, with row names corresponding to the column names of mat and columns named kingdom, phylum, class, order, family, genus and species.
#' @param freq an optional threshold number of timesteps for filtering. If not provided, the user will be prompted to enter the frequency.
#' @param rank the target rank at which the data are to be aggregated. Must be a rank at which records are available in mat. If missing, the user will be prompted to enter the target rank.
#' @param remove if TRUE remove samples in which higher rank taxa were recorded but not the target rank. If missing, the user will be prompted to enter a value.
#' @return A list comprised of:
#' \describe{
#'   \item{\code{df}}{a data frame of survey information for sites meeting the threshold sampling frequency. The data frame can be used to subset a matrix of species detection/nondetection or count data.}
#'   \item{\code{mat}}{a matrix of detections (binary variables), counts or densities aggregated to the target rank for sites meeting the threshold sampling frequency. If remove=TRUE, NA values will be given to the samples in which higher rank taxa were recorded but not the target rank.}
#'   \item{\code{bias}}{a data frame of results from a two-sample, two-sided Kolmogorov-Smirnov test. Higher values of the test statistics (D) indicate greater collection bias.}
#'   \item{\code{bias.taxon}}{a data frame of results from a two-sample, two-sided Kolmogorov-Smirnov test per taxon. Higher values of the test statistics (D) indicate greater collection bias. NULL if remove=FALSE.}

prepareData <- function(df, bg, points, vars, mat, info, freq=NA, rank=NA, remove=NA){
  x.meta <- filterSites(df, freq)
  x.mat <- mat[row.names(x.meta),]
  x.bias <- lapply(vars, function(x) collectionBias(bg, x.meta, x, TRUE))
  grid.arrange(grobs=lapply(x.bias, function(x) x$p))
  x.bias <- do.call(rbind, lapply(x.bias, function(x) x$result))
  exploreTaxa(x.mat, info)
  if(is.na(rank)){
    rank <- readline(prompt="Enter target rank: ")
  }
  rank <- tolower(rank)
  if(is.na(remove)){
    remove <- readline(prompt="Remove samples in which higher rank taxa were recorded but not the target rank? (Y/N): ")
    remove <- ifelse(remove %in% c("y", "Y"), TRUE, ifelse(remove %in% c("n", "N"), FALSE, NA))
  }
  x.mat <- aggregateTaxa(rank, x.mat, info, remove)
  if(remove==TRUE){
    message("Percentage of records removed per target taxon:")
    print(apply(x.mat, 2, function(x) length(x[is.na(x)])/length(x)*100))
    x.bias.2 <- do.call(rbind, lapply(vars, function(x) do.call(rbind, lapply(colnames(x.mat), function(y) data.frame(taxon=y, collectionBias(bg, x.meta[which(row.names(x.meta) %in% names(x.mat[,y][!is.na(x.mat[,y])])),], x, FALSE))))))
  } else{
    x.bias.2 <- NULL
  }
  list(df=x.meta, mat=x.mat, bias=x.bias, taxon.bias=x.bias.2)
}