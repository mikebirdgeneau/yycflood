Example of Glenmore Reservoir Water Flow
========================================================

This is a hypothetical example with MANY assumptions of how the glenmore reservoir system will respond to precipitation.
**Disclaimer:** I'm not a hydrogeologist, and don't have any knowledge of how the system actually works.

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


Next let's assume the Elbow River can safely flow at 150m3/s without downstream flooding, to see how long it would take to dissipate this precipitation from Glenmore Reservoir:
(Assuming that the water table is already high due to spring rain, and cannot absorb this precipitation, this all flows downstream?)

```r
max.elbow <- 150  #m3/s
dissipation.time <- precip.volume/(max.elbow * 3600)
dissipation.time
```

```
## [1] 156.9
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


Next let's suppose inflow from the Elbow is occurring at 500m3/s, and we can flow 150m3/s without downstream flooding (assumption):

```r
reservoir.inflow <- 500  #m3/s
reservoir.outflow <- 150  #m3/s, assume
fill.time <- spare.capacity/((reservoir.inflow - reservoir.outflow) * 3600)
fill.time
```

```
## [1] 15.24
```

So it would take ~ 15 hours to fill that spare capacity, after this, we would have to increase flow down the Elbow river from the Glenmore Dam... 

The problem is, at 150m3/s outflow, it would take 157 hours to dissipate the flow, but if we only have 5m of spare capacity (water level) in the reservoir, we can only maintain the 150m3/s of water flow for 15 before the capacity is full and the downstream flow has to increase.

There's a whole bunch of transient analysis that could be done to show the complexity of the system, but I'll leave that for the pros!
