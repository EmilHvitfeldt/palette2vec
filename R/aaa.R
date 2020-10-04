#' @importFrom grDevices col2rgb
#' @importFrom farver convert_colour compare_colour
#' @importFrom purrr map map_dbl map_chr
#' @importFrom dplyr mutate row_number bind_cols filter pull select
#' @importFrom stats .lm.fit IQR
NULL

utils::globalVariables(
  c(".", "name", "umap_1", "umap_2", "selected_", "n_cols")
)

check_package <- function(package) {
  if (!requireNamespace(package, quietly = TRUE)) {
    rlang::abort(
      paste0(
        "Package '",
        package ,
        "' needed. Please install it by running `install.packages('",
        package,
        "')`."
      )
    )
  }
}
