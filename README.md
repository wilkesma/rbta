# rbta

rbta provides funcions to support the reproducibility of biodiversity trend analyses by transparently processing biodiversity records.

## Installation

install_github("wilkesma/rbta")

## Functionality

| Function name  | Description |
| ------------- | ------------- |
| filterSites()  | Apply a sampling frequency filter to a dataset and optionally plot the empirical cumulative distribution function over multiple sampling frequency thresholds.|
| collectionBias()  | Assess the environmental collection bias associated with a dataset.|
| exploreTaxa()  | Given a taxonomic classification, plot the number of detections and/or total abundance recorded at successive taxonomic ranks.|
| aggregateTaxa()  | Given a taxonomic classification and a target rank, for each taxon at the target rank, aggregate the data to the target rank and optionally remove samples in which each higher rank taxon was recorded but not the target rank.|
| prepareData()  | Combines the above functions into a single function prompting user inputs to decide sampling frequency filter and target rank informed by outputted graphics, including optional plotting of environmental collection bias at specified sampling frequency thresholds.|
