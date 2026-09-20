# Shiny application entry point

library(shiny)
source('ui.R')
source('server.R')
shinyApp(ui = ui, server = server)
