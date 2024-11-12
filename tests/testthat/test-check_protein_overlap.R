test_that("Returning correct list works", {
  expect_equal(
    check_protein_overlap(
      protein_list = c("pcsk9", "apoa4", "lep", "tmprss15", "fam3b")
    ),
    c("pcsk9", "apoa4", "lep", "tmprss15", "fam3b")
    )
})
test_that("Returning correct part of a list works", {
  expect_equal(
    check_protein_overlap(
      protein_list = c("pcsk9", "ABC", "apoa4", "lep", "tmprss15", "fam3b", "DEF")
    ),
    c("pcsk9", "apoa4", "lep", "tmprss15", "fam3b")
    )
})
test_that("Fails on incorrect input type", {
  expect_error(
    check_protein_overlap(
      protein_list = c(1, 2, 3, 4, 5)
    ),
    "Input should be a vector of type `character`"
    )
})
test_that("Fails on empty input", {
  expect_error(
    check_protein_overlap(),
    "Need to provide a vector of protein targets to test for enrichment. Check column `mapping_id` of `prete::protein_mapping_table` for a list of accepted protein terms."
    )
})
test_that("Returning missing entries from input works", {
  expect_equal(
    check_protein_overlap(
      c("myprot", "pcsk9", "apoa4", "lep", "tmprss15", "fam3b"),
      return_missing = TRUE
    ),
    c("myprot")
  )
})
test_that("Returning empty missing entries from input works", {
  expect_equal(
    check_protein_overlap(
      c("pcsk9", "apoa4", "lep", "tmprss15", "fam3b"),
      return_missing = TRUE
    ),
    character()
  )
})
