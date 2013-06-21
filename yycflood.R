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

if(exists("raw.data")){old.data<-raw.data}

# Load Data from URLs
stations$url<-as.character(stations$url)
raw.data<-NULL
raw.data<-data.frame()
for(i in 1:nrow(stations))
{
  raw.data<-rbind(raw.data,
                  cbind(river=stations$river[i],station=stations$station[i],read.table(file=stations$url[i],sep=",",skip=22,header=TRUE,fill=TRUE,blank.lines.skip=TRUE,stringsAsFactors=FALSE)))
}

# Add old data, if not included in the latest data
old.data<-old.data[!which(old.data$Date...Time.in.MST %in% raw.data$Date...Time.in.MST),]
if(nrow(old.data)>0 & exists("old.data")){raw.data<-rbind(old.data,raw.data)}

# Remove Duplicates
raw.data<-raw.data[!duplicated(raw.data),]
save(raw.data,file="river_data.Rda")

# Clean-up & Format Data
colnames(raw.data)<-c("river","name","station.no","date","water.level.m","flow.m3s")

raw.data<-subset(raw.data,date!="")

raw.data$date<-as.POSIXct(strptime(raw.data$date,format="%Y-%m-%d %H:%M:%S"),tz="MST")
raw.data$flow.m3s<-as.numeric(raw.data$flow.m3s)
raw.data$water.level.m<-as.numeric(raw.data$water.level.m)

raw.data<-data.table(raw.data)
raw.data[,norm.factor:=min(water.level.m),by=c("name")]
raw.data[,norm.water.level:=water.level.m/norm.factor]
raw.data<-data.frame(raw.data)

# Pivot Data for plots
colnames(raw.data)<-c("river","name","station.no","date","Water Level (m)","Flow Rate (m3/s)","norm.factor","Normalized Water Level")
melted.data<-melt(raw.data,id.vars=c("river","name","station.no","date"))

# Filter data & Build Plot
plot.data<-subset(melted.data,date>=as.POSIXct("2013-06-19 12:00:00",tz="MST") & variable %in% c("Flow Rate (m3/s)","Normalized Water Level"))
p1<-ggplot(data=plot.data,aes(x=date,y=value))+geom_line(lwd=0.75,aes(color=name))+xlab("Date")+ylab("")+ggtitle("River Flow and Water Level - #yycflood")+facet_grid(river~.)+theme_bw()+theme(legend.position="bottom")+scale_color_discrete(name="")+facet_grid(variable~river,scales="free")

# Save to Image File
png("yycflood_riverplots.png",width=800,height=494,res=96)
grid.arrange(p1,nrow=1,sub = textGrob(paste0("Last Update: ",max(raw.data$date),",  Data: Alberta Environment (preliminary, subject to change) "), x=1, hjust=1, vjust=0,gp=gpar(fontsize=12)))
dev.off()

# Output newest date
max(plot.data$date)
