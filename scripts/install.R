# Parameters

packages <-
  c(
    "conflicted", 
    "curl", 
    "DBI", 
    "dbplyr", 
    "dplyr", 
    "duckplyr", 
    "ellmer", 
    "here", 
    "gander", 
    "ggplot2", 
    "magick", 
    "metaDigitise", 
    "pak",
    "purrr", 
    "scales", 
    "stringr", 
    "tibble", 
    "tesseract",
    "tuber",
    "ragnar", 
    "readr", 
    "RSQLite", 
    "usethis",
    "whisper"
  )

# Installs
install.packages(packages, repos = "http://cran.us.r-project.org")
pak::pak("tidyverse/ggbot2")