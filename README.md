# Tamiami Trail Flow Formula 

The Tamiami Trail Flow Formula (TTFF) provides weekly flow targets across Tamiami Trail. This page and the accompanying R package compare different approaches to modeling flow. The approaches use data from a network of stage, potential ET (PET), and rainfall gauges in WCA 3A and Everglades National Park. The specific approaches included here are detailed below:

&nbsp;

&nbsp;

## 1. Multiple linear regression

This formula operates on a subset of available rainfall, precipitation, and PET stations and has the form: 

<!---

[comment]: <>(formula generated from http://www.sciweavers.org/free-online-latex-equation-editor using input "Q_{t}^{sum}  =  \beta_{1}    \ast  S_{t}^{avg1}  +  \beta_{2}    \ast    S_{t}^{nesrs2} + \beta_{3}   \ast Q_{t-1}^{sum}  + \beta_{4}   \ast R_{t}^{avg}  + \beta_{5}   \ast PET_{t} + \beta_{6}   \ast ZA_{t}")

-->

![equation](http://www.sciweavers.org/tex2img.php?eq=Q_%7Bt%7D%5E%7Bsum%7D%20%3D%20%5Cbeta_%7B1%7D%20%5Cast%20S_%7Bt%7D%5E%7Bavg1%7D%20%2B%20%5Cbeta_%7B2%7D%20%5Cast%20S_%7Bt%7D%5E%7Bnesrs2%7D%20%2B%20%5Cbeta_%7B3%7D%20%5Cast%20Q_%7Bt-1%7D%5E%7Bsum%7D%20%2B%20%5Cbeta_%7B4%7D%20%5Cast%20R_%7Bt%7D%5E%7Bavg%7D%20%2B%20%5Cbeta_%7B5%7D%20%5Cast%20PET_%7Bt%7D%20%2B%20%5Cbeta_%7B6%7D%20%5Cast%20ZA_%7Bt%7D&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)
 

where:

Q<sub>t</sub><sup>sum</sup> is the target flow (sum of  S12C, S12D and S333) for the current (upcoming) week, t (cfs),

S<sub>t</sub><sup>avg1</sup> is the spatial average of observed stages (ft, NGVD) at WCA3A stages A-3, A-4 and A3-28 for the start of the current week t,

S<sub>t</sub><sup>nesrs2</sup> are observed stage (ft, NGVD) at ENP stage NESRS2 for the start of the current week,

Q<sub>t-1</sub> is the sum of observed releases at S12C, S12D and S333 for the previous week (cfs),

R<sub>t</sub> is the average weekly rainfall (in) for the entire WCA3A and BCNP for current week t (see map),

PET<sub>t</sub>  is the potential evaporation (in) at the Tamiami Trail Station (3AS3WX), and

ZA<sub>t</sub> is the Zone A regulation stage (ft, NGVD) value for time step t (beginning of current week).

Coefficients and associated standard errors:

|| Parameter	     | B<sub>0</sub>	  | B<sub>1</sub>	   | B<sub>2</sub>	   | B<sub>3</sub>	 | B<sub>4</sub> | B<sub>5</sub>      | B<sub>6</sub>  |
| :---            | :----: |  :----: |  :----: |  :----: |  ---: | 
| Coefficient	    | 318.42  | -44.62  | 0.644 | 24.32 | -96.31  | -221.79 |
| Standard Error  | 18.22	  | 18.50	 | 0.016 | 7.23 | 28.83  | 13.67 |


&nbsp;

&nbsp;


## 2. Segmented multiple linear regression

A two-variable segmented regression model has also been proposed. The data used in the model are stages in northeast Shark River Slough and WCA3A, with data breakpoints set where stages in northeast Shark River Slough reach 7.0' and 7.9' NGVD. This model follows the form: 

Q = B<sub>0</sub> + B<sub>1</sub> * S<sup>WCA3A</sup> + B<sub>2</sub> * S<sup>NESRS</sup> for x < 7.0

Q = B<sub>0</sub> + B<sub>1</sub> * S<sup>WCA3A</sup> + B<sub>3</sub> * S<sup>NESRS</sup> for 7.0 < x < 7.9 

Q = B<sub>0</sub> + B<sub>1</sub> * S<sup>WCA3A</sup> + B<sub>4</sub> * S<sup>NESRS</sup> for x > 7.9

Coefficients and associated standard errors:

| Parameter	     | B<sub>0</sub>	  | B<sub>1</sub>	   | B<sub>2</sub>	   | B<sub>3</sub>	 | B<sub>4</sub>  | 
| :---           | :----:  | :----: |  :----: |  :----: | ---: | 
| Coefficient	   | -3625.80   |  451.00 | 12.33  | 869.79 | 2132.31 |
| Standard Error | 187.66   | 21.71  | 26.46	 | 75.39  | 328.95 |


&nbsp;

&nbsp;

## 3. Principal component analysis 

This approach uses all available data. PCA reduces the dimensionality of the full dataset to a smaller number of truly independent variables. The PCA approach has two stages; first, PCA is applied to generate an initial flow estimate, which is then square-root transformed to generate a final estimate.

The PCA equation for the period of record has the following form:

<!---

[comment]: <> (formula generated from http://www.sciweavers.org/free-online-latex-equation-editor using input  " Q_{pred}  =  \sqrt{ \beta_{0} +  \beta_{1}    \ast    PC1 + \beta_{2}   \ast PC2  + \beta_{3}   \ast PC3  + \beta_{4}   \ast PC4 }")

-->

![equation](http://www.sciweavers.org/tex2img.php?eq=Q_%7Bt%7D%5E%7Bsum%7D%20%20%3D%20%20%5Csqrt%7B%20%5Cbeta_%7B0%7D%20%2B%20%20%5Cbeta_%7B1%7D%20%20%20%20%5Cast%20%20%20%20PC1%20%2B%20%5Cbeta_%7B2%7D%20%20%20%5Cast%20PC2%20%20%2B%20%5Cbeta_%7B3%7D%20%20%20%5Cast%20PC3%20%20%2B%20%5Cbeta_%7B4%7D%20%20%20%5Cast%20PC4%20%7D&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)

Coefficients and associated standard errors:

| Parameter	     | B<sub>0</sub>	  | B<sub>1</sub>	   | B<sub>2</sub>	   | B<sub>3</sub>	 | B<sub>4</sub> |  
| :---           | :----:  | :----: |  :----: |  :----: | ---: | 
| Coefficient	   | 15177.31   | -176.01  | -1032.68 | 6255.03 | 427.15 |
| Standard Error | 128.37 | 26.58 | 33.05	 | 72.68 | 90.22 |


&nbsp;

The final flow prediction is based on a square-root transformation of the PCA prediction:

Q = B<sub>0</sub> + B<sub>1</sub> * sqrt(Q<sub>pred</sub>)

| Parameter	     | B<sub>0</sub>	  | B<sub>1</sub>	   | 
| :---           | :----:  | ---: | 
| Coefficient	   | -19828.2 | 298.40 |
| Standard Error | 631.55 | 5.15 |

&nbsp;

&nbsp;


## R package installation and usage

The R package containing data and sample analysis can be installed from GitHub:


```
install.packages("devtools")
devtools::install_github("troyhill/TTFF")
```

This R package has the data from all rainfall, PET, and stage stations included in the analysis done by the COP modeling subteam in spring of 2019. 
