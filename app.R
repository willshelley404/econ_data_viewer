# app.R - Main Shiny Application
# Housing Market Economic Data Dashboard using FRED API

# Load required libraries
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(fredr)
library(dplyr)
library(ggplot2)
library(plotly)
library(DT)
library(lubridate)
library(scales)

# Suppress warnings and messages globally
options(warn = -1)
suppressMessages(library(shiny))
suppressWarnings(library(shinydashboard))

# Source helper functions
suppressMessages(source("data_config.R"))
suppressMessages(source("utils.R"))

# Load API key from environment or config file
load_fred_api_key <- function() {
  # Try environment variable first (for production)
  api_key <- Sys.getenv("FRED_API_KEY")
  
  if (api_key == "") {
    # Try config file (for development)
    if (file.exists("config.R")) {
      suppressMessages(source("config.R"))
      api_key <- tryCatch(get("fred_api_key", envir = .GlobalEnv), error = function(e) "")
    }
  }
  
  if (api_key == "" || is.null(api_key)) {
    # Silent failure instead of stop
    return(NULL)
  }
  
  return(api_key)
}

# Set FRED API key
api_key_loaded <- FALSE
suppressWarnings(suppressMessages({
  api_key <- load_fred_api_key()
  if (!is.null(api_key)) {
    tryCatch({
      fredr_set_key(api_key)
      api_key_loaded <- TRUE
    }, error = function(e) {
      api_key_loaded <- FALSE
    })
  }
}))

# UI Definition
ui <- dashboardPage(
  skin = "blue",
  
  # Header
  dashboardHeader(
    title = "FRED Housing Market Dashboard",
    titleWidth = 300
  ),
  
  # Sidebar
  dashboardSidebar(
    width = 300,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("chart-line")),
      menuItem("Data Table", tabName = "datatable", icon = icon("table")),
      menuItem("About", tabName = "about", icon = icon("info-circle"))
    ),
    
    # Controls
    div(style = "padding: 15px;",
        h4("Data Controls", style = "color: white; margin-bottom: 15px;"),
        
        # API Status Display
        if (api_key_loaded) {
          div(style = "background-color: #28a745; color: white; padding: 8px; border-radius: 4px; margin-bottom: 15px; text-align: center;",
              icon("check-circle"), " API Key Loaded")
        } else {
          div(style = "background-color: #dc3545; color: white; padding: 8px; border-radius: 4px; margin-bottom: 15px; text-align: center;",
              icon("exclamation-triangle"), " API Key Not Found")
        },
        
        # Series Selection
        selectInput("selected_series", 
                    "Economic Indicator:",
                    choices = if(exists("housing_series")) housing_series else list("Default" = "HOUST"),
                    selected = "HOUST",
                    width = "100%"),
        
        # Date Range
        dateRangeInput("date_range",
                       "Date Range:",
                       start = Sys.Date() - years(10),
                       end = Sys.Date(),
                       format = "yyyy-mm-dd",
                       width = "100%"),
        
        # Frequency Selection
        selectInput("frequency",
                    "Data Frequency:",
                    choices = list("Monthly" = "m",
                                   "Quarterly" = "q", 
                                   "Annual" = "a"),
                    selected = "m",
                    width = "100%"),
        
        # Load Data Button
        actionButton("load_data", 
                     "Load Data", 
                     class = "btn-primary",
                     style = "width: 100%; margin-top: 10px;")
    )
  ),
  
  # Body
  dashboardBody(
    # Custom CSS
    tags$head(
      tags$style(HTML("
        .content-wrapper, .right-side {
          background-color: #f4f4f4;
        }
        .box {
          box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);
        }
        .nav-tabs-custom > .nav-tabs > li.active {
          border-top-color: #3c8dbc;
        }
        /* Hide error messages */
        .shiny-output-error {
          display: none;
        }
        .shiny-output-error:before {
          display: none;
        }
      "))
    ),
    
    tabItems(
      # Dashboard Tab
      tabItem(tabName = "dashboard",
              fluidRow(
                # Info Boxes
                valueBoxOutput("latest_value", width = 4),
                valueBoxOutput("change_mom", width = 4),
                valueBoxOutput("change_yoy", width = 4)
              ),
              
              fluidRow(
                box(
                  title = "Time Series Visualization", 
                  status = "primary", 
                  solidHeader = TRUE,
                  width = 12,
                  height = "500px",
                  plotlyOutput("time_series_plot", height = "440px")
                )
              ),
              
              fluidRow(
                box(
                  title = "Summary Statistics", 
                  status = "info", 
                  solidHeader = TRUE,
                  width = 6,
                  tableOutput("summary_stats")
                ),
                
                box(
                  title = "Data Information", 
                  status = "info", 
                  solidHeader = TRUE,
                  width = 6,
                  htmlOutput("series_info")
                )
              )
      ),
      
      # Data Table Tab
      tabItem(tabName = "datatable",
              fluidRow(
                box(
                  title = "Raw Data", 
                  status = "primary", 
                  solidHeader = TRUE,
                  width = 12,
                  DT::dataTableOutput("data_table")
                )
              )
      ),
      
      # About Tab
      tabItem(tabName = "about",
              fluidRow(
                box(
                  title = "About This Dashboard", 
                  status = "primary", 
                  solidHeader = TRUE,
                  width = 12,
                  HTML("
              <h3>FRED Housing Market Dashboard</h3>
              <p>This dashboard provides access to key housing market economic indicators from the Federal Reserve Economic Data (FRED) database.</p>
              
              <h4>Features:</h4>
              <ul>
                <li>Interactive time series visualizations</li>
                <li>Customizable date ranges and frequencies</li>
                <li>Summary statistics and data information</li>
                <li>Downloadable data tables</li>
                <li>Multiple housing market indicators</li>
              </ul>
              
              <h4>Data Source:</h4>
              <p>Data is sourced from the Federal Reserve Bank of St. Louis Economic Data (FRED) API.</p>
              
              <h4>Setup:</h4>
              <ol>
                <li>Set up your FRED API key using environment variable or config.R file</li>
                <li>Select an economic indicator and date range</li>
                <li>Click 'Load Data' to fetch and visualize the data</li>
              </ol>
            ")
                )
              )
      )
    )
  )
)

# Server Logic
server <- function(input, output, session) {
  
  # Reactive values
  values <- reactiveValues(
    data = NULL,
    series_info = NULL
  )
  
  # Load data when button is clicked
  observeEvent(input$load_data, {
    req(input$selected_series)
    
    if (!api_key_loaded) {
      # Silent failure - no notification
      return()
    }
    
    # Suppress all messages and warnings during data loading
    suppressWarnings(suppressMessages({
      tryCatch({
        # Fetch data (API key already set globally)
        data <- fredr(
          series_id = input$selected_series,
          observation_start = input$date_range[1],
          observation_end = input$date_range[2],
          frequency = input$frequency
        )
        
        # Fetch series information
        series_info <- fredr_series(series_id = input$selected_series)
        
        # Store in reactive values
        values$data <- data
        values$series_info <- series_info
        
      }, error = function(e) {
        # Silent error handling - no notifications
        values$data <- NULL
        values$series_info <- NULL
      })
    }))
  })
  
  # Value boxes with error handling
  output$latest_value <- renderValueBox({
    tryCatch({
      if (is.null(values$data)) {
        valueBox(
          value = "No Data",
          subtitle = "Latest Value",
          icon = icon("chart-line"),
          color = "light-blue"
        )
      } else {
        latest <- tail(values$data, 1)
        value_formatted <- tryCatch({
          if(exists("format_value")) {
            format_value(latest$value, values$series_info$units)
          } else {
            round(latest$value, 2)
          }
        }, error = function(e) round(latest$value, 2))
        
        valueBox(
          value = value_formatted,
          subtitle = paste("Latest Value -", format(latest$date, "%b %Y")),
          icon = icon("chart-line"),
          color = "light-blue"
        )
      }
    }, error = function(e) {
      valueBox(
        value = "Error",
        subtitle = "Latest Value",
        icon = icon("chart-line"),
        color = "light-blue"
      )
    })
  })
  
  output$change_mom <- renderValueBox({
    tryCatch({
      if (is.null(values$data) || nrow(values$data) < 2) {
        valueBox(
          value = "N/A",
          subtitle = "Month-over-Month Change",
          icon = icon("arrow-up"),
          color = "green"
        )
      } else {
        change <- tryCatch({
          if(exists("calculate_change")) {
            calculate_change(values$data, periods = 1)
          } else {
            # Simple calculation if function doesn't exist
            recent_values <- tail(values$data$value, 2)
            ((recent_values[2] - recent_values[1]) / recent_values[1]) * 100
          }
        }, error = function(e) 0)
        
        color <- if(change >= 0) "green" else "red"
        icon_name <- if(change >= 0) "arrow-up" else "arrow-down"
        
        valueBox(
          value = paste0(ifelse(change >= 0, "+", ""), round(change, 2), "%"),
          subtitle = "Month-over-Month Change",
          icon = icon(icon_name),
          color = color
        )
      }
    }, error = function(e) {
      valueBox(
        value = "Error",
        subtitle = "Month-over-Month Change",
        icon = icon("arrow-up"),
        color = "green"
      )
    })
  })
  
  output$change_yoy <- renderValueBox({
    tryCatch({
      if (is.null(values$data) || nrow(values$data) < 12) {
        valueBox(
          value = "N/A",
          subtitle = "Year-over-Year Change",
          icon = icon("calendar"),
          color = "yellow"
        )
      } else {
        change <- tryCatch({
          if(exists("calculate_change")) {
            calculate_change(values$data, periods = 12)
          } else {
            # Simple calculation if function doesn't exist
            values_vec <- values$data$value
            if(length(values_vec) >= 12) {
              current <- tail(values_vec, 1)
              year_ago <- values_vec[length(values_vec) - 11]
              ((current - year_ago) / year_ago) * 100
            } else {
              0
            }
          }
        }, error = function(e) 0)
        
        color <- if(change >= 0) "green" else "red"
        icon_name <- if(change >= 0) "arrow-up" else "arrow-down"
        
        valueBox(
          value = paste0(ifelse(change >= 0, "+", ""), round(change, 2), "%"),
          subtitle = "Year-over-Year Change",
          icon = icon(icon_name),
          color = color
        )
      }
    }, error = function(e) {
      valueBox(
        value = "Error",
        subtitle = "Year-over-Year Change",
        icon = icon("calendar"),
        color = "yellow"
      )
    })
  })
  
  # Time series plot with error handling
  output$time_series_plot <- renderPlotly({
    tryCatch({
      if (is.null(values$data)) {
        p <- ggplot() + 
          geom_text(aes(x = 0, y = 0, label = "Please load data to view visualization"), 
                    size = 6, color = "gray50") +
          theme_void()
        return(ggplotly(p))
      }
      
      series_name <- tryCatch({
        if(exists("housing_series")) {
          names(housing_series)[housing_series == input$selected_series]
        } else {
          input$selected_series
        }
      }, error = function(e) input$selected_series)
      
      p <- ggplot(values$data, aes(x = date, y = value)) +
        geom_line(color = "#3c8dbc", size = 1.2) +
        geom_point(color = "#3c8dbc", size = 1.5, alpha = 0.6) +
        labs(
          title = series_name,
          x = "Date",
          y = if(!is.null(values$series_info)) values$series_info$units else "Value",
          caption = if(!is.null(values$series_info)) paste("Source: FRED,", values$series_info$title) else "Source: FRED"
        ) +
        theme_minimal() +
        theme(
          plot.title = element_text(size = 16, face = "bold"),
          axis.title = element_text(size = 12),
          axis.text = element_text(size = 10),
          panel.grid.minor = element_blank()
        )
      
      ggplotly(p, tooltip = c("x", "y")) %>%
        layout(hovermode = "x unified")
    }, error = function(e) {
      p <- ggplot() + 
        geom_text(aes(x = 0, y = 0, label = "Unable to display chart"), 
                  size = 6, color = "gray50") +
        theme_void()
      ggplotly(p)
    })
  })
  
  # Summary statistics with error handling
  output$summary_stats <- renderTable({
    tryCatch({
      if (is.null(values$data)) {
        return(data.frame(Statistic = "No data loaded", Value = ""))
      }
      
      if(exists("create_summary_stats")) {
        create_summary_stats(values$data$value, values$series_info$units)
      } else {
        # Basic summary if function doesn't exist
        data.frame(
          Statistic = c("Mean", "Median", "Min", "Max", "Std Dev"),
          Value = c(
            round(mean(values$data$value, na.rm = TRUE), 2),
            round(median(values$data$value, na.rm = TRUE), 2),
            round(min(values$data$value, na.rm = TRUE), 2),
            round(max(values$data$value, na.rm = TRUE), 2),
            round(sd(values$data$value, na.rm = TRUE), 2)
          )
        )
      }
    }, error = function(e) {
      data.frame(Statistic = "Error", Value = "Unable to calculate")
    })
  }, striped = TRUE, hover = TRUE)
  
  # Series information with error handling
  output$series_info <- renderUI({
    tryCatch({
      if (is.null(values$series_info)) {
        return(HTML("<p>No series information available</p>"))
      }
      
      HTML(paste0(
        "<p><strong>Series ID:</strong> ", values$series_info$id, "</p>",
        "<p><strong>Title:</strong> ", values$series_info$title, "</p>",
        "<p><strong>Units:</strong> ", values$series_info$units, "</p>",
        "<p><strong>Frequency:</strong> ", values$series_info$frequency, "</p>",
        "<p><strong>Last Updated:</strong> ", format(as.Date(values$series_info$last_updated), "%B %d, %Y"), "</p>",
        "<p><strong>Notes:</strong> ", substr(values$series_info$notes, 1, 200), 
        ifelse(nchar(values$series_info$notes) > 200, "...", ""), "</p>"
      ))
    }, error = function(e) {
      HTML("<p>Series information unavailable</p>")
    })
  })
  
  # Data table with error handling
  output$data_table <- DT::renderDataTable({
    tryCatch({
      if (is.null(values$data)) {
        return(data.frame(Message = "Please load data to view table"))
      }
      
      display_data <- values$data %>%
        mutate(
          Date = format(date, "%Y-%m-%d"),
          Value = round(value, 4)
        ) %>%
        select(Date, Value) %>%
        arrange(desc(Date))
      
      DT::datatable(
        display_data,
        options = list(
          pageLength = 25,
          scrollX = TRUE,
          dom = 'Bfrtip',
          buttons = c('copy', 'csv', 'excel')
        ),
        extensions = 'Buttons',
        rownames = FALSE
      )
    }, error = function(e) {
      DT::datatable(
        data.frame(Message = "Error loading data table"),
        options = list(pageLength = 25),
        rownames = FALSE
      )
    })
  })
}

# Run the app with error suppression
suppressWarnings(suppressMessages(shinyApp(ui = ui, server = server)))