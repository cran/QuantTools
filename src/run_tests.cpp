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

#include <Rcpp.h>
#include <vector>
#include "../inst/include/BackTest.h"
#include "../inst/include/setDT.h"
using namespace Rcpp;

class Test {
private:
  int test_01() {
    Rcout << "Test 01 - Limit Order - Execute" << std::endl;


    int errors = 0;

    double latencySend = 0.2;
    double latencyReceive = 0.1;
    Processor processor( 10, latencySend, latencyReceive );

    Order* order = new Order( OrderSide::BUY, OrderType::LIMIT, 10, "long" );
    bool onExecuted = false;
    order->onExecuted = [&] { onExecuted = true; };

    processor.SendOrder( order );

    Tick tick;
    tick.id = 1;
    tick.time = 0;
    tick.price = 9;
    tick.volume = 100;

    processor.Feed( tick );
    if( !order->IsNew() )
      Rcout << "1.  status not NEW - " << ++errors << std::endl;

    tick.id++;
    tick.time += latencySend;
    tick.price = 11;
    processor.Feed( tick );
    // not received on exchange
    if( !order->IsNew() )
      Rcout << "2.  status not NEW - " << ++errors << std::endl;

    tick.id++;
    tick.time += 100;
    tick.price = 12;
    processor.Feed( tick );
    // registered on exchange
    if( !order->IsRegistered() )
      Rcout << "3.1 status not REGISTERED - " << ++errors << std::endl;
    if( !std::isnan( order->priceExecuted ) )
      Rcout << "3.2 price executed not NAN - " << ++errors << std::endl;

    tick.id++;
    tick.time += 10;
    tick.price = 9;
    processor.Feed( tick );
    // executed on exchange
    if( !order->IsRegistered() )
      Rcout << "4.1 status not REGISTERED - " << ++errors << std::endl;
    if( !std::isnan( order->priceExecuted ) )
      Rcout << "4.2 price executed not NAN - " << ++errors << std::endl;

    tick.id++;
    tick.time += latencyReceive;
    tick.price = 15;
    processor.Feed( tick );
    // confirmation not received
    if( !order->IsRegistered() )
      Rcout << "5.1 status not REGISTERED - " << ++errors << std::endl;
    if( !std::isnan( order->priceExecuted ) )
      Rcout << "5.2 price executed not NAN - " << ++errors << std::endl;
    if( onExecuted )
      Rcout << "5.3 onExecuted called - " << ++errors << std::endl;

    tick.id++;
    tick.time += 0.00001;
    tick.price = 16;
    processor.Feed( tick );
    // confirmation received
    if( !order->IsExecuted() )
      Rcout << "6.1 status not EXECUTED - " << ++errors << std::endl;
    if( order->priceExecuted != 10 )
      Rcout << "6.2 price executed not equals price - " << ++errors << std::endl;
    if( !onExecuted )
      Rcout << "6.3 onExecuted not called - " << ++errors << std::endl;

    if( errors == 0 ) {
      Rcout << "Test 01 - PASSED!" << std::endl;
    } else {
      Rcout << "Test 01 - FAILED! Errors: " << errors << std::endl;
    }
    return( errors );

  }
  int test_02() {
    Rcout << "Test 02 - Limit Order - Cancel" << std::endl;

    int errors = 0;

    double latencySend = 0.2;
    double latencyReceive = 0.1;
    Processor processor( 10, latencySend, latencyReceive );

    Order* order = new Order( OrderSide::BUY, OrderType::LIMIT, 10, "long" );
    bool onExecuted = false;
    order->onExecuted = [&] { onExecuted = true; };
    bool onCancelled = false;
    order->onCancelled = [&] { onCancelled = true; };

    processor.SendOrder( order );

    Tick tick;
    tick.id = 1;
    tick.time = 0;
    tick.price = 9;
    tick.volume = 100;
    processor.Feed( tick );
    if( !order->IsNew() )
      Rcout << "1.  status not NEW - " << ++errors << std::endl;

    tick.id++;
    tick.time += latencySend;
    tick.price = 11;
    processor.Feed( tick );
    // not received on exchange
    if( !order->IsNew() )
      Rcout << "2.  status not NEW - " << ++errors << std::endl;

    tick.id++;
    tick.time += 100;
    tick.price = 12;
    processor.Feed( tick );
    // registered on exchange
    if( !order->IsRegistered() )
      Rcout << "3.1 status not REGISTERED - " << ++errors << std::endl;
    if( !std::isnan( order->priceExecuted ) )
      Rcout << "3.2 price executed not NAN - " << ++errors << std::endl;

    tick.id++;
    tick.time += 10;
    tick.price = 10;
    processor.Feed( tick );
    // not executed yet
    if( order->state != OrderState::REGISTERED )
      Rcout << "4.1 status not REGISTERED - " << ++errors << std::endl;
    if( !std::isnan( order->priceExecuted ) )
      Rcout << "4.2 price executed not NAN - " << ++errors << std::endl;
    order->Cancel();

    tick.id++;
    tick.time += 10;
    tick.price = 15;
    processor.Feed( tick );
    // cancel sent
    if( order->state != OrderState::CANCELLING )
      Rcout << "5.1 status not CANCEL - " << ++errors << std::endl;
    if( !std::isnan( order->priceExecuted ) )
      Rcout << "5.2 price executed not NAN - " << ++errors << std::endl;
    if( onExecuted )
      Rcout << "5.3 onExecuted called - " << ++errors << std::endl;
    if( onCancelled )
      Rcout << "5.4 onCancelled called - " << ++errors << std::endl;

    tick.id++;
    tick.time += latencySend + latencyReceive + 0.00001;
    tick.price = 15;
    processor.Feed( tick );
    // confirmation received
    if( order->state != OrderState::CANCELLED )
      Rcout << "6.1 status not CANCELED - " << ++errors << std::endl;
    if( !std::isnan( order->priceExecuted ) )
      Rcout << "6.2 price executed not NAN - " << ++errors << std::endl;
    if( onExecuted )
      Rcout << "6.3 onExecuted called - " << ++errors << std::endl;
    if( !onCancelled )
      Rcout << "6.4 onCancelled not called - " << ++errors << std::endl;

    tick.id++;
    tick.time += 100;
    tick.price = 16;
    processor.Feed( tick );
    // confirmation received
    if( order->state != OrderState::CANCELLED )
      Rcout << "7.1 status not CANCELED - " << ++errors << std::endl;
    if( !std::isnan( order->priceExecuted ) )
      Rcout << "7.2 price executed not NAN - " << ++errors << std::endl;

    if( errors == 0 ) {
      Rcout << "Test 02 - PASSED!" << std::endl;
    } else {
      Rcout << "Test 02 - FAILED! Errors: " << errors << std::endl;
    }
    return( errors );

  };
  int test_03() {
    Rcout << "Test 03 - Limit Order - Cancel Failed" << std::endl;

    int errors = 0;

    double latencySend = 0.2;
    double latencyReceive = 0.1;
    Processor processor( 10, latencySend, latencyReceive );

    Order* order = new Order( OrderSide::BUY, OrderType::LIMIT, 10, "long" );
    bool onExecuted = false;
    order->onExecuted = [&] { onExecuted = true; };
    bool onCancelled = false;
    order->onCancelled = [&] { onCancelled = true; };
    bool isCancelFailed = false;
    order->onCancelFailed = [&] { isCancelFailed = true; };

    processor.SendOrder( order );

    Tick tick;
    tick.id = 1;
    tick.time = 0;
    tick.price = 9;
    tick.volume = 100;
    processor.Feed( tick );
    if( order->state != OrderState::NEW )
      Rcout << "1.  status not NEW - " << ++errors << std::endl;

    tick.id ++;
    tick.time += latencySend;
    tick.price = 11;
    processor.Feed( tick );
    // not received on exchange
    if( order->state != OrderState::NEW )
      Rcout << "2.  status not NEW - " << ++errors << std::endl;

    tick.id ++;
    tick.time += 100;
    tick.price = 12;
    processor.Feed( tick );
    // registered on exchange
    if( order->state != OrderState::REGISTERED )
      Rcout << "3.1 status not REGISTERED - " << ++errors << std::endl;
    if( !std::isnan( order->priceExecuted ) )
      Rcout << "3.2 price executed not NAN - " << ++errors << std::endl;

    tick.id ++;
    tick.time += 10;
    tick.price = 10;
    processor.Feed( tick );
    // not executed yet
    if( order->state != OrderState::REGISTERED )
      Rcout << "4.1 status not REGISTERED - " << ++errors << std::endl;
    if( !std::isnan( order->priceExecuted ) )
      Rcout << "4.2 price executed not NAN - " << ++errors << std::endl;
    order->Cancel();

    tick.id ++;
    tick.time += 10;
    tick.price = 9;
    processor.Feed( tick );
    // at this tick Cancel sent and order executed on exchange
    if( order->state != OrderState::CANCELLING )
      Rcout << "5.1 status not CANCEL - " << ++errors << std::endl;
    if( !std::isnan( order->priceExecuted ) )
      Rcout << "5.2 price executed not NAN - " << ++errors << std::endl;

    tick.id ++;
    tick.time += latencyReceive + 0.00001;
    tick.price = 15;
    processor.Feed( tick );
    // execution confirmation received => cancel failed
    if( order->state != OrderState::EXECUTED )
      Rcout << "6.1 status not EXECUTED - " << ++errors << std::endl;
    if( order->priceExecuted != 10 )
      Rcout << "6.2 price executed not equals price - " << ++errors << std::endl;
    if( !isCancelFailed )
      Rcout << "7   onCancelFailed not called - " << ++errors << std::endl;
    if( !onExecuted )
      Rcout << "7.1 onExecuted not called - " << ++errors << std::endl;
    if( onCancelled )
      Rcout << "7.2 onCancelled called - " << ++errors << std::endl;

    if( errors == 0 ) {
      Rcout << "Test 03 - PASSED!" << std::endl;
    } else {
      Rcout << "Test 03 - FAILED! Errors: " << errors << std::endl;
    }
    return( errors );

  };

  int test_04() {
    Rcout << "Test 04 - Market Order" << std::endl;

    int errors = 0;

    double latencySend = 0.2;
    double latencyReceive = 0.1;
    Processor processor( 10, latencySend, latencyReceive );

    Order* order = new Order( OrderSide::BUY, OrderType::MARKET, NA_REAL, "long" );

    processor.SendOrder( order );

    Tick tick;
    tick.id = 1;
    tick.time = 0;
    tick.price = 9;
    tick.volume = 100;
    processor.Feed( tick );
    if( order->state != OrderState::NEW )
      Rcout << "1.  status not NEW - " << ++errors << std::endl;

    tick.id ++;
    tick.time += latencySend;
    tick.price = 11;
    processor.Feed( tick );
    // not received on exchange
    if( order->state != OrderState::NEW )
      Rcout << "2.  status not NEW - " << ++errors << std::endl;

    tick.id ++;
    tick.time += 0.0001;
    tick.price = 12;
    processor.Feed( tick );
    // received and executed on exchange
    //Rcout << "time exchange executed " << order->timeExchangeExecuted << std::endl;
    //Rcout << "time system   executed " << order->timeExecuted << std::endl;
    if( order->stateExchange != OrderStateExchange::EXECUTED )
      Rcout << "3.1 exchange status not EXECUTED - " << (int)order->stateExchange << ++errors << std::endl;
    if( order->state != OrderState::NEW )
      Rcout << "3.2 status not NEW - " << processor.OrderStateString[(int)order->state] << ++errors << std::endl;
    if( !std::isnan( order->priceExecuted ) )
      Rcout << "3.3 price executed not NAN - " << ++errors << std::endl;

    tick.id ++;
    tick.time += latencyReceive + 0.0001;
    tick.price = 9;
    processor.Feed( tick );
    //Rcout << "time system   executed " << order->timeExecuted << std::endl;
    if( order->stateExchange != OrderStateExchange::EXECUTED )
      Rcout << "4.1 exchange status not EXECUTED - " << (int)order->stateExchange << ++errors << std::endl;
    // confirmation received
    if( order->state != OrderState::EXECUTED )
      Rcout << "4.2 status not EXECUTED - " << processor.OrderStateString[(int)order->state] << ++errors << std::endl;
    if( order->priceExecuted != 12 )
      Rcout << "4.3 price executed not 12 - " << ++errors << std::endl;

    tick.id ++;
    tick.time += 100;
    tick.price = 15;
    processor.Feed( tick );
    if( errors == 0 ) {
      Rcout << "Test 04 - PASSED!" << std::endl;
    } else {
      Rcout << "Test 04 - FAILED! Errors: " << errors << std::endl;
    }
    return( errors );

  };

  int test_05() {
    Rcout << "Test 05 - Limit Order - Hit Market" << std::endl;

    int errors = 0;

    double latencySend = 0.2;
    double latencyReceive = 0.1;
    Processor processor( 10, latencySend, latencyReceive );
    processor.AllowLimitToHitMarket();

    Order* order = new Order( OrderSide::BUY, OrderType::LIMIT, 10, "long" );

    processor.SendOrder( order );

    Tick tick;
    tick.id = 1;
    tick.time = 0;
    tick.price = 200;
    tick.volume = 100;
    processor.Feed( tick );
    if( order->state != OrderState::NEW )
      Rcout << "1.  status not NEW - " << ++errors << std::endl;

    tick.id ++;
    tick.time += latencySend;
    tick.price = 200;
    processor.Feed( tick );
    // not received on exchange
    if( order->state != OrderState::NEW )
      Rcout << "2.  status not NEW - " << ++errors << std::endl;

    tick.id ++;
    tick.time += 0.0001;
    tick.price = 5;
    processor.Feed( tick );
    // received and executed on exchange
    //Rcout << "time exchange executed " << order->timeExchangeExecuted << std::endl;
    //Rcout << "time system   executed " << order->timeExecuted << std::endl;
    if( order->stateExchange != OrderStateExchange::EXECUTED )
      Rcout << "3.1 exchange status not EXECUTED - " << (int)order->stateExchange << ++errors << std::endl;
    if( order->state != OrderState::NEW )
      Rcout << "3.2 status not NEW - " << processor.OrderStateString[(int)order->state] << ++errors << std::endl;
    if( !std::isnan( order->priceExecuted ) )
      Rcout << "3.3 price executed not NAN - " << ++errors << std::endl;

    tick.id ++;
    tick.time += latencyReceive + 0.0001;
    tick.price = 200;
    processor.Feed( tick );
    //Rcout << "time system   executed " << order->timeExecuted << std::endl;
    if( order->stateExchange != OrderStateExchange::EXECUTED )
      Rcout << "4.1 exchange status not EXECUTED - " << (int)order->stateExchange << ++errors << std::endl;
    // confirmation received
    if( order->state != OrderState::EXECUTED )
      Rcout << "4.2 status not EXECUTED - " << processor.OrderStateString[(int)order->state] << ++errors << std::endl;
    if( order->priceExecuted != 5 )
      Rcout << "4.3 price executed not 5 - " << ++errors << std::endl;

    tick.id ++;
    tick.time += 110;
    tick.price = 200;
    processor.Feed( tick );
    if( errors == 0 ) {
      Rcout << "Test 05 - PASSED!" << std::endl;
    } else {
      Rcout << "Test 05 - FAILED! Errors: " << errors << std::endl;
    }
    return( errors );

  };
public:
  bool test() {
    int errors = 0;
    errors += test_01();
    errors += test_02();
    errors += test_03();
    errors += test_04();
    errors += test_05();
    Rcout << "-----------------------------------------" << std::endl;
    if( errors == 0 ) {
      Rcout << "Tests   - PASSED!" << std::endl;
    } else {
      Rcout << "Tests   - FAILED! Errors: " << errors << std::endl;
    }
    return errors == 0;
  }

};
// [[Rcpp::export]]
bool run_tests() {
  Test test;
  return test.test();
}

