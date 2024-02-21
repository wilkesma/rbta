#' Assess the environmental collection bias associated with a biodiversity data set
#'
#' This function takes a data frames of background environmental data and environmental data at the nodes of the biodiversity monitoring network, reporting the collection bias. Optionally, probability density functions may be plotted. Only supports continuous environmental variables.
#'
#' @param bg a data frame of background environmental data with columns corresponding to environmental variables.
#' @param points a data frame of environmental data at sampling locations, with columns corresponding to environmental variables.
#' @param var the environmental variable to be assessed for collection bias. It must be a column name in both bg and points.
#' @param plot if TRUE, probability density functions will be plotted. Default value is FALSE.
#' @return A data frame of results from a two-sample, two-sided Kolmogorov-Smirnov test. Higher values of the test statistics (D) indicate greater collection bias.

collectionBias <- function(bg, points, var, plot=FALSE){
  test <- ks.test(bg[,var], points[,var])
  bg$var <- as.numeric(bg[,var])
  points$var <- as.numeric(points[,var])
  if(plot==TRUE){
    p <- ggplot() +
      geom_density(data=bg, aes(x=var), color=NA, fill="grey62") +
      geom_density(data=points, aes(x=var), linewidth=0.65) +
      labs(title=paste0("Collection bias (D) = ", round(test$statistic, 2)), x=var)
    print(p)
    list(p=p, result=data.frame(var=var, D=test$statistic, p=test$p.value))
  } else{
    data.frame(var=var, D=test$statistic, p=test$p.value)
  }
}