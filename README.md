# rbta

rbta provides functions to support the reproducibility of biodiversity trend analyses by transparently processing biodiversity records.

## Functionality

| Function name  | Description |
| ------------- | ------------- |
| filterSites()  | Apply a sampling frequency filter to a dataset and optionally plot the empirical cumulative distribution function over multiple sampling frequency thresholds.|
| collectionBias()  | Assess the environmental collection bias associated with a dataset.|
| exploreTaxa()  | Given a taxonomic classification, plot the number of detections and/or total abundance recorded at successive taxonomic ranks.|
| aggregateTaxa()  | Given a taxonomic classification and a target rank, for each taxon at the target rank, aggregate the data to the target rank and optionally remove samples in which each higher rank taxon was recorded but not the target rank.|
| prepareData()  | Combines the above functions into a single function prompting user inputs to decide sampling frequency filter and target rank informed by outputted graphics, including optional plotting of environmental collection bias at specified sampling frequency thresholds.|

## Example usage

### Load packages and data

To get started with `rbta`, load required packages and an example
data set. We use example detetcion-nondetection data on nine nested diatom taxa available in the `rbta` package as the `y` object. Survey level information accompanying the detection-nondetection data are available as the `meta` object. Data on the taxonomic classification of each taxon is availale as the `info` object. Example land cover data for the background landscape and the surveyed locations are available as the `bg_lcm` and `meta_lcm` objects respectively.

``` r
library(rbta)
library(dplyr)
library(ggplot2)
library(ape)
library(ggtree)
library(stringr)
library(gridExtra)

data(y) #Object name is y
data(meta) #Object name is meta
data(info) #Object name is info
data(bg_lcm) #Object name is bg_lcm
data(meta_lcm) #Object name is meta_lcm
```

###Data filtering using `filterSites()`

Below we apply a sampling frequency filter to `meta` based on the number of timesteps at which each site has been surveyed. If we provide a pre-defined frequency to filter with, we can optionally output a plot of the empirical cumulative distribution function.

``` r
filterSites(meta) #User prompted to input frequency filter based on ecdf
filterSites(meta, 5) #For a pre-defined frequency filter
filterSites(meta, 5, TRUE) #For a pre-defined frequency filter including the ecdf
```

The function returns a data frame of survey information for sites meeting the threshold sampling frequency.

###Assessing collection bias using `collectionBias()`

Given data frames of environmental data in the backrgound landscape and at surveyed locations, we can use a two-sample, two-sided Kolmogorov-Smirnov test to quantify the collection bias. We can optionally return a plot comntrasting the probability density functions of the two distributions.

``` r
collectionBias(bg_lcm, meta_lcm, "broad_wood") #For a single variable
collectionBias(bg_lcm, meta_lcm, "broad_wood", TRUE) #With density plot returned
sapply(colnames(bg_lcm), function(x) collectionBias(bg_lcm, meta_lcm, x)) #For multiple variables
```

The function returns a data frame of results from a two-sample, two-sided Kolmogorov-Smirnov test. Higher values of the test statistic (D) indicate greater collection bias.

###Explore the taxonomic structure of the data using `exploreTaxa()`

Given a taxonomic classification, we can plot the number of detections and/or total abundance recorded at successive taxonomic ranks.

``` r
exploreTaxa(y, info)
```

The function outputs a plot showing the cladogram with node and tip symbols scaled to the value of the response variable.

###Aggregate data to a given rank using `aggregateTaxa()`

Given a taxonomic classification and a target rank, for each taxon at the target rank, we can aggregate the data to the target rank and optionally remove samples in which each higher rank taxon was recorded but not the target rank.

``` r
aggregateTaxa("genus", y, info, FALSE) #Aggregation without sample removal
aggregateTaxa("genus", y, info, TRUE) #With sample removal
```

The function returns a matrix of detections (binary variables), counts or densities aggregated to the target rank. If remove=TRUE, NA values will be given to the samples in which higher rank taxa were recorded but not the target rank.

###Use a combination of functions to prepare data with `prepareData()`

We combine the above functions into a single function prompting user inputs to decide sampling frequency filter and target rank informed by outputted graphics, including optional plotting of environmental collection bias at specified sampling frequency thresholds

``` r
prepareData(df=meta, bg=bg_lcm, points=meta_lcm, vars=colnames(bg_lcm), mat=y, info=info) #To follow user prompts
prepareData(df=meta, bg=bg_lcm, points=meta_lcm, vars=colnames(bg_lcm), mat=y, info=info, freq=2, rank="genus", remove=TRUE) #For pre-defined settings
```

The function returns a list comprised of A list comprised of:
| Name  | Description |
| ------------- | ------------- |
| df  | A data frame of survey information for sites meeting the threshold sampling frequency. The data frame can be used to subset a matrix of species detection/nondetection or count data.|
| mat  | A matrix of detections (binary variables), counts or densities aggregated to the target rank for sites meeting the threshold sampling frequency. If remove=TRUE, NA values will be given to the samples in which higher rank taxa were recorded but not the target rank.|
| bias  | A data frame of results from a two-sample, two-sided Kolmogorov-Smirnov test. Higher values of the test statistics (D) indicate greater collection bias.|
| bias.taxon  | A data frame of results from a two-sample, two-sided Kolmogorov-Smirnov test per taxon. Higher values of the test statistics (D) indicate greater collection bias. NULL if remove=FALSE.|
