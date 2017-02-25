#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* FIXME:
  Check these declarations against the C/Fortran source code.
*/

  /* .Call calls */
extern SEXP QuantTools_back_test(SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP QuantTools_bbands(SEXP, SEXP, SEXP);
extern SEXP QuantTools_crossover(SEXP, SEXP);
extern SEXP QuantTools_ema(SEXP, SEXP);
extern SEXP QuantTools_na_locf(SEXP);
extern SEXP QuantTools_roll_correlation(SEXP, SEXP, SEXP);
extern SEXP QuantTools_roll_lm(SEXP, SEXP, SEXP);
extern SEXP QuantTools_roll_max(SEXP, SEXP);
extern SEXP QuantTools_roll_min(SEXP, SEXP);
extern SEXP QuantTools_roll_percent_rank(SEXP, SEXP);
extern SEXP QuantTools_roll_quantile(SEXP, SEXP, SEXP);
extern SEXP QuantTools_roll_range(SEXP, SEXP);
extern SEXP QuantTools_roll_sd(SEXP, SEXP);
extern SEXP QuantTools_roll_sd_filter(SEXP, SEXP, SEXP, SEXP);
extern SEXP QuantTools_roll_volume_profile(SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP QuantTools_rsi(SEXP, SEXP);
extern SEXP QuantTools_run_tests();
extern SEXP QuantTools_sma(SEXP, SEXP);
extern SEXP QuantTools_stochastic(SEXP, SEXP, SEXP, SEXP);
extern SEXP QuantTools_to_candles(SEXP, SEXP);

static const R_CallMethodDef CallEntries[] = {
  {"QuantTools_back_test",           (DL_FUNC) &QuantTools_back_test,           5},
  {"QuantTools_bbands",              (DL_FUNC) &QuantTools_bbands,              3},
  {"QuantTools_crossover",           (DL_FUNC) &QuantTools_crossover,           2},
  {"QuantTools_ema",                 (DL_FUNC) &QuantTools_ema,                 2},
  {"QuantTools_na_locf",             (DL_FUNC) &QuantTools_na_locf,             1},
  {"QuantTools_roll_correlation",    (DL_FUNC) &QuantTools_roll_correlation,    3},
  {"QuantTools_roll_lm",             (DL_FUNC) &QuantTools_roll_lm,             3},
  {"QuantTools_roll_max",            (DL_FUNC) &QuantTools_roll_max,            2},
  {"QuantTools_roll_min",            (DL_FUNC) &QuantTools_roll_min,            2},
  {"QuantTools_roll_percent_rank",   (DL_FUNC) &QuantTools_roll_percent_rank,   2},
  {"QuantTools_roll_quantile",       (DL_FUNC) &QuantTools_roll_quantile,       3},
  {"QuantTools_roll_range",          (DL_FUNC) &QuantTools_roll_range,          2},
  {"QuantTools_roll_sd",             (DL_FUNC) &QuantTools_roll_sd,             2},
  {"QuantTools_roll_sd_filter",      (DL_FUNC) &QuantTools_roll_sd_filter,      4},
  {"QuantTools_roll_volume_profile", (DL_FUNC) &QuantTools_roll_volume_profile, 5},
  {"QuantTools_rsi",                 (DL_FUNC) &QuantTools_rsi,                 2},
  {"QuantTools_run_tests",           (DL_FUNC) &QuantTools_run_tests,           0},
  {"QuantTools_sma",                 (DL_FUNC) &QuantTools_sma,                 2},
  {"QuantTools_stochastic",          (DL_FUNC) &QuantTools_stochastic,          4},
  {"QuantTools_to_candles",          (DL_FUNC) &QuantTools_to_candles,          2},
  {NULL, NULL, 0}
};

void R_init_QuantTools(DllInfo *dll)
{
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
