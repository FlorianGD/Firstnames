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
    withProgress(value=0.5,message="Fetching data from Wikidata.org...",{
      queryStream(input$prenom)
    })
  })
  
  prenom<-eventReactive(input$action,{
    input$prenom
  })
  output$text1<-renderText({
    paste0("Nombre de ligne : ",nrow(dataPrenom()),
           "\nClasse : ",class(dataPrenom()))
  })
  
  output$text2<-renderPrint({
    dataset<-dataPrenom()
    summary(dataset)
  })
  
  output$donnees<-renderTable({
    head(dataPrenom(), n = input$numHead)
  })
  
  
  output$prenomMetiers<-renderPlotly({
    ggplotly(ggplot(dataPrenom() %>% distinct(item),aes(x=annee))+
      geom_histogram(binwidth = 10,aes(fill=pays))+
      ggtitle(paste("Répartition des", prenom() ,"dans Wikidata"))+
      ylab("Nombre")+
      xlab("Année de naissance") +
      scale_x_continuous(limits=c(input$dates[1],input$dates[2]))+
      theme(legend.position = "bottom")
      )
  })
})
