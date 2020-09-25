#' Title
#'
#' @param pals palettes
#' @param hue_contains_n number of hue colors used in contains columns
#'
#' @return a [tibble][tibble::tibble-package]
#' @export
#'
#' @examples
#' palette2vec(list(terrain = terrain.colors(10),
#'                  heat = heat.colors(16),
#'                  topo = topo.colors(8)))
palette2vec <- function(pals, hue_contains_n = 10) {
  if(length(names(pals)) == 0) {
    stop("`pals` must be a named list")
  }

  res <- tibble::tibble(
    name = names(pals),
    n_cols = lengths(pals),
    linear = map_dbl(pals, linear, "RGB"),
    linear_split = map_dbl(pals, linear_split, "RGB"),
    min_dist = map_dbl(pals, min_distance, "RGB"),
    max_dist = map_dbl(pals, max_distance, "RGB"),
    iqr_dist = map_dbl(pals, iqr_distance, "RGB")
    )

  hue_colors <- scales::hue_pal()(hue_contains_n)
  hue_contains_min <- colors_contains_min(pals, hue_colors, "RGB")
  hue_contains_all <- colors_contains_all(pals, hue_colors, "RGB")

  bind_cols(
    res,
    hue_contains_min,
    hue_contains_all
  )
}
