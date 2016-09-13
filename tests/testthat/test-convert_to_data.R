context("Testing conversion of a regression model output to a tidy table")

mtcars$dummy <- rbinom(nrow(mtcars), 1, 0.5)

lm1 <- lm(mpg ~ cyl, data = mtcars)
lm2 <- lm(mpg ~ cyl + wt, data = mtcars)
glm1 <- glm(dummy ~ cyl, family = binomial(link = 'logit'), data = mtcars)
glm2 <- glm(dummy ~ cyl + wt, family = binomial(link = 'logit'), data = mtcars)


# should return a dataset
test_that("Expected arguments yield a dataset", {
  expect_type(convert_to_data(lm1), "list")
  expect_type(convert_to_data(lm1), "list")
  expect_type(convert_to_data(lm1, digits = 1), "list")
  expect_type(convert_to_data(lm1, digits = -1), "list")
  expect_type(convert_to_data(lm1, stars = c('one', 'two', 'three')), "list")
  expect_type(convert_to_data(lm1, stars = c('one', NA, NA)), "list")
  expect_type(convert_to_data(glm1), "list")
  expect_type(convert_to_data(glm1), "list")
  expect_type(convert_to_data(glm1, digits = 1), "list")
  expect_type(convert_to_data(glm1, digits = -1), "list")
  expect_type(convert_to_data(glm1, stars = c('one', 'two', 'three')), "list")
  expect_type(convert_to_data(glm1, stars = c('one', NA, NA)), "list")

})

test_that("Wrong order of cutoffs produces an error", {
  expect_error(convert_to_data(lm1, cutoffs = c(0.01, 0.05, 0.1)))
  expect_error(convert_to_data(lm1, cutoffs = c(0.01, 0.05, NA)))
})

test_that("Cutoffs and stars vectors must be same length", {
  expect_error(convert_to_data(lm1, cutoffs = c(0.1, 0.05),
                               stars = c('*', '**', '***')))
  expect_type(convert_to_data(lm1, cutoffs = c(0.1, 0.05),
                               stars = c('*', '**')), "list")
})

test_that("Requesting coeffecient test stats that aren't available throws an error", {
  expect_error(convert_to_data(lm1, teststat = 'r.squared'))
  expect_type(convert_to_data(lm1, teststat = 'p.value'), "list")
  expect_type(convert_to_data(glm1, teststat = 'p.value'), "list")
  expect_error(convert_to_data(glm1, teststat = 't.statistic'))

})

