#' Test a list of protein identifiers for enrichment in multiple groups
#'
#' This function helps calculating protein characteristics enrichment for multiple groups. The output of this function can be plotted using `plot_enrichment_results()`.
#'
#' @param protein_foreground_list Named list. Different protein foregrounds to be tested for enrichment of UK Biobank study characteristics sequentially. The name of each list item is used as a grouping variable. See examples for details.
#' @inheritParams enrich_protein_characteristics
#' @return A data.table containing enrichment results for all groups in input data.
#' @export
#'
#' @examples
#'\dontrun{
#'
#' protein_foreground_list <- list(
#'   group1 = c("lep", "tmprss15", "fam3b"),
#'   group2 = c("pcsk9", "apoa4", "lep", "tmprss15", "fam3b")
#' )
#'
#' enrichment_test_across_experiments(
#'   protein_foreground_list
#' )
#'}

enrichment_test_across_groups <- function(
    protein_foreground_list = NULL,
    factor_minimum_explained_variance = 0,
    test_across = c("sex", "ancestry"),
    protein_background = NULL,
    n_cores = 1
) {

  if (is.null(protein_foreground_list) || !is.list(protein_foreground_list)) {
    stop("Please supply named list containing protein identifiers for each testing group.")
  }

  if (is.null(names(protein_foreground_list))) {
    warning("No names provided with the input list. Using default values: `group_1`, `group_2`...")
    names(protein_foreground_list) <- paste0("group", 1:length(protein_foreground_list))
  }

  if (
    any(is.na(names(protein_foreground_list))) ||
    any(nchar(names(protein_foreground_list)) == 0) ||
    data.table::uniqueN(names(protein_foreground_list)) != length(names(protein_foreground_list))
      ) {
    stop("Please supply unique and non-empty names to each element of protein_foreground_list.")
  }

  protein_characteristic_enrichments <- lapply(
    seq_along(protein_foreground_list),
    function(x) {

    protein_foreground <- protein_foreground_list[[x]]
    protein_foreground_group <- names(protein_foreground_list)[x]
    protein_foreground <- check_protein_overlap(protein_foreground)

    ## run the enrichment with the respective set of proteins
    single_group_enrichment <- enrich_protein_characteristics(
      protein_foreground = protein_foreground,
      factor_minimum_explained_variance = factor_minimum_explained_variance,
      test_across = test_across,
      protein_background = protein_background,
      n_cores = n_cores
    )

    ## report findings, but restrict to overall population
    return(
      data.table::data.table(
        group = protein_foreground_group,
        single_group_enrichment
        )
      )
  }
  )

  protein_characteristic_enrichments <- data.table::rbindlist(
    protein_characteristic_enrichments
  )

  return(protein_characteristic_enrichments)
}
