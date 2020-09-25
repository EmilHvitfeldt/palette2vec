vec2umap <- function(x, contains_min_w, length_w) {
    recipes::recipe(name ~ ., data = x) %>%
    recipes::step_normalize(recipes::all_predictors()) %>%
    recipes::step_mutate_at(tidyselect::starts_with("contains_min"),
                            fn = ~ . * contains_min_w) %>%
    recipes::step_mutate(n_cols = n_cols * length_w) %>%
    recipes::step_zv(recipes::all_predictors()) %>%
    embed::step_umap(recipes::all_predictors()) %>%
    recipes::prep() %>%
    recipes::bake(new_data = NULL)
}

#' Launch interactive umap embedding
#'
#' @param palettes named list of palettes
#'
#' @return selected palettes
#' @export
umap_embedding <- function(palettes) {
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
        shiny::sliderInput("contains_min_w", label = "Contains_min",
                           value = 1, min = 0.01, max = 5),
        shiny::sliderInput("length_w", label = "Length",
                           value = 1, min = 0.01, max = 5),
      ),

      # Show a plot of the generated distribution
      shiny::mainPanel(
        plotly::plotlyOutput("distPlot"),
        gt::gt_output("table")
      )
    )
  )

  # Define server logic required to draw a histogram
  server <- function(input, output) {
    embedding <- palette2vec(palettes)

    shared_embedding <- shiny::reactive({
      umap_embedding <- vec2umap(embedding,
                                 contains_min_w = input$contains_min_w,
                                 length_w = input$length_w)
      crosstalk::SharedData$new(umap_embedding)
    })

    selected_names  <- shiny::reactive({
      shared_embedding()$data(withSelection = TRUE) %>%
        filter(selected_) %>%
        pull(name) %>%
        as.character()
    })

    output$distPlot <- plotly::renderPlotly({
      # generate bins based on input$bins from ui.R
      p <- shared_embedding() %>%
        ggplot2::ggplot(ggplot2::aes(umap_1, umap_2, label = name)) +
        ggplot2::geom_point() +
        ggplot2::theme_void()

      plotly::ggplotly(p, tooltip = character()) %>%
        plotly::highlight(on = "plotly_selected", off = "plotly_doubleclick")
    })

    output$table <- gt::render_gt({
      if (length(selected_names()) > 0)
        pals_to_gt(palettes[selected_names()])
    })

    shiny::observe({
      if(input$stopButton > 0){
        shiny::stopApp(palettes[selected_names()])
      }
    })
    waiter::waiter_hide()
  }

  # Run the application
  shiny::runApp(list(ui = ui, server = server))
}
