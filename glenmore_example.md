Example of Glenmore Reservoir Water Flow
========================================================

This is a hypothetical example with MANY assumptions of how the glenmore reservoir system will respond to precipitation.

**Disclaimer:** I'm not a hydrogeologist, and don't have any knowledge of how the systme actually works.

Here are some numbers about the Glenmore Reservoir:

```r
catchment.area <- 1210 * 1000^2  #1,210km^2
surface.area <- 3.84 * 1000^2  #3.84km^2
avg.depth <- 6.1  # 6.1m average depth
max.depth <- 21.1  # 21.1m max depth
```



If we then calculate the volumetric capacity of the reservoir assuming the average depth & surface area:

```r
capacity.avg <- surface.area * avg.depth
capacity.avg
```

```
## [1] 23424000
```


Now let's assume rain falls into the catchment area:

```r
precip.depth <- 0.07  # 70mm average precipitation over catchment area
precip.volume <- catchment.area * precip.depth
precip.volume
```

```
## [1] 84700000
```


Next let's use max out-flow of the Elbow River assumed to be ~ 600m3/s, to see how long it would take to dissipate
thus precipitation from Glenmore Reservoir:

```r
max.elbow <- 600  #m3/s
dissipation.time <- precip.volume/(max.elbow * 3600)
dissipation.time
```

```
## [1] 39.21
```


If we're lucky, we might have some extra 'storage' capacity available in the reservoir. Let's assume the surface area
doesn't change (for simplicity), and we have the ability to add ~ 5m of water level into the reservoir:

```r
water.level.capacity <- 5
spare.capacity <- surface.area * water.level.capacity
spare.capacity
```

```
## [1] 19200000
```


Next let's suppose inflow from the Elbow is occurring at 500m3/s, and we can flow 200m3/s without downstream flooding:

```r
reservoir.inflow <- 500  #m3/s
reservoir.outflow <- 300  #m3/s, assume
fill.time <- spare.capacity/((reservoir.inflow - reservoir.outflow) * 3600)
fill.time
```

```
## [1] 26.67
```

So it would take ~ 26.6667 hours to fill that spare capacity, after this, we would have to increase reservoir.outflow!






```r
summary(cars)
```

```
##      speed           dist    
##  Min.   : 4.0   Min.   :  2  
##  1st Qu.:12.0   1st Qu.: 26  
##  Median :15.0   Median : 36  
##  Mean   :15.4   Mean   : 43  
##  3rd Qu.:19.0   3rd Qu.: 56  
##  Max.   :25.0   Max.   :120
```


You can also embed plots, for example:


```r
plot(cars)
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8.png) 


