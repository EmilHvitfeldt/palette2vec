#' @importFrom grDevices col2rgb
#' @importFrom farver convert_colour compare_colour
#' @importFrom purrr map map_dbl map_chr
#' @importFrom dplyr mutate row_number bind_cols filter pull
#' @importFrom stats lm IQR
NULL

utils::globalVariables(
  c(".", "name", "umap_1", "umap_2", "selected_", "n_cols")
)
