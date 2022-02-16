---
title: "Bird Species Richness Data for BIS"
author: "Lewis Elliott"
date: "16/02/2022"
output: 
  prettydoc::html_pretty:
    theme: hpstr
    highlight: github
---




This readme explains the steps for appending globally-consistent birds species richness data to the BlueHealth International Survey data files using R. BlueHealth International Survey data files can be found [here](https://beta.ukdataservice.ac.uk/datacatalogue/studies/study?id=8874), but this tutorial uses the 18-country file internal to the University of Exeter users.

Appending this data will require a number of geographical and data manipulation packages:


```r
if (!require("pacman")) install.packages("pacman") # easy package management
```

```
## Loading required package: pacman
```

```r
pacman::p_load(rgdal, rgeos, raster, sp, tidyverse)
```

## Retrieving the birds species richness data

The birds species richness data used for this exercise was from Biopama and is retrievable [here](https://geonode-rris.biopama.org/layers/geonode:birds_richness_compressed#/). The compressed .tif raster file from the original data is contained in this repository.

To load this TIF file into the global environment, we can use the `raster()` function and save it as an object (note, your file path will be wherever the TIF is saved):


```r
birds <- raster("C:/Users/lre203/OneDrive - University of Exeter/20160301_BH/20160301_Survey/20170713_Data/Exposure Assessment/Bird Richness/birds_richness_compressed.TIF")
```

