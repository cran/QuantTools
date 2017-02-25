// Copyright (C) 2016 Stanislav Kovalevsky
//
// This file is part of QuantTools.
//
// QuantTools is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 2 of the License, or
// (at your option) any later version.
//
// QuantTools is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with QuantTools. If not, see <http://www.gnu.org/licenses/>.

#ifndef PROCESSOR_H
#define PROCESSOR_H

#include "Order.h"
#include "Trade.h"
#include "Candle.h"
#include "Cost.h"
#include "Tick.h"
#include "Statistics.h"
#include "../CppToR.h"
#include "../ListBuilder.h"
#include "../NPeriods.h"
#include "../Alarm.h"
#include <map>
#include <cmath>
#include <Rcpp.h>

class Processor {

  friend class Test;
  friend class Statistics;

private:

  std::vector< std::string > OrderSideString  = { "buy", "sell" };
  std::vector< std::string > TradeSideString  = { "long", "short" };
  std::vector< std::string > OrderTypeString  = { "market", "limit" };
  std::vector< std::string > OrderStateString = { "new", "registered", "executed", "cancelling", "cancelled" };
  std::vector< std::string > TradeStateString = { "new", "opened", "closed", "closing" };

  std::vector<Order*> orders;
  std::vector<Order*> ordersProcessed;

  std::map< int, Trade*> trades;
  std::map< int, Trade*> tradesProcessed;

  std::vector<Candle> candles;

  double prevTickTime;
  double latencySend;
  double latencyReceive;
  int    timeFrame;
  Candle candle;

  Cost   cost;

  std::string timeZone;

  Alarm alarmMarketOpen;
  Alarm alarmMarketClose;


  double startTradingTime    = 0;
  double stopTradingDrawdown = NAN;
  double stopTradingLoss     = NAN;
  bool   isTradingStopped = false;

  void FormCandle( const Tick& tick ) {

    bool startOver = candle.time != floor( tick.time / timeFrame ) * timeFrame + timeFrame;

    if( startOver and candle.time != 0 ) {

      if( onCandle != nullptr ) onCandle( candle );

      candles.push_back( candle );

      statistics.Update( candle );

    }

    candle.Add( tick );

  };

public:

  Statistics statistics;

  std::function< void( const Tick&   ) > onTick;
  std::function< void( const Candle& ) > onCandle;
  std::function< void( ) > onMarketOpen;
  std::function< void( ) > onMarketClose;

  Processor( int timeFrame, double latencySend = 0.001, double latencyReceive = 0.001 ) :

    latencySend   ( latencySend    ),
    latencyReceive( latencyReceive ),
    timeFrame     ( timeFrame      ),
    candle        ( timeFrame      )

  {

    Reset();
    timeZone = "UTC";

  };

  ~Processor() { Reset(); }

  void SetCost( Cost cost ) { this->cost = cost; }
  void SetCost( Rcpp::List cost ) {

    Rcpp::StringVector names = cost.attr( "names" );

    bool hasPointValue = std::find( names.begin(), names.end(), "pointValue" ) != names.end();
    bool hasCancel     = std::find( names.begin(), names.end(), "cancel"     ) != names.end();
    bool hasOrder      = std::find( names.begin(), names.end(), "order"      ) != names.end();
    bool hasStockAbs   = std::find( names.begin(), names.end(), "stockAbs"   ) != names.end();
    bool hasTradeAbs   = std::find( names.begin(), names.end(), "tradeAbs"   ) != names.end();
    bool hasTradeRel   = std::find( names.begin(), names.end(), "tradeRel"   ) != names.end();
    bool hasLongAbs    = std::find( names.begin(), names.end(), "longAbs"    ) != names.end();
    bool hasLongRel    = std::find( names.begin(), names.end(), "longRel"    ) != names.end();
    bool hasShortAbs   = std::find( names.begin(), names.end(), "shortAbs"   ) != names.end();
    bool hasShortRel   = std::find( names.begin(), names.end(), "shortRel"   ) != names.end();

    if( hasPointValue ) this->cost.pointValue = cost["pointValue"];
    if( hasCancel     ) this->cost.cancel     = cost["cancel"    ];
    if( hasOrder      ) this->cost.order      = cost["order"     ];
    if( hasStockAbs   ) this->cost.stockAbs   = cost["stockAbs"  ];
    if( hasTradeAbs   ) this->cost.tradeAbs   = cost["tradeAbs"  ];
    if( hasTradeRel   ) this->cost.tradeRel   = cost["tradeRel"  ];
    if( hasLongAbs    ) this->cost.longAbs    = cost["longAbs"   ];
    if( hasLongRel    ) this->cost.longRel    = cost["longRel"   ];
    if( hasShortAbs   ) this->cost.shortAbs   = cost["shortAbs"  ];
    if( hasShortRel   ) this->cost.shortRel   = cost["shortRel"  ];

  }

  void SetStop( Rcpp::List stop ) {

    Rcpp::StringVector names = stop.attr( "names" );

    bool hasDrawDown = std::find( names.begin(), names.end(), "drawdown" ) != names.end();
    bool hasLoss	   = std::find( names.begin(), names.end(), "loss"     ) != names.end();

    if( hasDrawDown ) stopTradingDrawdown = stop["drawdown" ];
    if( hasLoss     ) stopTradingLoss     = stop["loss"     ];


  }
  void SetTradingHours( double start, double end ) {

    alarmMarketOpen .Set( start );
    alarmMarketClose.Set( end   );

  }
  bool IsTradingHoursSet() { return alarmMarketClose.IsSet() and alarmMarketOpen.IsSet(); }
  void SetLatencyReceive( double latencyReceive ) {

    this->latencyReceive = latencyReceive;

  }
  void SetLatencySend( double latencySend ) {

    this->latencySend = latencySend;

  }
  void SetLatency( double latency ) {

    latencySend    = latency / 2;
    latencyReceive = latency / 2;

  }
  void SetStartTradingTime( double startTradingTime ) {

    this->startTradingTime = startTradingTime;

  }

  void SetOptions( Rcpp::List options ) {

    Rcpp::StringVector names = options.attr( "names" );

    bool hasCost           = std::find( names.begin(), names.end(), "cost"            ) != names.end();
    bool hasStop           = std::find( names.begin(), names.end(), "stop"            ) != names.end();
    bool hasTradeStart     = std::find( names.begin(), names.end(), "trade_start"     ) != names.end();
    bool hasLatency        = std::find( names.begin(), names.end(), "latency"         ) != names.end();
    bool hasLatencyReceive = std::find( names.begin(), names.end(), "latency_receive" ) != names.end();
    bool hasLatencySend    = std::find( names.begin(), names.end(), "latency_send"    ) != names.end();
    bool hasTradingHours   = std::find( names.begin(), names.end(), "trading_hours"   ) != names.end();

    if( hasTradingHours ) {

      Rcpp::NumericVector tradingHours = options["trading_hours"];
      if( tradingHours.size() != 2 ) { throw std::invalid_argument( "trading_hours must have two elements" ); }
      SetTradingHours( tradingHours[0], tradingHours[1] );

    }

    if( hasCost ) {

      Rcpp::List cost = options["cost"];
      SetCost( cost );

    }
    if( hasStop           ) SetStop            ( options["stop"           ] );
    if( hasTradeStart     ) SetStartTradingTime( options["trade_start"    ] );
    if( hasLatency        ) SetLatency         ( options["latency"        ] );
    if( hasLatencyReceive ) SetLatencyReceive  ( options["latency_receive"] );
    if( hasLatencySend    ) SetLatencySend     ( options["latency_send"   ] );

  }


  void Feed( const Tick& tick ) {

    if( tick.time < prevTickTime ) { throw std::invalid_argument( "ticks must be time ordered tick.id = " + std::to_string( tick.id + 1 ) ); }

    if( statistics.drawDown < stopTradingDrawdown ) StopTrading();
    if( statistics.marketValue < stopTradingLoss )  StopTrading();

    if( onMarketOpen  != nullptr and alarmMarketOpen .IsRinging( tick.time ) ) onMarketOpen();
    if( onMarketClose != nullptr and alarmMarketClose.IsRinging( tick.time ) ) onMarketClose();

    FormCandle( tick );

    if( onTick != nullptr ) onTick( tick );

    for( auto it = orders.begin(); it != orders.end();  ) {

      Order* order = (*it);

      order->Update( tick, latencySend, latencyReceive );

      statistics.Update( order );

      if( trades.count( order->idTrade ) == 0 ) {

        Trade* trade    = new Trade;

        trade->idTrade  = order->idTrade;
        trade->state    = TradeState::NEW;
        trade->idSent   = order->idSent;
        trade->timeSent = order->timeSent;
        trade->side     = order->IsBuy() ? TradeSide::LONG : TradeSide::SHORT;
        trade->cost     = cost.order;

        trades[ order->idTrade ] = trade;

      } else {

        Trade* trade = trades[ order->idTrade ];
        if( order->IsExecuted() ) {

          trade->cost += cost.stockAbs + cost.tradeAbs + cost.tradeRel * order->priceExecuted * cost.pointValue;

          if( trade->IsOpened() or trade->IsClosing() ) {

            trade->idExit    = order->idProcessed;
            trade->timeExit  = order->timeProcessed;
            trade->priceExit = order->priceExecuted;
            trade->pnl       = ( trade->IsLong() ? +1. : -1. ) * ( trade->priceExit - trade->priceEnter ) * cost.pointValue + trade->cost;
            trade->pnlRel    = trade->pnl / ( trade->priceEnter * cost.pointValue );
            trade->state     = TradeState::CLOSED;

            statistics.Update( trade );

          }

          if( trade->IsNew() ) {

            trade->idEnter    = order->idProcessed;
            trade->timeEnter  = order->timeProcessed;
            trade->priceEnter = order->priceExecuted;

            trade->state = TradeState::OPENED;

          }

        }

        if( order->IsNew()       ) { trade->cost += cost.order;  }
        if( order->IsCancelled() ) { trade->cost += cost.cancel; }

        trade->costRel = trade->cost / ( trade->priceEnter * cost.pointValue );

      }

      if( order->IsExecuted() or order->IsCancelled() ) {

        ordersProcessed.push_back( order );
        it = orders.erase( it );

      } else ++it;

    }

    for( auto it = trades.begin(); it != trades.end();  ) {

      Trade* trade = it->second;

      if( trade->IsOpened() ) {

        int nNights = NNights( prevTickTime, tick.time );

        if( nNights > 0 ) {

          trade->cost += nNights * ( trade->IsLong() ? cost.longAbs : cost.shortAbs );
          trade->cost += nNights * ( trade->IsLong() ? cost.longRel : cost.shortRel ) * candles.back().close * cost.pointValue;

        }

        double mtm = ( trade->IsLong() ? +1. : -1. ) * ( tick.price - trade->priceEnter );

        if( trade->mtmMax < mtm ) {

          trade->mtmMax    = mtm;
          trade->mtmMaxRel = mtm / trade->priceEnter;

        }
        if( trade->mtmMin > mtm ) {

          trade->mtmMin    = mtm;
          trade->mtmMinRel = mtm / trade->priceEnter;

        }

        if( isTradingStopped and not trade->IsClosing() ) {

          Order* order = new Order( trade->IsLong() ? OrderSide::SELL : OrderSide::BUY, OrderType::MARKET, NA_REAL, "stop", trade->idTrade );

          orders.push_back( order );
          statistics.Update( order );

          trade->state = TradeState::CLOSING;

        }

      }

      if( trade->IsClosed() ) {

        tradesProcessed[it->first] = trade;
        it = trades.erase( it );

      } else ++it;

    }

    statistics.Update( tick );

    prevTickTime = tick.time;

  }

  Statistics GetStatistics() { return statistics; }

  void StopTrading() {

    isTradingStopped = true;

  }

  void Feed( Rcpp::NumericVector times, Rcpp::NumericVector prices, Rcpp::IntegerVector volumes ) {

    if( times.size() != prices.size() or times.size() != volumes.size() or prices.size() != volumes.size() ) {

      throw std::invalid_argument( "times, prices and volumes must have equal lengths" );

    }

    auto n = times.size();

    Tick tick;

    for( auto id = 0; id < n; id++ ) {

      tick.id = id;
      tick.time = times[id];
      tick.price = prices[id];
      tick.volume = volumes[id];
      Feed( tick );

    }

    statistics.Finalize();

  }

  void Feed( Rcpp::DataFrame ticks ) {


    Rcpp::StringVector names = ticks.attr( "names" );

    bool hasTime   = std::find( names.begin(), names.end(), "time"   ) != names.end();
    bool hasPrice  = std::find( names.begin(), names.end(), "price"  ) != names.end();
    bool hasVolume = std::find( names.begin(), names.end(), "volume" ) != names.end();

    if( !hasTime   ) throw std::invalid_argument( "ticks must contain 'time' column"   );
    if( !hasPrice  ) throw std::invalid_argument( "ticks must contain 'price' column"  );
    if( !hasVolume ) throw std::invalid_argument( "ticks must contain 'volume' column" );

    Rcpp::NumericVector  times   = ticks[ "time"   ];
    Rcpp::NumericVector  prices  = ticks[ "price"  ];
    Rcpp::IntegerVector  volumes = ticks[ "volume" ];

    std::vector<std::string> tzone = times.attr( "tzone" );

    if( tzone.empty() ) throw std::invalid_argument( "ticks timezone must be set" );

    timeZone = tzone[0];

    auto n = times.size();

    Tick tick;

    for( auto id = 0; id < n; id++ ) {

      tick.id     = id;
      tick.time   = times[id];
      tick.price  = prices[id];
      tick.volume = volumes[id];
      Feed( tick );

    }

    statistics.Finalize();

  }

  void SendOrder( Order* order ) {

    if( not CanTrade() ) {

      delete order;
      return;

    }

    orders.push_back( order );
    statistics.Update( order );

  }

  void CancelOrders() { for( auto order: orders ) order->Cancel( ); }

  bool CanTrade() { return not( prevTickTime < startTradingTime or isTradingStopped ); }

  int GetPosition() { return statistics.position; }

  int GetPositionPlanned() { return statistics.positionPlanned; }

  double GetMarketValue() { return statistics.marketValue * 100; }

  void Reset() {

    for( auto order: orders ) delete order;
    orders.clear();

    for( auto order: ordersProcessed ) delete order;
    ordersProcessed.clear();

    for( auto r: trades ) delete r.second;
    trades.clear();

    for( auto r: tradesProcessed ) delete r.second;
    tradesProcessed.clear();

    statistics.Reset();
    prevTickTime = 0;
    isTradingStopped = false;
  }

  std::vector<double> GetOnCandleMarketValueHistory() {  return statistics.onCandleHistoryMarketValue;  }

  std::vector<double> GetOnCandleDrawDownHistory() {  return statistics.onCandleHistoryDrawDown;  }

  Rcpp::List GetOnDayClosePerformanceHistory() {

    Rcpp::List performance = ListBuilder().AsDataTable()
      .Add( "date"     , IntToDate( statistics.onDayCloseHistoryDates ) )
      .Add( "return"   , statistics.onDayCloseHistoryMarketValueChange  )
      .Add( "pnl"      , statistics.onDayCloseHistoryMarketValue        )
      .Add( "drawdown" , statistics.onDayCloseHistoryDrawDown           )
      .Add( "avg_pnl"  , statistics.onDayCloseHistoryAvgTradePnl        )
      .Add( "n_per_day", statistics.onDayCloseHistoryNTrades            );

    return performance;

  }

  Rcpp::List GetCandles() {

    int n = candles.size();

    Rcpp::IntegerVector id    ( n );
    Rcpp::NumericVector open  ( n );
    Rcpp::NumericVector high  ( n );
    Rcpp::NumericVector low   ( n );
    Rcpp::NumericVector close ( n );
    Rcpp::NumericVector time  = DoubleToDateTime( std::vector<double>( n ), timeZone );
    Rcpp::IntegerVector volume( n );

    int i = 0;
    auto convertCandle = [&]( std::vector<Candle>::iterator it ) {

      id    [i] = it->id + 1;
      open  [i] = it->open;
      high  [i] = it->high;
      low   [i] = it->low;
      close [i] = it->close;
      time  [i] = it->time;
      volume[i] = it->volume;

      i++;

    };

    for( auto it = candles.begin(); it != candles.end(); it++ ) convertCandle( it );

    Rcpp::List candles = ListBuilder().AsDataTable()

      .Add( "time"  , time   )
      .Add( "open"  , open   )
      .Add( "high"  , high   )
      .Add( "low"   , low    )
      .Add( "close" , close  )
      .Add( "volume", volume )
      .Add( "id"    , id     );

    return candles;

  }

  Rcpp::List GetOrders() {

    int n = orders.size() + ordersProcessed.size();

    Rcpp::IntegerVector   id_trade      ( n );
    Rcpp::IntegerVector   id_sent       ( n );
    Rcpp::IntegerVector   id_processed  ( n );
    Rcpp::NumericVector   time_sent      = DoubleToDateTime( std::vector<double>( n ), timeZone );
    Rcpp::NumericVector   time_processed = DoubleToDateTime( std::vector<double>( n ), timeZone );
    Rcpp::NumericVector   price_init    ( n );
    Rcpp::NumericVector   price_exec    ( n );
    Rcpp::IntegerVector   side           = IntToFactor( std::vector<int>( n ), OrderSideString );
    Rcpp::IntegerVector   type           = IntToFactor( std::vector<int>( n ), OrderTypeString );
    Rcpp::IntegerVector   state          = IntToFactor( std::vector<int>( n ), OrderStateString );
    Rcpp::CharacterVector comment       ( n );

    int i = 0;
    auto convertOrder = [&]( Order* order ) {

      id_trade      [i] = order->idTrade;
      id_sent       [i] = order->idSent + 1;
      id_processed  [i] = order->idProcessed + 1;
      time_sent     [i] = order->timeSent;
      time_processed[i] = order->timeProcessed;
      price_init    [i] = order->price;
      price_exec    [i] = order->priceExecuted;
      side          [i] = (int)order->side + 1;
      type          [i] = (int)order->type + 1;
      state         [i] = (int)order->state + 1;
      comment       [i] = order->comment;

      i++;

    };

    for( auto it = ordersProcessed.begin(); it != ordersProcessed.end(); it++ ) convertOrder( *it );
    for( auto it = orders         .begin(); it != orders         .end(); it++ ) convertOrder( *it );

    Rcpp::List orders = ListBuilder().AsDataTable()

      .Add( "id_trade"      , id_trade       )
      .Add( "id_sent"       , id_sent        )
      .Add( "id_processed"  , id_processed   )
      .Add( "time_sent"     , time_sent      )
      .Add( "time_processed", time_processed )
      .Add( "price_init"    , price_init     )
      .Add( "price_exec"    , price_exec     )
      .Add( "side"          , side           )
      .Add( "type"          , type           )
      .Add( "state"         , state          )
      .Add( "comment"       , comment        );

    return orders;

  }

  Rcpp::List GetTrades() {

    int n = trades.size() + tradesProcessed.size();

    Rcpp::IntegerVector id_trade   ( n );
    Rcpp::IntegerVector id_sent    ( n );
    Rcpp::IntegerVector id_enter   ( n );
    Rcpp::IntegerVector id_exit    ( n );
    Rcpp::IntegerVector side       = IntToFactor( std::vector<int>( n ), TradeSideString );
    Rcpp::NumericVector price_enter( n );
    Rcpp::NumericVector price_exit ( n );
    Rcpp::NumericVector time_sent  = DoubleToDateTime( std::vector<double>( n ), timeZone );
    Rcpp::NumericVector time_enter = DoubleToDateTime( std::vector<double>( n ), timeZone );
    Rcpp::NumericVector time_exit  = DoubleToDateTime( std::vector<double>( n ), timeZone );
    Rcpp::NumericVector pnl        ( n );
    Rcpp::NumericVector mtm_min    ( n );
    Rcpp::NumericVector mtm_max    ( n );
    Rcpp::NumericVector cost       ( n );
    Rcpp::NumericVector pnl_rel    ( n );
    Rcpp::NumericVector mtm_min_rel( n );
    Rcpp::NumericVector mtm_max_rel( n );
    Rcpp::NumericVector cost_rel   ( n );
    Rcpp::IntegerVector state      = IntToFactor( std::vector<int>( n ), TradeStateString );

    const int basisPoints = 10000;

    int i = 0;
    auto convertTrade = [&]( Trade* trade ) {

      id_trade   [i] = trade->idTrade;
      id_sent    [i] = trade->idSent  + 1;
      id_enter   [i] = trade->idEnter + 1;
      id_exit    [i] = trade->idExit  + 1;
      time_sent  [i] = trade->timeSent;
      time_enter [i] = trade->timeEnter;
      time_exit  [i] = trade->timeExit;
      side       [i] = (int)trade->side + 1;
      price_enter[i] = trade->priceEnter;
      price_exit [i] = trade->priceExit;
      pnl        [i] = trade->pnl;
      mtm_min    [i] = trade->mtmMin;
      mtm_max    [i] = trade->mtmMax;
      cost       [i] = trade->cost;
      pnl_rel    [i] = trade->pnlRel    * basisPoints;
      mtm_min_rel[i] = trade->mtmMinRel * basisPoints;
      mtm_max_rel[i] = trade->mtmMaxRel * basisPoints;
      cost_rel   [i] = trade->costRel   * basisPoints;
      state      [i] = (int)trade->state + 1;

      i++;

    };

    for( auto it = tradesProcessed.begin(); it != tradesProcessed.end(); it++ ) convertTrade( it->second );
    for( auto it = trades         .begin(); it != trades         .end(); it++ ) convertTrade( it->second );

    Rcpp::List trades = ListBuilder().AsDataTable()

      .Add( "id_trade"   , id_trade    )
      .Add( "id_sent"    , id_sent     )
      .Add( "id_enter"   , id_enter    )
      .Add( "id_exit"    , id_exit     )
      .Add( "time_sent"  , time_sent   )
      .Add( "time_enter" , time_enter  )
      .Add( "time_exit"  , time_exit   )
      .Add( "side"       , side        )
      .Add( "price_enter", price_enter )
      .Add( "price_exit" , price_exit  )
      .Add( "pnl"        , pnl         )
      .Add( "mtm_min"    , mtm_min     )
      .Add( "mtm_max"    , mtm_max     )
      .Add( "cost"       , cost        )
      .Add( "pnl_rel"    , pnl_rel     )
      .Add( "mtm_min_rel", mtm_min_rel )
      .Add( "mtm_max_rel", mtm_max_rel )
      .Add( "cost_rel"   , cost_rel    )
      .Add( "state"      , state       );

    return trades;

  }

  Rcpp::List GetSummary() { return statistics.GetSummary(); }

};

#endif //PROCESSOR_H
