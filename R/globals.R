# Declare global variables to get around check()'s list of notes about NSE
# variables from dplyr and tidyr not showing up in the namespace

if(getRversion() >= "2.15.1") {
  utils::globalVariables(c("p.value", "displayed_stars", "estimate", "term",
                           "displayed_estimate", "displayed_stat", "type",
                           "value", "Result", "Variable"))
}
