// [[Rcpp::plugins(cpp11)]]
// [[Rcpp::depends(QuantTools)]]
#include <Rcpp.h>
#include "BackTest.h"

// [[Rcpp::export]]
Rcpp::List bbands_market_maker(
    Rcpp::DataFrame ticks,
    Rcpp::List parameters,
    Rcpp::List options,
    bool fast = false
) {

  int    n          = parameters["n"         ];
  double k          = parameters["k"         ];
  int    timeFrame  = parameters["timeframe" ];

  // define strategy states
  enum class ProcessingState{ INIT, LONG, FLAT, SHORT };
  ProcessingState state = ProcessingState::INIT;
  int idTrade = 1;

  // initialize indicators
  BBands bbands( n, k );

  // initialize Processor
  Processor bt( timeFrame );
  // set options
  bt.SetOptions( options );
  // if trading hours not set then isTradingHours set true
  bool isTradingHours = not bt.IsTradingHoursSet();


  Order* buy;
  Order* sell;

  double levelLongEnter;
  double levelLongExit;
  double levelShortEnter;
  double levelShortExit;

  // define events logic

  // any trade exit event declaration
  std::function<void()> onTradeExit;

  // long closer logic
  std::function<void()> quoteLongExit = [&]() {

    // quote sell with current levelLongExit price
    sell = new Order( OrderSide::SELL, OrderType::LIMIT, levelLongExit, "close long", idTrade );
    // attach events to order:
    //   when long position closed ( sold ) exit logic triggered
    sell->onExecuted  = onTradeExit;
    //   when long closing order cancelled quote long closing order again
    sell->onCancelled = quoteLongExit;
    // send order to exchange
    bt.SendOrder( sell );

  };

  // long opener logic
  std::function<void()> quoteLongEnter = [&]() {

    // quote buy with current levelLongEnter price
    buy = new Order( OrderSide::BUY, OrderType::LIMIT, levelLongEnter, "long", idTrade );
    // attach events to order:
    //   when long opening order executed
    buy->onExecuted = [&]() {
      // change state to LONG
      state = ProcessingState::LONG;
      // change onCancelled event for short opener so the next time when
      // short opener cancelled it will trigger long order exiter
      sell->onCancelled = quoteLongExit;
      // or in case it is accidently executed there is no need in quoting long exiter
      // because it is already closed
      sell->onExecuted  = [&]() {
        // so just add relevant comment to it
        sell->comment = "close long on cancel";
        // and trigger exit logic
        onTradeExit();
      };
    };
    //  when long opening order cancelled qoute it again
    buy->onCancelled = quoteLongEnter;
    // send order to exchange
    bt.SendOrder( buy );

  };

  // short order closer logic
  std::function<void()> quoteShortExit = [&]() {

    // quote buy with current levelShortExit price
    buy = new Order( OrderSide::BUY, OrderType::LIMIT, levelShortExit, "close short", idTrade );
    // attach events to order:
    //   when short position closed ( bought ) exit logic triggered
    buy->onExecuted  = onTradeExit;
    //   when short closing order cancelled it again
    buy->onCancelled = quoteShortExit;
    // send order to exchange
    bt.SendOrder( buy );

  };

  // short opener logic
  std::function<void()> quoteShortEnter = [&]() {
    // quote sell with current levelShortEnter price
    sell = new Order( OrderSide::SELL, OrderType::LIMIT, levelShortEnter, "short", idTrade );
    // attach events to order:
    //   when short opening order executed
    sell->onExecuted = [&]() {
      // change state to SHORT
      state = ProcessingState::SHORT;
      // change onCancelled event for long opener so the next time when
      // long opener cancelled it will trigger short order exiter
      buy->onCancelled = quoteShortExit;
      // or in case it is accidently executed there is no need in quoting short exiter
      // because it is already closed
      buy->onExecuted  = [&]() {
        // so just add relevant comment to it
        buy->comment = "close short on cancel";
        // and trigger exit logic
        onTradeExit();
      };
    };
    //  when short opening order cancelled qoute it again
    sell->onCancelled = quoteShortEnter;
    // send order to exchange
    bt.SendOrder( sell );

  };

  // trade exit logic
  onTradeExit = [&]() {

    // reset state to FLAT
    state = ProcessingState::FLAT;
    // increment trade id
    idTrade++;
    // and start quoting long and short openers
    quoteLongEnter ();
    quoteShortEnter();

  };


  // define market open/close events
  bt.onMarketOpen  = [&]() {
    // allow trading
    isTradingHours = true;

  };
  bt.onMarketClose = [&]() {
    // forbid trading and close open positions
    isTradingHours = false;
    // if state was SHORT
    if( state == ProcessingState::SHORT ) {
      // redefine cancel logic of short closer:
      //   when cancelled
      buy->onCancelled = [&]() {
        // create market order to close short position
        Order* buy = new Order( OrderSide::BUY, OrderType::MARKET, NA_REAL, "close short (EOD)", idTrade );
        // attach events to order:
        //   when market order executed
        buy->onExecuted = [&]() {
          // reset state to initial
          state = ProcessingState::INIT;
          // and increment trade id
          idTrade++;
        };
        // send order to exchange
        bt.SendOrder( buy );
      };
      //  when executed
      buy->onExecuted = [&]() {
        // reset state to initial
        state = ProcessingState::INIT;
        // and increment trade id
        idTrade++;
      };
      // send cancel request to exchange
      buy->Cancel();

    }
    // if state was LONG
    if( state == ProcessingState::LONG ) {
      // redefine cancel logic of long closer:
      //   when cancelled
      sell->onCancelled = [&]() {
        // create market order to close short position
        Order* sell = new Order( OrderSide::SELL, OrderType::MARKET, NA_REAL, "close long (EOD)", idTrade );
        // attach events to order:
        //   when market order executed
        sell->onExecuted = [&]() {
          // reset state to initial
          state = ProcessingState::INIT;
          // and increment trade id
          idTrade++;
        };
        // send order to exchange
        bt.SendOrder( sell );

      };
      //  when executed
      sell->onExecuted = [&]() {
        // reset state to initial
        state = ProcessingState::INIT;
        // and increment trade id
        idTrade++;
      };
      // send cancel request to exchange
      sell->Cancel();
    }
    // if state was FLAT
    if( state == ProcessingState::FLAT ) {

      // let's try to cancel openers

      // redefine short opener logic
      // in case short opener executed
      sell->onExecuted = [&]() {
        // mark it as failed to cancel
        sell->comment = "short cancel failed (EOD)";
        // send long opener cancel request to exchange
        buy->Cancel();
        // create market order to close short position
        Order* buy = new Order( OrderSide::BUY, OrderType::MARKET, NA_REAL, "close short (EOD)", idTrade );
        // attach events to order:
        //   when market order executed
        buy->onExecuted = [&]() {
          // reset state to initial
          state = ProcessingState::INIT;
          // and increment trade id
          idTrade++;
        };
        // send order to exchange
        bt.SendOrder( buy );
      };
      // in case short opener cancelled
      sell->onCancelled = [&]() {
        // mark it as cancelled
        sell->comment = "short cancel (EOD)";
        // reset state to initial
        state = ProcessingState::INIT;
        // and increment trade id
        idTrade++;
      };
      // send cancel request to exchange
      sell->Cancel();

      // redefine long opener logic
      // in case long opener executed
      buy->onExecuted = [&]() {
        // mark it as failed to cancel
        buy->comment = "long cancel failed (EOD)";
        // send short opener cancel request to exchange
        sell->Cancel();
        // create market order to close long position
        Order* sell = new Order( OrderSide::SELL, OrderType::MARKET, NA_REAL, "close long (EOD)", idTrade );
        // attach events to order:
        //   when market order executed
        sell->onExecuted = [&]() {
          // reset state to initial
          state = ProcessingState::INIT;
          // and increment trade id
          idTrade++;
        };
        // send order to exchange
        bt.SendOrder( sell );
      };
      // in case long opener cancelled
      buy->onCancelled = [&]() {
        // mark it as cancelled
        buy->comment = "long cancel (EOD)";
        // reset state to initial
        state = ProcessingState::INIT;
        // and increment trade id
        idTrade++;
      };
      // send cancel request to exchange
      buy->Cancel();

    }

  };

  // define what to do when new candle arrived
  bt.onCandle = [&]( Candle candle ) {

    // add values to indicators
    bbands.Add( candle.close );
    // if bbands not formed yet do nothing
    if( not bbands.IsFormed() ) return;

    if( not bt.CanTrade()  ) return;
    if( not isTradingHours ) return;

    // update current levels
    levelLongEnter  = bbands.GetValue().lower;
    levelLongExit   = bbands.GetValue().sma;
    levelShortEnter = bbands.GetValue().upper;
    levelShortExit  = bbands.GetValue().sma;

    if( state == ProcessingState::INIT ) {

      // in case of initial state
      // start quoting long and short openers
      quoteLongEnter();
      quoteShortEnter();
      // and change state to FLAT
      state = ProcessingState::FLAT;

    } else {

      // if not in initial state
      // move current orders according to set logic
      bt.CancelOrders();

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
