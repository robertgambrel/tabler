#' Convert a model output to a dataframe
#'
#' @param model A model output object
#' @param teststat Which test statistic to show ('std.error' standard error, 'p.value' p
#'   value, 'statistic' model-specific statistic, \code{NA} for none)
#' @param digits The number of digits to display
#' @param digits_coef Override for digits for coefficient
#' @param digits_teststat Override for digits for test statistic
#' @param cutoffs Levels of significance to display stars for, in descending
#'   order
#' @param stars Choices for displayed stars
#' @return The data formatted into a dataframe, ready to merge with other models

convert_to_data <- function(model,
                            teststat = 'std.error',
                            digits = 3,
                            digits_coef = digits,
                            digits_teststat = digits,
                            cutoffs = c(0.1, 0.05, 0.01),
                            stars = c('*', '**', '***')) {

  if (length(stars) != length(cutoffs)) {
    stop("Cutoff values for significance and significance signifiers (stars)
         must have the same length.")
  }

  if (sum(cutoffs == sort(cutoffs, decreasing = T)) != length(cutoffs)) {
    stop(paste0("Please enter cutoff values in descending order (i.e. c(",
                paste(sort(cutoffs, decreasing = T), collapse = ', '), ")) and
                verify that the order of the stars are as intended."))
  }

  # use broom to tidy the model
  cleaned <- tidy(model)

  # assign stars based on cutoffs
  for (i in 1:length(cutoffs)) {
    cleaned <- cleaned %>%
      mutate(
        displayed_stars = ifelse(p.value < cutoffs[i], stars[i], '')
      )
  }
  cleaned <- cleaned %>%
    mutate(
      displayed_estimate = paste0(round(estimate, digits_coef), displayed_stars)
    )

  # add test statistic, requires standard evaluation from dplyr
  if (is.na(teststat)) {
    NULL
  } else{
    cleaned <- cleaned %>%
      mutate_(
        displayed_stat = lazyeval::interp(~round(var, digits_teststat),
                                          var = as.name(teststat))
        )
  }

  # convert to long form for merging
  cleaned_long <- cleaned %>%
    select(term, displayed_estimate, displayed_stat) %>%
    gather(type, value, 2:3) %>%
    arrange(term, type)

  return(cleaned_long)
}


