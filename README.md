
# Estimating flow across Tamiami Trail

The Tamiami Trail Flow Formula provides weekly flow targets for water moving across Tamiami Trail through the S12A-D and S333 water management structures. This page and the accompanying R package compare different approaches to modeling flow. These approaches use data from a network of stage, potential evapotranspiration, and rainfall gauges in Water Conservation Area 3A and Everglades National Park. Estimates from each model for the current week are shown immediately below, followed by descriptions of the individual approaches.

&nbsp;

&nbsp;

## Current model values:


&nbsp;

<!---

[comment]: <>(

<img src="{{site.url}}/inst/figures/TTFFestimates.png" style="display: block; margin: auto;" />

![](https://github.com/troyhill/TTFF/blob/master/inst/figures/TTFFestimates.png "TTFF estimates")
)

-->

![](https://github.com/troyhill/TTFF/blob/master/docs/figures/TTFFestimates.png "TTFF estimates")

&nbsp;

Figure 1. Observed summed weekly flow through S333 and the S12 structures during the past nine months (black line). Flow estimates for the current week are shown in red (multiple linear regression model) and blue (segmented regression model). 

&nbsp;

&nbsp;

&nbsp;

&nbsp;


## R package installation and usage

The R package containing data and sample analysis can be installed from GitHub:


```
install.packages("devtools")
devtools::install_github("troyhill/TTFF")
```

This R package has the data from all rainfall, PET, and stage stations included in the analysis done by the Combined Operational Plan modeling subteam in spring of 2019. 

[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/troyhill/TTFF?branch=master&svg=true)](https://ci.appveyor.com/project/troyhill/TTFF) [![Build Status](https://travis-ci.org/troyhill/TTFF.svg?branch=master)](https://travis-ci.org/troyhill/TTFF) 

