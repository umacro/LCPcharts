
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
require(rCharts)
require(shiny)
require(shinyjs)

shinyUI(fluidPage(
  useShinyjs(),
  titlePanel('Life cycle Profile'),
  fluidRow(
    column(2, 
           fileInput('file1', "import data file",
                     accept=c('text/csv', 'text/comma-separated-values,text/plain'))
           
    ),
    column(
      2,    uiOutput('times')
    ),
    column(
      2,    uiOutput('Factors')
    ),
    column(
      2,    uiOutput('hheight')
    ),
    column(
      2,      actionButton("drawlcp", "draw profile"),a("example data",href="http://ec2-52-192-143-167.ap-northeast-1.compute.amazonaws.com:3838/app/data/VRFLCPROFILE.csv")
      ,actionButton("drawex", "example profile")
    )
  ),
  mainPanel(
    uiOutput('text'),
    showOutput("myChart", "highcharts"),
    tableOutput('mytable')
  )
)
)
