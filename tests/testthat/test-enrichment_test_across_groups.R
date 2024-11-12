test_that("Fails on empty input", {
  expect_error(
    enrichment_test_across_groups(),
    "Please supply named list containing protein identifiers for each testing group."
  )
})
test_that("Fails on wrongly formatted single-group input", {
  expect_error(
    enrichment_test_across_groups(protein_foreground_list = c("pcsk9")),
    "Please supply named list containing protein identifiers for each testing group."
  )
})
test_that("Fails on incompletely named input list", {
  expect_error(
    enrichment_test_across_groups(protein_foreground_list = list(
      group1 = c("pcsk9"),
      "anxa10"
    )),
    "Please supply unique and non-empty names to each element of protein_foreground_list."
  )
})
test_that("Fails on non-unique names of input list", {
  expect_error(
    enrichment_test_across_groups(protein_foreground_list = list(
      group1 = c("pcsk9"),
      group1 = c("anxa10")
    )),
    "Please supply unique and non-empty names to each element of protein_foreground_list."
  )
})
test_that("Warning on unnamed input list", {
  expect_warning(
    enrichment_test_across_groups(protein_foreground_list = list("pcsk9")),
    "No names provided with the input list. Using default values: `group_1`, `group_2`..."
  )
})
test_that("Warning on unnamed input list", {
  expect_warning(
    enrichment_test_across_groups(protein_foreground_list = list("pcsk9")),
    "No names provided with the input list. Using default values: `group_1`, `group_2`..."
  )
})
test_that("Runs without error on correct input", {
  expect_no_error(
    enrichment_test_across_groups(protein_foreground_list = list(
      group1 = "pcsk9",
      group2 = "anxa10"
      ))
  )
})
test_that("Returns data.table with `group` column and correctly named entries", {
  expect_contains({
    res <- enrichment_test_across_groups(protein_foreground_list = list(
      group1 = "pcsk9",
      group2 = "anxa10"
    ))
    names(res)
  },
  "group"
  )
  expect_equal({
    res <- enrichment_test_across_groups(protein_foreground_list = list(
      group1 = "pcsk9",
      group2 = "anxa10"
    ))
    unique(res$group)
  },
  c("group1", "group2")
  )
})
