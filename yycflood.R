# AB River Data

# Packages
require(data.table)
require(ggplot2)
require(reshape)
require(gridExtra)

# Load data (to maintain history, after AEnv removes older data...)
if(file.exists("river_data.Rda")){load("river_data.Rda")}

# Set-up Data Sources
stations<-data.frame()
stations<-rbind(stations,data.frame(river="Bow River",station="Lake Louise",url="http://www.environment.alberta.ca/apps/Basins/data/text/river/05BA001.csv"))
stations<-rbind(stations,data.frame(river="Bow River",station="Banff",url="http://www.environment.alberta.ca/apps/Basins/data/text/river/05BB001.csv"))
stations<-rbind(stations,data.frame(river="Bow River",station="Cochrane",url="http://www.environment.alberta.ca/apps/Basins/data/text/river/05BH005.csv"))
stations<-rbind(stations,data.frame(river="Bow River",station="Calgary",url="http://www.environment.alberta.ca/apps/Basins/data/text/river/05BH004.csv"))
stations<-rbind(stations,data.frame(river="Bow River",station="Carseland",url="http://www.environment.alberta.ca/apps/Basins/data/text/river/05BM002.csv"))
stations<-rbind(stations,data.frame(river="Bow River",station="Bassano",url="http://www.environment.alberta.ca/apps/Basins/data/text/river/05BM004.csv"))
stations<-rbind(stations,data.frame(river="Elbow River",station="Bragg Creek",url="http://www.environment.alberta.ca/apps/Basins/data/text/river/05BJ004.csv"))
stations<-rbind(stations,data.frame(river="Elbow River",station="Sarcee",url="http://www.environment.alberta.ca/apps/Basins/data/text/river/05BJ010.csv"))
stations<-rbind(stations,data.frame(river="Elbow River",station="Glenmore",url="http://www.environment.alberta.ca/apps/Basins/data/text/river/05BJ001.csv"))

res.stations<-data.frame()
res.stations<-rbind(res.stations,data.frame(reservoir="Glenmore",url="http://www.environment.alberta.ca/apps/Basins/data/text/lake/05BJ008.csv"))
res.stations<-rbind(res.stations,data.frame(reservoir="Ghost",url="http://www.environment.alberta.ca/apps/Basins/data/text/lake/05BE005.csv"))
res.stations<-rbind(res.stations,data.frame(reservoir="Bearspaw",url="http://www.environment.alberta.ca/apps/Basins/data/text/lake/05BH010.csv"))
res.stations<-rbind(res.stations,data.frame(reservoir="Horseshoe",url="http://www.environment.alberta.ca/apps/Basins/data/text/lake/TAU-004.csv"))
res.stations<-rbind(res.stations,data.frame(reservoir="Cascade",url="http://www.environment.alberta.ca/apps/Basins/data/text/lake/TAU-002.csv"))
res.stations<-rbind(res.stations,data.frame(reservoir="Barrier",url="http://www.environment.alberta.ca/apps/Basins/data/text/lake/05BF024.csv"))
res.stations<-rbind(res.stations,data.frame(reservoir="Spray Lake",url="http://www.environment.alberta.ca/apps/Basins/data/text/lake/05BC006.csv"))


if(exists("raw.data")){old.data<-raw.data}
if(exists("raw.res.data")){old.res.data<-raw.res.data}

# Load Data from URLs
stations$url<-as.character(stations$url)
res.stations$url<-as.character(res.stations$url)

raw.data<-NULL
raw.data<-data.frame()
for(i in 1:nrow(stations))
{
  raw.data<-rbind(raw.data,cbind(river=stations$river[i],station=stations$station[i],read.table(file=stations$url[i],sep=",",skip=22,header=TRUE,fill=TRUE,blank.lines.skip=TRUE,stringsAsFactors=FALSE)))
}

raw.res.data<-NULL
raw.res.data<-data.frame()
for(i in 1:nrow(res.stations))
{
  raw.res.data<-rbind(raw.res.data,cbind(reservoir=res.stations$reservoir[i],read.table(file=res.stations$url[i],sep=",",skip=20,header=TRUE,fill=TRUE,blank.lines.skip=TRUE,stringsAsFactors=FALSE)))
}

# Add old data, if not included in the latest data
if(exists("old.data")){
  old.data<-old.data[!which(old.data$Date...Time.in.MST %in% raw.data$Date...Time.in.MST),]
  if(nrow(old.data)>0 ){raw.data<-rbind(old.data,raw.data)}
}

if(exists("old.res.data"))
{
  old.res.data<-old.res.data[!which(old.res.data$Date...Time.in.MST %in% raw.res.data$Date...Time.in.MST),]
  if(nrow(old.res.data)>0){raw.res.data<-rbind(old.res.data,raw.res.data)}
}

# Remove Duplicates
raw.data<-raw.data[!duplicated(raw.data),]
save(raw.data,file="river_data.Rda")
raw.res.data<-raw.res.data[!duplicated(raw.res.data),]
save(raw.res.data,file="reservoir_data.Rda")

# Clean-up & Format Data
colnames(raw.data)<-c("river","name","station.no","date","water.level.m","flow.m3s")
colnames(raw.res.data)<-c("reservoir","station.no","date","water.level.m","storage.m3")


raw.data<-subset(raw.data,date!="")
raw.res.data<-subset(raw.res.data,date!="")

raw.data$date<-as.POSIXct(strptime(raw.data$date,format="%Y-%m-%d %H:%M:%S"),tz="MST")
raw.data$flow.m3s<-as.numeric(raw.data$flow.m3s)
raw.data$water.level.m<-as.numeric(raw.data$water.level.m)

raw.data<-data.table(raw.data)
raw.data[,norm.factor:=min(water.level.m),by=c("name")]
raw.data[,norm.water.level:=water.level.m/norm.factor]
raw.data<-data.frame(raw.data)

raw.res.data$date<-as.POSIXct(strptime(raw.res.data$date,format="%Y-%m-%d %H:%M:%S"),tz="MST")
raw.res.data$storage.m3<-as.numeric(raw.res.data$storage.m3)
raw.res.data$water.level.m<-as.numeric(raw.res.data$water.level.m)

raw.res.data<-data.table(raw.res.data)
raw.res.data[,norm.factor:=min(water.level.m),by=c("reservoir")]
raw.res.data[,norm.water.level:=water.level.m-norm.factor]
raw.res.data<-data.frame(raw.res.data)

# Pivot Data for plots
colnames(raw.data)<-c("river","name","station.no","date","Water Level (m)","Flow Rate (m3/s)","norm.factor","Normalized Water Level")
melted.data<-melt(raw.data,id.vars=c("river","name","station.no","date"))

colnames(raw.res.data)<-c("reservoir","station.no","date","Water Level (m)","Storage (m3)","norm.factor","Water Level Change (m)")
melted.res.data<-melt(raw.res.data,id.vars=c("reservoir","station.no","date"))

# Filter data & Build Plot
plot.data<-subset(melted.data,date>=as.POSIXct("2013-06-19 18:00:00",tz="MST") & variable %in% c("Flow Rate (m3/s)","Normalized Water Level"))
p1<-ggplot(data=plot.data,aes(x=date,y=value))+geom_line(lwd=0.75,aes(color=name))+xlab("Date")+ylab("")+ggtitle("River Flow and Water Level - #yycflood #abflood\n")+facet_grid(river~.)+theme_bw()+theme(legend.position="bottom")+scale_color_discrete(name="")+facet_wrap(variable~river,scales="free")+theme(axis.text.x = element_text(angle = -90, hjust = 1))

plot.res.data<-subset(melted.res.data,date>=as.POSIXct("2013-06-19 18:00:00",tz="MST") & variable %in% c("Storage (m3)","Water Level Change (m)"))
p2<-ggplot(data=plot.res.data,aes(x=date,y=value))+geom_line(lwd=0.75,aes(color=reservoir))+xlab("Date")+ylab("")+ggtitle("Reservoir Storage and Water Level - #yycflood #abflood\n")+facet_grid(variable~.,scales="free")+theme_bw()+theme(legend.position="bottom")+scale_color_discrete(name="")+theme(axis.text.x = element_text(angle = -90, hjust = 1))

# Save to Image File
png("yycflood_riverplots.png",width=1400,height=1730,res=96)
grid.arrange(p1,p2,nrow=2,sub = textGrob(paste0("Last Update: ",max(raw.data$date),"  -  Source: Alberta Environment (real-time data subject to revision) "), x=0.5, hjust=0.5, vjust=0,gp=gpar(fontsize=12)))
dev.off()

# Output newest date
max(plot.data$date)
