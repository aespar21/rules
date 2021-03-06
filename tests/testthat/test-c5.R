context("C5 fits")

source(file.path(test_path(), "test-helpers.R"))

ctrl <- C50::C5.0Control(subset = FALSE, seed = 2)

# ------------------------------------------------------------------------------

test_that('formula method', {

  c5_fit_exp <-
    C50::C5.0(
      x = ad_mod_x,
      y = ad_mod$Class,
      trials = 10,
      rules = TRUE,
      control = C50::C5.0Control(seed = 2)
    )
  c5_pred_exp <- predict(c5_fit_exp, ad_pred_x)
  c5_prob_exp <- predict(c5_fit_exp, ad_pred_x, type = "prob")

  expect_error(
    c5_mod <-
      C5_rules(trees = 10) %>%
      set_engine("C5.0", seed = 2),
    NA
  )

  expect_error(
    c5_fit <- fit(c5_mod, Class ~ ., data = ad_mod),
    NA
  )
  c5_pred <- predict(c5_fit, ad_pred)
  c5_prob <- predict(c5_fit, ad_pred, type = "prob")

  expect_equal(c5_fit_exp$boostResults, c5_fit$fit$boostResults)
  expect_equal(names(c5_pred), ".pred_class")
  expect_true(tibble::is_tibble(c5_pred))
  expect_equal(c5_pred$.pred_class, c5_pred_exp)
})

# ------------------------------------------------------------------------------

test_that('formula method - control', {

  c5_fit_exp <-
    C50::C5.0(
      x = ad_mod_x,
      y = ad_mod$Class,
      trials = 2,
      rules = TRUE,
      control = C50::C5.0Control(seed = 2, subset = FALSE)
    )
  c5_pred_exp <- predict(c5_fit_exp, ad_pred_x)

  expect_error(
    c5_mod <-
      C5_rules(trees = 2) %>%
      set_engine("C5.0", control = ctrl),
    NA
  )

  expect_error(
    c5_fit <- fit(c5_mod, Class ~ ., data = ad_mod),
    NA
  )
  c5_pred <- predict(c5_fit, ad_pred)
  c5_prob <- predict(c5_fit, ad_pred, type = "prob")

  expect_equal(c5_fit_exp$boostResults, c5_fit$fit$boostResults)
  expect_equal(names(c5_pred), ".pred_class")
  expect_true(tibble::is_tibble(c5_pred))
  expect_equal(c5_pred$.pred_class, c5_pred_exp)
})

# ------------------------------------------------------------------------------

test_that('non-formula method', {

  c5_fit_exp <-
    C50::C5.0(
      x = as.data.frame(ad_mod[, -1]),
      y = ad_mod$Class,
      trials = 10,
      rules = TRUE,
      control = C50::C5.0Control(seed = 2)
    )
  c5_pred_exp <- predict(c5_fit_exp, ad_pred)

  expect_error(
    c5_mod <-
      C5_rules(trees = 10) %>%
      set_engine("C5.0", seed = 2),
    NA
  )

  expect_error(
    c5_fit <- fit_xy(c5_mod, x = as.data.frame(ad_mod[, -1]), y = ad_mod$Class),
    NA
  )
  c5_pred <- predict(c5_fit, ad_pred)
  c5_prob <- predict(c5_fit, ad_pred, type = "prob")

  expect_equal(c5_fit_exp$boostResults, c5_fit$fit$boostResults)
  expect_equal(names(c5_pred), ".pred_class")
  expect_true(tibble::is_tibble(c5_pred))
  expect_equal(c5_pred$.pred_class, c5_pred_exp)
})

# ------------------------------------------------------------------------------

test_that('non-formula method - control', {

  c5_fit_exp <-
    C50::C5.0(
      x = as.data.frame(ad_mod[, -1]),
      y = ad_mod$Class,
      trials = 2,
      rules = TRUE,
      control = C50::C5.0Control(seed = 2, subset = FALSE)
    )
  c5_pred_exp <- predict(c5_fit_exp, ad_pred)

  expect_error(
    c5_mod <-
      C5_rules(trees = 2) %>%
      set_engine("C5.0", control = ctrl),
    NA
  )

  expect_error(
    c5_fit <- fit_xy(c5_mod, x = as.data.frame(ad_mod[, -1]), y = ad_mod$Class),
    NA
  )
  c5_pred <- predict(c5_fit, ad_pred)
  c5_prob <- predict(c5_fit, ad_pred, type = "prob")

  expect_equal(c5_fit_exp$boostResults, c5_fit$fit$boostResults)
  expect_equal(names(c5_pred), ".pred_class")
  expect_true(tibble::is_tibble(c5_pred))
  expect_equal(c5_pred$.pred_class, c5_pred_exp)
})

# ------------------------------------------------------------------------------

test_that('printing', {
  expect_output(print(C5_rules(trees = 1)))
})

# ------------------------------------------------------------------------------

test_that('updates', {
  spec_1 <-    C5_rules(trees =  1)
  spec_1_a <-  C5_rules(trees =  1, min_n = 100)
  spec_10 <-   C5_rules(trees = 10)
  spec_10_a <- C5_rules(trees = 10, min_n = 100)

  expect_equal(update(spec_1,   tibble::tibble(trees = 10))$args$trees, 10)
  expect_equal(update(spec_1_a, tibble::tibble(trees = 10))$args$trees, 10)

  expect_equal(update(spec_1,   trees = 10), spec_10)
  expect_equal(update(spec_1_a, trees = 10), spec_10_a)
})


# ------------------------------------------------------------------------------

test_that('mulit-predict', {
  c5_fit <-
    C5_rules(trees = 10) %>%
    set_engine("C5.0", seed = 2) %>%
    fit_xy(x = ad_mod_x[-(1:5), -1], y = ad_mod$Class[-(1:5)])

  c5_multi_pred <-
    multi_predict(c5_fit, ad_mod_x[1:5, -1], trees = 1:3) %>%
    mutate(.rows = row_number()) %>%
    tidyr::unnest(cols = c(.pred))
  c5_multi_prob <-
    multi_predict(c5_fit, ad_mod_x[1:5, -1], type = "prob", trees = 1:3) %>%
    mutate(.rows = row_number()) %>%
    tidyr::unnest(cols = c(.pred))

  expect_equivalent(
    predict(c5_fit$fit, ad_mod_x[1:5, -1], trees = 1, type = "prob")[,1],
    c5_multi_prob$.pred_Impaired[c5_multi_prob$trees == 1]
  )

})
