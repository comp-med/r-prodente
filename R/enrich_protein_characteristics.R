#' Test for enrichment of proteins in UK Biobank participant characteristics
#'
#' Perform enrichment analysis with a list of input protein identifiers. Check
#' column `mapping_id` of the included data object `prodente::protein_mapping_table`
#' for a full overview of protein identifiers that can be submitted for
#' enrichment analysis.
#'
#' @param protein_foreground Vector of strings. Vector of all lowercase protein
#'   targets to test enrichment for. Use `check_protein_overlap` to get only
#'   proteins available in the background data or check manually against column
#'   `mapping_id` of `prodente::protein_mapping_table`.
#' @param factor_minimum_explained_variance Numeric. Defaults to `0`. Value
#'   between 0-1 to require a minimum of explained variance by certain factors
#'   to be considered.
#' @param protein_background Vector of strings. Optional list of proteins to be used as background.
#' @param test_across String. Defaults to "sex". Whether to test for enrichment
#'   stratified by sex or genetic ancestry. Either "sex" or "ancestry" is
#'   accepted.
#' @param n_cores Integer. Defaults to `1`. Number of cores to use to
#'   parallelize enrichment testing. Passed to `mc.cores` of
#'   `parallel::mclapply`.
#'
#' @return A data.table object.
#' @export
#'
#' @examples
#' \dontrun{
#' # All valid proteins
#' my_proteins <- c("pcsk9", "apoa4", "lep", "tmprss15", "fam3b")
#' enrich_protein_characteristics(
#'   protein_foreground = my_proteins,
#'   factor_minimum_explained_variance = 0,
#'   test_across = "sex",
#'   protein_background = NULL,
#'   n_cores = 1
#'   )
#'}

enrich_protein_characteristics <- function(
    protein_foreground = NULL,
    factor_minimum_explained_variance = 0,
    test_across = c("sex", "ancestry"),
    protein_background = NULL,
    n_cores = 1
    ) {

  # Fix number of cores to 1 when running on windows
  os_used <- Sys.info()[["sysname"]]
  if (os_used == "Windows" & n_cores > 1) {
    message("`mclapply` is not supported on Windows. Setting `n_cores` to 1.")
    n_cores <- 1
  }


  test_across <- test_across[1]
  if (test_across == "sex") {
    variance_decomposition_background <- prodente::variance_decomposition_background[
      type == "by_sex"
    ]
  } else if (test_across == "ancestry") {
    variance_decomposition_background <- prodente::variance_decomposition_background[
      type == "by_ancestry"
    ]
  } else {
    stop("Please choose to test either across `sex` or `ancestry`!")
  }

  if (
    length(factor_minimum_explained_variance) != 1 ||
      !is.numeric(factor_minimum_explained_variance) ||
    factor_minimum_explained_variance > 1 ||
    factor_minimum_explained_variance < 0
  ) {
    stop("Please choose a single numeric value between 0-1.")
  }

  if (
    length(n_cores) != 1 ||
    is.na(suppressWarnings(as.integer(n_cores))) ||
    (n_cores %% 1 != 0)
  ) {
    stop("Please choose a valid full number (integer) as the number of cores.")
  }

  ## drop associations not passing certain explained variance threshold
  if (factor_minimum_explained_variance > 0) {
    variance_decomposition_background <- variance_decomposition_background[
      p_50 > factor_minimum_explained_variance
    ]
  }

  ## subset to background if required
  if (!is.null(protein_background)) {
    variance_decomposition_background <- variance_decomposition_background[
      protein %in% protein_background
    ]
  }

  if (nrow(variance_decomposition_background) == 0) {
    stop("Empty protein background. Please make sure `factor_minimum_explained_variance` is not too stringent or `protein_background` is a subset of `prodente::variance_decomposition_background`")
  }

  if (is.null(protein_foreground)) {
    stop("Need to provide a vector of protein targets to test for enrichment. Check column `mapping_id` of `prodente::protein_mapping_table` for a list of accepted protein terms.")
  }

  if (length(check_protein_overlap(protein_foreground)) == 0) {
    stop("None of the supplied proteins in `protein_foreground` found in background data. Please use `check_protein_overlap()` to see the overlap between your input data and the background data. Also make sure `factor_minimum_explained_variance` is not too stringent.")
  }

  if (
    !all(
      protein_foreground %in%
      unique(variance_decomposition_background$protein)
    )
  ) {
    protein_foreground <- protein_foreground[
      protein_foreground %in% unique(variance_decomposition_background$protein)
      ]
    warning("Not all the proteins supplied in `protein_foreground` found in background data. Please use `check_protein_overlap()` to see the overlap between your input data and the background data. Also make sure `factor_minimum_explained_variance` is not too stringent. Non-matching proteins were removed from the foreground.")
  }

  ## define variables to test for across different populations
  variable_tests <- variance_decomposition_background[
    variable != "Residuals",
    .(variable_frequency = length(protein)),
    by = c("population", "variable")
  ]

  ## reduce to at least five variables
  variable_tests <- variable_tests[variable_frequency >= 5]

  if (nrow(variable_tests) == 0) {
    stop("No variable with at least five selected proteins in background data. Is your background too small?")
  }

  ## perform enrichment by variable and population
  enrichment_results <- parallel::mclapply(
    seq_len(nrow(variable_tests)),
    function(x) {

      ## variable of interest
      variable_id <- variable_tests$variable[x]

      ## population of interest
      population_id <- variable_tests$population[x]

      ## define protein back ground for population
      protein_background <- variance_decomposition_background[
        variable != "Residuals" & population == (population_id),
        unique(protein)
      ]

      ## protein of interest and selected for the variable of interest
      d1 <- variance_decomposition_background[
        variable == variable_id &
          population == population_id &
          protein %in% protein_foreground,
        .N
      ]

      ## protein not of interest and selected for the variable of interest
      d2 <- variance_decomposition_background[
        variable == variable_id &
          population == population_id &
          !(protein %in% protein_foreground),
        .N
      ]

      ## protein of interest but not selected
      d3 <- length(protein_foreground) - d1

      ## protein not of interest and not selected
      d4 <- length(
        protein_background[
          !(
            protein_background %in% protein_foreground |
              protein_background %in% variance_decomposition_background[
                variable == variable_id &
                  population == population_id,
                protein
              ]
          )
        ]
      )

      ## test for enrichment
      enr <- stats::fisher.test(matrix(c(d1, d2, d3, d4), 2, 2, byrow = T))

      intersection <- variance_decomposition_background[
          variable == variable_id &
            population == population_id &
            protein %in% protein_foreground,
          paste(protein, collapse = "|")
      ]
      intersection <- ifelse(
        intersection == "",
        NA,
        intersection
      )

      ## return information needed
      return(
        data.table(
          population = population_id,
          variable = variable_id,
          or = enr$estimate,
          pval = enr$p.value,
          intersection,
          d1 = d1,
          d2 = d2,
          d3 = d3,
          d4 = d4
        )
      )
    },
    mc.cores = n_cores
  )

  ## return list
  enrichment_results <- data.table::rbindlist(enrichment_results, fill = TRUE)
  data.table::setkey(enrichment_results, "variable")
  data.table::setkey(prodente::participant_characteristics_labels, "short_name")

  ## add label
  enrichment_results <- enrichment_results[
    prodente::participant_characteristics_labels,
    nomatch = NULL
  ]

  return(enrichment_results)
}
