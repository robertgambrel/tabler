#' Convert a set of model outputs to a nice table
#'
#' @importFrom utils write.csv
#'
#' @export
#'
#' @param ... A model objects
#' @param teststat Which test statistic to show ('std.error' standard error,
#'   'p.value' p value, 'statistic' model-specific statistic, \code{NA} for
#'   none)
#' @param digits The number of digits to display
#' @param digits_coef Override for digits for coefficient
#' @param digits_teststat Override for digits for test statistic
#' @param cutoffs Levels of significance to display stars for, in descending
#'   order
#' @param stars Choices for displayed stars
#' @param intercept_last If true, move intercept to end of output
#' @param N whether or not to display observation count for the model
#' @param fit an optional list of model fit statistics (i.e. c("r.squared", "adj.r.squared"))
#' @param file Optional: output the file as a csv
#' @return A dataset of merged output, sorted nicely
#'



tablify <- function(...,
                   teststat = 'p.value',
                   digits = 3,
                   digits_coef = digits,
                   digits_teststat = digits,
                   cutoffs = c(0.1, 0.05, 0.01),
                   stars = c('*', '**', '***'),
                   intercept_last = T,
                   N = T,
                   fit = NULL,
                   file = NULL) {

  # check that each part of list is a model summary. They follow regular
  # patterns in class type
  model_list <- list(...)
  for (model in model_list) {
    #print(class(summary(model)))
    if (!grepl("summary[[:punct:]]", paste(class(summary(model)), collapse = ''))) {
      stop("Tried to convert a non-model object. Be sure inputs are model outputs.")
    }
  }

  # convert each model to a long form, and merge them
  base <- convert_to_data(model_list[[1]], teststat, digits, digits_coef, digits_teststat,
                         cutoffs, stars, N, fit)
  if (length(model_list) >= 2) {
    for (model in model_list[2:length(model_list)]) {
      temp <- convert_to_data(model, teststat, digits, digits_coef, digits_teststat,
                               cutoffs, stars, N, fit)
      base <- merge(base, temp, by = c('term', 'type'), all = T)
    }
  }

  names(base) <- c("Variable", "Result", paste0("Model ", 1:(length(names(base))-2)))

  base <- within(base, {
                 Result <- ifelse(Result == "displayed_estimate", "Coefficient", Result)
                 Result <- ifelse(Result == "displayed_stat", teststat, Result)
                })




  # if there were any overall fit stats (r-squared etc.) move them to the bottom
  if (!is.null(fit)) {
    base_nonfit <- base %>%
      dplyr::filter_(
        lazyeval::interp(~! x %in% fit, x = as.name("Variable"))
      )
    base_fit <- base %>%
      dplyr::filter_(
        lazyeval::interp(~x %in% fit, x = as.name("Variable"))
      )
    base <- rbind(base_nonfit, base_fit)
  }

  # if intercept last, move intercept to bottom of the coefficient list, but
  # keep N and model fit stats last
  if (intercept_last) {
    base <- base[c(3:nrow(base), 1:2), ]
    # if N was reported, move that last
    if (N) {
      base_1 <- base %>%
        dplyr::filter_(
          lazyeval::interp(~x != "N", x = as.name("Variable"))
        )
      base_2 <- base %>%
        dplyr::filter_(
          lazyeval::interp(~x == "N", x = as.name("Variable"))
        )
    }
    # if fit stat was requested
    if (!is.null(fit)) {
      for (stat in fit) {
        base_3 <- base %>%
          dplyr::filter_(
            lazyeval::interp(~x != stat, x = as.name("Variable"))
          )
        base_4 <- base %>%
          dplyr::filter_(
            lazyeval::interp(~x == stat, x = as.name("Variable"))
          )
        base <- rbind(base_3, base_4)
      }
    }

  }

  # make significance key
  sig_key = paste(paste0(paste0('p<', cutoffs, ': '), stars), collapse = ' ')

  sig_row = c(sig_key, NA, rep(NA_character_, ncol(base) - 2))

  final <- list(base, sig_key)

  if (!is.null(file)) {
    if (!grepl('.csv|.xls', file)) {
      stop("File must be a csv, xls, or xlsx output. Please include the appropriate file .type in the file argument.")
    } else if (grepl('.csv', file)) {
      output <- rbind(base, sig_row)
      write.csv(output, file, na = '')
    } else if (grepl('.xls', file)) {
      if (!requireNamespace("WriteXLS", quietly = TRUE)) {
        stop("Pkg WriteXLS needed to write xls / xlsx files. Please install it or switch to csv output.",
             call. = FALSE)
      }
      output <- rbind(base, sig_row)
      WriteXLS::WriteXLS("output", ExcelFileName = file)
    }

  }

  return(final)

}

