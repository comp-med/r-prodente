#' UK Biobank Study Participant Characteristics
#'
#' A list of characteristics in UK Biobank that were used as the basis for the
#' the analysis of factors influencing plasma protein levels.
#'
#' @format ## `participant_characteristics_labels`
#' A data frame with X rows and Y columns
#' @source <TODO_ADD_LINK>
"participant_characteristics_labels"

#' Olink Protein Mapping Table
#'
#' A mapping table containing protein identifiers that can be used to check own
#' data against the background used to run the enrichment analysis.
#'
#' @format ## `protein_mapping_table`
#' A data frame with X rows and Y columns:
#' \describe{
#'   \item{col}{col meanind}
#'   \item{col2, col3}{,multiple col meanings}
#' }
#' @source <TODO_ADD_LINK>
"protein_mapping_table"

#' Protein Determinants Data
#'
#' Explained variance in protein levels by various participant's characteristics.
#'
#' @format ## `variance_decomposition_background`
#' A data frame with X rows and Y columns
#'
#' @source <TODO_ADD_LINK>
"variance_decomposition_background"
