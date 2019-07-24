# Tamiami Trail Flow Formula 
The Tamiami Trail Flow Formula (TTFF) provides weekly flow targets across Tamiami Trail. This page and the accompanying R package compare different approaches to modeling flow. The approaches use data from a network of stage, potential ET (PET), and rainfall gauges in WCA 3A and Everglades National Park. The specific approaches included here are detailed below:

## 1. Multiple linear regression

This formula operates on a subset of available rainfall, precipitation, and PET stations and has the form: 

[//] # (formula generated from http://www.sciweavers.org/free-online-latex-equation-editor using input "Q_{t}^{sum}  =  \beta_{1}    \ast  S_{t}^{avg1}  +  \beta_{2}    \ast    S_{t}^{nesrs2} + \beta_{3}   \ast Q_{t-1}^{sum}  + \beta_{4}   \ast R_{t}^{avg}  + \beta_{5}   \ast PET_{t} + \beta_{6}   \ast ZA_{t}")


![equation](http://www.sciweavers.org/tex2img.php?eq=Q_%7Bt%7D%5E%7Bsum%7D%20%20%3D%20%20%5Cbeta_%7B1%7D%20%20%20%20%5Cast%20%20S_%7Bt%7D%5E%7Bavg1%7D%20%20%2B%20%20%5Cbeta_%7B2%7D%20%20%20%20%5Cast%20%20%20%20S_%7Bt%7D%5E%7Bnesrs2%7D%20%2B%20%5Cbeta_%7B3%7D%20%20%20%5Cast%20Q_%7Bt-1%7D%5E%7Bsum%7D%20%20%2B%20%5Cbeta_%7B4%7D%20%20%20%5Cast%20R_%7Bt%7D%5E%7Bavg%7D%20%20%2B%20%5Cbeta_%7B5%7D%20%20%20%5Cast%20PET_%7Bt%7D%20%2B%20%5Cbeta_%7B6%7D%20%20%20%5Cast%20ZA_%7Bt%7D&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)


where:

Q_t^sum is the target flow (sum of  S12C, S12D and S333) for the current (upcoming) week, t (cfs),

S_t^avg1 is the spatial average of observed stages (ft, NGVD) at WCA3A stages A-3, A-4 and A3-28 for the start of the current week t,

S_t^nesrs2 are observed stage (ft, NGVD) at ENP stage NESRS2 for the start of the current week,

Q_(t-1)^sum is the sum of observed releases at S12C, S12D and S333 for the previous week (cfs),

R_t^avg is the average weekly rainfall (in) for the entire WCA3A and BCNP for current week t (see map),

PET_t^1 is the potential evaporation (in) at the Tamiami Trail Station (3AS3WX), and

ZAt is the Zone A regulation stage (ft, NGVD) value for time step t (beginning of current week).

Coefficients and associated standard errors:

| Parameter	     | B1	   | B2	   | B3	 | B4   | B5     | B6 |
| :---            | :----: |  :----: |  :----: |  :----: |  ---: | 
| Coefficient	    | 318.42  | -44.62  | 0.644 | 24.32 | -96.31  | -221.79 |
| Standard Error  | 18.22	  | 18.50	 | 0.016 | 7.23 | 28.83  | 13.67 |



## 2. Segmented regression

A segmented regression model has also been proposed. The model uses breakpoints defined by stages in northeast Shark River Slough of 7.0' and 7.9'. 



## 3. Principal component analysis 

This approach uses all available data. PCA reduces the dimensionality of the full dataset to a smaller number of truly independent variables. 

 [//] # (formula generated from http://www.sciweavers.org/free-online-latex-equation-editor using input  " Q_{t}^{sum}  =  \sqrt{ \beta_{0} +  \beta_{1}    \ast    PC1 + \beta_{2}   \ast PC2  + \beta_{3}   \ast PC3  + \beta_{4}   \ast PC4 }")

![equation](http://www.sciweavers.org/tex2img.php?eq=Q_%7Bt%7D%5E%7Bsum%7D%20%20%3D%20%20%5Csqrt%7B%20%5Cbeta_%7B0%7D%20%2B%20%20%5Cbeta_%7B1%7D%20%20%20%20%5Cast%20%20%20%20PC1%20%2B%20%5Cbeta_%7B2%7D%20%20%20%5Cast%20PC2%20%20%2B%20%5Cbeta_%7B3%7D%20%20%20%5Cast%20PC3%20%20%2B%20%5Cbeta_%7B4%7D%20%20%20%5Cast%20PC4%20%7D&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)

Coefficients and associated standard errors:

| Parameter	     | B0	  | B1	   | B2	   | B3	 | B4  
| :---           | :----:  | :----: |  :----: |  :----: | ---: | 
| Coefficient	   | 0	   | 0  | -44.62  | 0.644 | -221.79 |
| Standard Error | 0	   | 18.22	  | 18.50	 | 28.83  | 13.67 |




## R package installation and usage

The R package containing data and sample analysis can be installed from GitHub:


```
install.packages("devtools")
devtools::install_github("troyhill/TTFF")
```

This R package has the data from all rainfall, PET, and stage stations included in the analysis done by the COP modeling subteam in spring of 2019. 
