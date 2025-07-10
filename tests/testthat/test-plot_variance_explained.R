test_that("Fails with user-friendly error if protein_id or population is missing or invalid", {
  expect_error(
    plot_variance_explained(pop = "EUR"),
    "Please supply a valid protein ID"
  )
  expect_error(
    plot_variance_explained(protein_id = "pcsk9"),
    "Please supply a valid population"
  )
})

test_that("Fails with message when no matching data found", {
  expect_error(
    plot_variance_explained(protein_id = "nonexistent_protein", pop = "EUR"),
    "No data found for the given protein and population"
  )
})

test_that("Returns a gridExtra/gtable object for valid input", {
  skip_if_not_installed("gridExtra")
  skip_if_not_installed("ggplot2")
  
  pdf(NULL) # suppress device output
  p <- plot_variance_explained(protein_id = "pcsk9", pop = "EUR")
  dev.off()
  
  expect_true(inherits(p, "gtable") || inherits(p, "grob"))
})