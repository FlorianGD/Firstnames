# Firstnames
Retrieving information of firstnames in Wikipedia via Wikidata

## Presentation
The idea is to study the data about given names from [wikipedia.org](http://wikipedia.org), and in particular, what are the occupations of people with that given name.
It turns out that scrapping wikipedia, getting the first names and the occupation would be difficult, as the data is unstructured. Hopefully, the [wikidata project](https://www.wikidata.org) exists. It gives access to structured data.

The tools are given in R, and you can see it in action on [shinyapps.io](http://floriangd.shinyapps.io/Firstnames). This provide visualizations, and enables you to get the dataframe in csv directly. You can download the files and run it locally within R, either trough the app (server.R and ui.R, with queries.R and mySPARL.R in the same folder), or using the functions in queries.R (with mySPARQL.R) directly.

You can knit the Firstnames.Rmd file to get a description of the functions and some examples.

## Files and functions

* __queries.R__ provides the main functions
	+ In particular, __queryStream__ takes the string of a firstname as an argument and gives the dataset.
	+ Note that __queryStreamWithProgress__ is the same, with an increase for the progress bar on the app, and is only useful within the shiny app.
* __mySPARQL.R__ is a rewrite of certain functions within the SPARQL package to include a support for UTF-8. Normally, it will soon be added to the package, so this won't be needed.
* __server.R__ and __ui.R__ are the files for the shiny app that [can be seen there](http://floriangd.shinyapps.io/Firstnames).

## Packages needed

All the packages are provided on CRAN.

### Minimal packages to get the informations:

* __WikidataR__ to get item and properties informations,
* __SPARQL__ for the main query,
* __dplyr__, __tidyr__ and __magrittr__ for data manipulation and cleaning.

### Packages for data visualization:

* __stringr__ for string manipulation,
* __wordcloud__ for a wordcloud,
* __ggplot2__ and __ggthemes__ for graphs,

### Packages to run the app

* __shiny__ and __shinyjs__

## Contribute

Do not hesitate to fork me and/or contact me for more informations.

Enjoy!

