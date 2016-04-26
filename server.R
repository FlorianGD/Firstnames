library(shiny)
library(ggplot2)
library(WikidataR)
library(SPARQL)
source("mySPARQL.R") #until the SPARQL package is fixed for UTF-8
library(stringr)
library(tidyr)
library(dplyr)
library(ggthemes)
library(magrittr)
library(plotly)

theme_set(theme_minimal(12))

source("queries.R")  #to get the data from Wikidata

shinyServer(function(input, output, session) {
  
  dataPrenom<-eventReactive(input$action,{
    withProgress(value=0.2,message="Querying Wikidata",{
      res<-queryStreamWithProgress(input$prenom)
      minRes<-min(res$annee,na.rm=TRUE)
      maxRes<-max(res$annee,na.rm=TRUE)
      updateSliderInput(session,"dates",min=minRes,max=maxRes,
                        value=c(minRes,maxRes))
      res
    })
  })
  
  prenom<-eventReactive(input$action,{
    input$prenom
  })
  
  
  output$prenomMetiers<-renderPlot({
    ggplot(dataPrenom() %>% distinct(item),aes(x=annee))+
      geom_histogram(binwidth = input$regroup,aes(fill=pays))+
      ggtitle(paste("Années de naissance des", prenom() ,
                    "dans Wikidata, regroupé par",input$regroup,"ans"))+
      ylab("Nombre")+
      xlab(NULL) +
      scale_x_continuous(limits=c(input$dates[1],input$dates[2]))+
      theme(legend.position = "bottom")
  })
})
