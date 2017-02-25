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

#include "../inst/include/Indicators/BBands.h"

//' Bollinger Bands
//'
//' @name bbands
//' @param x numeric vectors
//' @param n window size
//' @param k number of standard deviations
//' @family technical indicators
//' @return
//' Returns data.table with columns \code{upper, lower, sma}.
//' @description Bollinger bands is a mix of Rolling Range and SMA indicators. It shows the average price and its range over n past values based on price volatility.
//' @export
// [[Rcpp::export]]
Rcpp::List bbands( Rcpp::NumericVector x, std::size_t n, double k ) {

  BBands bbands( n, k );

  for( auto i = 0; i < x.size(); i++ ) bbands.Add( x[i] );

  return bbands.GetHistory();

}
