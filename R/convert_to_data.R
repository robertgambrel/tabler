#' Convert a model output to a dataframe
#'
#' This takes each model used in the final table and converts it to a tidy
#' dataset, formatted and ready to be merged with others in a nice table.
#'
#' @inheritParams tablify
#' @param model A single model result
#'
#' @importFrom magrittr %>%
#'

convert_to_data <- function(model,
                            teststat = 'p.value',
                            digits = 3,
                            digits_coef = digits,
                            digits_teststat = digits,
                            cutoffs = c(0.1, 0.05, 0.01),
                            stars = c('*', '**', '***'),
                            N = T,
                            fit = NULL) {

  if (length(stars) != length(cutoffs)) {
    stop("Cutoff values for significance and significance signifiers (stars)
         must have the same length.")
  }

  if (!all.equal(cutoffs, sort(cutoffs, decreasing = T))) {
    stop(paste0("Please enter cutoff values in descending order (i.e. c(",
                paste(sort(cutoffs, decreasing = T), collapse = ', '), ")) and
                verify that the order of the stars are as intended."))
  }

  # use broom to tidy the model
  cleaned <- broom::tidy(model)

  # assign stars based on cutoffs
  cleaned$displayed_stars <- ''
  for (i in 1:length(cutoffs)) {
    cleaned <-
      dplyr::mutate(cleaned,
        displayed_stars = ifelse(p.value < cutoffs[i], stars[i], displayed_stars)
      )
  }
  cleaned <-
    dplyr::mutate(cleaned,
      displayed_estimate = paste0(round(estimate, digits_coef), displayed_stars)
    )

  # add test statistic, requires standard evaluation from dplyr

  if (!teststat %in% names(cleaned)) {
    stop(paste0("Test statistic ", teststat, " not available. Please select from ",
                paste(names(cleaned)[3:ncol(cleaned)], collapse = ", ")))
  }
  if (is.na(teststat)) {
    NULL
  } else {
    cleaned <- dplyr::`mutate_`(cleaned,
        displayed_stat = lazyeval::interp(~round(var, digits_teststat),
                                          var = as.name(teststat))
        )
  }



  # convert to long form for merging
  cleaned_long <- cleaned %>%
    dplyr::select(term, displayed_estimate, displayed_stat) %>%
    tidyr::gather(type, value, 2:3) %>%
    dplyr::arrange(term, type)

  # add number of observations if desired
  if (N) {
    n_obs <- length(model$residuals)
    cleaned_long <- rbind(cleaned_long, c("N", "", n_obs))
  }

  # add fit stats if they're requested
  if (!is.null(fit)) {
    for (stat in fit) {
      if (!stat %in% names(summary(model))) {
        stop(paste0("Error with fit statistic ", stat,
                    ". No statistic by that name found in model ",
                    deparse(substitute(model)), "."))
      }
      model_fit <- round(summary(model)[stat][[1]], digits_teststat)
      cleaned_long <- rbind(cleaned_long, c(stat, '', model_fit))
    }
  }
  return(cleaned_long)
}


