
# -------------------------------------------------------------------------------------------- #
# Code developed to define the interface, i.e. the layout and appearance of the application
#
# Authors: Anne-Isabelle Graux, Thomas Demarty
#
# Copyright (c) Anne-Isabelle Graux, 2023
# Email: anne-isabelle.graux@inrae.fr
# -------------------------------------------------------------------------------------------- #

library(shiny)
library(bslib)

options(encoding = 'UTF-8')

shinyUI(
    navbarPage(
        tags$head(
            tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
           ),
        theme = bs_theme(version = 4),# Bootstrap version 4
        title = "Evolution of thermal comfort of dairy cows under climate change", # Navigation bar title
        selected = "Information",
        tabPanel("Information", htmlOutput("infotext")),
        # Main app
        tabPanel("Viewer", sidebarLayout(
            sidebarPanel(
                width = 2,
                selectInput("dataset","Simulation dataset",
                    c("DRIAS-2020 simulations"="dataset_Drias2020",
                      "Jouzel-2014 simulations"="dataset_Jouzel2014")),
                selectInput("thi","Temperature Humidity Index",
                    c("THI1"="T1", 
                      "THI2"="T2", 
                      "THI3"="T3",
                      "THI4"="T4",
                      "THI5"="T5",
                      "THI6"="T6",
                      "THI7"="T7",
                      "THI8"="T8")),
                uiOutput("thinfo"),
                selectInput(
                    "threshold",
                    "Comfort conditions",
                    c(
                        "No stress" = "no_stress",
                        "Mild stress" = "mild_stress",
                        "Moderate stress" = "moderate_stress",
                        "Severe stress" = "severe_stress",
                        "Emergency" = "emergency"
                    )
                ),
                uiOutput("thresinfo"),
                tags$div(HTML("
                         <p class='border border-warning p-2 text-muted'><small>
                         Only 2 types of visualization are currently possible 
                         allowing either to compare several RCP (2.6, 4.5 and 
                         8.5) with the same time horizon (Ref, H1, H2 or H3) or 
                         to compare several time horizons (Ref, H1, H2 and H3) 
                         with the same RCP (2.6, 4.5 or 8.5).</small></p>")),
                checkboxGroupInput(
                    "rcp",
                    "Representative Concentration Pathway",
                    c("RCP2.6" = "2.6",
                      "RCP4.5" = "4.5",
                      "RCP8.5" = "8.5"),
                    selected = c("2.6", "4.5", "8.5")),
                checkboxGroupInput(
                    "horizon",
                    "Time period",
                    c(
                        "Ref (1976-2005)" = "Ref",
                        "H1 (2021-2050)" = "H1",
                        "H2 (2041-2070)" = "H2",
                        "H3 (2071-2100)" = "H3"),
                    selected = c("H3")
                ),
                submitButton("Apply Changes", width = "100%")
            ),
            mainPanel(
                width = 10,
                fluidRow(
                    column(10, align = "center", textOutput("headRow"), style = "background-color:#03a4e1;color:#ffffff;font-size:x-large;font-weight:bold")),
                fluidRow(
                    column(1, align = "center", ""),
                    column(3, align = "center", "Minimum (5th percentile)", style = "background-color:#ccecf8;margin:1em 0 1em 0;font-size:large;font-weight:bold"),
                    column(3, align = "center", "Median", style = "background-color:#ccecf8;margin:1em 0 1em 0;font-size:large;font-weight:bold"),
                    column(3, align = "center", "Maximum (95th percentile)", style = "background-color:#ccecf8;margin:1em 0 1em 0;font-size:large;font-weight:bold")),
                
                fluidRow(
                    column(1, align = "center", textOutput("firstRow"), style = "background-color:#ccecf8;font-size:large;font-weight:bold"),
                    column(3, align = "center", uiOutput("map1", height = "10%", width="10%")),
                    column(3, align = "center", uiOutput("map2", height = "10%", width="10%")),
                    column(3, align = "center", uiOutput("map3", height = "10%", width="10%"))),
                
                fluidRow(
                    column(1, align = "center", textOutput("secondRow"), style = "background-color:#ccecf8;font-size:large;font-weight:bold"),
                    column(3, align = "center", uiOutput("map4", height = "10%", width="10%")),
                    column(3, align = "center", uiOutput("map5", height = "10%", width="10%")),
                    column(3, align = "center", uiOutput("map6", height = "10%", width="10%"))),
                fluidRow(
                    column(1, align = "center", textOutput("thirdRow"), style = "background-color:#ccecf8;font-size:large;font-weight:bold"),
                    column(3, align = "center", uiOutput("map7", height = "5%", width="5%")),
                    column(3, align = "center", uiOutput("map8", height = "5%", width="5%")),
                    column(3, align = "center", uiOutput("map9", height = "5%", width="5%"))),


                tags$span(uiOutput("uiout"),style="background-color:#ccecf8;font-size:large;font-weight:bold"), #optional display of a fourth line in the case of four time horizons,
                #ajout
                fluidRow(
                  column(1, align = "center", ""),
                  column(9, align = "center", tags$h5("Number of days per year when dairy cows are in the selected comfort conditions"))
                ),
                #fin ajout
                fluidRow(
                    column(1, align = "center", ""),
                    column(9, align = "center", uiOutput("mylegend", height = "5%", width="5%")),
                )
                
            )
        ))
    )
)
