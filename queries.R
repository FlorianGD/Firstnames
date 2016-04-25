
library(WikidataR)
library(dplyr)
library(tidyr)
library(magrittr)
library(ggthemes)
library(plotly)
library(SPARQL)
library(wordcloud)
library(stringr)


selectionnerID<-function(nom){
  liste <- find_item(nom)
  id <-""
  for(i in 1:length(liste)){
    if(is.null(liste[[i]]$description)){
      next
    }
    if(grepl("given name",liste[[i]]$description)){ 
      id <- liste[[i]]$id
      break # we break on the first given name we find
    }
  }
  # If we haven't found given name, then we take the first id
  if(id==""){
    id<-liste[[1]]$id
  } 
  return(id)
}

endpoint <- "https://query.wikidata.org/bigdata/namespace/wdq/sparql"
#endpoint <- "https://query.wikidata.org/sparql"

prefix<-c("wd","<http://www.wikidata.org/entity/>",
          "wdt", "<http://www.wikidata.org/prop/direct/>",
          "wikibase","<http://wikiba.se/ontology#>")

generic_query <-"SELECT ?item ?itemLabel ?occupationLabel ?paysLabel ?annee
WHERE
{
  ?item wdt:P735 wd:REPLACE_ID .
  ?item wdt:P106 ?occupation .
  OPTIONAL {?item wdt:P569 ?anneeN} .
  OPTIONAL {?item wdt:P27 ?pays} .
  BIND(YEAR(?anneeN) as ?annee) .	
  SERVICE wikibase:label { bd:serviceParam wikibase:language \"fr,en\" }
  }
  ORDER BY DESC (?annee)"
  
selectionnerNom<-function(x,colonne,nom) {
  a<-x %>%
    separate_(colonne,c("debut",nom,"fin"),sep="\"",remove=TRUE) %>%
    select(-debut,-fin)
  a[,nom]<-factor(a[,nom])
  return(a)
}

cleaningRes<-function(resultats){
  resultats<-selectionnerNom(resultats,"itemLabel","nom")
  resultats<-selectionnerNom(resultats,"occupationLabel","metier")
  resultats<-selectionnerNom(resultats,"paysLabel","pays")
  return(resultats)
}

queryStream <- . %>% 
  selectionnerID %>% 
  sub("REPLACE_ID", . ,generic_query) %>% 
  mySPARQL(endpoint, . , 
           ns=prefix,format = "xml") %>% 
  use_series(results) %>% 
  cleaningRes()

