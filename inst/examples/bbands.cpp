// [[Rcpp::plugins(cpp11)]]
// [[Rcpp::depends(QuantTools)]]
#include <Rcpp.h>
#include "BackTest.h"

// [[Rcpp::export]]
Rcpp::List bbands(
    Rcpp::DataFrame ticks,
    Rcpp::List parameters,
    Rcpp::List options,
    bool fast = false
  ) {

  int    n          = parameters["n"         ];
  double k          = parameters["k"         ];
  int    timeFrame  = parameters["timeframe" ];

  // define strategy states
  enum class ProcessingState{ LONG, FLAT, SHORT };
  ProcessingState state = ProcessingState::FLAT;
  int idTrade = 1;

  // initialize indicators
  BBands bbands( n, k );

  // initialize Processor
  Processor bt( timeFrame );
  // set options
  bt.SetOptions( options );
  // if trading hours not set then isTradingHours set true
  bool isTradingHours = not bt.IsTradingHoursSet();

  // define market open/close events
  bt.onMarketOpen  = [&]() {
    // allow trading
    isTradingHours = true;

  };
  bt.onMarketClose = [&]() {
    // forbid trading and close open positions
    isTradingHours = false;
    if( state == ProcessingState::SHORT ) {
      bt.SendOrder(
        new Order( OrderSide::BUY, OrderType::MARKET, NA_REAL, "close short (EOD)", idTrade++ )
      );
    }
    if( state == ProcessingState::LONG ) {
      bt.SendOrder(
        new Order( OrderSide::SELL, OrderType::MARKET, NA_REAL, "close long (EOD)", idTrade++ )
      );
    }
    state = ProcessingState::FLAT;

  };

  // define what to do when new candle is formed
  bt.onCandle = [&]( Candle candle ) {

    // add values to indicators
    bbands.Add( candle.close );

  };

  // define what to do when new tick arrived
  bt.onTick = [&]( Tick tick ) {

    // if bbands not formed yet do nothing
    if( not bbands.IsFormed() ) return;

    if( not bt.CanTrade()  ) return;
    if( not isTradingHours ) return;

    // if strategy has no position
    if( state == ProcessingState::FLAT) {
      // if price below lower band then buy
      if( tick.price < bbands.GetValue().lower ) {

        bt.SendOrder(
          new Order( OrderSide::BUY, OrderType::MARKET, NA_REAL, "long", idTrade )
        );
        state = ProcessingState::LONG;

      }
      // if price above apper band then sell
      if( tick.price > bbands.GetValue().upper ) {

        bt.SendOrder(
          new Order( OrderSide::SELL, OrderType::MARKET, NA_REAL, "short", idTrade )
        );
        state = ProcessingState::SHORT;

      }

    }
    // if strategy is long and price goes above sma then close long
    if( state == ProcessingState::LONG and tick.price > bbands.GetValue().sma ) {

      bt.SendOrder(
        new Order( OrderSide::SELL, OrderType::MARKET, NA_REAL, "close long", idTrade++ )
      );
      state = ProcessingState::FLAT;

    }
    // if strategy is below and price goes below sma then close long
    if( state == ProcessingState::SHORT and tick.price < bbands.GetValue().sma ) {

      bt.SendOrder(
        new Order( OrderSide::BUY, OrderType::MARKET, NA_REAL, "close short", idTrade++ )
      );
      state = ProcessingState::FLAT;

    }

  };

  // run back test on tick data
  bt.Feed( ticks );

  // test summary
  Rcpp::List summary = bt.GetSummary();

  // if fast return only summary
  if( fast ) return summary;

  // combine candles and indicators history
  Rcpp::List indicators = ListBuilder().AsDataTable()
    .Add( bt.GetCandles()                                )
    .Add( bbands.GetHistory()                            )
    .Add( "pnl"     , bt.GetOnCandleMarketValueHistory() )
    .Add( "drawdown", bt.GetOnCandleDrawDownHistory()    );

  // return back test summary, trades, orders and candles/indicators
  return ListBuilder()
    .Add( "summary"          , summary                              )
    .Add( "trades"           , bt.GetTrades()                       )
    .Add( "orders"           , bt.GetOrders()                       )
    .Add( "indicators"       , indicators                           )
    .Add( "daily_performance", bt.GetOnDayClosePerformanceHistory() );

}
