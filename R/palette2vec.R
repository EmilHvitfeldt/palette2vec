#' Title
#'
#' @param pals palettes
#' @param hue_contains_n number of hue colors used in contains columns
#'
#' @return a [tibble][tibble::tibble-package]
#' @export
#'
#' @examples
#' palette2vec(list(terrain.colors(10), heat.colors(16), topo.colors(8)))
palette2vec <- function(pals, hue_contains_n = 10) {
  res <- tibble::tibble(n_cols = lengths(pals))

  hue_colors <- scales::hue_pal()(hue_contains_n)
  hue_contains_min <- colors_contains_min(pals, hue_colors, "RGB")
  hue_contains_all <- colors_contains_all(pals, hue_colors, "RGB")

  dplyr::bind_cols(
    res,
    hue_contains_min,
    hue_contains_all
  )
}
