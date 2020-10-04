# Copied from {gt} https://github.com/rstudio/gt/blob/6058358fe2f56901f2ef175fb74fa655e0b9793b/data-raw/X04-palettes_strips.R
make_rects <- function(colors,
                       full_width = 400,
                       height = 30) {
  check_package("glue")

  col_count <- length(colors)
  width_each <- full_width / col_count

  bound_vals <- (0:(col_count - 1) * width_each) + 1

  color_vec <- vector(mode = "character", length = length(colors))

  for (i in seq_along(colors)) {

    color_vec[i] <-
      glue::glue('    <rect id="color_{i}" fill="{colors[i]}" x="{bound_vals[i]}" y="1" width="{width_each}" height="30"></rect>') %>%
      as.character()
  }

  paste(color_vec, collapse = "\n")
}

make_color_strip_svg <- function(colors) {
  check_package("glue")

  rects <- make_rects(colors)

  glue::glue(
    '<svg width="403px" height="32px" viewBox="0 0 403 32" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <defs>
    <rect id="path-1" x="1" y="1" width="400" height="30" rx="4"></rect>
  </defs>
  <g id="main" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
{rects}
    <g id="outer_rect">
      <rect stroke="#979797" stroke-width="1" x="1.5" y="1.5" width="399" height="29" rx="4"></rect>
      <rect stroke="#FFFFFF" stroke-width="2" x="0" y="0" width="402" height="32" rx="4"></rect>
    </g>
  </g>
</svg>
') %>% as.character()
}

#' Turns named list of color palettes into {gt} chart
#'
#' @param pals named list of palettes
#'
#' @return [gt::gt] chart
#' @export
#'
#' @examples
#' pals_to_gt(color_hex_palettes[1:5])
pals_to_gt <- function(pals) {
  check_package("gt")
  tibble(names = names(pals),
         colors = map_chr(pals, make_color_strip_svg)) %>%
    gt::gt() %>%
    gt::text_transform(locations = gt::cells_body("colors"),
                   fn = function(x) {
                     map_chr(pals, make_color_strip_svg)
                   })
}
