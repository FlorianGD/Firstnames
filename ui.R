library(shiny)
library(shinyjs)

shinyUI(fluidPage(title="Prénoms dans Wikidata",
  useShinyjs(),
  tags$h2(id="pretitle","Prénoms dans Wikidata"),
  uiOutput(outputId="title",inline=FALSE,container=tags$div),
  sidebarLayout(
    sidebarPanel(width=3,
                 textInput("prenom", label = "Saisir un prénom", 
                           value = "Malika"),
                 actionButton("action", label = " Récupérer",width="100%",
                              icon=icon("wikipedia-w")),
                 br(),
                 p("Les informations sont extraites de", a(href="https://www.wikidata.org","wikidata.org"),
                   "via",a(href="https://query.wikidata.org/", "SPARQL."),"Le code source est disponible sur",
                   a(href="https://github.com/ptiflus/Firstnames","GitHub.")),
                 uiOutput(outputId="info",inline=TRUE,container=tags$span),
                 br(),
                 downloadButton("download",label="Télécharger les données"),
                 p("Récupérez les données sous forme de fichier csv.")),
    mainPanel(width=9,
      tabsetPanel(id="tabset",type="tab",
                  tabPanel("Années de naissance",value="tabAnnees",
                           wellPanel(fluidRow(
                             column(6,sliderInput("dates",
                                                  label = "Dates",
                                                  min = 1700, max = 2010, value = c(1700, 2010),
                                                  round=TRUE,step = 1,sep="",
                                                  width="100%")),
                             column(2,sliderInput("regroup",label="Années",min=1,max=10,
                                                  value=10,width="100%")),
                             column(4,selectizeInput("pays",label="Pays",choices=c("Choisir un ou plusieurs"=""),
                                                     multiple=TRUE)))),
                           fluidRow(plotOutput("naissance"))
                           ),
                  tabPanel("Top des pays", value = "tabPays",
                           wellPanel(fluidRow(
                             sliderInput("nbPays",label="Nombre de pays",
                                         min=1,max=30,value=10,step=1))),
                           fluidRow(plotOutput("histoPays"))
                  ),
                  tabPanel("Nuage des métiers", value="tabNuageMetiers",
                           wellPanel(fluidRow(
                             column(2,checkboxInput("cut",label="Couper métiers",value=TRUE)),
                             column(3,sliderInput("minFreq",label="Fréquence minimum",
                                                  min=1,max=25,value=2,step=1)),
                             column(3,sliderInput("scaleMin",label="Echelle min",
                                                  min=0,max=2,step=0.1,value=0.5)),
                             column(4,sliderInput("scaleMax",label="Echelle max",
                                                  min=1,max=6,step=0.5,value=4.5))
                           )),
                           fluidRow(plotOutput("metiers"))
                  ),
                  tabPanel("Top des métiers",value = "tabMetiers",
                           wellPanel(fluidRow(
                             sliderInput("nbMetiers",label="Nombre de métiers",
                                         min=1,max=20,value=10,step=1))),
                           fluidRow(plotOutput("histoMetier"))
                  )
    )
  )
)))
