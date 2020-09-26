vec2norm <- function(x, contains_w, length_w, linearity_w, dist_w, sat_w,
                     light_w) {
  recipes::recipe(name ~ ., data = x) %>%
    recipes::step_normalize(recipes::all_predictors()) %>%
    recipes::step_mutate_at(tidyselect::starts_with("contains"),
                            fn = ~ . * contains_w) %>%
    recipes::step_mutate_at(tidyselect::starts_with("linear"),
                            fn = ~ . * linearity_w) %>%
    recipes::step_mutate_at(tidyselect::ends_with("dist"),
                            fn = ~ . * dist_w) %>%
    recipes::step_mutate_at(tidyselect::ends_with("saturation"),
                            fn = ~ . * sat_w) %>%
    recipes::step_mutate_at(tidyselect::ends_with("lightness"),
                            fn = ~ . * sat_w) %>%
    recipes::step_mutate(n_cols = n_cols * length_w) %>%
    recipes::step_zv(recipes::all_predictors()) %>%
    recipes::prep() %>%
    recipes::bake(new_data = NULL)
}

#' Launch interactive Nearest neighbor finder
#'
#' @param palettes named list of palettes
#'
#' @return selected palettes
#' @export
nn_palettes <- function(palettes) {
  waiting_screen <- shiny::tagList(
    waiter::spin_flower(),
    shiny::h4("Calculating palette2vec"),
    shiny::h4("please wait")
  )

  ui <- shiny::fluidPage(
    waiter::use_waiter(), # include dependencies
    waiter::waiter_show_on_load(waiting_screen),

    # Application title
    shiny::titlePanel("palette2vec UMAP embedding"),

    # Sidebar with a slider input for number of bins
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::actionButton("stopButton", "Stop to return selected palettes"),
        shiny::selectInput("pal_select", "Palette Selection", names(palettes), names(palettes)[1]),
        shiny::sliderInput("length_w", label = "Length",
                           value = 1, min = 0, max = 5),
        shiny::sliderInput("linearity_w", label = "Linearity",
                           value = 1, min = 0, max = 5),
        shiny::sliderInput("contains_w", label = "Contains",
                           value = 1, min = 0, max = 5),
        shiny::sliderInput("dist_w", label = "Distances",
                           value = 1, min = 0, max = 5),
        shiny::sliderInput("sat_w", label = "Saturation",
                           value = 1, min = 0, max = 5),
        shiny::sliderInput("light_w", label = "Lightness",
                           value = 1, min = 0, max = 5),
      ),

      # Show a plot of the generated distribution
      shiny::mainPanel(
        gt::gt_output("table")
      )
    )
  )

  # Define server logic required to draw a histogram
  server <- function(input, output) {
    embedding <- palette2vec(palettes)

    norm_embedding <- shiny::reactive({
      vec2norm(embedding,
               contains_w = input$contains_w,
               length_w = input$length_w,
               linearity_w = input$linearity_w,
               dist_w = input$dist_w,
               sat_w = input$sat_w,
               light_w = input$light_w)
    })

    waiter::waiter_hide()

    nn_palettes <- shiny::reactive({
      nn <- RANN::nn2(
        norm_embedding() %>%
          select(-name) %>%
          as.matrix(),
        norm_embedding() %>%
          filter(name == input$pal_select) %>%
          select(-name) %>%
          as.matrix()
      )

      palettes[as.character(norm_embedding()$name)[nn$nn.idx[1, ]]]
    })

    output$table <- gt::render_gt({

      pals_to_gt(
        nn_palettes()
      )
    })

    shiny::observe({
      if(input$stopButton > 0){
        shiny::stopApp(nn_palettes())
      }
    })
  }

  # Run the application
  shiny::runApp(list(ui = ui, server = server))
}
