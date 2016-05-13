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

theme_set(theme_minimal(12))

source("queries.R")  #to get the data from Wikidata

shinyServer(function(input, output, session) {
  disable("download")
  runjs("document.getElementById('prenom').focus()")
  output$info<-renderUI({
    switch(input$tabset,
           "tabAnnees"=tags$p(strong("Dates"),"permet de choisir l'intervalle à afficher ;",
                              br(),strong("Années"), "donne la largeur des barres de l'histogramme ;",
                              br(),strong("Pays"),"permet de filtrer sur un ou plusieurs pays ; laisser vide pour tous les pays,
                              la liste qui s'affiche est classée dans l'ordre décroissant 
                              du nombre de personnes ayant le prénom cherché dans ce pays.",
                              br(),em("Inconnu"),"indique que le pays n'est pas renseigné dans Wikidata."),
           "tabPays"=tags$p(strong("Pays"),"permet de sélectionner le nombre de pays à afficher ;",br(), 
                            em("Inconnu"),"indique que le pays n'est pas renseigné dans Wikidata."),
           "tabNuageMetiers"=tags$p(em("Attention")," : certains mots trop longs peuvent ne pas s'afficher.",br(),
                                    strong("Couper métiers"),"permet d'insérer un retour à la ligne si les mots contiennent un esapce ou tiret ;",
                                    br(),strong("Fréquence minimum"), "les métiers appraissant moins fréquemment que ce paramètre ne seront pas affichés ;" ,
                                    br(),strong("Echelle min"),"et",strong("Echelle max"), "permettent de régler la taille des mots, en fonction de leur fréquence.",
                                    br(),em("Note :"),"par construction de la requête, ne sont récupérées que les informations quand le métier est précisé. 
                                    Une personne peut avoir plusieurs métiers."),
           "tabMetiers"=tags$p(strong("Métiers"),"permet de sélectionner le nombre de métiers à afficher ;",br(), 
                               em("Note :"),"par construction de la requête, les informations ne sont récupérées que lorsque le métier est précisé. 
                               Une personne peut avoir plusieurs métiers.")
    )
  })
  
  dataPrenom<-eventReactive(input$action,{
    withProgress(value=0.2,message="Querying Wikidata",{
      disable("download")
      res<-queryStreamWithProgress(input$prenom)
      minRes<-min(res$annee,na.rm=TRUE)
      maxRes<-max(res$annee,na.rm=TRUE)
      updateSliderInput(session,"dates",min=minRes,max=maxRes,
                        value=c(minRes,maxRes))
      updateSelectizeInput(session,"pays",choices=c("Choisir un ou plusieurs"="",
                                                    names(sort(-table(res$pays)))))
      updateSliderInput(session,"nbMetiers",max=length(levels(res$metier)),
                        value=10)
      shinyjs::hide("pretitle")
      enable("download")
      res
    })
  })
  
  output$title<-renderUI({
    metier<- dataPrenom() %>% count(metier) %>% top_n(1,n) %>% use_series(metier)
    metiers<-paste(metier,collapse="/")
    pays<- dataPrenom() %>% count(pays) %>% top_n(1,n) %>% use_series(pays)
    pays2<-paste(pays,collapse = "/")
    tags$h2(paste("Dans Wikidata,",isolate(input$prenom),"est",metiers,"en",pays2))
  })
  
  output$download <- downloadHandler(
    filename = function() { 
      paste(input$prenom, '.csv', sep='') 
    },
    content = function(file) {
      write.csv(dataPrenom(), file)
    }
  )
  
  output$naissance<-renderPlot({
    if(is.null(input$pays)){
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
  
  output$histoMetier<-renderPlot({
    met<-dataPrenom() %>% 
      count(metier) %>% 
      arrange(desc(n)) %>% 
      top_n(input$nbMetiers,n) %>% 
      droplevels() 
    
    met$metier <-reorder(met$metier,met$n,identity)
    
    ggplot(data=met,aes(x=metier,y=n))+
      geom_bar(stat="identity",fill="darkorange")+
      scale_x_discrete(limits=levels(met$metier))+
      geom_text(aes(label=n),hjust=1.5,colour="white")+
      xlab(NULL)+
      ylab(NULL)+
      ggtitle(label = paste("Top",input$nbMetiers,"des métiers de",
                            isolate(input$prenom),"dans Wikidata"))+
      coord_flip()
  })
  
  output$histoPays<-renderPlot({
    topPays<-dataPrenom() %>% 
      count(pays) %>% 
      arrange(desc(n)) %>% 
      top_n(input$nbPays,n) %>% 
      droplevels() 
    
    topPays$pays <-reorder(topPays$pays,topPays$n,identity)
    
    ggplot(data=topPays,aes(x=pays,y=n))+
      geom_bar(stat="identity",fill="deepskyblue2")+
      scale_x_discrete(limits=levels(topPays$pays))+
      geom_text(aes(label=n),hjust=1.5)+
      xlab(NULL)+
      ylab(NULL)+
      ggtitle(label = paste("Top",input$nbPays,"des nationalités des",
                            isolate(input$prenom),"dans Wikidata"))+
      coord_flip()
  })
})
