library(shiny)
library(shinyjs)

shinyUI(fluidPage(
  useShinyjs(),
    fluidRow(column(6,h1("Prénoms dans Wikidata")),
             column(6,wellPanel(fluidRow(
               column(4,textInput("prenom", label = "Saisir un prénom", 
                                          value = "Malika")),
               column(4,br(),
                      actionButton("action", label = "Récupérer",width="100%",
                                             icon=icon("wikipedia-w"))),
               column(4,br(),
                      downloadButton("download",label="Télécharger"))
               )))),
    fluidRow(
      column(4,wellPanel(fluidRow(
        column(6,sliderInput("dates",
                                     label = "Dates",
                                     min = 1700, max = 2010, value = c(1800, 2010),
                                     round=TRUE,step = 1,sep="",
                                     width="100%")),
        column(2,sliderInput("regroup",label="Années",min=1,max=10,
                                     value=10,width="100%")),
        column(4,selectizeInput("pays",label="Pays",choices=c("Choisir un ou plusieurs"="","Tous"),
                                multiple=TRUE))))),
      column(4,wellPanel(fluidRow(
        column(2,checkboxInput("cut",label="Couper métiers",value=TRUE)),
        column(4,sliderInput("minFreq",label="Fréquence minimum",
                             min=1,max=25,value=2,step=1)),
        column(3,sliderInput("scaleMin",label="Echelle min",
                             min=0,max=2,step=0.1,value=0.5)),
        column(3,sliderInput("scaleMax",label="Echelle max",
                             min=1,max=6,step=0.5,value=3))
      ))),
      column(4,wellPanel(fluidRow(
        sliderInput("nbMetiers",label="Nombre de métiers",
                    min=1,max=20,value=10,step=1)
      )))
        
      ),
    fluidRow(column(4,plotOutput("naissance")),
             column(4,plotOutput("metiers")),
             column(4,plotOutput("histoMetier"))
    )
))
