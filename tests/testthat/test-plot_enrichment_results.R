test_that("Fails on empty input", {
  expect_error(
    plot_enrichment_results(),
    "Please supply the output of `enrich_protein_characteristics()` to this function.",
    fixed = TRUE
  )
})
test_that("Fails when population column contains more than one value", {
  expect_error({
    plot_enrichment_results(prete:::test_fail_data_group_enrichment)
    },
    "Please specify which population to plot. Find available values in the `population` column of the enrichment results."
  )
  expect_error({
    plot_enrichment_results(prete:::test_fail_data_group_enrichment, plot_population = c("All", "Male"))
    },
    "Please specify which population to plot. Find available values in the `population` column of the enrichment results."
  )
})
test_that("Fails when no variables are enriched", {
  expect_error({
    plot_enrichment_results(
      enrichment_results = prete:::test_fail_data_group_enrichment,
      plot_population = "All")
    },
    "No enriched variables to plot."
  )
})
test_that("Returns ggplot2 object on correct input", {
  expect_equal({
    res <- enrichment_test_across_groups(
      protein_foreground_list = list(
        group1 = c("pcsk9", "apoa4", "lep", "tmprss15", "fam3b"),
        group2 = c("pcsk9", "apoa4", "lep", "tmprss15", "fam3b", "anxa10")
      )
    )
    pdf(NULL)
    plot <- plot_enrichment_results(res, plot_population = "All")
    dev.off()
    class(plot)
    },
    c("gg", "ggplot")
  )
})
