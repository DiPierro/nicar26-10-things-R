# Libraries
library(rvest)
library(stringr)
library(purrr)

# Code

# Assign BPPE Disciplinary actions page to a variable
base_url <- "https://www.bppe.ca.gov/enforcement/disciplinary_actions.shtml"
# browser()
# Fetch html
html <- read_html(base_url)

# Fetch pdf links
pdfs <- 
  html |> 
  # Filter to links
  html_elements("a") |>
  html_attr("href") |> 
  # Filter to enforcement actions
  str_subset("/enforcement/actions/.*pdf") |>
  # Format links to include prefix
  map_chr(
    .f = ~ str_interp("https://www.bppe.ca.gov${.}")
  ) |>
  # Some links have extra slashes that need to be removed
  map_chr(
    .f = ~ str_replace_all(str_replace_all(., "\\.\\.", ""), "\\/\\/", "/") 
  )|> 
  # Remove white space in link addresses
  map_chr(
    .f = ~ str_squish(.) 
  )|>
  # Remove any duplicate links
  unique()

# Download pdfs

# Create the pdfs directory if it doesn't exist
if (!dir.exists("pdfs")) {
  dir.create("pdfs", recursive = TRUE)
}

pdfs |> 
  map(function(url) {
    
    filename <- basename(url)
    file_path <- file.path("pdfs", filename)
    httr::GET(url, httr::write_disk(file_path))
    cat(file_path, "\n")
    Sys.sleep(0.5)
  })
