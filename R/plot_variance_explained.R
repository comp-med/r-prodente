#' Plot Variance Explained for a Protein
#'
#' Visualize the top factors explaining variance for a selected protein in a given population.
#'
#' @param protein_id Character. Protein ID to plot (e.g. "pcsk9").
#' @param plot_population Character. The population to subset by ("EUR", "AFR", "CSA", "Female" or "Male").
#'
#' @return A patchwork ggplot object showing explained variance for the top 20 contributing factors.
#' @export
plot_variance_explained <- function(protein_id, plot_population) {
  
  if (missing(protein_id) || !is.character(protein_id) || length(protein_id) != 1) {
    stop("Please supply a valid protein ID (e.g., 'pcsk9').", call. = FALSE)
  }
  if (missing(plot_population) || !is.character(plot_population) || length(plot_population) != 1) {
    stop("Please supply a valid population (e.g., 'EUR', 'AFR', 'Female', etc.).", call. = FALSE)
  }
  
  # Load internal data from the package
  res <- get("variance_decomposition_background", envir = asNamespace("prodente"))
  lab <- get("participant_characteristics_labels", envir = asNamespace("prodente"))
  
  # Filter for protein and population
  res_subset <- dplyr::filter(res, protein == protein_id, population == plot_population)
  
  if (nrow(res_subset) == 0) {
    stop("No data found for the given protein and population. Please check the inputs.", call. = FALSE)
  }
  
  # Get top 20
  res_subset <- head(dplyr::arrange(res_subset, dplyr::desc(p_50)), 20)
  
  # Merge labels
  res_subset <- dplyr::left_join(res_subset, dplyr::select(lab, short_name, cl), by = c("variable" = "short_name"))
  
  color_palette <- stats::setNames(res_subset$cl, res_subset$variable)
  
  total_explained_variance <- sum(res_subset$p_50, na.rm = TRUE)
  
  res_subset <- dplyr::mutate(res_subset,
      cum_p50 = cumsum(p_50) - p_50 / 2,
      label_wrapped = stringr::str_wrap(label, width = 30))
  
  top_plot <- ggplot2::ggplot(res_subset) +
    ggplot2::geom_rect(
      ggplot2::aes(xmin = cumsum(p_50) - p_50, xmax = cumsum(p_50), ymin = 0, ymax = 1, fill = variable),
      color = "white"
    ) +
    ggplot2::scale_fill_manual(values = color_palette, na.value = "grey") +
    ggplot2::labs(x = "Explained variance [%]", y = NULL) +
    ggplot2::scale_x_continuous(
      limits = c(0, 1),
      labels = scales::percent_format(scale = 100),
      expand = c(0, 0)
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.text.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_blank(),
      legend.position = "none",
      panel.grid = ggplot2::element_blank()
    ) +
    ggplot2::annotate(
      "text",
      x = sum(res_subset$p_50), y = 0.5,
      label = sprintf("%.1f%%", total_explained_variance * 100),
      hjust = -0.1, vjust = 0.5, size = 3.5, color = "black"
    )
  
  bottom_plot <- ggplot2::ggplot(
    res_subset,
    ggplot2::aes(x = reorder(label_wrapped, -p_50), y = p_50 * 100, fill = variable)
  ) +
    ggplot2::geom_bar(stat = "identity") +
    ggplot2::geom_errorbar(
      ggplot2::aes(ymin = p_025 * 100, ymax = p_975 * 100),
      width = 0.2
    ) +
    ggplot2::geom_text(
      ggplot2::aes(y = p_50 * 100 * 1.05, label = sprintf("%.1f", p_50 * 100)),
      vjust = -0.5, hjust = -0.2, size = 3
    ) +
    ggplot2::scale_fill_manual(values = color_palette, na.value = "grey") +
    ggplot2::labs(x = NULL, y = "Explained variance [%]") +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 60, hjust = 1, size = 8),
      legend.position = "none"
    )
  
  combined_plot <- gridExtra::grid.arrange(top_plot, bottom_plot, heights = c(0.2, 0.8), ncol = 1)
  
  return(combined_plot)
}
