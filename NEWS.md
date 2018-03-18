#### v0.5.7:
- `Processor` `allow_exact_stop` option added.
- `ProcessorMulti` class added for backtesting single strategy on multiple symbols.
- `Order` stop and trail types added.
- `Alarm.GetTime()` method added.
- `Crossover` initial pair value set to `NAN`.
- `get_finam_data` local storage fixed.
- `get_iqfeed_data` retries to download if no message received.
- `get_iqfeed_data` `from` and `to` timestamp support added.
- `get_yahoo_data` dividend adjustment added and yahoo's split bug workaround added.
- `roll_lm` `x` and `y` inconsistency with `lm` fixed.
- `bw` `to` is included for `Date`s.
- `plot_dts` segments support added.
- `ListBuilder` possible protection stack imbalance fixed.
- fixed duplicated trades when orders cancelled after trade close.
- documentation layout updated for rdocumentation.com to be displayed correctly.


#### v0.5.6:
- `Processor` multiple options support added. You can set execution type, price step and act on time intervals. See help `?Processor` for details.
    - use `intervals` to set intervals and `onIntervalOpen()` and `onIntervalClose()` to act on interval open and close. 
    - use `price_step` to automatically round order price to this value before placing orders. 
    - use `execution_type` to choose between `bbo` and `trade` (default) execution types.
- `Processor` `mtm` and `mtm_rel` mark to market values added to trades and updated on every tick.
- `Processor` Bollinger Bands Market Maker example added. See examples in `?Processor`.
- `Order` `GetExecutionTime()`, `GetProcessedTime()`, `GetState()` methods added.
- `multi_heatmap` unsorted input values support added.
- `get_finam_data` local storage error fixed.
- `get_iqfeed_data` irrelevant warnings fixed.
- `bw` closed interval fixed for `Date`s.
- `plot_dts` single value plotting fixed.
- `back_test` `side` fixed.

#### v0.5.5:
- `na_locf` became smarter. Added support for `data.table`, `data.frame` and non numeric `vector`.
- `dof` function updated and `dofc` added. Apply function to `data.table` excluding first column ( e.g. if first column is date or time ) column-wise or to the rest columns as to single `data.table`.
- `bw` functionality updated. Now `/` can be used instead of `c( from, to )`. See `?bw` for examples.
- `plot_dts` chainable `plot_ts` successor added. A little buggy but much more configurable than `plot_ts`. See examples in `?Processor`.
- `Processor.GetCandle()` method added to retrieve current candle.
- `Processor.AllowLimitToHitMarket()` method added to allow limit orders to be executed as market if placed at price worse than current market price.
- `Processor` `onMarketClose` event now executed before `onMarketOpen`.
- `Processor` Bollinger Bands example added and SMA Crossover example updated.
- `get_yahoo_data` and `get_finam_data` fixed.

#### v0.5.4:
- `Processor` multiple options support added. You can set trading hours, latency, portfolio value stop loss and stop draw down, trading start time.
    - use `SetTradingHours( double start, double end )` method to set trading hours and `onMarketOpen()`, `onMarketClose()` events to act on trading hours `start` and `end`. Use `IsTradingHoursSet()` method to check if trading hours are set.
    - use `SetLatency( double x )`, `SetLatencySend( double x )`, `SetLatencyReceive( double x )` to set latency.
    - use `SetStop( Rcpp::List stop )` to set stop on portfolio negative market value and/or on portfolio draw down thresholds. `StopTrading()` method can be used to stop trading. Use `CanTrade()` to check if trading stopped. 
    - use `SetStartTradingTime( double t )` method to prevent order placing until time `t`.
    - use `SetOptions( Rcpp::List options )` to set any of above options using single list. `?Processor` 'Options' section for details.
- `Processor` trade cost and R Squared calculation fixed.
- `GetOnDayClosePerformanceHistory()` also returns average trade P&L ( `avg_pnl` ) and number of trades ( `n_per_day` ) per date. `return` first value set to `pnl`.
- `to_UTC` function added to convert time zone to 'UTC' without changing time value.
- `bw` function now selects time with `1e-6` precision and selects all if interval set to `NULL`
- `multi_heatmap` user axes support added.
- `plot_table` completely rewritten. See help for details.
- IQFeed hidden functionality added.
    - `QuantTools:::.get_iqfeed_security_types_info()`
    - `QuantTools:::.get_iqfeed_symbol_info( symbol, type_ids )`
- `get_iqfeed_data` current date check omited.
- `to_ticks` minimum volume set to 1.
- `ListBuilder` completely rewritten due to random errors and crashes. Should be used only with `Rcpp::List` class. `AsDataTable()` and `AsDataFrame()` methods should be used to tell R that created list is `data.table` and `data.frame` correspondingly.
- `IntToDate` return type set to `Rcpp::IntegerVector`.
- `Alarm` C++ class added.

#### v0.5.3:
- `round_POSIXct` `days` units support added.
- IQFeed local storage `1min` to `day` period support added.
- `Processor` mark to market caclulation fixed. Draw down calculation changed to difference between maximum market value and current market value.
- Added [MOEX](https://www.moex.com/en/derivatives/contracts.aspx) futures and options trades data support. Use `store_moex_data` to initialize local storage with `moex_storage`, `moex_data_url`, `moex_storage_from` settings. Use `get_moex_futures_data`, `get_moex_continuous_futures_data`, `get_moex_options_data` to get data from storage.
- `Processor.GetSummary()` method now returns `sharpe`, `sortino`, `r_squared`, `avg_dd`.
- `GetOnCandleMarketValueHistory()`, `GetOnCandleDrawDownHistory()`, `GetOnDayClosePerformanceHistory()` methods added to `Processor`.

#### v0.5.1:
- `Processor` now operates in the same time zone as input ticks. Ticks `tzone` attribute must be specified.
- `to_ticks` function added. As it is easier to get one minute bars than ticks for time span of several years `to_ticks` provides convinient way to convert these bars to ticks. Note that back test results on approximated ticks will be less realistic but may be acceptable for some strategies.
- IQFeed documentation updated and some hidden functionality added.
    - `QuantTools:::.get_iqfeed_markets_info()` retrieves markets info.
    - `QuantTools:::.get_iqfeed_trade_conditions_info()` retrieves trade conditions info.
- `get_finam_data` fixed.
- `round_POSIXct` changed to generic version.

#### v0.5.0: 
- Initial Release.
