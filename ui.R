library(shiny)

shinyUI(fluidPage(
    fluidRow(column(6,h1("Prénoms dans Wikidata")),
             column(6,wellPanel(fluidRow(
               column(6,textInput("prenom", label = "Saisir un prénom", 
                                          value = "Malika")),
               column(6,br(),
                      actionButton("action", label = "Récupérer",width="100%",
                                             icon=icon("wikipedia-w")))
               )))),
    fluidRow(
      column(6,wellPanel(fluidRow(
        column(10,sliderInput("dates",
                                     label = "Sélectionner les dates :",
                                     min = 1700, max = 2010, value = c(1800, 2010),
                                     round=TRUE,step = 1,sep="",
                                     width="100%")),
        column(2,numericInput("regroup",label="Années",
                                     value=10,width="100%"))))),
      column(6,wellPanel(fluidRow(
        column(2,checkboxInput("cut",label="Couper métiers",value=TRUE)),
        column(4,sliderInput("minFreq",label="Fréquence minimum",
                             min=0,max=100,value=2,step=1)),
        column(3,sliderInput("scaleMin",label="Echelle min",
                             min=0,max=2,step=0.1,value=0.5)),
        column(3,sliderInput("scaleMax",label="Echelle max",
                             min=1,max=6,step=0.5,value=3))
      )))
        
      ),
    fluidRow(column(6,plotOutput("naissance")),
             column(6,plotOutput("metiers"))
    )
))
