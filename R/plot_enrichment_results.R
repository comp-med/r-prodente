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
  
  # Add empty group column for single-group results
  if (!"group" %in% names(enrichment_results)) {
    enrichment_results[, group := "protein_list"]
  }

  # pvalue adjustment (stays the same if bonferroni method chosen)
  enrichment_results[, p_adjust := stats::p.adjust(pval, method = (pvalue_adjustment))]
  # variables enriched at least once
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

  # Cap Infinite odds ratios
  finite_or <- plotting_data$or[is.finite(plotting_data$or)]
  
  if (length(finite_or) > 0) {
    dynamic_cap <- max(finite_or, na.rm = TRUE) * 1.1
    cap_value <- max(dynamic_cap, 30)  # use whichever is larger: dynamic cap or 30
    plotting_data$or[is.infinite(plotting_data$or)] <- cap_value
  } else {
    warning("No finite OR values found in the enrichment results with p_adj<0.05 and OR>1 to plot.")
  }
  
  # add tag for significance (to determine stroke color later)
  plotting_data$sig <- as.factor(ifelse(plotting_data$p_adjust < 0.05, 1, 0))
  
  enrichment_plot <- ggplot2::ggplot(
    plotting_data,
    ggplot2::aes(
      x = label,
      y = group,
      size = or,
      fill = log10p,
      col = sig
    )
  ) +
    ggplot2::geom_point(pch = 21) +
    ggplot2::scale_fill_gradient(
      low = "white",
      high = "#CB625F") +
    ggplot2::scale_color_manual(
      values = c("1" = "black", "0" = "grey60"),
      guide = "none") +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)

    )
  
  # If there's a single group, dont display the y axis title
  if (length(unique(enrichment_results$group))==1) {
    enrichment_plot <- enrichment_plot + ggplot2::labs(y = NULL)
  }
  
  print(enrichment_plot)
  return(enrichment_plot)

}
