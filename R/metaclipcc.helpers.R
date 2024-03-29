#' @title Table of IPCC Datasets
#' @description Shows the internal table with IPCC Datasets and relevant metadata
#' @param names.only Logical flag indicating that only the internal dataset names are shown. Default to \code{TRUE}. Otherwise, the full metadata table is shown
#' @export
#' @author J Bedia
#' @return Either a vector with all dataset names (when \code{names.only = TRUE}) or a \code{data.frame} with all the associated metadata.
#' @keywords internal
#' @export
#' @family lookup-tables
#' @importFrom utils read.csv
#' @examples showIPCCdatasets()

showIPCCdatasets <- function(names.only = TRUE) {
    out <- read.csv(file.path(find.package("metaclipcc"), "dataset_table.csv"),
             stringsAsFactors = FALSE, na.strings = "NA")
    if (isTRUE(names.only)) out <- out$name
    return(out)
}

#' @title Table of IPCC Atlas Variables
#' @description Shows the internal table with IPCC Variables and relevant metadata
#' @param names.only Logical flag indicating that only the variable names are shown. Default to \code{TRUE}. Otherwise, the full metadata table is shown
#' @export
#' @author J Bedia
#' @return Either a vector with all dataset names (when \code{names.only = TRUE}) or a \code{data.frame} with all the associated metadata.
#' @keywords internal
#' @export
#' @family lookup-tables
#' @importFrom utils read.csv
#' @examples showIPCCvars()

showIPCCvars <- function(names.only = TRUE) {
    out <- read.csv(file.path(find.package("metaclipcc"), "var_table.csv"),
                    stringsAsFactors = FALSE, na.strings = "")
    if (isTRUE(names.only)) out <- out$variable
    return(out)
}


#' @title Get future period
#' @description Get a future period time slice ready to be used by \code{metaclipR} functions
#' @param project Either \code{"CMIP5"} or \code{"CMIP6"}
#' @param model GCM name, as encoded in the reference lookup \code{dataset_table.csv}. Type  \code{unique(showIPCCdatasets(names.only = FALSE)$GCM)}
#' @param run Model run, as extracted literally from reference tables \code{Run} field
#' @param future.period Current options include the standard AR5 future time slices for near term, \code{"2021-2040"},
#'  medium term \code{"2041-2060"} and long term \code{"2081-2100"}, and the global warming levels
#'  of +1.5 degC \code{"1.5"}, +2 \code{"2"}, +3 \code{"3"} and +4 \code{"4"}.
#' @param rcp Experiment. Accepted values are restricted to \code{"historical", "rcp26", "rcp45", "rcp60", "rcp85"}
#' or corresponding ssps in case of CMIP6
#' @return An integer vector of length two, formed by start and end year of the future time slice
#' @keywords internal
#' @family lookup-tables
#' @importFrom utils read.csv
#' @importFrom magrittr %>%

# #TODO: Handle the way the driving GCM warming level period is retrieved for CORDEX
# project = "CMIP5"
# model = ref.model
# future.period = "1.5"
# rcp = experiment

metaclipcc.getFuturePeriod <- function(project, model, run, future.period, rcp) {
    project <- match.arg(project, choices = c("CMIP5", "CMIP6"))
    if (future.period == "1.5" | future.period == "2" | future.period == "3" | future.period == "4") {
        filename <- switch(project,
                           "CMIP5" = "gwl_CMIP5.csv",
                           "CMIP6" = "gwl_CMIP6.csv")
        out <- read.csv(file.path(find.package("metaclipcc"), filename),
                        stringsAsFactors = FALSE, na.strings = "NA")
        ind.row <- grep(paste0(model, "_", run), out$GCM, ignore.case = TRUE)
        ind.col <- grep(paste0(future.period,"_", rcp), names(out), ignore.case = TRUE)
        yr <- out[ind.row, ind.col]
        if (length(yr) == 0) yr <- NA # No GWL data for that model
        yr <- ifelse(yr == 9999, NA, yr)
        c(yr - 9, yr + 10) %>% return()
    } else {
        strsplit(future.period, split = "-") %>% unlist() %>% as.integer() %>% return()
    }
}


#' @title Internal for retrieving a Variable version from the dataset master table
#' @description Obtain the \code{ds:withVersionTag} data property associated with a CMIP6 \code{ds:Variable}
#' @return The variable version for the specified dataset, as a character string
#' @keywords internal
#' @family lookup-tables

getVariableVersion <- function(Dataset.name, variable) {
    aux <- showIPCCdatasets(names.only = FALSE)
    ind.row <- grep(Dataset.name, aux$name)
    ind.col <- grep(paste(variable, "version", sep = "_"), names(aux))
    return(aux[ind.row, ind.col])
}

