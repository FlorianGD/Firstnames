library(shiny)
library(ggplot2)
library(WikidataR)
library(SPARQL)
source("mySPARQL.R") #until the SPARQL package is fixed for UTF-8
library(stringr)
library(tidyr)
library(dplyr)
library(ggthemes)

theme_set(theme_minimal(12))

source("queries.R")  #to get the data from Wikidata

shinyServer(function(input, output, session) {
  
  dataPrenom<-eventReactive(input$action, {
    cleaningRes(mySPARQL(endpoint,
             sub("REPLACE_ID",selectionnerID(input$prenom),generic_query),
             ns=prefix,format = "xml")$results)
  })
  
  updateNumericInput(session, "dateDebut", value = min(dataPrenom()$annee))
  
  updateNumericInput(session, "dateFin", value = max(dataPrenom()$annee))
  
  output$text1<-renderText({
    paste0("This is your text: ",input$prenom)
  })
  
  output$prenomMetiers<-renderPlot({
    prenom<-word(dataPrenom()$nom[1])
    ggplot(dataPrenom() %>% distinct(item),aes(x=annee))+
      geom_histogram(binwidth = 10,aes(fill=pays))+
      ggtitle(paste("Répartition des", prenom,"dans Wikidata"))+
      ylab("Nombre")+
      xlab("Année de naissance")+
      scale_x_continuous(limits=c(input$dateDebut,input$dateFin))
      theme(legend.position = "bottom")
  })
})
