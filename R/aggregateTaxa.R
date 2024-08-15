#' Aggregate biodiversity records to a given taxonomic rank
#'
#' Given a taxonomic classification and a target rank, for each taxon at the target rank, aggregate data to the target rank and optionally remove samples in which higher rank taxa were recorded but not the target rank.
#'
#' @param rank the target rank at which the data are to be aggregated. Must be a rank at which records are available in mat.
#' @param mat a matrix of detections (binary variables), counts or densities with columns corresponding to the row names of info.
#' @param info a data frame of taxonomic information, with row names corresponding to the column names of mat and columns named kingdom, phylum, class, order, family, genus and species.
#' @param remove if TRUE remove samples in which higher rank taxa were recorded but not the target rank.
#' @return A matrix of detections (binary variables), counts or densities aggregated to the target rank. If remove=TRUE, NA values will be given to the samples in which higher rank taxa were recorded but not the target rank.

aggregateTaxa <- function(rank, mat, info, remove){
  x.info <- info[colnames(mat),]
  taxa.target <- unique(na.omit(x.info[,rank]))
  removeHigherTaxon <- function(taxon){
    taxa.lower <- try(na.omit(info[which(info[,rank]==taxon),(which(colnames(info)==rank)+1):ncol(info)]), silent=TRUE)
    if(class(taxa.lower)=="try-error"){
      taxa.lower <- NULL
    }
    taxa.higher <- as.vector(apply(unique(info[which(info[,rank]==taxon),1:(which(colnames(info)==rank)-1)]), 2, function(x) na.omit(unique(x))))
    x.mat <- cbind(rowSums(as.data.frame(mat[,which(colnames(mat) %in% c(taxon, taxa.lower))])), rowSums(as.data.frame(mat[,which(colnames(mat) %in% taxa.higher)])))
    row.names(x.mat) <- row.names(mat)
    colnames(x.mat) <- c(taxon, "higher")
    if(remove==TRUE){
      x.mat[which(x.mat[,2]>0 & x.mat[,1]==0)] <- NA
    }
    x.mat[,1]
  }
  output <- do.call(cbind, lapply(taxa.target, removeHigherTaxon))
  class(output)
  colnames(output) <- taxa.target
  if(ncol(output)>1){
    output <- output[,!duplicated(colnames(output))]
  }
  output
}

                                   
