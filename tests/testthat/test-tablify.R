context("Testing conversion of a regression model output to a tidy table")

mtcars$dummy <- rbinom(nrow(mtcars), 1, 0.5)

lm1 <- lm(mpg ~ cyl, data = mtcars)
lm2 <- lm(mpg ~ cyl + wt, data = mtcars)
glm1 <- glm(dummy ~ cyl, family = binomial(link = 'logit'), data = mtcars)
glm2 <- glm(dummy ~ cyl + wt, family = binomial(link = 'logit'), data = mtcars)

fake_model <- list('head', 'body', 'foot')

test_that("Only model outputs are processed", {
  expect_type(tablify(lm1), "list")
  expect_type(tablify(lm1, lm2), "list")
  expect_type(tablify(lm1, lm2, digits = 1), "list")
  expect_type(tablify(lm1, lm2, digits = -1), "list")
  expect_type(tablify(lm1, lm2, stars = c('one', 'two', 'three')), "list")
  expect_type(tablify(lm1, lm2, stars = c('one', NA, NA)), "list")
  expect_type(tablify(glm1), "list")
  expect_type(tablify(glm1, glm2), "list")
  expect_type(tablify(glm1, glm2, digits = 1), "list")
  expect_type(tablify(glm1, glm2, digits = -1), "list")
  expect_type(tablify(glm1, glm2, stars = c('one', 'two', 'three')), "list")
  expect_type(tablify(glm1, glm2, stars = c('one', NA, NA)), "list")
  expect_error(tablify(fake_model))
  expect_error(tablify(lm1, fake_model))
  expect_error(tablify(nonexistent_model))
})

test_that("Models of different types can't display fit stats", {
  expect_type(tablify(lm1, glm1), "list")
  expect_error(tablify(lm1, glm1, fit = 'r.squared'))
})

test_that("Models of different types can display all coefficient test statistics", {
  expect_type(tablify(lm1, glm1, teststat = 'p.value'), "list")
  expect_type(tablify(lm1, glm1, teststat = 'statistic'), "list")
  expect_type(tablify(lm1, glm1, teststat = 'std.error'), "list")
})
