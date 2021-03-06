#' @importFrom rlang enquo call2 abort eval_tidy warn new_quosure empty_env
#' @importFrom rlang enquos expr
#' @importFrom purrr map_dfr
#' @importFrom tibble is_tibble as_tibble tibble
#' @importFrom parsnip set_new_model multi_predict update_dot_check show_fit
#' @importFrom parsnip new_model_spec is_varying null_value update_main_parameters
#' @importFrom parsnip check_final_param
#' @importFrom stats predict model.frame model.response setNames
#' @importFrom dials new_quant_param
#' @importFrom tidyr nest
#' @importFrom utils head globalVariables
#' @importFrom dplyr %>% bind_rows
#'
#' @export
parsnip::multi_predict

# ------------------------------------------------------------------------------

utils::globalVariables(
  c(
    ".pred_1", ".pred_2", ".pred_class", ".rows", "object", "new_data", "name",
    ".pred", "(Intercept)", "committee", "rule", "trials"
  )
)
