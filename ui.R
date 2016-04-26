library(shiny)

shinyUI(fluidPage(
    titlePanel("Prénoms dans Wikidata"),
    fluidRow(column(3,wellPanel(
      textInput("prenom", label = h4("Entrer un prénom"), 
                value = "Florian"),
      actionButton("action", label = "Récupérer",width="100%")
    )),
    column(9,wellPanel(
      fluidRow(column(10,sliderInput("dates",
                                     label = "Sélectionner les dates :",
                                     min = 0, max = 2010, value = c(1800, 2000),
                                     round=TRUE,step = 1,sep="",
                                     width="100%")),
               column(2,numericInput("regroup",label="Regroupement",
                                     value=10,width="100%"))))
    )),

    fluidRow(plotOutput("prenomMetiers"))
))
