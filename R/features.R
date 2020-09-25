colors_contains_min <- function(pals, colors, space) {
  res <- map(pals, color_contains_min, color = colors, space = space)
  res <- matrix(unlist(res), ncol = length(colors), byrow = TRUE)
  colnames(res) <- paste0("contains_min_", names(colors))
  tibble::as_tibble(res)
}

color_contains_min <- function(pal, color, space) {
  spectrum1 <- convert_colour(t(col2rgb(pal)), "rgb", space)
  spectrum2 <- convert_colour(t(col2rgb(color)), "rgb", space)

  res <- compare_colour(spectrum1, spectrum2, space, method = "cie2000")

  apply(res, 2, min)
}

colors_contains_all <- function(pals, colors, space) {
  res <- map(pals, color_contains_all, color = colors, space = space)
  res <- matrix(unlist(res), ncol = length(colors), byrow = TRUE)
  colnames(res) <- paste0("contains_all_", names(colors))
  tibble::as_tibble(res)
}

color_contains_all <- function(pal, color, space) {
  spectrum1 <- convert_colour(t(col2rgb(pal)), "rgb", space)
  spectrum2 <- convert_colour(t(col2rgb(color)), "rgb", space)

  res <- compare_colour(spectrum1, spectrum2, space, method = "cie2000")

  apply(res, 2, mean)
}

linear <- function(pal, space) {
  colors <- convert_colour(t(col2rgb(pal)), "rgb", space) %>%
    as.data.frame() %>%
    mutate(x = row_number())

  out <- suppressWarnings({lm(x ~ ., colors) %>%
    summary() %>%
    .$adj.r.squared})

  if(is.nan(out))
    return(0)

  out
}

linear_split <- function(pal, space) {
  colors <- convert_colour(t(col2rgb(pal)), "rgb", space) %>%
    as.data.frame()

  colors1 <- colors[seq_len(ceiling(nrow(colors) / 2)), ] %>%
    mutate(x = row_number())
  colors2 <- colors[seq_len(ceiling(nrow(colors) / 2)) + floor(nrow(colors) / 2), ] %>%
    mutate(x = row_number())

  out <- min(
    suppressWarnings({
      lm(x ~ ., colors1) %>%
      summary() %>%
      .$adj.r.squared}),
    suppressWarnings({lm(x ~ ., colors2) %>%
      summary() %>%
      .$adj.r.squared})
  )

  if(is.nan(out))
    return(0)

  out
}

min_distance <- function(pal, space) {
  spectrum1 <- convert_colour(t(col2rgb(pal)), "rgb", space)
  spectrum2 <- spectrum1

  mat <- compare_colour(spectrum1, spectrum2, space, method = "cie2000")
  min(mat[upper.tri(mat)])
}

max_distance <- function(pal, space) {
  spectrum1 <- convert_colour(t(col2rgb(pal)), "rgb", space)
  spectrum2 <- spectrum1

  mat <- compare_colour(spectrum1, spectrum2, space, method = "cie2000")
  max(mat[upper.tri(mat)])
}

iqr_distance <- function(pal, space) {
  spectrum1 <- convert_colour(t(col2rgb(pal)), "rgb", space)
  spectrum2 <- spectrum1

  mat <- compare_colour(spectrum1, spectrum2, space, method = "cie2000")
  IQR(mat[upper.tri(mat)])
}
