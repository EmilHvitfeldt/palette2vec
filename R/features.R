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

fast_r_squared <- function(x) {
  y <- seq_len(nrow(x))

  fit <- .lm.fit(x, y)

  r <- fit$residuals
  f <- y - r
  mss <- sum(f ^ 2)
  rss <- sum(r ^ 2)
  r.squared <- mss/(mss + rss)
  r.squared
}

linear <- function(pal, space) {
  colors <- convert_colour(t(col2rgb(pal)), "rgb", space)

  out <- fast_r_squared(colors)

  if(is.nan(out))
    return(0)

  out
}

linear_split <- function(pal, space) {
  if (length(pal) < 4) {
    return(0)
  }

  colors <- convert_colour(t(col2rgb(pal)), "rgb", space)

  colors1 <- colors[seq_len(ceiling(nrow(colors) / 2)), ]
  colors2 <- colors[seq_len(ceiling(nrow(colors) / 2)) + floor(nrow(colors) / 2), ]

  out <- min(
    fast_r_squared(colors1),
    fast_r_squared(colors2)
  )

  if(is.nan(out))
    return(0)

  out
}

pal_distances <- function(pal, funs, space) {
  spectrum1 <- convert_colour(t(col2rgb(pal)), "rgb", space)
  spectrum2 <- spectrum1

  mat <- compare_colour(spectrum1, spectrum2, space, method = "cie2000")

  upper_tri <- mat[upper.tri(mat)]

  map_dbl(funs, ~.x(upper_tri))
}
