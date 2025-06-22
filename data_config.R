# data_config.R
# Configuration file for housing market economic indicators

# Housing market related FRED series
housing_series <- list(
  "Housing Starts" = "HOUST",
  "New Home Sales" = "HSN1F",
  "Existing Home Sales" = "EXHOSLUSM495S",
  "Housing Permits" = "PERMIT",
  "Median Home Price" = "MSPUS",
  "Case-Shiller Home Price Index" = "CSUSHPISA",
  "Housing Price Index (FHFA)" = "USSTHPI",
  "Mortgage Rates (30-Year Fixed)" = "MORTGAGE30US",
  "Mortgage Rates (15-Year Fixed)" = "MORTGAGE15US",
  "Housing Inventory" = "MSACSR",
  "Homeownership Rate" = "RHORUSQ156N",
  "Construction Spending (Residential)" = "TLRESCONS",
  "Pending Home Sales Index" = "HPENDUSA",
  "Rental Vacancy Rate" = "RRVRUSQ156N",
  "Home Ownership Vacancy Rate" = "RHVRUSQ156N"
)

# Series descriptions for reference
series_descriptions <- list(
  "HOUST" = "New privately-owned housing units started (thousands of units, seasonally adjusted annual rate)",
  "HSN1F" = "New one family houses sold (thousands of units, seasonally adjusted annual rate)",
  "EXHOSLUSM495S" = "Existing home sales (thousands of units, seasonally adjusted annual rate)",
  "PERMIT" = "New privately-owned housing units authorized by building permits (thousands of units, seasonally adjusted annual rate)",
  "MSPUS" = "Median sales price of houses sold (dollars, not seasonally adjusted)",
  "CSUSHPISA" = "S&P/Case-Shiller U.S. National Home Price Index (index, seasonally adjusted)",
  "USSTHPI" = "All-Transactions House Price Index for the United States (index, seasonally adjusted)",
  "MORTGAGE30US" = "30-Year Fixed Rate Mortgage Average (percent, not seasonally adjusted)",
  "MORTGAGE15US" = "15-Year Fixed Rate Mortgage Average (percent, not seasonally adjusted)",
  "MSACSR" = "Monthly supply of houses (months, seasonally adjusted)",
  "RHORUSQ156N" = "Homeownership rate (percent, seasonally adjusted)",
  "TLRESCONS" = "Total construction spending: Residential (millions of dollars, seasonally adjusted annual rate)",
  "HPENDUSA" = "Pending home sales index (index, seasonally adjusted)",
  "RRVRUSQ156N" = "Rental vacancy rate (percent, seasonally adjusted)",
  "RHVRUSQ156N" = "Homeowner vacancy rate (percent, seasonally adjusted)"
)