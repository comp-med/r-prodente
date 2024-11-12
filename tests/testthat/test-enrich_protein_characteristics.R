test_that("Returns no error with correct input", {
  expect_no_error(
    enrich_protein_characteristics("pcsk9"),
    )
  expect_no_error(
    enrich_protein_characteristics("pcsk9", test_across = "sex"),
    )
  expect_no_error(
    enrich_protein_characteristics("pcsk9", test_across = "ancestry"),
    )
})
test_that("Fails on wrong input for `factor_minimum_explained_variance`", {
  expect_error(
    enrich_protein_characteristics("pcsk9", factor_minimum_explained_variance = 80),
    "Please choose a single numeric value between 0-1."
    )
  expect_error(
    enrich_protein_characteristics("pcsk9", factor_minimum_explained_variance = 'point_3'),
    "Please choose a single numeric value between 0-1."
    )
  expect_error(
    enrich_protein_characteristics("pcsk9", factor_minimum_explained_variance = c(0.1, 0.2, 0.3)),
    "Please choose a single numeric value between 0-1."
    )
})
test_that("Returns warning when elements in foreground are not found in background.", {
  expect_warning(
    enrich_protein_characteristics(c("pcsk9", "ANXA10")),
    "Not all the proteins supplied in `protein_foreground` found in background data. Please use `check_protein_overlap()` to see the overlap between your input data and the background data. Also make sure `factor_minimum_explained_variance` is not too stringent.", fixed = TRUE
    )
})
test_that("Returns `data.table` object on default parameters and correct input.", {
  expect_equal(
    class(enrich_protein_characteristics("pcsk9")),
    c("data.table", "data.frame")
    )
})
test_that("Returns `data.table` with expected column names on correct input.", {
  expect_equal(
    names(enrich_protein_characteristics("pcsk9")),
    c(
      "population", "variable", "or", "pval", "intersection", "d1",
      "d2", "d3", "d4", "category", "id", "column_name", "label", "released",
      "type", "category_sort"
    )
  )
})
test_that("Fails when `factor_minimum_explained_variance` is too stringent and background is of length 0", {
  expect_error(
    enrich_protein_characteristics("pcsk9", factor_minimum_explained_variance = 1),
    "Empty protein background. Please make sure `factor_minimum_explained_variance` is not too stringent or `protein_background` is a subset of `prete::variance_decomposition_background`"
    )
})
test_that("Fails on bad user-supplied background", {
  expect_error(
    enrich_protein_characteristics("pcsk9", protein_background = c("bad")),
    "Empty protein background. Please make sure `factor_minimum_explained_variance` is not too stringent or `protein_background` is a subset of `prete::variance_decomposition_background`"
    )
})
test_that("Fails when wrong `test_across` is given", {
  expect_error(
    enrich_protein_characteristics("pcsk9", test_across = "something_else"),
    "Please choose to test either across `sex` or `ancestry`!"
    )
})
test_that("Multi-threading works (when available on machine)", {
  expect_no_error(
    enrich_protein_characteristics("pcsk9", n_cores = 2),
    )
})
test_that("Fails without any input", {
  expect_error(
    enrich_protein_characteristics(),
    "Need to provide a vector of protein targets to test for enrichment. Check column `mapping_id` of `prete::protein_mapping_table` for a list of accepted protein terms."
    )
})
test_that("Fails with wrong type for `n_cores`", {
  expect_error(
    enrich_protein_characteristics(protein_foreground = "pcsk9", n_cores = "three"),
    "Please choose a valid full number (integer) as the number of cores.", fixed = TRUE
    )
})
