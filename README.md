# Tamiami Trail Flow Formula 
The Tamiami Trail Flow Formula (TTFF) provides weekly flow targets across Tamiami Trail. This page and the accompanying R package compare different approaches to modeling flow. The approaches use data from a network of stage, potential ET (PET), and rainfall gauges in WCA 3A and Everglades National Park. The specific approaches included here are:

1. Multiple linear regression

This formula takes the form: 

![equation](http://www.sciweavers.org/tex2img.php?eq=%20Q_%7Bt%7D%5E%7Bsum%7D%20%20%3D%20%20%20%5Cbeta_%7B1%7D%20%20%20%20%5Cast%20%20%20%20S_%7Bt%7D%5E%7Bnesrs2%7D%20%2B%20%5Cbeta_%7B3%7D%20%20%20%5Cast%20Q_%7Bt-1%7D%5E%7Bsum%7D%20%20%2B%20%5Cbeta_%7B4%7D%20%20%20%5Cast%20R_%7Bt%7D%5E%7BAvg%7D%20%20%2B%20%5Cbeta_%7B5%7D%20%20%20%5Cast%20PET_%7Bt%7D%20%2B%20%5Cbeta_%7B6%7D%20%20%20%5Cast%20ZA_%7Bt%7D&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)


where;
Q_t^sum is the target flow (sum of  S12C, S12D and S333) for the current (upcoming) week, t (cfs),

S_t^avg1 is the spatial average of observed stages (ft, NGVD) at WCA3A stages A-3, A-4 and A3-28 for the start of the current week t,

S_t^nesrs2 are observed stage (ft, NGVD) at ENP stage NESRS2 for the start of the current week,

Q_(t-1)^sum is the sum of observed releases at S12C, S12D and S333 for the previous week (cfs),

R_t^avg is the average weekly rainfall (in) for the entire WCA3A and BCNP.  (Figure X.X) for current week t (see map),

PET_t^1 is the potential evaporation (in) at the Tamiami Trail Station (3AS3WX), and

ZAt is the Zone A regulation stage (ft, NGVD) value for time step t (beginning of current week).

Coefficients and associated standard errors:

| Parameter	     | B1	   | B2	   | B3	 | B4   | B5     | B6 |
| :---            | :----: |  :----: |  :----: |  :----: |  ---: | 
| Coefficient	    | 318.42  | -44.62  | 0.644 | 24.32 | -96.31  | -221.79 |
| Standard Error  | 18.22	  | 18.50	 | 0.016 | 7.23 | 28.83  | 13.67 |



# Installation and usage

'COPmod' can be installed from GitHub:


```
install.packages("devtools")
devtools::install_github("troyhill/COPmod")
```
