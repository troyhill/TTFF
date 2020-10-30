
# Estimating flow across Tamiami Trail

The Tamiami Trail Flow Formula (TTFF) provides weekly flow targets for water moving across Tamiami Trail through five water management structures: S12A, S12B, S12C, S12D, and S333. This page and the accompanying R package compare different approaches to modeling flow. These approaches use data from a network of stage, potential evapotranspiration (PET), and rainfall gauges in Water Conservation Area 3A (WCA3A) and Everglades National Park (ENP). Estimates from each model for the current week are shown immediately below, followed by descriptions of the individual approaches.

&nbsp;


## Current model values:


<!---

[comment]: <>(

![](https://github.com/troyhill/TTFF/blob/master/inst/figures/TTFFestimates.png "TTFF estimates")
)

-->

<img src="{{site.url}}/figures/TTFFestimates.png" style="display: block; margin: auto;" />


Figure 1. Observed flow through S333 and the four S12 structures during the past nine months (black line). Values shown are the average combined daily flow in a given week (average daily flow at five structures, summed for each week and then divided by 7). Flow estimates generated using [multiple linear regression](#multiple-linear-regression) (red), [segmented regression](#segmented-multiple-linear-regression) (blue), and [principal component analysis](#principal-component-analysis) (green) are also shown. 

&nbsp;


### Model performance

<img src="{{site.url}}/figures/predicted_vs_observed.png" style="display: block; margin: auto;" width="500" />


Figure 2. Relationships between observed flows during the past year and values predicted by each model. Flow estimates generated using [multiple linear regression](#multiple-linear-regression) (red), [segmented regression](#segmented-multiple-linear-regression) (blue), and [principal component analysis](#principal-component-analysis) (green). 

&nbsp;

&nbsp;


## Model descriptions

### Multiple linear regression

This formula operates on a subset of available rainfall, precipitation, and PET stations and has the form: 

<!---

[comment]: <>(formula generated from http://www.sciweavers.org/free-online-latex-equation-editor using input "Q_{t}^{sum}  =  \beta_{1}    \ast  S_{t}^{avg1}  +  \beta_{2}    \ast    S_{t}^{nesrs2} + \beta_{3}   \ast Q_{t-1}^{sum}  + \beta_{4}   \ast R_{t}^{avg}  + \beta_{5}   \ast PET_{t} + \beta_{6}   \ast ZA_{t}")

![equation](http://www.sciweavers.org/tex2img.php?eq=Q_%7Bt%7D%5E%7Bsum%7D%20%3D%20%5Cbeta_%7B1%7D%20%5Cast%20S_%7Bt%7D%5E%7Bavg1%7D%20%2B%20%5Cbeta_%7B2%7D%20%5Cast%20S_%7Bt%7D%5E%7Bnesrs2%7D%20%2B%20%5Cbeta_%7B3%7D%20%5Cast%20Q_%7Bt-1%7D%5E%7Bsum%7D%20%2B%20%5Cbeta_%7B4%7D%20%5Cast%20R_%7Bt%7D%5E%7Bavg%7D%20%2B%20%5Cbeta_%7B5%7D%20%5Cast%20PET_%7Bt%7D%20%2B%20%5Cbeta_%7B6%7D%20%5Cast%20ZA_%7Bt%7D&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)


-->


&nbsp;
         
<!---

[comment]: <>(

![](https://github.com/troyhill/TTFF/blob/master/inst/figures/eq1.png "multiple regression formula")
)

-->


<img src="{{site.url}}/figures/eq1.png" style="display: block; margin: auto;" />


&nbsp;

where:

Q<sub>t</sub><sup>sum</sup> is the target flow (sum of  S12A/B/C/D and S333) for the current (upcoming) week, t (cfs),

S<sub>t</sub><sup>avg1</sup> is the spatial average of observed stages (ft, NGVD) at WCA3A stages A-3, A-4 and A3-28 for the start of the current week t,

S<sub>t</sub><sup>nesrs2</sup> is observed stage (ft, NGVD) at ENP stage NESRS2 for the start of the current week,

Q<sub>t-1</sub> is the sum of observed releases at S12A/B/C/D and S333 for the previous week (cfs),

R<sub>t</sub> is the average weekly rainfall (in) for the entire WCA3A and BCNP for current week t (see map),

PET<sub>t</sub> is the potential evaporation (in) at the Tamiami Trail Station (3AS3WX), and

ZA<sub>t</sub> is the Zone A regulation stage (ft, NGVD) value for time step t (beginning of current week).

Coefficients and associated standard errors:

| Parameter	    | B<sub>1</sub>	   | B<sub>2</sub>	   | B<sub>3</sub>	 | B<sub>4</sub> | B<sub>5</sub>      | B<sub>6</sub>  |
| :---        | :----:     | :----: |  :----: |  :----: |  :----: |  ---: | 
| Coefficient	    | 318.42  | -44.62  | 0.644 | 24.32 | -96.31  | -221.79 |
| Standard Error  | 18.22	  | 18.50	 | 0.016 | 7.23 | 28.83  | 13.67 |
| t value  | 17.5	  | -2.4	 | 39.4 | 3.4 | -3.3  | -16.2 |

Adjusted R<sup>2</sup>: 0.93

&nbsp;



### Segmented multiple linear regression

A two-variable segmented regression model has also been proposed. The data used in the model are stages in northeast Shark River Slough and WCA3A, with data breakpoints set where stages in northeast Shark River Slough reach 7.0' and 7.9' NGVD. This model follows the form: 

Q = B<sub>0</sub> + B<sub>1</sub> * S<sup>WCA3A</sup> + B<sub>2</sub> * S<sup>NESRS</sup> for S<sup>NESRS</sup> < 7.0

Q = B<sub>0</sub> + B<sub>1</sub> * S<sup>WCA3A</sup> + B<sub>3</sub> * S<sup>NESRS</sup> for 7.0 < S<sup>NESRS</sup> < 7.9 

Q = B<sub>0</sub> + B<sub>1</sub> * S<sup>WCA3A</sup> + B<sub>4</sub> * S<sup>NESRS</sup> for S<sup>NESRS</sup> > 7.9

Coefficients and associated standard errors:

| Parameter	     | B<sub>0</sub>	  | B<sub>1</sub>	   | B<sub>2</sub>	   | B<sub>3</sub>	 | B<sub>4</sub>  | 
| :---           | :----:  | :----: |  :----: |  :----: | ---: | 
| Coefficient	   | -3625.80   |  451.00 | 12.33  | 869.79 | 2132.31 |
| Standard Error | 187.66   | 21.71  | 26.46	 | 75.39  | 328.95 |
| t value | -19.3   | 20.8  | 0.5	 | 11.5  | 6.6 |

Adjusted R<sup>2</sup>: 0.74

&nbsp;

### Principal component analysis 

This approach uses all available data. PCA reduces the dimensionality of the full dataset to a smaller number of statistically independent synthetic variables. A PCA is applied to a training dataset and then the model is used on recent data to generate a flow prediction.

The six-dimension PCA used here has the following form:

<!---

[comment]: <> (formula generated from http://www.sciweavers.org/free-online-latex-equation-editor using input  " Q_{pred}  =  \beta_{0} +  \beta_{1}    \ast    PC1 + \beta_{2}   \ast PC2  + \beta_{3}   \ast PC3  + \beta_{4}   \ast PC4   + \beta_{5}   \ast PC5   + \beta_{6}   \ast PC6 ")


![](https://github.com/troyhill/TTFF/blob/master/inst/figures/eqPCA.png "PCA formula")

-->


<img src="{{site.url}}/figures/eqPCA.png" style="display: block; margin: auto;" />



&nbsp;


Coefficients and associated standard errors:

| Parameter	     | B<sub>0</sub>	  | B<sub>1</sub>	   | B<sub>2</sub>	   | B<sub>3</sub>	 | B<sub>4</sub> |   B<sub>5</sub> |   B<sub>6</sub> |  
| :---           | :----:  | :----: |  :----: |  :----: | :----: | :----: | ---: | 
| Coefficient	| 721.6  | 344.1  | 145.3 | 105.5 | -134.2 | 150.6 | 97.7 |
| Standard Error  | 5.8   | 1.7    | 3.2	 | 3.4 | 3.5 | 3.8 | 4.8 |
| t value         | 124.8 | 201.1 | 45.2	 | 30.7 | -38.0 |39.1 | 20.3 | 

Adjusted R<sup>2</sup>: 0.96

&nbsp;



&nbsp;


## R package installation and usage

The R package containing data and sample analysis can be installed from GitHub:


```
install.packages("devtools")
devtools::install_github("troyhill/TTFF")

```

This R package has the data from all rainfall, PET, and stage stations included in the analysis done by the COP modeling subteam in spring of 2019. The analysis presented above can be generated using [this R script](https://github.com/troyhill/TTFF/blob/master/docs/TTFF_application_20190805.R).

[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/troyhill/TTFF?branch=master&svg=true)](https://ci.appveyor.com/project/troyhill/TTFF) [![Build Status](https://travis-ci.org/troyhill/TTFF.svg?branch=master)](https://travis-ci.org/troyhill/TTFF) 

