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

  name <- names(pals)
  n_cols <- lengths(pals)
  linear <- map_dbl(pals, linear, "lab")
  linear_split <- map_dbl(pals, linear_split, "lab")

  pal_dist <- map(pals, pal_distances, list(min, max, mean), "lab")
  pal_dist_mat <- matrix(unlist(pal_dist), ncol = 3, byrow = TRUE)
  colnames(pal_dist_mat) <- c("min_dist", "max_dist", "mean_dist")

  hue_contains_min <- colors_contains_min(pals, main_colors, "hsl")
  hue_contains_all <- colors_contains_all(pals, main_colors, "hsl")

  pal_sat <- map(pals, pal_saturations, list(min, max, mean))
  pal_sat_mat <- matrix(unlist(pal_sat), ncol = 3, byrow = TRUE)
  colnames(pal_sat_mat) <- c("min_saturation", "max_saturation", "mean_saturation")

  pal_light <- map(pals, pal_lightness, list(min, max, mean))
  pal_light_mat <- matrix(unlist(pal_light), ncol = 3, byrow = TRUE)
  colnames(pal_light_mat) <- c("min_lightness", "max_lightness", "mean_lightness")


  tibble(
    name,
    n_cols,
    linear,
    linear_split,
    as.data.frame(pal_dist_mat),
    as.data.frame(pal_sat_mat),
    as.data.frame(pal_light_mat),
    hue_contains_min,
    hue_contains_all
  )
}

main_colors <- cbind(
  h = c(0, 30, 60, 120, 180, 240, 270, 300),
  s = 100,
  l = 50
) %>%
  farver::encode_colour(from = "hsl")
names(main_colors) <- c("red", "orange", "yellow", "green",
                        "turqouise", "blue", "purple", "pink")

