library(shiny)

shinyUI(fluidPage(
    titlePanel("Prénoms dans Wikidata"),
    
    sidebarLayout(
      sidebarPanel( 
        fluidRow(textInput("prenom", label = h4("Entrer un prénom"), 
                  value = "Florian")),
        
        fluidRow(actionButton("action", label = "Récupérer")),
        
        fluidRow(sliderInput("dates",
                    label = "Sélectionner les dates :",
                    min = 0, max = 2010, value = c(1800, 2000),
                    round=TRUE,step = 1,sep="")),
        fluidRow(numericInput("numHead",
                              label="Number of rows to display",
                              value=10))
        ),
      mainPanel(
        textOutput("text1"),
        plotOutput("prenomMetiers"),
        verbatimTextOutput("text2"),
        tableOutput("donnees")
      )
    )
))
