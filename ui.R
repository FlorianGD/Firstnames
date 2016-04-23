library(shiny)

shinyUI(fluidPage(
    titlePanel("Prénoms dans Wikidata"),
    
    sidebarLayout(
      sidebarPanel( 
        fluidRow(column(8,
                        textInput("prenom", label = h4("Entrer un prénom"), 
                  value = "Florian")),
                  column(4,h4(""), actionButton("action", label = "Récupérer"))),
        
        fluidRow(column(12,sliderInput("dates", 
                    label = "Sélectionner les dates :",
                    min = 1850, max = 2010, value = c(1900, 2000),
                    round=TRUE,step = 1,sep=""))),
        fluidRow(column(12,dateRangeInput("dates2", label = "Sélectionner les dates",
                       start="1900-01-01",end="2010-01-01",
                       startview = "year",language="fr",
                       separator="à"))),
        fluidRow(column(6,numericInput("dateDebut",label="Date début",value=1800,step=1)),
                 column(6,numericInput("dateFin",label="Date fin",value=2010,step=1)))
        ),
      mainPanel(
        h2("Graphique"),
        textOutput("text1"),
        plotOutput("prenomMetiers")
      )
    )
))
