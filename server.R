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
      updateSelectizeInput(session,"pays",choices=c("Choisir un ou plusieurs"="",
                                                    "Tous",levels(res$pays)))
      res
    })
  })
  
  output$naissance<-renderPlot({
    if(is.null(input$pays) | "Tous" %in% input$pays){
      newdata<-dataPrenom() %>% 
        distinct(item)
    }
    else{
      newdata<-dataPrenom() %>%
        filter(pays %in% input$pays) %>%
        distinct(item)
    }
    
    minGraph<-floor(input$dates[1]/10)*10
    maxGraph<-ceiling(input$dates[2]/10)*10
    
    ggplot(newdata,aes(x=annee))+
      geom_histogram(binwidth = input$regroup,aes(fill=pays))+
      ggtitle(paste("Années de naissance des", isolate(input$prenom) ,
                    "dans Wikidata, regroupé par",input$regroup,"ans"))+
      ylab("Nombre")+
      xlab(NULL) +
      scale_x_continuous(limits=c(minGraph,maxGraph),
                         breaks=seq(minGraph,maxGraph,
                                    by=max(5,(maxGraph-minGraph)/10)))+
      scale_fill_hue("Pays")+
      theme(legend.position = "bottom")
  })
  
  output$metiers<-renderPlot({
    everyOccupation<-dataPrenom() %>% 
      group_by(metier) %>% 
      count(metier)
    
    if(input$cut){
      everyOccupation$occ<-mapply(couperMot,everyOccupation$metier)}
    else everyOccupation$occ<-everyOccupation$metier
    
    set.seed(14)
    wordcloud(everyOccupation$occ,everyOccupation$n,
              scale=c(input$scaleMax,input$scaleMin),
              min.freq=input$minFreq,
              colors=brewer.pal(6,"Dark2"),
              random.order = FALSE,rot.per=0.3)
  })
})
