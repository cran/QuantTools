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
#include "../setDT.h"
#include "../ListBuilder.h"
#include <map>
#include <cmath>
#include <Rcpp.h>

class Processor {

  friend class Test;

private:

  std::vector< std::string > OrderSideString  = { "buy", "sell" };
  std::vector< std::string > TradeSideString  = { "long", "short" };
  std::vector< std::string > OrderTypeString  = { "market", "limit" };
  std::vector< std::string > OrderStateString = { "new", "registered", "executed", "cancelling", "cancelled" };
  std::vector< std::string > TradeStateString  = { "new", "opened", "closed" };

  std::vector<Order*> orders;
  std::vector<Order*> ordersProcessed;

  std::map< int, Trade*> trades;

  std::vector<Candle> candles;
  int    position;
  double positionValue;
  int    positionPlanned;
  Tick   tick;
  double latencySend;
  double latencyReceive;
  int    timeFrame;
  Candle candle;

  Cost   cost;

  int    nDaysTested;
  double timeFirstTick;
  double timeLastTick;
  double drawdownMax;
  double drawdownMaxStart;
  double drawdownMaxEnd;
  double drawdown;
  double drawdownStart;
  double drawdownEnd;
  double pnl;
  double marketValue;
  double marketValueMax;
  bool   isDrawdownMax;

  void FormCandle( Tick tick ) {

    bool startOver = candle.time != floor( tick.time / timeFrame ) * timeFrame + timeFrame;

    if( startOver and candle.time != 0 ) {

      if( onCandle != nullptr ) onCandle( candle );
      candles.push_back( candle );

    }

    candle.Add( tick );

  };

  int NNights( double time1, double time2 ) {

    const int nSecondsInDay = 60 * 60 * 24;
    return std::abs( std::trunc( time1 / nSecondsInDay ) - std::trunc( time2 / nSecondsInDay ) );

  }

public:

  std::function< void( Tick   ) > onTick;
  std::function< void( Candle ) > onCandle;

  Processor( int timeFrame, double latencySend = 0.001, double latencyReceive = 0.001 ) :
    latencySend   ( latencySend    ),
    latencyReceive( latencyReceive ),
    timeFrame     ( timeFrame      ),
    candle        ( timeFrame      )

  {

    cost              = {};
    position          = 0;
    positionValue     = 0;
    positionPlanned   = 0;
    nDaysTested       = 0;

    nDaysTested       = 0;
    timeFirstTick     = NAN;
    timeLastTick      = NAN;
    drawdownMax       = 0;
    drawdownMaxStart  = NAN;
    drawdownMaxEnd    = NAN;
    drawdown          = 0;
    drawdownStart     = NAN;
    drawdownEnd       = NAN;
    pnl               = 0;
    marketValue       = 1;
    marketValueMax    = 1;
    isDrawdownMax     = false;
    tick = {};

  };

  ~Processor() {

    for( auto order: orders ) delete order;
    orders.clear();

    for( auto order: ordersProcessed ) delete order;
    ordersProcessed.clear();

    for( auto r: trades ) delete r.second;
    trades.clear();

  }

  void SetCost( Cost cost ) { this->cost = cost; }

  void Feed( const Tick& tick ) {

    if( tick.time < this->tick.time ) { throw std::invalid_argument( "ticks must be time ordered tick.id = " + std::to_string( tick.id + 1 ) ); }

    FormCandle( tick );

    if( onTick != nullptr ) onTick( tick );

    int nNights = NNights( this->tick.time, tick.time );

    if( nDaysTested == 0 ) { nDaysTested = 1; }
    if( nNights > 0      ) { nDaysTested++;   }
    if( std::isnan( timeFirstTick ) ) { timeFirstTick = tick.time; }
    timeLastTick = tick.time;

    for( auto order: orders ) {

      order->Update( tick, latencySend, latencyReceive );

      if( order->IsExecuted() ) {

        if( order->side == OrderSide::BUY ) {

          if( position == -1 ) positionValue = order->priceExecuted;
          if( position >=  0 ) positionValue = ( positionValue * position + order->priceExecuted ) / ( position + 1 );
          position++;
          positionPlanned--;

        } else {

          if( position ==  1 ) positionValue = order->priceExecuted;
          if( position <=  0 ) positionValue = ( positionValue * position - order->priceExecuted ) / ( position - 1 );
          position--;
          positionPlanned++;

        }

      }
      if( order->IsCancelled() ) { order->side == OrderSide::BUY ? positionPlanned-- : positionPlanned++; }

      if( trades.count( order->idTrade ) == 0 ) {

        Trade* trade = new Trade;
        trade->idTrade = order->idTrade;
        trade->state = TradeState::NEW;
        trade->idSent = order->idSent;
        trade->timeSent = order->timeSent;
        trade->side = order->IsBuy() ? TradeSide::LONG : TradeSide::SHORT;
        trade->cost = cost.order;
        trades[ order->idTrade ] = trade;

      } else {

        Trade* trade = trades[ order->idTrade ];
        if( order->IsExecuted() ) {

          if( trade->state == TradeState::OPENED ) {

            trade->idExit = order->idProcessed;
            trade->timeExit = order->timeProcessed;
            trade->priceExit = order->priceExecuted;
            trade->pnl    = ( trade->side == TradeSide::LONG ? +1. : -1. ) * ( trade->priceExit - trade->priceEnter ) * cost.pointValue + trade->cost;
            trade->pnlRel = trade->pnl / ( trade->priceEnter * cost.pointValue );

            pnl += trade->pnlRel;

            trade->state = TradeState::CLOSED;

          }

          if( trade->state == TradeState::NEW ) {

            trade->idEnter = order->idProcessed;
            trade->timeEnter = order->timeProcessed;
            trade->priceEnter = order->priceExecuted;

            trade->state = TradeState::OPENED;

          }

          trade->cost += cost.stockAbs + cost.tradeAbs + cost.tradeRel * order->priceExecuted * cost.pointValue;

        }

        if( nNights > 0 ) {

          trade->cost += nNights * ( trade->side == TradeSide::LONG ? cost.longAbs : cost.shortAbs );
          trade->cost += nNights * ( trade->side == TradeSide::LONG ? cost.longRel : cost.shortRel ) * this->tick.price * cost.pointValue;

        }

        if( order->IsNew()       ) { trade->cost += cost.order;  }
        if( order->IsCancelled() ) { trade->cost += cost.cancel; }

        if( trade->state == TradeState::OPENED ) {

          double mtm    = ( trade->side == TradeSide::LONG ? +1. : -1. ) * ( tick.price - trade->priceEnter );
          double mtmRel = ( trade->side == TradeSide::LONG ? +1. : -1. ) * ( tick.price / trade->priceEnter - 1 );
          if( trade->mtmMax < mtm ) trade->mtmMax = mtm;
          if( trade->mtmMin > mtm ) trade->mtmMin = mtm;
          if( trade->mtmMaxRel < mtmRel ) trade->mtmMaxRel = mtmRel;
          if( trade->mtmMinRel > mtmRel ) trade->mtmMinRel = mtmRel;

        }
        trade->costRel = trade->cost / ( trade->priceEnter * cost.pointValue );

      }

    }

    for( auto it = orders.begin(); it != orders.end();  ) {

      if( ( *it )->state == OrderState::EXECUTED or ( *it )->state == OrderState::CANCELLED ) {

        ordersProcessed.push_back( *it );
        it = orders.erase( it );

      } else ++it;

    }

    marketValue = 1 + pnl + position * ( tick.price / positionValue - 1 );

    if( marketValueMax < marketValue ) marketValueMax = marketValue;

    double prevDrowdown = drawdown;
    drawdown = ( 1 - marketValue / marketValueMax );

    // drawdown started
    if( prevDrowdown == 0 and drawdown > 0 ) {

      drawdownStart = tick.time;
      drawdownEnd   = NAN;

    }
    // drawdown ended
    if( prevDrowdown > 0 and drawdown == 0 ) {

      drawdownEnd = tick.time;

      // max drawdown recovered
      if( isDrawdownMax ) {

        drawdownMaxEnd = drawdownEnd;
        isDrawdownMax = false;

      }

    }
    // drawdown is highest ever
    if( drawdownMax < drawdown ) {

      drawdownMax = drawdown;
      drawdownMaxStart = drawdownStart;
      drawdownMaxEnd = NAN;
      isDrawdownMax = true;

    }

    this->tick = tick;
    /*
    Rcpp::Rcout << "position: " << position << " value: " << positionValue << " planned: " << positionPlanned <<

      " pnl: " << pnl << " mtm: " << pnlMtm << " fixed: " << pnlFixed << " dd: " << drawdown << std::endl;
    */
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

    size_t n = times.size();

    Tick tick;

    for( size_t id = 0; id < n; id++ ) {

      tick.id = id;
      tick.time = times[id];
      tick.price = prices[id];
      tick.volume = volumes[id];
      Feed( tick );

    }

  }

  void SendOrder( Order* order ) {

    orders.push_back( order );
    positionPlanned += order->side == OrderSide::BUY ? +1 : -1;

  }

  void CancelOrders() { for( auto order: orders ) order->Cancel( ); }

  int GetPosition() { return position; }

  int GetPositionPlanned() { return positionPlanned; }

  double GetMarketValue() { return marketValue * 100; }

  void Reset() {

    for( auto order: orders ) delete order;
    orders.clear();

    for( auto order: ordersProcessed ) delete order;
    ordersProcessed.clear();

    for( auto r: trades ) delete r.second;
    trades.clear();

    cost              = {};
    position          = 0;
    positionValue     = 0;
    positionPlanned   = 0;
    nDaysTested       = 0;

    nDaysTested       = 0;
    timeFirstTick     = NAN;
    timeLastTick      = NAN;
    drawdownMax       = 0;
    drawdownMaxStart  = NAN;
    drawdownMaxEnd    = NAN;
    drawdown          = 0;
    drawdownStart     = NAN;
    drawdownEnd       = NAN;
    pnl               = 0;
    marketValue       = 1;
    marketValueMax    = 1;
    isDrawdownMax     = false;
    tick = {};

  }

  Rcpp::List GetCandles() {

    int n = candles.size();

    Rcpp::IntegerVector  id    ( n );
    Rcpp::NumericVector  open  ( n );
    Rcpp::NumericVector  high  ( n );
    Rcpp::NumericVector  low   ( n );
    Rcpp::NumericVector  close ( n );
    Rcpp::DatetimeVector time  ( n );
    Rcpp::IntegerVector  volume( n );

    for( int i = 0; i < n; i++ ){

      id    [i] = candles[i].id;
      open  [i] = candles[i].open;
      high  [i] = candles[i].high;
      low   [i] = candles[i].low;
      close [i] = candles[i].close;
      time  [i] = candles[i].time;
      volume[i] = candles[i].volume;

    }

    Rcpp::List candles = Rcpp::List::create(

      Rcpp::Named( "time"   ) = time,
      Rcpp::Named( "open"   ) = open,
      Rcpp::Named( "high"   ) = high,
      Rcpp::Named( "low"    ) = low,
      Rcpp::Named( "close"  ) = close,
      Rcpp::Named( "volume" ) = volume,
      Rcpp::Named( "id"     ) = id + 1

    );

    setDT( candles );

    return candles;

  }

  Rcpp::List GetOrders() {

    std::vector< Order* > all_orders;
    for( auto order: ordersProcessed ) all_orders.push_back( order );
    for( auto order: orders ) all_orders.push_back( order );

    int n = all_orders.size();

    Rcpp::IntegerVector   id_trade      ( n );
    Rcpp::IntegerVector   id_sent       ( n );
    Rcpp::IntegerVector   id_processed  ( n );
    Rcpp::DatetimeVector  time_sent     ( n );
    Rcpp::DatetimeVector  time_processed( n );
    Rcpp::NumericVector   price_init    ( n );
    Rcpp::NumericVector   price_exec    ( n );
    Rcpp::IntegerVector   side          ( n );
    Rcpp::IntegerVector   type          ( n );
    Rcpp::IntegerVector   state         ( n );
    Rcpp::CharacterVector comment       ( n );

    for( int i = 0; i < n; i++ ) {

      id_trade      [i] = all_orders[i]->idTrade;
      id_sent       [i] = all_orders[i]->idSent + 1;
      id_processed  [i] = all_orders[i]->idProcessed + 1;
      time_sent     [i] = all_orders[i]->timeSent;
      time_processed[i] = all_orders[i]->timeProcessed;
      price_init    [i] = all_orders[i]->price;
      price_exec    [i] = all_orders[i]->priceExecuted;
      side          [i] = (int)all_orders[i]->side + 1;
      type          [i] = (int)all_orders[i]->type + 1;
      state         [i] = (int)all_orders[i]->state + 1;
      comment       [i] = all_orders[i]->comment;

    }
    side.attr( "levels" ) = Rcpp::wrap( OrderSideString );
    side.attr( "class" ) = "factor";
    type.attr( "levels" ) = Rcpp::wrap( OrderTypeString );
    type.attr( "class" ) = "factor";
    state.attr( "levels" ) = Rcpp::wrap( OrderStateString );
    state.attr( "class" ) = "factor";

    Rcpp::List orders = Rcpp::List::create(

      Rcpp::Named( "id_trade"       ) = id_trade,
      Rcpp::Named( "id_sent"        ) = id_sent,
      Rcpp::Named( "id_processed"   ) = id_processed,
      Rcpp::Named( "time_sent"      ) = time_sent,
      Rcpp::Named( "time_processed" ) = time_processed,
      Rcpp::Named( "price_init"     ) = price_init,
      Rcpp::Named( "price_exec"     ) = price_exec,
      Rcpp::Named( "side"           ) = side,
      Rcpp::Named( "type"           ) = type,
      Rcpp::Named( "state"          ) = state,
      Rcpp::Named( "comment"        ) = comment

    );

    setDT( orders );

    return orders;

  }

  Rcpp::List GetTrades() {

    int n = trades.size();

    Rcpp::IntegerVector  id_trade   ( n );
    Rcpp::IntegerVector  id_sent    ( n );
    Rcpp::IntegerVector  id_enter   ( n );
    Rcpp::IntegerVector  id_exit    ( n );
    Rcpp::IntegerVector  side       ( n );
    Rcpp::NumericVector  price_enter( n );
    Rcpp::NumericVector  price_exit ( n );
    Rcpp::DatetimeVector time_sent  ( n );
    Rcpp::DatetimeVector time_enter ( n );
    Rcpp::DatetimeVector time_exit  ( n );
    Rcpp::NumericVector  pnl        ( n );
    Rcpp::NumericVector  mtm_min    ( n );
    Rcpp::NumericVector  mtm_max    ( n );
    Rcpp::NumericVector  cost       ( n );
    Rcpp::NumericVector  pnl_rel    ( n );
    Rcpp::NumericVector  mtm_min_rel( n );
    Rcpp::NumericVector  mtm_max_rel( n );
    Rcpp::NumericVector  cost_rel   ( n );
    Rcpp::IntegerVector  state      ( n );

    const int basisPoints = 10000;
    const double moneyPrecision = 0.0001;

    int i = 0;
    for( const auto &r : trades ) {

      id_trade   [i] = r.first;
      id_sent    [i] = r.second->idSent;
      id_enter   [i] = r.second->idEnter;
      id_exit    [i] = r.second->idExit;
      time_sent  [i] = r.second->timeSent;
      time_enter [i] = r.second->timeEnter;
      time_exit  [i] = r.second->timeExit;
      side       [i] = (int)r.second->side + 1;
      price_enter[i] = r.second->priceEnter;
      price_exit [i] = r.second->priceExit;
      pnl        [i] = std::round( r.second->pnl / moneyPrecision ) * moneyPrecision;
      mtm_min    [i] = r.second->mtmMin;
      mtm_max    [i] = r.second->mtmMax;
      cost       [i] = std::round( r.second->cost / moneyPrecision ) * moneyPrecision;
      pnl_rel    [i] = std::rint( r.second->pnlRel * basisPoints );
      mtm_min_rel[i] = std::rint( r.second->mtmMinRel * basisPoints );
      mtm_max_rel[i] = std::rint( r.second->mtmMaxRel * basisPoints );
      cost_rel   [i] = std::rint( r.second->costRel * basisPoints );
      state      [i] = (int)r.second->state + 1;

      i++;

    }
    side.attr( "levels" ) = Rcpp::wrap( TradeSideString );
    side.attr( "class" ) = "factor";

    state.attr( "levels" ) = Rcpp::wrap( TradeStateString );
    state.attr( "class" ) = "factor";

    Rcpp::List output = Rcpp::List::create(

      Rcpp::Named( "id_trade"    ) = id_trade,
      Rcpp::Named( "id_sent"     ) = id_sent + 1,
      Rcpp::Named( "id_enter"    ) = id_enter + 1,
      Rcpp::Named( "id_exit"     ) = id_exit + 1,
      Rcpp::Named( "time_sent"   ) = time_sent,
      Rcpp::Named( "time_enter"  ) = time_enter,
      Rcpp::Named( "time_exit"   ) = time_exit,
      Rcpp::Named( "side"        ) = side,
      Rcpp::Named( "price_enter" ) = price_enter,
      Rcpp::Named( "price_exit"  ) = price_exit,
      Rcpp::Named( "pnl"         ) = pnl,
      Rcpp::Named( "mtm_min"     ) = mtm_min,
      Rcpp::Named( "mtm_max"     ) = mtm_max,
      Rcpp::Named( "cost"        ) = cost,
      Rcpp::Named( "pnl_rel"     ) = pnl_rel,
      Rcpp::Named( "mtm_min_rel" ) = mtm_min_rel,
      Rcpp::Named( "mtm_max_rel" ) = mtm_max_rel,
      Rcpp::Named( "cost_rel"    ) = cost_rel,
      Rcpp::Named( "state"       ) = state

    );

    setDT( output );

    return output;

  }

  Rcpp::List GetSummary() {

    int    nTrades      = 0;
    int    nTradesWin   = 0;
    int    nTradesLoss  = 0;
    int    nTradesLong  = 0;
    int    nTradesShort = 0;
    double totalWin     = 0;
    double totalLoss    = 0;
    double totalPnl     = 0;

    std::map< int, int > uniqueDates;
    const int nSecondsInDay = 60 * 60 * 24;
    const int basisPoints = 10000;
    const int percent = 100;
    const double roundPrecision = 0.01;

    for( auto&& r : trades ) {

      if( r.second->state != TradeState::CLOSED ) continue;
      nTrades++;
      if( r.second->pnlRel > 0 ) {

        nTradesWin++;
        totalWin += r.second->pnlRel;

      } else {

        nTradesLoss++;
        totalLoss += r.second->pnlRel;

      }

      r.second->side == TradeSide::LONG ? nTradesLong++ : nTradesShort++;

      totalPnl += r.second->pnlRel;
      uniqueDates[ std::trunc( r.second->timeEnter / nSecondsInDay ) ] = 0;
      uniqueDates[ std::trunc( r.second->timeExit  / nSecondsInDay ) ] = 0;

    }
    int nDaysTraded = uniqueDates.size();
    double nTradesPerDay = nDaysTested == 0 ? 0 : std::round( nTrades * 1. / nDaysTested / roundPrecision ) * roundPrecision;

    double pctTradesWin  = nTrades == 0 ? NA_REAL : std::round( nTradesWin  * 1. / nTrades * percent / roundPrecision ) * roundPrecision;
    double pctTradesLoss = nTrades == 0 ? NA_REAL : std::round( nTradesLoss * 1. / nTrades * percent / roundPrecision ) * roundPrecision;

    double avgWin  = nTradesWin  == 0 ? NA_REAL : std::round( totalWin  / nTradesWin  * basisPoints / roundPrecision ) * roundPrecision;
    double avgLoss = nTradesLoss == 0 ? NA_REAL : std::round( totalLoss / nTradesLoss * basisPoints / roundPrecision ) * roundPrecision;
    double avgPnl  = nTrades     == 0 ? NA_REAL : std::round( totalPnl  / nTrades     * basisPoints / roundPrecision ) * roundPrecision;

    totalWin  = std::round( totalWin  * percent / roundPrecision ) * roundPrecision;
    totalLoss = std::round( totalLoss * percent / roundPrecision ) * roundPrecision;
    totalPnl  = std::round( totalPnl  * percent / roundPrecision ) * roundPrecision;

    int nDaysDrawdownMax = std::isnan( drawdownMaxEnd ) ? NA_INTEGER : NNights( drawdownMaxStart, drawdownMaxEnd );

    Rcpp::DataFrame summary = ListBuilder()

      .Add( "from"          , Rcpp::Datetime( std::isnan( timeFirstTick ) ? NA_REAL : timeFirstTick ) )
      .Add( "to"            , Rcpp::Datetime( std::isnan( timeLastTick  ) ? NA_REAL : timeLastTick ) )
      .Add( "days_tested"   , nDaysTested )
      .Add( "days_traded"   , nDaysTraded )
      .Add( "n_per_day"     , nTradesPerDay )
      .Add( "n"             , nTrades )
      .Add( "n_long"        , nTradesLong )
      .Add( "n_short"       , nTradesShort )
      .Add( "n_win"         , nTradesWin )
      .Add( "n_loss"        , nTradesLoss )
      .Add( "pct_win"       , pctTradesWin )
      .Add( "pct_loss"      , pctTradesLoss )
      .Add( "avg_win"       , avgWin )
      .Add( "avg_loss"      , avgLoss )
      .Add( "avg_pnl"       , avgPnl )
      .Add( "win"           , totalWin )
      .Add( "loss"          , totalLoss )
      .Add( "pnl"           , totalPnl )
      .Add( "max_dd"        , -std::round( drawdownMax  * percent / roundPrecision ) * roundPrecision )
      .Add( "max_dd_start"  , Rcpp::Datetime( std::isnan( drawdownMaxStart ) ? NA_REAL: drawdownMaxStart ) )
      .Add( "max_dd_end"    , Rcpp::Datetime( std::isnan( drawdownMaxEnd   ) ? NA_REAL: drawdownMaxEnd   ) )
      .Add( "max_dd_length" , nDaysDrawdownMax );

    return summary;

  }

};

#endif //PROCESSOR_H
