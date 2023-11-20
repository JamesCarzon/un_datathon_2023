# About

This repository contains the work of the Scotty XD team for the United Nations Datathon, which occurred November 3rd to November 6th, 2023. 
The collaborators in this project are PhD students in the Department of Statistics and Data Science at Carnegie Mellon University, namely:
1. James Carzon
2. Margaret Ellingwood
3. Anni Hong
4. Peem Lerdputtipongporn
5. Maya Shen

# Dataset 
TODO: Describe some EDA and pre-processing steps. If possible, also discuss the trefsfsf
- Power Plant Data (Anni) 
- NO2 data: Sentinel-5P TROPOMI Tropospheric NO2 data downloaded from NASA EarthData. Details can be found in the EDA/no2_data_processing.R script
- Urban density data (Maya)
- Topographical and geographical data (Meg): Accessing the R-package on elevation, lat/long. 

# Background and Question Statement
Background and Question Statement: Air pollution has become a global health issue. According to the UNEP, 7 million people worldwide experience premature death due to air pollution (2019). Whereas closing down major sources of pollution is an evident policy solution, its implementation is difficult in practice. Not only must regulators balance pollution abatement with other objectives, such as economic development, they must also identify sources and quantity of pollution to act in the first place (OECD, 2018). To further complicate this issue, neighborhoods with mountainous topography (EEA) or high population density experience the impact of pollution more than other areas. In this project, we seek to answer a subset of this broad policy issue, namely:

“Is elevation in factory location associated with the amount of nitrogen dioxide?”

Specifically, nitrogen dioxide (known as NO2) is a common pollutant caused by both human activity and factory emissions. Pollutants such as NO2 tend to be trapped in low-level regions due to thermal inversion — a phenomenon where warmer air rises up and forms a blanket trapping harmful pollutants underneath. Through this question, our team hopes to
Visualize the region with high concentrations of NO2, in combination with urban density and factory locations. 
Quantify the relative impact of a factory's location on pollution in comparison to other factors. 
Suggest areas for future policy investigation, such as how the amount of NO2 would change if a factory is shut down, whether zoning improves NO2 circulation, etc.

# Analysis
Describe Gaussian Process model. 

# Results 
TODO: Link to Peem's video submission 
Our final submission can be linked here []
# Usage

The work in this repo depends on the following requirements:
* R libraries
  + reticulate
  + tidyverse
  + ncdf4
  + dplyr
  + melt
  + ggplot2 (optional)
  + RColorBrewer (optional)
* Python packages
  + numpy
  + matplotlib
  + pandas
  + scipy
  + scikit
