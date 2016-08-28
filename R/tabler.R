#' Convert a set of model outputs to a nice table
#'
#' @param model_list Names of a set of model object
#' @param teststat Which test statistic to show ('std.error' standard error,
#'   'p.value' p value, 'statistic' model-specific statistic, \code{NA} for
#'   none)
#' @param digits The number of digits to display
#' @param digits_coef Override for digits for coefficient
#' @param digits_teststat Override for digits for test statistic
#' @param cutoffs Levels of significance to display stars for, in descending
#'   order
#' @param stars Choices for displayed stars
#' @param file Optional: output the file as a csv
#' @return A dataset of merged output, sorted nicely
#'
#'
#'
tabler <- function(model_list,
                   teststat = 'p.value',
                   digits = 3,
                   digits_coef = digits,
                   digits_teststat = digits,
                   cutoffs = c(0.1, 0.05, 0.01),
                   stars = c('*', '**', '***'),
                   intercept_last = T,
                   save = F) {

  # check that each part of list is a model summary. They follow regular
  # patterns in class type
  for (model in model_list) {
    print(class(summary(model)))
    if (!grepl("summary[[:punct:]]", paste(class(summary(model)), collapse = ''))) {
      stop("Tried to convert a non-model object. Be sure model list is of type list() and not c().")
    }
  }

  # convert each model to a long form, and merge them
  base <- convert_to_data(model_list[[1]], teststat, digits, digits_coef, digits_teststat,
                         cutoffs, stars)
  for (model in model_list[2:length(model_list)]) {
    temp <- convert_to_data(model, teststat, digits, digits_coef, digits_teststat,
                             cutoffs, stars)
    base <- merge(base, temp, by = c('term', 'type'), all = T)
  }

  names(base) <- c("Variable", "Result", paste0("Model ", 1:(length(names(base))-2)))

  base <- base %>%
    mutate(
      Result = ifelse(Result == "displayed_estimate", "Coefficient", Result),
      Result = ifelse(Result == "displayed_stat", teststat, Result)
    )

  # if intercept last, move intercept to bottom of the table
  if (intercept_last) {
    base <- base[c(3:nrow(base), 1:2), ]
  }

  # make significance key
  sig_key = paste(paste0(paste0('p<', cutoffs, ': '), stars), collapse = ' ')

  sig_row = c(sig_key, rep(NA, ncol(base) - 1))

  final <- rbind(base, sig_row)

  return(final)

}
