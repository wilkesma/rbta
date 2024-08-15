#' Apply a sampling frequency filter to a biodiversity data set in preparation for trend analysis
#'
#' This function takes a data frame of survey information and a sampling frequency threshold to return survey information only for those sites meeting the threshold. Optionally, the empirical cumulative distribution function (ECDF) may be plotted.
#'
#' @param df a dataframe of survey information with at least two columns named timestep and site.
#' @param freq an optional threshold number of timesteps for filtering. If not provided, the user will be prompted to enter the frequency.
#' @param plot if TRUE, the ECDF will be plotted. Default value is FALSE
#' @return A data frame of survey information for sites meeting the threshold sampling frequency. The data frame can be used to subset a matrix of species detection/nondetection or count data

filterSites <- function(df, freq=NA, plot=FALSE){
  ts.len <- left_join(df, do.call(rbind, lapply(unique(df$site), function(x) data.frame(site=x, n.timesteps=length(unique(df$timestep[df$site==x]))))))
  row.names(ts.len) <- row.names(df)
  if(plot==TRUE | is.na(freq)){
    p <- ggplot(ts.len, aes(x=n.timesteps)) +
      stat_ecdf(aes(y = (1 - after_stat(y))), geom = "step") +
      ylab("Proportion of sites") +
      xlab("Number of timesteps with samples")
    if(!is.na(freq)){
      p <- p + geom_vline(xintercept=freq, linetype=2)
    }
    print(p)
  }
  if(is.na(freq)){
    freq <- readline(prompt="Enter threshold number of timesteps for filtering: ")
  }
  return(ts.len[ts.len$n.timesteps>=freq, -which(colnames(ts.len)=="n.timesteps")])
}
                                                
