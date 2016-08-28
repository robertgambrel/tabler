lm1 <- lm(mpg ~ cyl, data = mtcars)

# should return a dataset
convert_to_data(lm1)

# does not exist, shoudl raise error
convert_to_data(lm0)

# should raise order error
convert_to_data(lm1, cutoffs = c(0.01, 0.05, 0.1))
