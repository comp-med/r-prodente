#' Plot enrichment results for multiple groups
#'
#' Plot enrichment of UK Biobank study characteristics across several groups.
#'
#' @param enrichment_results data.table. Output from `enrichment_test_across_groups()`, restricted to a single population (of either sex or genetic ancestry).
#' @param plot_population String. To limit plot size, choose one population to plot results for.
#' @param pvalue_adjustment string. Defaults to "bonferroni". Passed to `p.adjust()`. See that function's help page for options.
#'
#' @return A `ggplot2` object.
#' @export
plot_enrichment_results <- function(
    enrichment_results = NULL,
    plot_population = NULL,
    pvalue_adjustment = "bonferroni"
) {

  if (is.null(enrichment_results)) {
    stop("Please supply the output of `enrich_protein_characteristics()` to this function.")
  }

  if (
    is.null(plot_population) ||
    length(plot_population) != 1 ||
    !(plot_population %in% enrichment_results$population)
  ) {
    stop("Please specify which population to plot. Find available values in the `population` column of the enrichment results.")
  } else {
    enrichment_results <- enrichment_results[population == (plot_population)]
  }

  # variables enriched at least once
  enrichment_results[, p_adjust := stats::p.adjust(pval, method = (pvalue_adjustment))]
  enriched_variables <-  enrichment_results[
    (p_adjust < (0.05)) & (or > 1),
    unique(label)
  ]
  if (length(enriched_variables) == 0) {
    stop("No enriched variables to plot.")
  }

  ## sort and reduce to characteristics enriched at least once
  plotting_data <- enrichment_results[label %in% enriched_variables]
  plotting_data <- plotting_data[order(category_sort, variable), ]
  plotting_data[, log10p := -log10(pval)]

  enrichment_plot <- ggplot2::ggplot(
    plotting_data,
    ggplot2::aes(
      x = label,
      y = group,
      size = or,
      fill = log10p
    )
  ) +
    ggplot2::geom_point(pch = 21) +
    ggplot2::scale_fill_gradient(
      low = "white",
      high = "#CB625F") +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)

    )
  print(enrichment_plot)
  return(enrichment_plot)

}
