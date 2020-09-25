## code to prepare `color_hex` dataset goes here

library(tidyverse)
library(rvest)

extract_color_hex <- function(id) {
  html <- paste0("https://www.color-hex.com/color-palette/", id) %>%
    read_html()

  pal <- html %>%
    html_nodes('table') %>%
    html_table() %>%
    .[[c(1, 2)]]

  name <- html %>%
    html_nodes('div[id="breadcrumb"] em') %>%
    html_text()

  list(name, pal)
}

clean_raw_palettes <- function(x) {
  pals <- x %>%
    map("result") %>%
    compact()

  res <- map(pals, 2)
  names(res) <- map_chr(pals, 1)
  res
}
color_hex_palettes_raw <- map(98399 - seq_len(1000),
                              ~safely(extract_color_hex)(.x))

color_hex_palettes <- clean_raw_palettes(color_hex_palettes_raw)

usethis::use_data(color_hex_palettes, overwrite = TRUE)
