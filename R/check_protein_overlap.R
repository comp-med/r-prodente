#' Check overlap between user-supplied and background protein identifiers
#'
#' This function...
#'
#' @param protein_list Vector of strings. List of proteins to test for enrichment. Should be in all lower-case letters. check `data(protein_mapping_table)` for the full list of proteins available as background.
#' @param return_missing Logical. Defaults to `FALSE`. Instead of returning the overlapping proteins (that can be tested for enrichment), return the proteins in the foreground not found in the background data.
#'
#' @return Protein identifiers that could be mapped against the available background proteins.
#' @export
#'
#' @examples
#' # All valid proteins
#' my_proteins <- c("pcsk9", "apoa4", "lep", "tmprss15", "fam3b")
#' check_protein_overlap(my_proteins)
#'
#' # Some invalid proteins. Returns
#' my_proteins <- c("PCSK9", "apoa4", "Lep", "tmprss-15", "fam3b")
#' check_protein_overlap(my_proteins, return_missing = TRUE)
check_protein_overlap <- function(
  protein_list = NULL,
  return_missing = FALSE
) {

  if (is.null(protein_list)) {
    stop("Need to provide a vector of protein targets to test for enrichment. Check column `mapping_id` of `data(protein_mapping_table)` for a list of accepted protein terms.")
  }

  data(protein_mapping_table)
  protein_overlap <- protein_list[
    protein_list %in% protein_mapping_table$mapping_id
    ]

  missing_proteins <- protein_list[
    !(protein_list %in% protein_mapping_table$mapping_id)
  ]

  if (isTRUE(return_missing)) {
    return(missing_proteins)
  } else {
    return(protein_overlap)
  }
}
