ui <- shinyUI(
            navbarPage("University dispersion by conference", id="nav",
                 tabPanel("Interactive map",
                          div(class="outer",
                              
                              tags$head(
                                # Include custom CSS from http://bit.ly/1mWdMmw
                                includeCSS("/Users/user/Documents/R/projects/styles.css"),
                                includeScript("/Users/user/Documents/R/projects/gomap.js")
                              ),
                              
                              leafletOutput("map", width="100%", height="100%"),
                              
                              # Shiny versions prior to 0.11 should use class="modal" instead.
                              absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                            draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                            width = 330, height = "auto",
                                            
                                            h2("Conference explorer"),
                                            
                                            selectInput("conference", "Conference", unique(colleges$conf))
                              )
                          )
                 ),
                 tabPanel("Raw Data",
                          sidebarLayout(
                            sidebarPanel(
                              selectInput(inputId = "conf",
                                          label = "Choose a conference",
                                          choices = unique(as.character(colleges$conf)),
                                          multiple = FALSE)
                            ),
                            mainPanel(dataTableOutput("display"))
                          )
                 ),
                 tabPanel("Conference Dispersion",
                            mainPanel(dataTableOutput("displayDispersion"))
                            ),
                 conditionalPanel("false", icon("crosshair"))
))
