#' All discrete paletteer palettes
#'
#' @return named list of color palettes
#' @export
paletteer_palettes <- function() {
  check_package("paletteer")
  unlist(paletteer::palettes_d, FALSE)
}
