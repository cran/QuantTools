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

#include "../inst/include/Indicators/Stochastic.h"

//' Stochastic
//'
//' @name stochastic
//' @param n window size
//' @param x \code{high, low, close} data.frame or numeric vector
//' @param nFast fast smooth
//' @param nSlow slow smooth
//' @family technical indicators
//' @return data.table with columns \code{k_fast, d_fast, d_slow}
//' @description Stochastic oscillator shows position of price in respect to its range over n past values.
//' @export
// [[Rcpp::export]]
Rcpp::List stochastic( SEXP x, size_t n, size_t nFast, size_t nSlow ) {


  switch( TYPEOF( x ) ) {

  case REALSXP: {

    Rcpp::NumericVector vec = Rcpp::as< Rcpp::NumericVector >( x );

    Stochastic<double> stochastic( n, nFast, nSlow );

    for( auto i = 0; i < vec.size(); i++ ) stochastic.Add( vec[i] );

    return stochastic.GetHistory();

  }
  case VECSXP: {

    Rcpp::DataFrame hlc = Rcpp::as< Rcpp::DataFrame >( x );
    Rcpp::StringVector names = hlc.attr( "names" );

    bool hasHigh   = std::find( names.begin(), names.end(), "high"   ) != names.end();
    bool hasLow  = std::find( names.begin(), names.end(), "low"  ) != names.end();
    bool hasClose = std::find( names.begin(), names.end(), "close" ) != names.end();

    if( !hasHigh   ) throw std::invalid_argument( "ticks must contain 'high' column"   );
    if( !hasLow  ) throw std::invalid_argument( "ticks must contain 'low' column"  );
    if( !hasClose ) throw std::invalid_argument( "ticks must contain 'close' column" );

    Rcpp::NumericVector highs  = hlc[ "high"   ];
    Rcpp::NumericVector lows   = hlc[ "low"    ];
    Rcpp::NumericVector closes = hlc[ "close"  ];

    Stochastic<Candle> stochastic( n, nFast, nSlow );

    for( auto i = 0; i < highs.size(); i++ ) {
      Candle candle( 1 );
      candle.low   = lows  [i];
      candle.high  = highs [i];
      candle.close = closes[i];

      stochastic.Add( candle );
    }

    return stochastic.GetHistory();

  }

  }

  return R_NilValue;

}
//' @name stochastic
