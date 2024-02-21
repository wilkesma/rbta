#' Plot the structure of biodiversity records across the taxonomic hierarchy
#'
#' Given a taxonomic classification, plot the number of detections or total abundance recorded at successive taxonomic ranks.
#'
#' @param mat a matrix of detections (binary variables), counts or densities with columns corresponding to the row names of info.
#' @param info a data frame of taxonomic information, with row names corresponding to the column names of mat and columns named kingdom, phylum, class, order, family, genus and species.
#' @return A cladogram mapping aggregated biodiversity data across the taxonomic hierarchy.

exploreTaxa <- function(mat, info){
  x.info <- info[colnames(mat),]
  x.info$records <- colSums(mat)
  
  tree.info <- x.info[,c("phylum", "class", "order", "family", "genus", "species")]
  not.species.info <- tree.info[is.na(tree.info$species),]
  species.info <- tree.info[!is.na(tree.info$species),]
  nodes.in <- apply(not.species.info, 1, function(x) x[!is.na(x)][length(x[!is.na(x)])])[apply(not.species.info, 1, function(x) x[!is.na(x)][length(x[!is.na(x)])]) %in% as.vector(species.info)]
  
  taxa.levels <- apply(x.info[-which(row.names(x.info) %in% nodes.in),], 1, function(x) c("Phylum", "Class", "Order", "Family", "Genus", "Species")[which(is.na(x))-1][1])
  taxa.levels[is.na(taxa.levels)] <- "Species"
  
  dummy.info <- x.info[-which(row.names(x.info) %in% nodes.in),]
  dummy.info$class[is.na(dummy.info$class)] <- paste0("Phylum=", dummy.info$phylum[is.na(dummy.info$class)])
  dummy.info$order[is.na(dummy.info$order)] <- paste0("Class=", dummy.info$class[is.na(dummy.info$order)])
  dummy.info$family[is.na(dummy.info$family)] <- paste0("Order=", dummy.info$order[is.na(dummy.info$family)])
  dummy.info$genus[is.na(dummy.info$genus)] <- paste0("Family=", dummy.info$family[is.na(dummy.info$genus)])
  dummy.info$species[is.na(dummy.info$species)] <- paste0("Genus=", dummy.info$genus[is.na(dummy.info$species)])
  
  dummy.info$species <- paste0(taxa.levels, "=", sapply(dummy.info$species, function(x){ y <- str_split(x, "=")[[1]]; y[length(y)]}))
  dummy.info$species <- str_replace_all(dummy.info$species, "Species=", "")
  
  tree.info <- dummy.info %>% mutate_if(is.character,as.factor)
  tree <- as.phylo(~phylum/class/order/family/genus/species, data=tree.info, collapse=F)
  tip.data <- data.frame(tip=tree$tip.label, records=x.info[tree$tip.label,"records"])
  tip.data <- tip.data[which(tip.data$tip %in% species.info$species),]
  node.data <- unique(do.call(c,c(tree.info[,c("phylum", "class", "order", "family", "genus")])))
  node.data <- data.frame(tip=node.data[!is.na(node.data)], records=NA)
  row.names(node.data) <- node.data$tip
  node.data[row.names(not.species.info), "records"] <- x.info[row.names(not.species.info), "records"]
  node.data <- node.data[tree$node.label,]
  tree.data <- rbind(tip.data, node.data)
  
  tree$tip.label[is.na(tree$tip.label)] <- dummy.info$species[is.na(tree$tip.label)]
  
  p <- ggtree(tree) + geom_tiplab(offset=0.2, fontface=3) + xlim(0,10) + ylim(NA, nrow(tree.info))
  p <- p %<+% tree.data +
    geom_nodepoint(aes(size=records), alpha=0.25) +
    geom_tippoint(aes(size=records), alpha=0.25) +
    geom_nodepoint(aes(size=records), fill=NA, colour="black", shape=1) +
    geom_tippoint(aes(size=records), fill=NA, colour="black", shape=1) +
    scale_size_continuous("Records", trans="log10")
  print(p)
}
