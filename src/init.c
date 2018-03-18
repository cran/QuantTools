#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* FIXME:
  Check these declarations against the C/Fortran source code.
*/

  /* .Call calls */
extern SEXP _QuantTools_back_test(SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _QuantTools_bbands(SEXP, SEXP, SEXP);
extern SEXP _QuantTools_crossover(SEXP, SEXP);
extern SEXP _QuantTools_ema(SEXP, SEXP);
extern SEXP _QuantTools_na_locf_numeric(SEXP);
extern SEXP _QuantTools_roll_correlation(SEXP, SEXP, SEXP);
extern SEXP _QuantTools_roll_lm(SEXP, SEXP, SEXP);
extern SEXP _QuantTools_roll_max(SEXP, SEXP);
extern SEXP _QuantTools_roll_min(SEXP, SEXP);
extern SEXP _QuantTools_roll_percent_rank(SEXP, SEXP);
extern SEXP _QuantTools_roll_quantile(SEXP, SEXP, SEXP);
extern SEXP _QuantTools_roll_range(SEXP, SEXP);
extern SEXP _QuantTools_roll_sd(SEXP, SEXP);
extern SEXP _QuantTools_roll_sd_filter(SEXP, SEXP, SEXP, SEXP);
extern SEXP _QuantTools_roll_volume_profile(SEXP, SEXP, SEXP, SEXP, SEXP);
extern SEXP _QuantTools_rsi(SEXP, SEXP);
extern SEXP _QuantTools_run_tests();
extern SEXP _QuantTools_sma(SEXP, SEXP);
extern SEXP _QuantTools_stochastic(SEXP, SEXP, SEXP, SEXP);
extern SEXP _QuantTools_to_candles(SEXP, SEXP);

static const R_CallMethodDef CallEntries[] = {
  {"_QuantTools_back_test",           (DL_FUNC) &_QuantTools_back_test,           5},
  {"_QuantTools_bbands",              (DL_FUNC) &_QuantTools_bbands,              3},
  {"_QuantTools_crossover",           (DL_FUNC) &_QuantTools_crossover,           2},
  {"_QuantTools_ema",                 (DL_FUNC) &_QuantTools_ema,                 2},
  {"_QuantTools_na_locf_numeric",     (DL_FUNC) &_QuantTools_na_locf_numeric,     1},
  {"_QuantTools_roll_correlation",    (DL_FUNC) &_QuantTools_roll_correlation,    3},
  {"_QuantTools_roll_lm",             (DL_FUNC) &_QuantTools_roll_lm,             3},
  {"_QuantTools_roll_max",            (DL_FUNC) &_QuantTools_roll_max,            2},
  {"_QuantTools_roll_min",            (DL_FUNC) &_QuantTools_roll_min,            2},
  {"_QuantTools_roll_percent_rank",   (DL_FUNC) &_QuantTools_roll_percent_rank,   2},
  {"_QuantTools_roll_quantile",       (DL_FUNC) &_QuantTools_roll_quantile,       3},
  {"_QuantTools_roll_range",          (DL_FUNC) &_QuantTools_roll_range,          2},
  {"_QuantTools_roll_sd",             (DL_FUNC) &_QuantTools_roll_sd,             2},
  {"_QuantTools_roll_sd_filter",      (DL_FUNC) &_QuantTools_roll_sd_filter,      4},
  {"_QuantTools_roll_volume_profile", (DL_FUNC) &_QuantTools_roll_volume_profile, 5},
  {"_QuantTools_rsi",                 (DL_FUNC) &_QuantTools_rsi,                 2},
  {"_QuantTools_run_tests",           (DL_FUNC) &_QuantTools_run_tests,           0},
  {"_QuantTools_sma",                 (DL_FUNC) &_QuantTools_sma,                 2},
  {"_QuantTools_stochastic",          (DL_FUNC) &_QuantTools_stochastic,          4},
  {"_QuantTools_to_candles",          (DL_FUNC) &_QuantTools_to_candles,          2},
  {NULL, NULL, 0}
};

void R_init_QuantTools(DllInfo *dll)
{
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
