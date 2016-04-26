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
      queryStreamWithProgress(input$prenom)
    })
  })
  
  prenom<-eventReactive(input$action,{
    input$prenom
  })
  
  
  
  output$prenomMetiers<-renderPlot({
    ggplot(dataPrenom() %>% distinct(item),aes(x=annee))+
      geom_histogram(binwidth = input$regroup,aes(fill=pays))+
      ggtitle(paste("Répartition des", prenom() ,
                    "dans Wikidata, tous les",input$regroup,"ans"))+
      ylab("Nombre")+
      xlab("Année de naissance") +
      scale_x_continuous(limits=c(input$dates[1],input$dates[2]))+
      theme(legend.position = "bottom")
  })
})
