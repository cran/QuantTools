// [[Rcpp::plugins(cpp11)]]
// [[Rcpp::depends(QuantTools)]]
#include <Rcpp.h>
#include "BackTest.h"

// [[Rcpp::export]]
Rcpp::List sma_crossover(
    Rcpp::DataFrame ticks,
    Rcpp::List parameters,
    Rcpp::List options,
    bool fast = false
  ) {

  int    fastPeriod = parameters["period_fast" ];
  int    slowPeriod = parameters["period_slow" ];
  int    timeFrame  = parameters["timeframe"   ];

  // define strategy states
  enum class ProcessingState{ LONG, FLAT, SHORT };
  ProcessingState state = ProcessingState::FLAT;
  int idTrade = 1;

  // initialize indicators
  Sma smaFast( fastPeriod );
  Sma smaSlow( slowPeriod );
  Crossover crossover;

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
    smaSlow.Add( candle.close );
    smaFast.Add( candle.close );

    // if moving averages not formed yet do nothing
    if( not smaFast.IsFormed() or not smaSlow.IsFormed() ) return;

    // update crossover
    crossover.Add( std::pair< double, double >( smaFast.GetValue(), smaSlow.GetValue() ) );

    if( not bt.CanTrade()  ) return;
    if( not isTradingHours ) return;

    // if smaFast is above smaSlow and current state is not long
    if( crossover.IsAbove() and state != ProcessingState::LONG ) {
      // if strategy has no position then buy
      if( state == ProcessingState::FLAT ) {
        bt.SendOrder(
          new Order( OrderSide::BUY, OrderType::MARKET, NA_REAL, "long", idTrade )
        );
      }
      // if strategy has short position then close short position and open long position
      if( state == ProcessingState::SHORT ) {
        bt.SendOrder(
          new Order( OrderSide::BUY, OrderType::MARKET, NA_REAL, "close short", idTrade++ )
        );
        bt.SendOrder(
          new Order( OrderSide::BUY, OrderType::MARKET, NA_REAL, "reverse short", idTrade )
        );
      }
      // set state to long
      state = ProcessingState::LONG;

    }
    // if smaFast is below smaSlow and current state is not short
    if( crossover.IsBelow() and state != ProcessingState::SHORT ) {
      // if strategy has no position then sell
      if( state == ProcessingState::FLAT ) {
        bt.SendOrder(
          new Order( OrderSide::SELL, OrderType::MARKET, NA_REAL, "short", idTrade )
        );
      }
      // if strategy has long position then close long position and open short position
      if( state == ProcessingState::LONG ) {
        bt.SendOrder(
          new Order( OrderSide::SELL, OrderType::MARKET, NA_REAL, "close long", idTrade++ )
        );
        bt.SendOrder(
          new Order( OrderSide::SELL, OrderType::MARKET, NA_REAL, "reverse long", idTrade )
        );
      }
      // set state to short
      state = ProcessingState::SHORT;

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
    .Add( "sma_slow", smaSlow.GetHistory()               )
    .Add( "sma_fast", smaFast.GetHistory()               )
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
