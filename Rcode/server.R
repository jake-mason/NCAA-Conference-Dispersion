server <- shinyServer(function(input, output){
  
  # reactive table for "Raw Data"  tab
  data <- reactive({
    validate(
      need(input$conf, "Choose a conference")
    )
    colleges[conf == input$conf]
  })
  
  # reactive table for "Conference Dispersion" tab
  dataDispersion <- reactive({
    confDispersion
  })
  
  # reactive table for map tab
  data_map <- reactive({
    validate(
      need(input$conference, "Conference")
    )
    colleges[conf == input$conference]
  })
  
  ## Interactive Map #################################################################
  
  # Create the map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = -93.85, lat = 37.45, zoom = 4)
  })
  
  # A reactive expression that returns the set of zips that are
  # in bounds right now
  zipsInBounds <- reactive({
    if (is.null(input$map_bounds))
      return(colleges[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    subset(colleges,
           latitude >= latRng[1] & latitude <= latRng[2] &
             longitude >= lngRng[1] & longitude <= lngRng[2])
  })
  
  # This observer is responsible for maintaining the circles and legend,
  # according to the variables the user has chosen to map to color and size.
  observe({
    filt <- colleges[input$conference]
    colorData <- filt[["absLongLat"]]
    
    # used for centroid of each conference
    meanLongitude <- mean(filt$longitude)
    meanLatitude <- mean(filt$latitude)
    
    pal <- colorBin("Greens", colorData, 6, pretty = FALSE)
    
    leafletProxy("map", data = filt) %>%
      clearShapes() %>%
      clearPopups() %>%
      # add centroid for each conference
      addRectangles(meanLongitude-0.2, meanLatitude+0.2, meanLongitude+0.2, meanLatitude-0.2, 
                    layerId = input$conference, fillColor="#000000") %>%
      # add circles for each school in the conference
      addCircles(~longitude, ~latitude, radius = ~sqrt(absLongLat)*60000, layerId=~team,
                 stroke=FALSE, fillOpacity=0.8, fillColor=pal(colorData)) %>%
      addLegend("bottomleft", pal=pal, values=colorData, title=input$conference,
                layerId="colorLegend")
  })
  
  # Show a popup at the given location
  showSchoolPopup <- function(school, lat, lng){
    selectedSchool <- data_map()[match(school,data_map()$team)]
    content <- as.character(tagList(
      tags$h4(school, selectedSchool$nickname),
      tags$strong(HTML(sprintf("%s, %s", selectedSchool$city, selectedSchool$state))), tags$br(),
      sprintf("Latitude: %s", round(selectedSchool$latitude, 2)), tags$br(),
      sprintf("Longitude: %s", round(selectedSchool$longitude, 2)), tags$br(),
      sprintf("Outlyingness Index: %s", round(selectedSchool$absLongLat, 2)), tags$br()
    ))
    leafletProxy("map") %>% addPopups(lng, lat, content, layerId = school)
  }
  
  # Show a popup for each conference's centroid (i.e. each conference's mean latitude & longitude)
  showCentroidPopup <- function(centroid, lat, lng){
    meanLatCentroid <- mean(data_map()$latitude)
    meanLngCentroid <- mean(data_map()$longitude)
    confCentroid <- unique(data_map()$conf)
    
    content <- as.character(tagList(
      tags$h4(sprintf("Centroid: %s",confCentroid)),
      sprintf("Latitude: %s", round(meanLatCentroid, 2)), tags$br(),
      sprintf("Longitude: %s", round(meanLngCentroid, 2)), tags$br()
    ))
    leafletProxy("map") %>% addPopups(lng, lat, content, layerId = input$conference)
  }
  
  # When map is clicked, show a popup with city info
  observe({
    leafletProxy("map") %>% clearPopups()
    event <- input$map_shape_click
    if (is.null(event))
      return()
    
    isolate({
      # if you click on a particular school's circle
      if(event$id %in% data_map()$team){
        showSchoolPopup(event$id, event$lat, event$lng)
      }
      # else show the conference's centroid data
      else{
        showCentroidPopup(event$id, event$lat, event$lng)
      }
    })
  })
  
  # display data table on "Raw Data" tab
  output$display <- renderDataTable({
    data()
  })
  
  # display data table on "Conference Dispersion" tab
  output$displayDispersion <- renderDataTable({
    dataDispersion()
  })
})
