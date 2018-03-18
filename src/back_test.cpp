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
#include <algorithm>
#include "../inst/include/ListBuilder.h"

//' Generic back test function
//'
//' @name back_test
//' @param enter bool vector of length n of enter signals
//' @param exit bool vector of length n of exit signals
//' @param price numeric vector of length n of prices
//' @param stop_loss relative stop loss, must be negative
//' @param side direction of enter order, \code{-1}:short, \code{1}:long
//' @description Back test by enter and exit signals with stop loss on price history. Execution is immediate. Useful for testing on daily data.
//' @return trades data.table with columns \code{ price_enter,price_exit,mtm_min,mtm_max,id_enter,id_exit,pnl_trade,side}
//' @export
// [[Rcpp::export]]
Rcpp::List back_test( Rcpp::LogicalVector enter, Rcpp::LogicalVector exit, Rcpp::NumericVector price, double stop_loss = -1000, int side = 1 ) {

  int n = enter.size();

  Rcpp::NumericVector id_enter( n );
  Rcpp::NumericVector id_exit( n );
  Rcpp::NumericVector enters( n );
  Rcpp::NumericVector exits( n );

  Rcpp::NumericVector mtm_mins( n );
  Rcpp::NumericVector mtm_maxs( n );

  Rcpp::NumericVector pnls( n );

  bool isInPosition = false;

  double mtm_min = 0;
  double mtm_max = 0;
  double p_open = 0;

  for( int i = 0; i < n; ++i ) {

    if( ( not isInPosition ) and enter[i] == true ){

      enters[i] = price[i];
      id_enter[i] = i + 1;
      p_open = price[i];

      mtm_min = 0;
      mtm_max = 0;

      isInPosition = true;
      continue;

    }

    if( isInPosition ){

      mtm_min = std::min( mtm_min, side * ( price[i] / p_open - 1 ) );
      mtm_max = std::max( mtm_max, side * ( price[i] / p_open - 1 ) );

    }

    if( isInPosition and ( exit[i] == true or mtm_min < stop_loss ) ){

      exits[i] = price[i];
      id_exit[i] = i + 1;

      mtm_mins[i] = mtm_min;
      mtm_maxs[i] = mtm_max;

      pnls[i] = side * ( price[i] / p_open - 1 );

      isInPosition = false;

    }

  }

  if( isInPosition ) {

    exits[n-1] = price[n-1];
    id_exit[n-1] = n;

    mtm_mins[n-1] = mtm_min;
    mtm_maxs[n-1] = mtm_max;
    pnls[n-1] = side * ( price[n-1] / p_open - 1 );

  }

  id_enter = id_enter[ enters > 0 ];

  if( id_enter.size() == 0 ) return R_NilValue;

  id_exit = id_exit[ exits > 0 ];

  mtm_mins = mtm_mins[ exits > 0 ];
  mtm_maxs = mtm_maxs[ exits > 0 ];

  pnls = pnls[ exits > 0 ];

  enters = enters[ enters > 0 ];
  exits = exits[ exits > 0 ];

  Rcpp::IntegerVector sideV( enters.size(), side );

  Rcpp::List output = ListBuilder().AsDataTable()
    .Add( "price_enter", enters   )
    .Add( "price_exit" , exits    )
    .Add( "mtm_min"    , mtm_mins )
    .Add( "mtm_max"    , mtm_maxs )
    .Add( "id_enter"   , id_enter )
    .Add( "id_exit"    , id_exit  )
    .Add( "pnl_trade"  , pnls     )
    .Add( "side"       , sideV    );

  return output;

}
