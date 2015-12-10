
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
require(rCharts)
library(shiny)
require(shinyjs)

shinyServer(function(input, output) {
  output$text = renderUI({
    helpText()
  })
  output$times = renderUI({
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    LP<-read.table(inFile$datapath,sep=",",header=T,fileEncoding = "GBK")
    
    selectInput('times', 'Select Time', names(LP))
  })
  output$Factors = renderUI({
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    LP<-read.table(inFile$datapath,sep=",",header=T,fileEncoding = "GBK")
    
    selectInput('Factors', 'Select Factors Columns', names(LP),multiple = TRUE)
  }) 
  output$hheight=renderUI({
    sliderInput("hheight","Height",min=200,max=2400,value=400,step = 1)
  })
  output$mytable=renderTable({
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    LP<-read.table(inFile$datapath,sep=",",header=T,fileEncoding = "GBK")
  })
  # Take an action every time button is pressed;
  # here, we just print a message to the console
  observe({
    toggleState(id = "drawlcp", condition = !is.null(input$Factors))
  })
  # Take a reactive dependency on input$button, but
  # not on any of the stuff inside the function
  df <- eventReactive(input$drawlcp, {
    inFile <- input$file1
    if (is.null(inFile))
      return(NULL)
    LP<-read.table(inFile$datapath,sep=",",header=T,fileEncoding = "GBK")
    #LP<-read.table(file="http://ec2-52-192-38-8.ap-northeast-1.compute.amazonaws.com:3838/myproject/mydata/VRFLCPROFILE.csv",sep=",",header=T,fileEncoding = "GBK")
    time <-input$times#names(LP)[5] #select.list(names(LP),preselect = NULL, multiple = FALSE,title = "选择时间列", graphics = TRUE)
    showlist <-input$Factors# names(LP)[6:10] #select.list(names(LP),preselect = NULL, multiple = T,title = "按Ctrl选择要绘制的因子", graphics = TRUE)
    is.categorical <- function(x) is.factor(x) || is.character(x)
    ay <- lapply(1:length(showlist),function(i){
      if (is.categorical(LP[,showlist[i]])){
        list(height =paste(95/length(showlist),"%",sep="") ,top=paste(100*(i-1)/length(showlist),"%",sep=""),labels=list(align="left"),title=list(offset=20,text=showlist[i]),offset=20,categories = c(unique(as.character(LP[,showlist[i]]))), replace = T)
      }else {
        list(height =paste(95/length(showlist),"%",sep="") ,top=paste(100*(i-1)/length(showlist),"%",sep=""),labels=list(align="left"),title=list(offset=20,text=showlist[i]),offset=20)
      }
    })
    h1 <- Highcharts$new()
    h1$chart(type = "line")
    for(i in 1:length(showlist)){
      if (is.categorical(LP[,showlist[i]])){
        
        h1$series(data = toJSONArray(data.frame(x=LP[,time],y=as.numeric(LP[,showlist[i]])-1,z=LP[,showlist[i]]),json = F), name = showlist[i],yAxis=i-1,step="left") 
      }else {
        h1$series(data = toJSONArray(data.frame(x=LP[,time],y=as.numeric(LP[,showlist[i]]),z=LP[,showlist[i]]),json = F), name = showlist[i],yAxis=i-1,step="left") 
        
      }
      
      
    }
    #         h1$series(data = toJSONArray2(data.frame(LP[,time],LP[,showlist[2]]),json = F, names = F), name = showlist[1],yAxis=0,step="left")
    #         h1$series(data = toJSONArray2(data.frame(LP[,time],LP[,showlist[1]]),json = F, names = F), name = showlist[1],yAxis=1,step="left")
    #         h1$series(data = toJSONArray2(data.frame(LP[,time],LP[,showlist[1]]),json = F, names = F),name = showlist[1],yAxis=2,step="left")
    h1$xAxis(crosshair=TRUE)
    h1$yAxis(ay)
    
    h1$tooltip(formatter = "#!function () {
               var s = '<b>' + this.x + '</b>';
               
               $.each(this.points, function () {
               s += '<br/>'+this.series.name +':'+ this.point.z;
               });
               
               return s;
  }!#",shared=T)
    #h1$tooltip(shared=T)
    h1$chart(zoomType='x',panning=T,panKey='ctrl')
    h1$params$width=1200
    h1$params$height=input$hheight
    h1$legend(verticalAlign="top")
    h1$exporting(enabled = T)
    h1
    
})
ex <- eventReactive(input$drawex,{
  
})
output$myChart=renderChart2({
  df()
})
})
