# -------------------------------------------------------------------------------------------- #
# Code developed to gives the instructions allowing the calculations under R in order to create
# the outputs and update the results of the interface according to the choices of the user
#
# Authors: Anne-Isabelle Graux, Thomas Demarty
#
# Copyright (c) Anne-Isabelle Graux, 2023
# Email: anne-isabelle.graux@inrae.fr
# -------------------------------------------------------------------------------------------- #


library(shiny)
library(dplyr)

source("./utils/functions_and_htmlcode.R")

shinyServer(function(input, output) {
  
  #definition of the content to display in the information tab
  output$infotext <- renderText({HTML(infotext)})
  
  #names of the maps to be displayed according to the user's selection
  observe(print(c("RCP", input$rcp, "horizons", input$horizon)))
  
  names <- reactive({mapnames(
    dataset=input$dataset, 
    thi=input$thi, 
    threshold=input$threshold, 
    rcp=input$rcp, 
    horizons = input$horizon)})
  
  #names of the table headers according to the user's selection
  rcnames <- reactive({rowcolnames(input$horizon, input$rcp)})
  
  #names of the legend to be displayed according to the user's selection
  legend_name <- reactive({legendnames(input$threshold)})
  
  #
  infoThres <- reactive({threshtmlText(input$threshold)})
  
  #definition of the information to be displayed to explain what corresponds to the selected thermal comfort class
  output$thresinfo <- renderUI({HTML(infoThres())})
  
  #add an optional line to the expected display if the user has selected a CPR and four time horizons
  output$uiout <- renderUI({
    if(length(input$horizon)>length(input$rcp)){
      fluidRow(
        #column(1, align="center", ""),
        column(1, align = "center", textOutput("fourthRow"), style = "writing-mode: sideways-lr;background-color:#ccecf8"),
        column(3, align = "center", uiOutput("map10", height = "5%", width="5%")),
        column(3, align = "center", uiOutput("map11", height = "5%", width="5%")),
        column(3, align = "center", uiOutput("map12", height = "5%", width="5%")))
    }
  }) 
  
  #definition of the table headings
  output$headRow <- renderText({rcnames()[1]})
  output$firstRow <- renderText({rcnames()[2]})
  output$secondRow <- renderText({rcnames()[3]})
  output$thirdRow <- renderText({rcnames()[4]})
  output$fourthRow <- renderText({rcnames()[5]})
  
  #definition of the generated maps to be displayed according to the selection made
  # the maps 10 to 12 are not displayed if output$uiout is empty, i.e. if the user has selected one time horizon and three RCPs
  #src: The output file path
  #alt: Alternate text for the image
 
  output$map1  <- renderUI({tags$img(src=names()[1], alt=names()[1], height = "100%", width="100%")})
  output$map2  <- renderUI({tags$img(src=names()[2], alt=names()[2], height = "100%", width="100%")})
  output$map3  <- renderUI({tags$img(src=names()[3], alt=names()[3], height = "100%", width="100%")})
  output$map4  <- renderUI({tags$img(src=names()[4], alt=names()[4], height = "100%", width="100%")})
  output$map5  <- renderUI({tags$img(src=names()[5], alt=names()[5], height = "100%", width="100%")})
  output$map6  <- renderUI({tags$img(src=names()[6], alt=names()[6], height = "100%", width="100%")})
  output$map7  <- renderUI({tags$img(src=names()[7], alt=names()[7], height = "100%", width="100%")})
  output$map8  <- renderUI({tags$img(src=names()[8], alt=names()[8], height = "100%", width="100%")})
  output$map9  <- renderUI({tags$img(src=names()[9], alt=names()[9], height = "100%", width="100%")})
  output$map10 <- renderUI({tags$img(src=names()[10], alt=names()[10], height = "100%", width="100%")})
  output$map11 <- renderUI({tags$img(src=names()[11], alt=names()[11], height = "100%", width="100%")})
  output$map12 <- renderUI({tags$img(src=names()[12], alt=names()[12], height = "100%", width="100%")})
  
  
  #addition of the specific legend for each thermal comfort class
  output$mylegend <- renderUI({tags$img(src=legend_name(), alt=legend_name(), height = "100%", width="100%")})
  
})
