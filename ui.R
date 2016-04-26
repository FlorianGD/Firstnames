library(shiny)

shinyUI(fluidPage(
    titlePanel("Prénoms dans Wikidata"),
    fluidRow(column(3,wellPanel(
      textInput("prenom", label = "Saisir un prénom", 
                value = "Florian"),
      actionButton("action", label = "Récupérer",width="100%",
                   icon=icon("wikipedia-w"))
    )),
    column(9,wellPanel(
      fluidRow(column(10,sliderInput("dates",
                                     label = "Sélectionner les dates :",
                                     min = 1700, max = 2010, value = c(1800, 2010),
                                     round=TRUE,step = 1,sep="",
                                     width="100%")),
               column(2,numericInput("regroup",label="Regroupement",
                                     value=10,width="100%"))))
    )),

    fluidRow(plotOutput("prenomMetiers"))
))
