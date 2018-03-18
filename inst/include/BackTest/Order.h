// Copyright (C) 2016-2018 Stanislav Kovalevsky
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

#ifndef ORDER_H
#define ORDER_H

#include <Rcpp.h>
#include "Tick.h"
#include <vector>

enum class ExecutionType: int { TRADE, BBO };

enum class OrderSide: int { BUY, SELL };

enum class OrderType: int { MARKET, LIMIT, STOP, TRAIL };

enum class OrderState: int {
  NEW,        // created
  REGISTERED, // placement confirmed
  EXECUTED,   // execution confirmed
  CANCELLING, // cancellation request sent
  CANCELLED,  // cancel comfirmed
};

enum class OrderStateExchange: int {
  WAIT,         // order is on the way to exchange
  REGISTERED,
  EXECUTED,
  CANCELLED,
  CANCEL_FAILED
};

class Order {

  friend class Processor;
  friend class Statistics;
  friend class Test;

  private:

    OrderState state;
    OrderStateExchange stateExchange;

    OrderSide side;
    OrderType type;
    double price;
    double trail;
    double priceExecuted;
    int idTrade;

    int idSent;       // tick id when sent
    int idRegistered; // tick id when placement confirmed
    int idCancel;     // tick id when cancellation sent
    int idProcessed;  // tick id when done

    int idExchangeRegistered;
    int idExchangeExecuted;

    double timeSent;
    double timeExchangeRegistered;
    double timeRegistered;
    double timeExchangeExecuted;
    double timeExecuted;
    double timeCancel;
    double timeExchangeCancel;
    double timeCancelled;
    double timeProcessed;

    bool allowLimitToHitMarket;
    bool allowExactStop;
    bool isStopActivated;

    double priceExchangeExecuted;

    ExecutionType executionType = ExecutionType::TRADE;
    double bid;
    double ask;

    void Update( Tick tick, double latencySend, double latencyReceive ) {

      if( state == OrderState::CANCELLED or state == OrderState::EXECUTED ) {
        // done
        return;

      }
      /*
       * Order State Cycle:
       * Market Order
       * Standard   : Exchange:       ┌─REGISTERED === EXECUTED───┐
       *              System  : NEW─s─┘                           └─r─EXECUTED
       * Limit Order:
       * Standard   : Exchange:       ┌─REGISTERED─┬───EXECUTED───┐
       *              System  : NEW─s─┘            └─r─REGISTERED └─r─EXECUTED
       * Cancel     : Exchange:       ┌─REGISTERED─┬───────────────────────┬─────CANCELLED─┐
       *              System  : NEW─s─┘            └─r─REGISTERED─CANCEL─s─┘               └─r─CANCELLED
       * Cancel Fail: Exchange:       ┌─REGISTERED─┬──────────────────EXECUTED─┬─CANCEL_FAILED
       *              System  : NEW─s─┘            └─r─REGISTERED─CANCEL─s─┘   └─r─EXECUTED
       *                        ────────────────────────────────────────────────────────────────────────>t
       * s = latency send
       * r = latency receive
       */

      if( state == OrderState::NEW ) {

        if( std::isnan( timeSent ) ) {
          // order sent
          timeSent = tick.time;
          idSent = tick.id;
          timeExchangeRegistered = tick.time + latencySend;
          timeRegistered = timeExchangeRegistered + latencyReceive;
        }
        if( tick.time > timeExchangeRegistered ) {

          // registered on exchange
          if( stateExchange == OrderStateExchange::WAIT ) {

            stateExchange = OrderStateExchange::REGISTERED;
            idExchangeRegistered = tick.id;

          }

        }
        if( tick.time > timeRegistered ) {
          // placement confirmation received
          if( stateExchange == OrderStateExchange::REGISTERED ) { state = OrderState::REGISTERED; }
          idRegistered = tick.id;
          if( onRegistered != nullptr ) onRegistered();
        }

      }
      if( stateExchange == OrderStateExchange::REGISTERED ) {
        // market order executed on same tick as registerred
        if( type == OrderType::MARKET or isStopActivated ) {

          if( executionType == ExecutionType::TRADE and not tick.system ) {

            stateExchange = OrderStateExchange::EXECUTED;
            priceExchangeExecuted = tick.price;

          }
          if( executionType == ExecutionType::BBO ) {

            stateExchange = OrderStateExchange::EXECUTED;
            priceExchangeExecuted = side == OrderSide::BUY ? ask : bid;

          }

        }
        // stop order
        if( type == OrderType::STOP or type == OrderType::TRAIL ) {

          if( type == OrderType::TRAIL ) {

            if( side == OrderSide::BUY  ) price = std::min( price, tick.price * ( 1. + trail ) );
            if( side == OrderSide::SELL ) price = std::max( price, tick.price * ( 1. - trail ) );

          }

          // isStopActivated checked first and if true next tick order is executed as market order
          if( executionType == ExecutionType::TRADE and not tick.system ) {
            isStopActivated = ( side == OrderSide::BUY and tick.price > price ) or ( side == OrderSide::SELL and tick.price < price );
          }
          if( executionType == ExecutionType::BBO ) {
            isStopActivated = ( side == OrderSide::BUY and ask >= price ) or ( side == OrderSide::SELL and bid <= price );
          }

        }
        // limit order
        if( type == OrderType::LIMIT ) {

          if( executionType == ExecutionType::TRADE and not tick.system ) {
            if( ( side == OrderSide::BUY and tick.price < price ) or ( side == OrderSide::SELL and tick.price > price ) ) {
              // when price below long or above short order is executed
              stateExchange = OrderStateExchange::EXECUTED;
              priceExchangeExecuted = price;

            }
          }
          if( executionType == ExecutionType::BBO ) {
            if( ( side == OrderSide::BUY and ask <= price ) or ( side == OrderSide::SELL and bid >= price ) ) {
              // when ask below long or bid above short order is executed
              stateExchange = OrderStateExchange::EXECUTED;
              priceExchangeExecuted = price;

            }
          }

        }
        if( stateExchange == OrderStateExchange::EXECUTED ) {

          timeExchangeExecuted = tick.time;
          timeExecuted = timeExchangeExecuted + latencyReceive;

          idExchangeExecuted = tick.id;
          if( allowLimitToHitMarket and type == OrderType::LIMIT and idExchangeExecuted == idExchangeRegistered ) {

            if( executionType == ExecutionType::TRADE and not tick.system ) {
              priceExchangeExecuted = tick.price;
            }
            if( executionType == ExecutionType::BBO ) {
              priceExchangeExecuted = side == OrderSide::BUY ? ask : bid;
            }

          }
          if( allowExactStop and ( type == OrderType::STOP or type == OrderType::TRAIL ) ) {

            priceExchangeExecuted = price;

          }

        }

      }
      if( stateExchange == OrderStateExchange::EXECUTED ) {

        if( tick.time > timeExecuted ) {
          // execution confirmation received
          idProcessed   = tick.id;
          timeProcessed = timeExecuted;
          priceExecuted = priceExchangeExecuted;
          if( state == OrderState::CANCELLING ) {
            // order was about to cancel
            stateExchange = OrderStateExchange::CANCEL_FAILED;
            state = OrderState::EXECUTED;
            if( onCancelFailed != nullptr ) onCancelFailed();
          }
          state = OrderState::EXECUTED;
          if( onExecuted != nullptr ) onExecuted();

        }

      }
      if( state == OrderState::CANCELLING ) {

        if( std::isnan( timeCancel ) ) {
          // cancel sent
          idCancel           = tick.id;
          timeCancel         = tick.time;
          timeExchangeCancel = timeCancel + latencySend;
          timeCancelled      = timeExchangeCancel + latencyReceive;
        }
        if( tick.time > timeExchangeCancel ) {
          // cancel request received by exchange
          stateExchange = OrderStateExchange::CANCELLED;
        }
        if( tick.time > timeCancelled ) {
          // cancel confirmation received
          state = OrderState::CANCELLED;
          idProcessed = tick.id;
          timeProcessed = timeCancelled;
          if( onCancelled != nullptr ) onCancelled();
        }

      }
      if( executionType == ExecutionType::BBO and not tick.system ) {

        bid = tick.bid;
        ask = tick.ask;

      }

    };

  public:

    std::string comment;
    std::function< void() > onExecuted;
    std::function< void() > onCancelled;
    std::function< void() > onRegistered;
    std::function< void() > onCancelFailed;

    Order( Order& order ) {

      Order( order.side, order.type, order.price, order.comment, order.idTrade, order.trail );
      onExecuted     = order.onExecuted    ;
      onCancelled    = order.onCancelled   ;
      onRegistered   = order.onRegistered  ;
      onCancelFailed = order.onCancelFailed;

    }

    Order( OrderSide side, OrderType type, double price, std::string comment, int idTrade = NA_INTEGER, double trail = 0 ):

      side   ( side    ),
      type   ( type    ),
      price  ( price   ),
      trail  ( trail   ),
      idTrade( idTrade ),
      comment( comment )

    {

      priceExecuted = NA_REAL;
      idProcessed   = NA_INTEGER - 1;
      idSent        = NA_INTEGER - 1;
      idCancel      = NA_INTEGER - 1;

      timeSent               = NAN;
      timeExchangeRegistered = NAN;
      timeRegistered         = NAN;
      timeExchangeExecuted   = NAN;
      timeExecuted           = NAN;
      timeCancel             = NAN;
      timeExchangeCancel     = NAN;
      timeCancelled          = NAN;
      timeProcessed          = NAN;
      state                  = OrderState::NEW;
      stateExchange          = OrderStateExchange::WAIT;

      isStopActivated        = false;

    };

    void Cancel() {

      if( type != OrderType::MARKET and state == OrderState::REGISTERED ) {
        state = OrderState::CANCELLING;
      }

    };

    bool IsExecuted() { return state == OrderState::EXECUTED; }
    bool IsCancelled() { return state == OrderState::CANCELLED; }
    bool IsCancelling() { return state == OrderState::CANCELLING; }
    bool IsRegistered() { return state == OrderState::REGISTERED; }
    bool IsNew() { return state == OrderState::NEW; }
    bool IsBuy() { return side == OrderSide::BUY; }
    bool IsSell() { return side == OrderSide::SELL; }
    bool IsLimit() { return type == OrderType::LIMIT; }
    bool IsMarket() { return type == OrderType::MARKET; }
    double GetExecutionPrice() { return priceExecuted; }
    double GetExecutionTime() { return timeExecuted; }
    double GetProcessedTime() { return timeProcessed; }
    OrderState GetState() { return state; }
    int GetTradeId() { return idTrade; }


};

#endif //ORDER_H
