# FRED Housing Market Dashboard

A Shiny application that visualizes key housing market economic indicators from the Federal Reserve Economic Data (FRED) database.

## Features

- **Interactive Visualizations**: Dynamic line charts with hover details using Plotly
- **Multiple Data Views**: Both graphical and tabular data presentation
- **Real-time Data**: Direct API connection to FRED database
- **Comprehensive Metrics**: 15+ key housing market indicators
- **Statistical Analysis**: Summary statistics and period-over-period changes
- **Responsive Design**: Professional dashboard layout with shinydashboard
- **Data Export**: Download capabilities for further analysis

## Housing Market Indicators

The app includes the following economic indicators:

1. **Housing Starts** - New privately-owned housing units started
2. **New Home Sales** - New one family houses sold
3. **Existing Home Sales** - Existing home sales volume
4. **Housing Permits** - Building permits issued
5. **Median Home Price** - Median sales price of houses
6. **Case-Shiller Home Price Index** - S&P/Case-Shiller price index
7. **Housing Price Index (FHFA)** - All-transactions house price index
8. **30-Year Mortgage Rates** - Average 30-year fixed mortgage rate
9. **15-Year Mortgage Rates** - Average 15-year fixed mortgage rate
10. **Housing Inventory** - Monthly supply of houses
11. **Homeownership Rate** - Percentage of owner-occupied housing
12. **Construction Spending** - Residential construction spending
13. **Pending Home Sales Index** - Leading indicator of home sales
14. **Rental Vacancy Rate** - Percentage of rental units vacant
15. **Homeowner Vacancy Rate** - Percentage of owner units vacant

## Setup Instructions

### Prerequisites

You'll need R (version 4.0+) with the following packages:

```r
install.packages(c(
  "shiny",
  "shinydashboard", 
  "shinyWidgets",
  "fredr",
  "dplyr",
  "ggplot2",
  "plotly",
  "DT",
  "lubridate",
  "scales"
))
```

### FRED API Key Setup

The app supports secure API key management through multiple methods:

#### Method 1: Configuration File (Recommended for Development)
1. Create a `config.R` file in your app directory:
   ```r
   # config.R
   fred_api_key <- "your_32_character_api_key_here"
   ```
2. The `config.R` file is already included in `.gitignore` to keep your key secure

#### Method 2: Environment Variable (Recommended for Production)
Set the environment variable:
```r
Sys.setenv(FRED_API_KEY = "your_api_key_here")
```

Or add to your `.Renviron` file:
```
FRED_API_KEY=your_api_key_here
```

### Getting a FRED API Key

1. Visit the [FRED API documentation](https://fred.stlouisfed.org/docs/api/api_key.html)
2. Create a free account if you don't have one
3. Request an API key (it's free and instant)
4. Copy your 32-character API key

### Running the Application

1. **Download all files** to the same directory:
   - `app.R` (main application file)
   - `data_config.R` (housing series configuration)
   - `utils.R` (utility functions)
   - `.gitignore` (git ignore file)

2. **Set up your API key** using one of the methods above

3. **Set your working directory** to the folder containing the files

4. **Run the application**:
   ```r
   shiny::runApp()
   ```

5. **The app will automatically detect your API key** and show the status in the sidebar

6. **Select an indicator** and date range, then click "Load Data"

## File Structure

```
├── app.R              # Main Shiny application
├── data_config.R      # Housing market series definitions
├── utils.R            # Utility functions for data processing
└── README.md          # This file
```

## Usage Tips

- **Date Ranges**: Start with shorter date ranges (2-3 years) for faster loading
- **Frequency**: Monthly data provides the most detail, quarterly/annual for trends
- **API Limits**: FRED has rate limits, so avoid rapid repeated requests
- **Data Availability**: Some series have different start dates and update frequencies

## Troubleshooting

**Common Issues:**

1. **"Invalid API key"**: Ensure your key is exactly 32 characters and correctly entered
2. **"No data returned"**: Check if the date range is valid for the selected series
3. **Slow loading**: Large date ranges take longer; try shorter periods first
4. **Missing packages**: Install all required packages listed in prerequisites

**API Rate Limits:**
- FRED allows 120 requests per 60 seconds
- If you hit limits, wait a minute before making new requests

## Data Sources

All data is sourced from the Federal Reserve Economic Data (FRED) database, maintained by the Federal Reserve Bank of St. Louis. Each series includes detailed metadata about collection methodology, seasonal adjustments, and update frequency.

## Customization

The app is designed to be easily extensible:

- **Add new series**: Modify `housing_series` list in `data_config.R`
- **Change styling**: Update CSS in the UI section of `app.R`
- **Add visualizations**: Extend the server function with new plot types
- **Modify calculations**: Update utility functions in `utils.R`

## License

This application is provided as-is for educational and research purposes. Please respect FRED's terms of service when using their API.

## Support

For issues with:
- **The app**: Check the troubleshooting section above
- **FRED API**: Visit [FRED API documentation](https://fred.stlouisfed.org/docs/api/)
- **R packages**: Consult respective package documentation
